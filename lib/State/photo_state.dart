import 'package:equatable/equatable.dart';

import '../Items/media_item.dart';

class PhotoState extends Equatable {
  final bool isLoading;
  final bool loadFail;
  final bool loadSuccess;

  /// MEDIA LIST
  final List<MediaItem> photos;

  /// CURRENT INDEX
  final int currentIndex;

  /// ACTION COUNTS
  final int deleteCount;
  final int keepCount;

  /// HAS UNDO
  final bool hasAction;

  const PhotoState({
    this.isLoading = false,
    this.loadFail = false,
    this.loadSuccess = false,
    this.photos = const [],
    this.currentIndex = 0,
    this.deleteCount = 0,
    this.keepCount = 0,
    this.hasAction = false,
  });

  PhotoState copyWith({
    bool? isLoading,
    bool? loadFail,
    bool? loadSuccess,
    List<MediaItem>? photos,
    int? currentIndex,
    int? deleteCount,
    int? keepCount,
    bool? hasAction,
  }) {
    return PhotoState(
      isLoading: isLoading ?? this.isLoading,
      loadFail: loadFail ?? this.loadFail,
      loadSuccess: loadSuccess ?? this.loadSuccess,
      photos: photos ?? this.photos,
      currentIndex:
          currentIndex ?? this.currentIndex,
      deleteCount:
          deleteCount ?? this.deleteCount,
      keepCount: keepCount ?? this.keepCount,
      hasAction: hasAction ?? this.hasAction,
    );
  }

  @override
  List<Object> get props => [
        isLoading,
        loadFail,
        loadSuccess,
        photos,
        currentIndex,
        deleteCount,
        keepCount,
        hasAction,
      ];
}