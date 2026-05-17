import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image/image.dart'
    as img;
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

  /// =========================
  /// LOAD DUPLICATES
  /// =========================
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
      /// =========================
      /// PERMISSION
      /// =========================
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

      /// =========================
      /// LOAD ALBUMS
      /// =========================
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

      /// =========================
      /// LOAD ASSETS
      /// =========================
      final assets =
          await albums.first
              .getAssetListPaged(
        page: 0,
        size: 3000,
      );

      final filteredAssets =
          assets.where(
        (e) =>
            e.type == AssetType.image ||
            e.type == AssetType.video,
      );

      /// =========================
      /// HASH STORAGE
      /// =========================
      final List<MediaItem> allMedia =
          [];

      final Map<String, String>
          hashMap = {};

      /// =========================
      /// CREATE HASH
      /// =========================
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

          /// thumbnail nhỏ để hash
          final thumb =
              await asset
                  .thumbnailDataWithSize(
            const ThumbnailSize(
              32,
              32,
            ),
          );

          if (thumb == null) {
            continue;
          }

          final decoded =
              img.decodeImage(thumb);

          if (decoded == null) {
            continue;
          }

          final hash =
              generateDHash(decoded);

          hashMap[asset.id] = hash;

          allMedia.add(media);
        } catch (e) {
          // ignore
        }
      }

      /// =========================
      /// FIND DUPLICATES
      /// =========================
      final List<List<MediaItem>>
          duplicateGroups = [];

      final Set<String> used =
          {};

      for (int i = 0;
          i < allMedia.length;
          i++) {
        final current =
            allMedia[i];

        if (used.contains(
          current.asset.id,
        )) {
          continue;
        }

        final currentHash =
            hashMap[
                current.asset.id];

        if (currentHash == null) {
          continue;
        }

        final List<MediaItem> group =
            [
          current,
        ];

        for (int j = i + 1;
            j < allMedia.length;
            j++) {
          final compare =
              allMedia[j];

          if (used.contains(
            compare.asset.id,
          )) {
            continue;
          }

          /// time filter
          final difference = current
              .asset.createDateTime
              .difference(
                compare.asset
                    .createDateTime,
              )
              .inSeconds
              .abs();

          if (difference > 30) {
            continue;
          }

          final compareHash =
              hashMap[
                  compare.asset.id];

          if (compareHash == null) {
            continue;
          }

          final distance =
              hammingDistance(
            currentHash,
            compareHash,
          );

          /// threshold
          if (distance <= 8) {
            group.add(compare);

            used.add(
              compare.asset.id,
            );
          }
        }

        if (group.length > 1) {
          duplicateGroups.add(
            group,
          );

          used.add(
            current.asset.id,
          );
        }
      }

      /// =========================
      /// AUTO SELECT
      /// keep first image
      /// =========================
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

  /// =========================
  /// dHash
  /// =========================
  String generateDHash(
    img.Image image,
  ) {
    final resized = img.copyResize(
      image,
      width: 9,
      height: 8,
    );

    final grayscale =
        img.grayscale(resized);

    String hash = "";

    for (int y = 0; y < 8; y++) {
      for (int x = 0; x < 8; x++) {
        final left =
            grayscale.getPixel(x, y);

        final right =
            grayscale.getPixel(
          x + 1,
          y,
        );

        final leftLuma =
            left.r.toInt();

        final rightLuma =
            right.r.toInt();

        hash +=
            leftLuma > rightLuma
                ? "1"
                : "0";
      }
    }

    return hash;
  }

  /// =========================
  /// HAMMING DISTANCE
  /// =========================
  int hammingDistance(
    String a,
    String b,
  ) {
    int distance = 0;

    for (int i = 0;
        i < min(a.length, b.length);
        i++) {
      if (a[i] != b[i]) {
        distance++;
      }
    }

    return distance;
  }

  /// =========================
  /// TOGGLE SELECT
  /// =========================
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

  /// =========================
  /// SELECT ALL
  /// =========================
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

  /// =========================
  /// CLEAR
  /// =========================
  void clearSelection() {
    emit(
      state.copyWith(
        selectedIds: {},
      ),
    );
  }

  /// =========================
  /// DELETE SELECTED
  /// =========================
  Future<void>
      deleteSelected() async {
    try {
      final List<AssetEntity>
          deleteAssets = [];

      for (final group
          in state.duplicateGroups) {
        for (final item
            in group) {
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

      await loadDuplicates();
    } catch (e) {
      emit(
        state.copyWith(
          isDeleting: false,
        ),
      );
    }
  }

  /// =========================
  /// TOTAL DUPLICATES
  /// =========================
  int get totalDuplicates {
    int total = 0;

    for (final group
        in state.duplicateGroups) {
      total += group.length;
    }

    return total;
  }

  /// =========================
  /// TOTAL SELECTED
  /// =========================
  int get totalSelected =>
      state.selectedIds.length;

  /// =========================
  /// TOTAL SIZE
  /// =========================
  Future<String>
      calculateSelectedSize() async {
    int totalBytes = 0;

    for (final group
        in state.duplicateGroups) {
      for (final item
          in group) {
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