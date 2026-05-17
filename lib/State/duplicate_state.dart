import 'package:equatable/equatable.dart';

import '../Items/media_item.dart';

class DuplicatePhotoState
    extends Equatable {
  /// LOADING
  final bool isLoading;

  /// DELETE LOADING
  final bool isDeleting;

  /// FAIL
  final bool loadFail;

  /// SUCCESS
  final bool loadSuccess;

  /// DANH SÁCH NHÓM TRÙNG
  final List<List<MediaItem>>
      duplicateGroups;

  /// NHÓM HIỆN TẠI
  final int currentGroupIndex;

  /// SELECTED IDS
  final Set<String> selectedIds;

  /// KEEP COUNT
  final int keepCount;

  /// DELETE COUNT
  final int deleteCount;

  /// HAS ACTION
  final bool hasAction;

  const DuplicatePhotoState({
    this.isLoading = false,
    this.isDeleting = false,
    this.loadFail = false,
    this.loadSuccess = false,
    this.duplicateGroups = const [],
    this.currentGroupIndex = 0,
    this.selectedIds = const {},
    this.keepCount = 0,
    this.deleteCount = 0,
    this.hasAction = false,
  });

  /// CURRENT GROUP
  List<MediaItem> get currentGroup {
    if (duplicateGroups.isEmpty) {
      return [];
    }

    if (currentGroupIndex >=
        duplicateGroups.length) {
      return [];
    }

    return duplicateGroups[
        currentGroupIndex];
  }

  /// TOTAL GROUPS
  int get totalGroups =>
      duplicateGroups.length;

  /// TOTAL PHOTOS
  int get totalPhotos =>
      duplicateGroups.fold(
        0,
        (sum, group) =>
            sum + group.length,
      );

  /// TOTAL SELECTED
  int get totalSelected =>
      selectedIds.length;

  DuplicatePhotoState copyWith({
    bool? isLoading,
    bool? isDeleting,
    bool? loadFail,
    bool? loadSuccess,
    List<List<MediaItem>>?
        duplicateGroups,
    int? currentGroupIndex,
    Set<String>? selectedIds,
    int? keepCount,
    int? deleteCount,
    bool? hasAction,
  }) {
    return DuplicatePhotoState(
      isLoading:
          isLoading ?? this.isLoading,

      isDeleting:
          isDeleting ?? this.isDeleting,

      loadFail:
          loadFail ?? this.loadFail,

      loadSuccess:
          loadSuccess ??
              this.loadSuccess,

      duplicateGroups:
          duplicateGroups ??
              this.duplicateGroups,

      currentGroupIndex:
          currentGroupIndex ??
              this.currentGroupIndex,

      selectedIds:
          selectedIds ??
              this.selectedIds,

      keepCount:
          keepCount ?? this.keepCount,

      deleteCount:
          deleteCount ??
              this.deleteCount,

      hasAction:
          hasAction ?? this.hasAction,
    );
  }

  @override
  List<Object> get props => [
        isLoading,
        isDeleting,
        loadFail,
        loadSuccess,
        duplicateGroups,
        currentGroupIndex,
        selectedIds,
        keepCount,
        deleteCount,
        hasAction,
      ];
}