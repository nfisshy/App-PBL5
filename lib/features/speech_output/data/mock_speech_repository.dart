import 'dart:async';
import 'dart:collection';

import 'package:photomanager/features/speech_output/domain/speech_message.dart';
import 'package:photomanager/features/speech_output/domain/speech_message_type.dart';
import 'package:photomanager/features/speech_output/domain/speech_queue_item.dart';
import 'package:photomanager/features/speech_output/domain/speech_repository.dart';
import 'package:photomanager/features/speech_output/domain/speech_state.dart';
import 'package:photomanager/features/speech_output/domain/speech_statistics.dart';

class MockSpeechRepository implements SpeechRepository {
  MockSpeechRepository({
    this.initializationDelay = const Duration(milliseconds: 300),
    this.sentenceDuration = const Duration(seconds: 1),
  });

  final Duration initializationDelay;
  final Duration sentenceDuration;

  final _stateController = StreamController<SpeechState>.broadcast();
  final _messageController = StreamController<SpeechMessage>.broadcast();
  final _statisticsController = StreamController<SpeechStatistics>.broadcast();
  final _queueController = StreamController<List<SpeechQueueItem>>.broadcast();
  final Queue<SpeechQueueItem> _waitingQueue = Queue<SpeechQueueItem>();

  SpeechState _state = SpeechState.idle;
  SpeechStatistics _statistics = const SpeechStatistics.empty();
  SpeechQueueItem? _currentItem;
  Timer? _initializationTimer;
  Completer<void>? _initializationCompleter;
  Timer? _speechTimer;
  int _spokenCount = 0;
  int _idSequence = 0;
  bool _disposed = false;

  @override
  Future<void> initialize() {
    if (_disposed ||
        _state == SpeechState.ready ||
        _state == SpeechState.speaking ||
        _state == SpeechState.paused) {
      return Future.value();
    }
    if (_state == SpeechState.initializing) {
      return _initializationCompleter?.future ?? Future.value();
    }

    _emitState(SpeechState.initializing);
    final completer = Completer<void>();
    _initializationCompleter = completer;
    _initializationTimer = Timer(initializationDelay, () {
      _initializationTimer = null;
      _initializationCompleter = null;
      if (!_disposed) {
        _emitState(SpeechState.ready);
      }
      if (!completer.isCompleted) {
        completer.complete();
      }
    });
    return completer.future;
  }

  @override
  Future<void> speakDraft(String text) {
    return _enqueue(text, SpeechMessageType.draft);
  }

  @override
  Future<void> speakFinal(String text) {
    return _enqueue(text, SpeechMessageType.finalResult);
  }

  @override
  Future<void> speakSystem(String text) {
    return _enqueue(text, SpeechMessageType.system);
  }

  @override
  Future<void> pause() async {
    if (_state != SpeechState.speaking) {
      return;
    }
    _speechTimer?.cancel();
    _speechTimer = null;
    _emitState(SpeechState.paused);
    _emitStatistics();
  }

  @override
  Future<void> resume() async {
    if (_state != SpeechState.paused || _currentItem == null) {
      return;
    }
    _emitState(SpeechState.speaking);
    _emitStatistics();
    _scheduleCurrentItem();
  }

  @override
  Future<void> stop() async {
    _speechTimer?.cancel();
    _speechTimer = null;
    _currentItem = null;
    _waitingQueue.clear();
    if (!_disposed) {
      _emitState(SpeechState.stopped);
      _emitQueue();
      _emitStatistics();
    }
  }

  @override
  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _initializationTimer?.cancel();
    _initializationTimer = null;
    final completer = _initializationCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
    _initializationCompleter = null;
    _speechTimer?.cancel();
    _speechTimer = null;
    _currentItem = null;
    _waitingQueue.clear();
    await Future.wait([
      _stateController.close(),
      _messageController.close(),
      _statisticsController.close(),
      _queueController.close(),
    ]);
  }

  @override
  Stream<SpeechState> speechStateStream() {
    return _currentValueStream(_state, _stateController.stream);
  }

  @override
  Stream<SpeechMessage> spokenMessageStream() => _messageController.stream;

  @override
  Stream<SpeechStatistics> statisticsStream() {
    return _currentValueStream(_statistics, _statisticsController.stream);
  }

  @override
  Stream<List<SpeechQueueItem>> queueStream() {
    return _currentValueStream(_queueSnapshot, _queueController.stream);
  }

  Future<void> _enqueue(String text, SpeechMessageType type) async {
    final trimmedText = text.trim();
    if (_disposed || trimmedText.isEmpty) {
      return;
    }

    final now = DateTime.now();
    _idSequence++;
    final message = SpeechMessage(
      messageId: 'speech-${now.microsecondsSinceEpoch}-$_idSequence',
      text: trimmedText,
      type: type,
      createdAt: now,
    );
    _waitingQueue.add(
      SpeechQueueItem(
        queueId: 'queue-${now.microsecondsSinceEpoch}-$_idSequence',
        message: message,
        enqueuedAt: now,
      ),
    );
    _emitQueue();
    _emitStatistics();
    await initialize();
    _processNext();
  }

  void _processNext() {
    if (_disposed ||
        _currentItem != null ||
        _waitingQueue.isEmpty ||
        _state == SpeechState.paused) {
      return;
    }

    _currentItem = _waitingQueue.removeFirst();
    _emitState(SpeechState.speaking);
    _emitQueue();
    _emitStatistics();
    _scheduleCurrentItem();
  }

  void _scheduleCurrentItem() {
    final currentItem = _currentItem;
    if (_disposed || currentItem == null) {
      return;
    }
    _speechTimer?.cancel();
    _speechTimer = Timer(_durationFor(currentItem.message.text), () {
      _speechTimer = null;
      if (_disposed || _state != SpeechState.speaking) {
        return;
      }

      _messageController.add(currentItem.message);
      _spokenCount++;
      _currentItem = null;
      _emitQueue();
      if (_waitingQueue.isEmpty) {
        _emitState(SpeechState.ready);
        _emitStatistics();
      } else {
        _emitStatistics();
        _processNext();
      }
    });
  }

  Duration _durationFor(String text) {
    final sentenceCount = text
        .split(RegExp(r'[.!?]+'))
        .where((sentence) => sentence.trim().isNotEmpty)
        .length;
    return sentenceDuration * (sentenceCount == 0 ? 1 : sentenceCount);
  }

  List<SpeechQueueItem> get _queueSnapshot => List.unmodifiable([
        if (_currentItem case final current?) current,
        ..._waitingQueue,
      ]);

  Stream<T> _currentValueStream<T>(T currentValue, Stream<T> updates) {
    return Stream<T>.multi(
      (controller) {
        controller.addSync(currentValue);
        final subscription = updates.listen(controller.add);
        controller.onCancel = subscription.cancel;
      },
      isBroadcast: true,
    );
  }

  void _emitState(SpeechState state) {
    _state = state;
    _stateController.add(state);
  }

  void _emitQueue() {
    _queueController.add(_queueSnapshot);
  }

  void _emitStatistics() {
    _statistics = SpeechStatistics(
      spokenCount: _spokenCount,
      queuedCount: _queueSnapshot.length,
      isSpeaking: _state == SpeechState.speaking,
    );
    _statisticsController.add(_statistics);
  }
}
