import 'package:equatable/equatable.dart';

class CompressEditorState extends Equatable {
  final bool isLoading;
  final bool loadSuccess;
  final bool loadFail;

  final Duration duration;

  final bool isCompressing;
  final bool compressSuccess;
  final bool compressFail;

  final int resolution; // height in px (e.g., 360, 480, 720, 1080)
  final int fps;
  final int bitrateKbps; // in kbps

  const CompressEditorState({
    this.isLoading = false,
    this.loadSuccess = false,
    this.loadFail = false,
    this.duration = Duration.zero,
    this.isCompressing = false,
    this.compressSuccess = false,
    this.compressFail = false,
    this.resolution = 1080,
    this.fps = 30,
    this.bitrateKbps = 10000,
  });

  CompressEditorState copyWith({
    bool? isLoading,
    bool? loadSuccess,
    bool? loadFail,
    Duration? duration,
    bool? isCompressing,
    bool? compressSuccess,
    bool? compressFail,
    int? resolution,
    int? fps,
    int? bitrateKbps,
  }) {
    return CompressEditorState(
      isLoading: isLoading ?? this.isLoading,
      loadSuccess: loadSuccess ?? this.loadSuccess,
      loadFail: loadFail ?? this.loadFail,
      duration: duration ?? this.duration,
      isCompressing: isCompressing ?? this.isCompressing,
      compressSuccess: compressSuccess ?? this.compressSuccess,
      compressFail: compressFail ?? this.compressFail,
      resolution: resolution ?? this.resolution,
      fps: fps ?? this.fps,
      bitrateKbps: bitrateKbps ?? this.bitrateKbps,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        loadSuccess,
        loadFail,
        duration,
        isCompressing,
        compressSuccess,
        compressFail,
        resolution,
        fps,
        bitrateKbps,
      ];
}
