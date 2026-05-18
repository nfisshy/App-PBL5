// duplicate_state.dart — thêm progress, giữ nguyên phần còn lại
import 'package:equatable/equatable.dart';
import '../Items/media_item.dart';

class DuplicatePhotoState extends Equatable {
  final bool isLoading;
  final bool isDeleting;
  final bool loadFail;
  final bool loadSuccess;
  final List<List<MediaItem>> duplicateGroups;
  final int currentGroupIndex;
  final Set<String> selectedIds;
  final int keepCount;
  final int deleteCount;
  final bool hasAction;
  final double progress; // 0.0 → 1.0

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
    this.progress = 0.0,
  });

  List<MediaItem> get currentGroup {
    if (duplicateGroups.isEmpty) return [];
    if (currentGroupIndex >= duplicateGroups.length) return [];
    return duplicateGroups[currentGroupIndex];
  }

  int get totalGroups => duplicateGroups.length;
  int get totalPhotos => duplicateGroups.fold(0, (sum, g) => sum + g.length);
  int get totalSelected => selectedIds.length;

  DuplicatePhotoState copyWith({
    bool? isLoading,
    bool? isDeleting,
    bool? loadFail,
    bool? loadSuccess,
    List<List<MediaItem>>? duplicateGroups,
    int? currentGroupIndex,
    Set<String>? selectedIds,
    int? keepCount,
    int? deleteCount,
    bool? hasAction,
    double? progress,
  }) {
    return DuplicatePhotoState(
      isLoading: isLoading ?? this.isLoading,
      isDeleting: isDeleting ?? this.isDeleting,
      loadFail: loadFail ?? this.loadFail,
      loadSuccess: loadSuccess ?? this.loadSuccess,
      duplicateGroups: duplicateGroups ?? this.duplicateGroups,
      currentGroupIndex: currentGroupIndex ?? this.currentGroupIndex,
      selectedIds: selectedIds ?? this.selectedIds,
      keepCount: keepCount ?? this.keepCount,
      deleteCount: deleteCount ?? this.deleteCount,
      hasAction: hasAction ?? this.hasAction,
      progress: progress ?? this.progress,
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
        progress,
      ];
}