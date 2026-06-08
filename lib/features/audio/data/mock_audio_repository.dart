import 'dart:async';
import 'dart:math';

import 'package:photomanager/features/audio/domain/audio_capture_state.dart';
import 'package:photomanager/features/audio/domain/audio_chunk.dart';
import 'package:photomanager/features/audio/domain/audio_repository.dart';
import 'package:photomanager/features/audio/domain/audio_statistics.dart';

class MockAudioRepository implements AudioRepository {
  MockAudioRepository({
    this.initializationDelay = const Duration(milliseconds: 300),
    this.chunkInterval = const Duration(seconds: 1),
    Random? random,
  }) : _random = random ?? Random();

  final Duration initializationDelay;
  final Duration chunkInterval;
  final Random _random;

  final _stateController = StreamController<AudioCaptureState>.broadcast();
  final _chunkController = StreamController<AudioChunk>.broadcast();
  final _statisticsController = StreamController<AudioStatistics>.broadcast();

  AudioCaptureState _state = AudioCaptureState.idle;
  AudioStatistics _statistics = const AudioStatistics.empty();
  Timer? _initializationTimer;
  Completer<void>? _initializationCompleter;
  Timer? _chunkTimer;
  int _sequenceNumber = 0;
  int _totalSizeBytes = 0;

  @override
  Future<void> initialize() {
    if (_state == AudioCaptureState.ready ||
        _state == AudioCaptureState.recording ||
        _state == AudioCaptureState.paused) {
      return Future.value();
    }
    if (_state == AudioCaptureState.initializing) {
      return _initializationCompleter?.future ?? Future.value();
    }

    _emitState(AudioCaptureState.initializing);
    final completer = Completer<void>();
    _initializationCompleter = completer;
    _initializationTimer = Timer(initializationDelay, () {
      _initializationTimer = null;
      _initializationCompleter = null;
      _emitState(AudioCaptureState.ready);
      if (!completer.isCompleted) {
        completer.complete();
      }
    });
    return completer.future;
  }

  @override
  Future<void> startRecording() async {
    await initialize();
    _sequenceNumber = 0;
    _totalSizeBytes = 0;
    _statistics = const AudioStatistics.empty();
    _emitState(AudioCaptureState.recording);
    _emitStatistics(_statisticsWithRecording(true));
    _startChunkTimer();
  }

  @override
  Future<void> pauseRecording() async {
    if (_state != AudioCaptureState.recording) {
      return;
    }
    _chunkTimer?.cancel();
    _chunkTimer = null;
    _emitState(AudioCaptureState.paused);
    _emitStatistics(_statisticsWithRecording(false));
  }

  @override
  Future<void> resumeRecording() async {
    if (_state != AudioCaptureState.paused) {
      return;
    }
    _emitState(AudioCaptureState.recording);
    _emitStatistics(_statisticsWithRecording(true));
    _startChunkTimer();
  }

  @override
  Future<void> stopRecording() async {
    _chunkTimer?.cancel();
    _chunkTimer = null;
    _emitState(AudioCaptureState.stopped);
    _emitStatistics(_statisticsWithRecording(false));
  }

  @override
  Future<void> dispose() async {
    _initializationTimer?.cancel();
    _initializationTimer = null;
    final completer = _initializationCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
    _initializationCompleter = null;
    _chunkTimer?.cancel();
    _chunkTimer = null;
    _emitState(AudioCaptureState.stopped);
    _emitStatistics(_statisticsWithRecording(false));
  }

  @override
  Stream<AudioCaptureState> captureStateStream() {
    return _stateStream(_state, _stateController.stream);
  }

  @override
  Stream<AudioChunk> audioChunkStream() => _chunkController.stream;

  @override
  Stream<AudioStatistics> statisticsStream() {
    return _stateStream(_statistics, _statisticsController.stream);
  }

  void _startChunkTimer() {
    _chunkTimer?.cancel();
    _chunkTimer = Timer.periodic(chunkInterval, (_) => _generateChunk());
  }

  void _generateChunk() {
    if (_state != AudioCaptureState.recording) {
      return;
    }

    _sequenceNumber++;
    final timestamp = DateTime.now();
    final sizeBytes = 28000 + _random.nextInt(12001);
    final durationMs = chunkInterval.inMilliseconds;
    _totalSizeBytes += sizeBytes;
    final chunk = AudioChunk(
      chunkId: 'chunk-${timestamp.microsecondsSinceEpoch}-$_sequenceNumber',
      timestamp: timestamp,
      durationMs: durationMs,
      sizeBytes: sizeBytes,
      sequenceNumber: _sequenceNumber,
    );
    _chunkController.add(chunk);
    _emitStatistics(
      AudioStatistics(
        chunkCount: _sequenceNumber,
        totalDurationMs: _statistics.totalDurationMs + durationMs,
        averageChunkSize: _totalSizeBytes / _sequenceNumber,
        isRecording: true,
      ),
    );
  }

  AudioStatistics _statisticsWithRecording(bool isRecording) {
    return AudioStatistics(
      chunkCount: _statistics.chunkCount,
      totalDurationMs: _statistics.totalDurationMs,
      averageChunkSize: _statistics.averageChunkSize,
      isRecording: isRecording,
    );
  }

  Stream<T> _stateStream<T>(T currentState, Stream<T> updates) {
    return Stream<T>.multi(
      (controller) {
        controller.addSync(currentState);
        final subscription = updates.listen(controller.add);
        controller.onCancel = subscription.cancel;
      },
      isBroadcast: true,
    );
  }

  void _emitState(AudioCaptureState state) {
    _state = state;
    _stateController.add(state);
  }

  void _emitStatistics(AudioStatistics statistics) {
    _statistics = statistics;
    _statisticsController.add(statistics);
  }
}
