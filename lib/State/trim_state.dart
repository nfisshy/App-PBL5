import 'package:equatable/equatable.dart';

import '../Items/media_item.dart';

class TrimState extends Equatable {
  final bool isLoading;

  final bool loadSuccess;

  final bool loadFail;

  final List<MediaItem> over10Minutes;

  final List<MediaItem> over5Minutes;

  final List<MediaItem> over3Minutes;

  final List<MediaItem> others;

  const TrimState({
    this.isLoading = false,
    this.loadSuccess = false,
    this.loadFail = false,
    this.over10Minutes = const [],
    this.over5Minutes = const [],
    this.over3Minutes = const [],
    this.others = const [],
  });

  int get over10MinutesCount =>
      over10Minutes.length;

  int get over5MinutesCount =>
      over5Minutes.length;

  int get over3MinutesCount =>
      over3Minutes.length;

  int get othersCount =>
      others.length;

  int get totalVideos =>
      over10Minutes.length +
      over5Minutes.length +
      over3Minutes.length +
      others.length;

  bool get isEmpty =>
      totalVideos == 0;

  TrimState copyWith({
    bool? isLoading,
    bool? loadSuccess,
    bool? loadFail,
    List<MediaItem>? over10Minutes,
    List<MediaItem>? over5Minutes,
    List<MediaItem>? over3Minutes,
    List<MediaItem>? others,
  }) {
    return TrimState(
      isLoading:
          isLoading ?? this.isLoading,

      loadSuccess:
          loadSuccess ?? this.loadSuccess,

      loadFail:
          loadFail ?? this.loadFail,

      over10Minutes:
          over10Minutes ??
              this.over10Minutes,

      over5Minutes:
          over5Minutes ??
              this.over5Minutes,

      over3Minutes:
          over3Minutes ??
              this.over3Minutes,

      others:
          others ?? this.others,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        loadSuccess,
        loadFail,
        over10Minutes,
        over5Minutes,
        over3Minutes,
        others,
      ];
}