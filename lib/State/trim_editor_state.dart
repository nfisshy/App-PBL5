import 'package:equatable/equatable.dart';

class TrimEditorState extends Equatable {
  final bool isLoading;
  final bool loadSuccess;
  final bool loadFail;

  final Duration duration;

  final bool isPlaying;
  final bool isTrimming;
  final bool trimSuccess;
  final bool trimFail;

  const TrimEditorState({
    this.isLoading = false,
    this.loadSuccess = false,
    this.loadFail = false,
    this.duration = Duration.zero,
    this.isPlaying = false,
    this.isTrimming = false,
    this.trimSuccess = false,
    this.trimFail = false,
  });

  TrimEditorState copyWith({
    bool? isLoading,
    bool? loadSuccess,
    bool? loadFail,
    Duration? duration,
    bool? isPlaying,
    bool? isTrimming,
    bool? trimSuccess,
    bool? trimFail,
  }) {
    return TrimEditorState(
      isLoading: isLoading ?? this.isLoading,
      loadSuccess: loadSuccess ?? this.loadSuccess,
      loadFail: loadFail ?? this.loadFail,
      duration: duration ?? this.duration,
      isPlaying: isPlaying ?? this.isPlaying,
      isTrimming: isTrimming ?? this.isTrimming,
      trimSuccess: trimSuccess ?? this.trimSuccess,
      trimFail: trimFail ?? this.trimFail,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        loadSuccess,
        loadFail,
        duration,
        isPlaying,
        isTrimming,
        trimSuccess,
        trimFail,
      ];
}
