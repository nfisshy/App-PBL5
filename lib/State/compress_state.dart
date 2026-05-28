import 'package:equatable/equatable.dart';

import '../Items/media_item.dart';

class CompressState extends Equatable {
  final bool isLoading;

  final bool loadSuccess;

  final bool loadFail;

  final List<MediaItem> over1GB;

  final List<MediaItem> over500MB;

  final List<MediaItem> over250MB;

  final List<MediaItem> others;

  const CompressState({
    this.isLoading = false,
    this.loadSuccess = false,
    this.loadFail = false,
    this.over1GB = const [],
    this.over500MB = const [],
    this.over250MB = const [],
    this.others = const [],
  });

  int get over1GBCount =>
      over1GB.length;

  int get over500MBCount =>
      over500MB.length;

  int get over250MBCount =>
      over250MB.length;

  int get othersCount =>
      others.length;

  int get totalVideos =>
      over1GB.length +
      over500MB.length +
      over250MB.length +
      others.length;

  bool get isEmpty =>
      totalVideos == 0;

  CompressState copyWith({
    bool? isLoading,
    bool? loadSuccess,
    bool? loadFail,
    List<MediaItem>? over1GB,
    List<MediaItem>? over500MB,
    List<MediaItem>? over250MB,
    List<MediaItem>? others,
  }) {
    return CompressState(
      isLoading:
          isLoading ?? this.isLoading,

      loadSuccess:
          loadSuccess ?? this.loadSuccess,

      loadFail:
          loadFail ?? this.loadFail,

      over1GB:
          over1GB ?? this.over1GB,

      over500MB:
          over500MB ??
              this.over500MB,

      over250MB:
          over250MB ??
              this.over250MB,

      others:
          others ?? this.others,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        loadSuccess,
        loadFail,
        over1GB,
        over500MB,
        over250MB,
        others,
      ];
}