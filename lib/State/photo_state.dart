import 'package:equatable/equatable.dart';

import '../Items/media_item.dart';

class PhotoState extends Equatable {
  /// =========================
  /// LOAD STATE
  /// =========================

  final bool isLoading;
  final bool loadFail;
  final bool loadSuccess;

  /// =========================
  /// MEDIA
  /// =========================

  final List<MediaItem> photos;

  final int currentIndex;

  /// Tổng số ảnh cần review trong session này.
  /// Được set ngay sau Phase 1 (scan metadata) nên
  /// luôn đúng từ tấm ảnh đầu tiên, dù thumbnail
  /// các ảnh còn lại chưa load xong.
  final int totalCount;

  /// =========================
  /// SESSION COUNTS
  /// =========================

  final int deleteCount;

  final int keepCount;

  /// =========================
  /// SUMMARY DATA
  /// =========================

  /// all delete items
  /// including previous sessions
  final List<MediaItem> pendingDeletes;

  /// total reviewed assets
  /// across all sessions
  final int totalReviewedCount;

  /// total storage saved
  /// across all sessions
  final int totalSavedBytes;

  /// =========================
  /// HOME RECENT STATUS
  /// =========================

  /// recent photos not swiped yet
  final int recentUnreviewedCount;

  /// summary opened but not confirmed
  final bool hasPendingSummary;

  /// all recent photos completed
  final bool recentCompleted;

  /// =========================
  /// ACTION STATE
  /// =========================

  final bool hasAction;

  final bool isDeleting;

  const PhotoState({
    this.isLoading = false,
    this.loadFail = false,
    this.loadSuccess = false,

    this.photos = const [],
    this.currentIndex = 0,
    this.totalCount = 0,

    this.deleteCount = 0,
    this.keepCount = 0,

    this.pendingDeletes = const [],
    this.totalReviewedCount = 0,
    this.totalSavedBytes = 0,

    this.recentUnreviewedCount = 0,
    this.hasPendingSummary = false,
    this.recentCompleted = false,

    this.hasAction = false,
    this.isDeleting = false,
  });

  /// =========================
  /// CURRENT SESSION REVIEWED
  /// =========================

  int get reviewedCount => keepCount + deleteCount;

  /// =========================
  /// CURRENT SESSION COMPLETE
  /// Dùng totalCount thay vì photos.length để
  /// isSessionComplete không bị sai trong lúc
  /// background batch vẫn đang load thumbnail
  /// =========================

  bool get isSessionComplete =>
      totalCount > 0 && reviewedCount >= totalCount;

  /// =========================
  /// PROGRESS (0.0 → 1.0)
  /// =========================

  double get progress =>
      totalCount > 0 ? reviewedCount / totalCount : 0.0;

  /// =========================
  /// COPY WITH
  /// =========================

  PhotoState copyWith({
    bool? isLoading,
    bool? loadFail,
    bool? loadSuccess,

    List<MediaItem>? photos,
    int? currentIndex,
    int? totalCount,

    int? deleteCount,
    int? keepCount,

    List<MediaItem>? pendingDeletes,
    int? totalReviewedCount,
    int? totalSavedBytes,

    int? recentUnreviewedCount,
    bool? hasPendingSummary,
    bool? recentCompleted,

    bool? hasAction,
    bool? isDeleting,
  }) {
    return PhotoState(
      isLoading: isLoading ?? this.isLoading,
      loadFail: loadFail ?? this.loadFail,
      loadSuccess: loadSuccess ?? this.loadSuccess,

      photos: photos ?? this.photos,
      currentIndex: currentIndex ?? this.currentIndex,
      totalCount: totalCount ?? this.totalCount,

      deleteCount: deleteCount ?? this.deleteCount,
      keepCount: keepCount ?? this.keepCount,

      pendingDeletes: pendingDeletes ?? this.pendingDeletes,
      totalReviewedCount: totalReviewedCount ?? this.totalReviewedCount,
      totalSavedBytes: totalSavedBytes ?? this.totalSavedBytes,

      recentUnreviewedCount:
          recentUnreviewedCount ?? this.recentUnreviewedCount,
      hasPendingSummary: hasPendingSummary ?? this.hasPendingSummary,
      recentCompleted: recentCompleted ?? this.recentCompleted,

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
        totalCount,

        deleteCount,
        keepCount,

        pendingDeletes,
        totalReviewedCount,
        totalSavedBytes,

        recentUnreviewedCount,
        hasPendingSummary,
        recentCompleted,

        hasAction,
        isDeleting,
      ];
}