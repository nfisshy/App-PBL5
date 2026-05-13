import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Items/media_item.dart';
import '../State/photo_state.dart';

enum PhotoMode {
  recent,
  random,
}

class PhotoCubit extends Cubit<PhotoState> {
  PhotoCubit()
      : super(
          const PhotoState(
            isLoading: true,
          ),
        );

  /// CURRENT MODE
  PhotoMode currentMode =
      PhotoMode.recent;

  /// RECENT LIMIT
  static const int recentDays = 5;

  /// STORAGE KEY
  static const String processedKey =
      "processed_assets";

  /// LOAD RECENT
  Future<void> loadRecentPhotos() async {
    currentMode = PhotoMode.recent;

    await _loadPhotos(
      randomMode: false,
    );
  }

  /// LOAD RANDOM
  Future<void> loadRandomPhotos() async {
    currentMode = PhotoMode.random;

    await _loadPhotos(
      randomMode: true,
    );
  }

  /// CORE LOADER
  Future<void> _loadPhotos({
    required bool randomMode,
  }) async {
    emit(
      state.copyWith(
        isLoading: true,
        loadFail: false,
        loadSuccess: false,
        currentIndex: 0,
        photos: [],
      ),
    );

    try {
      /// PERMISSION
/// PERMISSION
final PermissionState permission =
    await PhotoManager.requestPermissionExtend(
  requestOption: const PermissionRequestOption(
    androidPermission: AndroidPermission(
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

      /// PREFS
      final prefs =
          await SharedPreferences.getInstance();

      final processedIds =
          prefs.getStringList(
                processedKey,
              ) ??
              [];

      /// LOAD ALBUM
      final albums =
          await PhotoManager.getAssetPathList(
        type: RequestType.common,
        onlyAll: true,
        filterOption: FilterOptionGroup(
          containsLivePhotos: true,
          imageOption: const FilterOption(
            sizeConstraint:
                SizeConstraint(
              ignoreSize: true,
            ),
          ),
          videoOption: const FilterOption(
            sizeConstraint:
                SizeConstraint(
              ignoreSize: true,
            ),
          ),
        ),
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

      /// GET ALL MEDIA
      final rawMedia =
          await albums.first
              .getAssetListPaged(
        page: 0,
        size: 1000,
      );

      /// SORT NEWEST -> OLDEST
      rawMedia.sort(
        (a, b) => b.createDateTime
            .compareTo(
          a.createDateTime,
        ),
      );

      final List<MediaItem> mediaList =
          [];

      final now = DateTime.now();

for (final asset in rawMedia) {
  try {
    debugPrint(
      "ASSET => "
      "type=${asset.type} "
      "id=${asset.id} "
      "title=${asset.title}",
    );

    /// ONLY IMAGE / VIDEO
    if (asset.type != AssetType.image &&
        asset.type != AssetType.video) {
      debugPrint(
        "SKIP TYPE",
      );
      continue;
    }

    /// SKIP PROCESSED
    if (processedIds.contains(
      asset.id,
    )) {
      debugPrint(
        "SKIP PROCESSED",
      );
      continue;
    }

    /// RECENT FILTER
    if (!randomMode) {
      final difference = now
          .difference(
            asset.createDateTime,
          )
          .inDays;

      if (difference > recentDays) {
        debugPrint(
          "SKIP OLD",
        );
        continue;
      }
    }

    /// CREATE MEDIA ITEM
    final media =
        await MediaItem.fromAsset(
      asset,
    );

    if (media == null) {
      debugPrint(
        "MEDIA NULL",
      );
      continue;
    }

    debugPrint(
      "ADD MEDIA => "
      "${media.asset.type}",
    );

    mediaList.add(media);
  } catch (e) {
    debugPrint(
      "LOAD ASSET ERROR: $e",
    );
  }
}

      /// RANDOM
      if (randomMode) {
        mediaList.shuffle(
          Random(),
        );
      }

      debugPrint(
        "FINAL MEDIA COUNT: ${mediaList.length}",
      );

      if (mediaList.isEmpty) {
        emit(
          state.copyWith(
            isLoading: false,
            loadFail: true,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          isLoading: false,
          loadFail: false,
          loadSuccess: true,
          photos: mediaList,
          currentIndex: 0,
        ),
      );
    } catch (e) {
      debugPrint(
        "LOAD PHOTO ERROR: $e",
      );

      emit(
        state.copyWith(
          isLoading: false,
          loadFail: true,
        ),
      );
    }
  }

  /// MARK CURRENT AS PROCESSED
  Future<void>
      _markCurrentProcessed() async {
    if (state.photos.isEmpty) return;

    final prefs =
        await SharedPreferences.getInstance();

    final processedIds =
        prefs.getStringList(
              processedKey,
            ) ??
            [];

    final current =
        state.photos[state.currentIndex];

    if (!processedIds.contains(
      current.asset.id,
    )) {
      processedIds.add(
        current.asset.id,
      );

      await prefs.setStringList(
        processedKey,
        processedIds,
      );
    }
  }

  /// KEEP
  Future<void> keepPhoto() async {
    await _markCurrentProcessed();

    emit(
      state.copyWith(
        keepCount:
            state.keepCount + 1,
        hasAction: true,
      ),
    );

    nextPhoto();
  }

  /// DELETE
  Future<void> deletePhoto() async {
    await _markCurrentProcessed();

    emit(
      state.copyWith(
        deleteCount:
            state.deleteCount + 1,
        hasAction: true,
      ),
    );

    nextPhoto();
  }

  /// NEXT
  void nextPhoto() {
    if (state.currentIndex <
        state.photos.length - 1) {
      emit(
        state.copyWith(
          currentIndex:
              state.currentIndex + 1,
        ),
      );
    }
  }

  /// UNDO
  void undoAction() {
    if (!state.hasAction) return;

    int newIndex =
        state.currentIndex;

    int newKeep =
        state.keepCount;

    int newDelete =
        state.deleteCount;

    if (newIndex > 0) {
      newIndex--;
    }

    if (newKeep > 0) {
      newKeep--;
    } else if (newDelete > 0) {
      newDelete--;
    }

    emit(
      state.copyWith(
        currentIndex: newIndex,
        keepCount: newKeep,
        deleteCount: newDelete,
        hasAction:
            newKeep > 0 ||
                newDelete > 0,
      ),
    );
  }
}