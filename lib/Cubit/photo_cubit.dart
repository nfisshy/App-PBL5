import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Items/media_item.dart';
import '../State/photo_state.dart';

enum PhotoSessionType {
  anything,
  photos,
  videos,
  recent,
  random,
  screenshots,
  livePhotos,
}

enum _SwipeActionType {
  keep,
  delete,
}

class _SwipeAction {
  const _SwipeAction({
    required this.type,
    required this.item,
  });

  final _SwipeActionType type;
  final MediaItem item;
}

class PhotoCubit extends Cubit<PhotoState> {
  PhotoCubit()
      : super(
          const PhotoState(
            isLoading: true,
          ),
        );

  /// CURRENT SESSION
  PhotoSessionType currentSession =
      PhotoSessionType.anything;

  /// RECENT LIMIT
  static const int recentDays = 5;

  /// STORAGE KEY
  static const String processedKey =
      "processed_assets";

  /// HISTORY
  final List<_SwipeAction>
      _actionHistory = [];

  /// LOAD SESSION
  Future<void> loadSession(
    PhotoSessionType type,
  ) async {
    currentSession = type;

    await _loadPhotos();
  }

  /// SESSION TITLE
  String get sessionTitle {
    switch (currentSession) {
      case PhotoSessionType.anything:
        return "Anything";

      case PhotoSessionType.photos:
        return "Photos";

      case PhotoSessionType.videos:
        return "Videos";

      case PhotoSessionType.recent:
        return "Recents";

      case PhotoSessionType.random:
        return "Random";

      case PhotoSessionType.screenshots:
        return "Screenshots";

      case PhotoSessionType.livePhotos:
        return "Live Photos";
    }
  }

  /// CHECK SCREENSHOT
  Future<bool> _isScreenshot(
    AssetEntity asset,
  ) async {
    final file = await asset.file;

    if (file == null) {
      return false;
    }

    final path =
        file.path.toLowerCase();

    final title =
        (asset.title ?? "")
            .toLowerCase();

    return path.contains(
              "screenshot",
            ) ||
        title.contains(
          "screenshot",
        ) ||
        path.contains(
          "screen_shot",
        );
  }

  /// FILTER
  Future<bool> _shouldIncludeAsset(
    AssetEntity asset,
  ) async {
    switch (currentSession) {
      /// EVERYTHING
      case PhotoSessionType.anything:
        return asset.type ==
                AssetType.image ||
            asset.type ==
                AssetType.video;

      /// ONLY PHOTOS
      case PhotoSessionType.photos:
        return asset.type ==
            AssetType.image;

      /// ONLY VIDEOS
      case PhotoSessionType.videos:
        return asset.type ==
            AssetType.video;

      /// RECENT
      case PhotoSessionType.recent:
        final difference = DateTime.now()
            .difference(
              asset.createDateTime,
            )
            .inDays;

        return (asset.type ==
                    AssetType.image ||
                asset.type ==
                    AssetType.video) &&
            difference <= recentDays;

      /// RANDOM
      case PhotoSessionType.random:
        return asset.type ==
                AssetType.image ||
            asset.type ==
                AssetType.video;

      /// SCREENSHOTS
      case PhotoSessionType.screenshots:
        if (asset.type !=
            AssetType.image) {
          return false;
        }

        return await _isScreenshot(
          asset,
        );

      /// LIVE PHOTOS
      case PhotoSessionType.livePhotos:
        return asset.isLivePhoto;
    }
  }

  /// LOAD PHOTOS
  Future<void> _loadPhotos() async {
    _actionHistory.clear();

    emit(
      state.copyWith(
        isLoading: true,
        loadFail: false,
        loadSuccess: false,
        currentIndex: 0,
        photos: [],
        deleteCount: 0,
        keepCount: 0,
        pendingDeletes: [],
        hasAction: false,
        isDeleting: false,
      ),
    );

    try {
      /// PERMISSION
      final PermissionState permission =
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
          imageOption:
              const FilterOption(
            sizeConstraint:
                SizeConstraint(
              ignoreSize: true,
            ),
          ),
          videoOption:
              const FilterOption(
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

      /// LOAD MEDIA
      final rawMedia =
          await albums.first
              .getAssetListPaged(
        page: 0,
        size: 1000,
      );

      /// SORT
      rawMedia.sort(
        (a, b) => b.createDateTime
            .compareTo(
          a.createDateTime,
        ),
      );

      final List<MediaItem> mediaList =
          [];

      for (final asset in rawMedia) {
        try {
          /// FILTER
          if (!(await _shouldIncludeAsset(
            asset,
          ))) {
            continue;
          }

          /// SKIP PROCESSED
          if (processedIds.contains(
            asset.id,
          )) {
            continue;
          }

          /// CREATE MEDIA
          final media =
              await MediaItem.fromAsset(
            asset,
          );

          if (media == null) {
            continue;
          }

          mediaList.add(media);
        } catch (e) {
          debugPrint(
            "LOAD ASSET ERROR: $e",
          );
        }
      }

      /// RANDOMIZE
      if (currentSession ==
          PhotoSessionType.random) {
        mediaList.shuffle(
          Random(),
        );
      }

      /// EMPTY
      if (mediaList.isEmpty) {
        emit(
          state.copyWith(
            isLoading: false,
            loadFail: true,
          ),
        );
        return;
      }

      /// SUCCESS
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

  /// MARK CURRENT PROCESSED
  Future<void>
      _markCurrentProcessed() async {
    if (state.photos.isEmpty) {
      return;
    }

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
    if (state.photos.isEmpty ||
        state.isSessionComplete) {
      return;
    }

    final current =
        state.photos[state.currentIndex];

    await _markCurrentProcessed();

    _actionHistory.add(
      _SwipeAction(
        type: _SwipeActionType.keep,
        item: current,
      ),
    );

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
    if (state.photos.isEmpty ||
        state.isSessionComplete) {
      return;
    }

    final current =
        state.photos[state.currentIndex];

    await _markCurrentProcessed();

    final pending =
        List<MediaItem>.from(
      state.pendingDeletes,
    )..add(current);

    _actionHistory.add(
      _SwipeAction(
        type: _SwipeActionType.delete,
        item: current,
      ),
    );

    emit(
      state.copyWith(
        deleteCount:
            state.deleteCount + 1,
        pendingDeletes: pending,
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
    if (!state.hasAction ||
        _actionHistory.isEmpty) {
      return;
    }

    final last =
        _actionHistory.removeLast();

    int newIndex =
        state.currentIndex;

    int newKeep =
        state.keepCount;

    int newDelete =
        state.deleteCount;

    final pending =
        List<MediaItem>.from(
      state.pendingDeletes,
    );

    if (newIndex > 0) {
      newIndex--;
    }

    if (last.type ==
        _SwipeActionType.keep) {
      newKeep--;
    } else {
      newDelete--;

      pending.removeWhere(
        (e) =>
            e.asset.id ==
            last.item.asset.id,
      );
    }

    emit(
      state.copyWith(
        currentIndex: newIndex,
        keepCount: newKeep,
        deleteCount: newDelete,
        pendingDeletes: pending,
        hasAction:
            newKeep > 0 ||
                newDelete > 0,
      ),
    );
  }

  /// TOGGLE PENDING DELETE
  void togglePendingDelete(
    String assetId,
  ) {
    final pending =
        List<MediaItem>.from(
      state.pendingDeletes,
    );

    final index =
        pending.indexWhere(
      (e) => e.asset.id == assetId,
    );

    if (index < 0) {
      return;
    }

    pending.removeAt(index);

    emit(
      state.copyWith(
        pendingDeletes: pending,
        deleteCount: pending.length,
      ),
    );
  }

  /// CONFIRM DELETE
  Future<bool>
      confirmDeletePending() async {
    if (state.pendingDeletes.isEmpty) {
      return true;
    }

    emit(
      state.copyWith(
        isDeleting: true,
      ),
    );

    try {
      await PhotoManager.editor
          .deleteWithIds(
        state.pendingDeletes
            .map(
              (e) => e.asset.id,
            )
            .toList(),
      );

      emit(
        state.copyWith(
          isDeleting: false,
          pendingDeletes: [],
        ),
      );

      return true;
    } catch (e) {
      debugPrint(
        "CONFIRM DELETE ERROR: $e",
      );

      emit(
        state.copyWith(
          isDeleting: false,
        ),
      );

      return false;
    }
  }
}