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

  /// Swiped left — pending real delete on summary screen
  final List<MediaItem> pendingDeletes;

  /// HAS UNDO
  final bool hasAction;

  /// Confirm delete in progress
  final bool isDeleting;

  const PhotoState({
    this.isLoading = false,
    this.loadFail = false,
    this.loadSuccess = false,
    this.photos = const [],
    this.currentIndex = 0,
    this.deleteCount = 0,
    this.keepCount = 0,
    this.pendingDeletes = const [],
    this.hasAction = false,
    this.isDeleting = false,
  });

  int get reviewedCount => keepCount + deleteCount;

  bool get isSessionComplete =>
      photos.isNotEmpty && reviewedCount >= photos.length;

  PhotoState copyWith({
    bool? isLoading,
    bool? loadFail,
    bool? loadSuccess,
    List<MediaItem>? photos,
    int? currentIndex,
    int? deleteCount,
    int? keepCount,
    List<MediaItem>? pendingDeletes,
    bool? hasAction,
    bool? isDeleting,
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
      pendingDeletes:
          pendingDeletes ?? this.pendingDeletes,
      hasAction: hasAction ?? this.hasAction,
      isDeleting: isDeleting ?? this.isDeleting,
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
        pendingDeletes,
        hasAction,
        isDeleting,
      ];
}