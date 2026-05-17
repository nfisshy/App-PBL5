import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';

import '../Items/media_item.dart';
import '../State/duplicate_state.dart';

class DuplicateCubit
    extends Cubit<DuplicatePhotoState> {
  DuplicateCubit()
      : super(
          const DuplicatePhotoState(
            isLoading: true,
          ),
        );

  /// LOAD DUPLICATES
  Future<void> loadDuplicates() async {
    emit(
      state.copyWith(
        isLoading: true,
        loadFail: false,
        loadSuccess: false,
        duplicateGroups: [],
        selectedIds: {},
      ),
    );

    try {
      /// PERMISSION
      final permission =
          await PhotoManager
              .requestPermissionExtend(
        requestOption:
            const PermissionRequestOption(
          androidPermission:
              AndroidPermission(
            type: RequestType.common,
            mediaLocation: true,
          ),
        ),
      );

      if (permission !=
              PermissionState.authorized &&
          permission !=
              PermissionState.limited) {
        emit(
          state.copyWith(
            isLoading: false,
            loadFail: true,
          ),
        );
        return;
      }

      /// LOAD ALBUMS
      final albums =
          await PhotoManager.getAssetPathList(
        type: RequestType.common,
        onlyAll: true,
      );

      if (albums.isEmpty) {
        emit(
          state.copyWith(
            isLoading: false,
            loadFail: true,
          ),
        );
        return;
      }

      /// LOAD ALL MEDIA
      final assets =
          await albums.first
              .getAssetListPaged(
        page: 0,
        size: 3000,
      );

      /// ONLY IMAGE / VIDEO
      final filteredAssets =
          assets.where(
        (e) =>
            e.type == AssetType.image ||
            e.type == AssetType.video,
      );

      /// GROUP MAP
      final Map<
              String,
              List<MediaItem>>
          duplicateMap = {};

      for (final asset
          in filteredAssets) {
        try {
          final media =
              await MediaItem.fromAsset(
            asset,
          );

          if (media == null) {
            continue;
          }

          final file =
              await asset.file;

          if (file == null ||
              !(await file.exists())) {
            continue;
          }

          final stat =
              await file.stat();

          /// VERY SIMPLE HASH
          /// same:
          /// - size
          /// - filename
          final key =
              "${stat.size}_${asset.title}";

          duplicateMap.putIfAbsent(
            key,
            () => [],
          );

          duplicateMap[key]!.add(
            media,
          );
        } catch (e) {
          // ignore
        }
      }

      /// KEEP ONLY DUPLICATES
      final duplicateGroups =
          duplicateMap.values
              .where(
                (e) => e.length > 1,
              )
              .toList();

      /// AUTO SELECT
      /// keep first item
      final Set<String> selected =
          {};

      for (final group
          in duplicateGroups) {
        for (int i = 1;
            i < group.length;
            i++) {
          selected.add(
            group[i].asset.id,
          );
        }
      }

      emit(
        state.copyWith(
          isLoading: false,
          loadFail: false,
          loadSuccess: true,
          duplicateGroups:
              duplicateGroups,
          selectedIds: selected,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          loadFail: true,
        ),
      );
    }
  }

  /// TOGGLE SELECT
  void toggleSelect(
    String assetId,
  ) {
    final current =
        Set<String>.from(
      state.selectedIds,
    );

    if (current.contains(
      assetId,
    )) {
      current.remove(
        assetId,
      );
    } else {
      current.add(
        assetId,
      );
    }

    emit(
      state.copyWith(
        selectedIds: current,
      ),
    );
  }

  /// SELECT ALL
  void selectAll() {
    final Set<String> all =
        {};

    for (final group
        in state.duplicateGroups) {
      for (final item in group) {
        all.add(
          item.asset.id,
        );
      }
    }

    emit(
      state.copyWith(
        selectedIds: all,
      ),
    );
  }

  /// CLEAR SELECT
  void clearSelection() {
    emit(
      state.copyWith(
        selectedIds: {},
      ),
    );
  }

  /// DELETE SELECTED
  Future<void>
      deleteSelected() async {
    try {
      final List<AssetEntity>
      deleteAssets = [];

      for (final group
          in state.duplicateGroups) {
        for (final item in group) {
          if (state.selectedIds
              .contains(
            item.asset.id,
          )) {
            deleteAssets.add(
              item.asset,
            );
          }
        }
      }

      if (deleteAssets.isEmpty) {
        return;
      }

      emit(
        state.copyWith(
          isDeleting: true,
        ),
      );

      await PhotoManager.editor
          .deleteWithIds(
        deleteAssets
            .map(
              (e) => e.id,
            )
            .toList(),
      );

      emit(
        state.copyWith(
          isDeleting: false,
        ),
      );

      /// RELOAD
      await loadDuplicates();
    } catch (e) {
      emit(
        state.copyWith(
          isDeleting: false,
        ),
      );
    }
  }

  /// TOTAL DUPLICATES
  int get totalDuplicates {
    int total = 0;

    for (final group
        in state.duplicateGroups) {
      total += group.length;
    }

    return total;
  }

  /// TOTAL SELECTED
  int get totalSelected =>
      state.selectedIds.length;

  /// TOTAL SAVED SIZE
  Future<String>
      calculateSelectedSize() async {
    int totalBytes = 0;

    for (final group
        in state.duplicateGroups) {
      for (final item in group) {
        if (state.selectedIds
            .contains(
          item.asset.id,
        )) {
          totalBytes +=
              item.fileSize;
        }
      }
    }

    if (totalBytes <
        1024 * 1024) {
      return "${(totalBytes / 1024).toStringAsFixed(1)} KB";
    }

    if (totalBytes <
        1024 *
            1024 *
            1024) {
      return "${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB";
    }

    return "${(totalBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB";
  }
}