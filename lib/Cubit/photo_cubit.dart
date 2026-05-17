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

enum _SwipeActionType { keep, delete }

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

  PhotoMode currentMode = PhotoMode.recent;

  static const int recentDays = 5;
  static const String processedKey = "processed_assets";

  final List<_SwipeAction> _actionHistory = [];

  Future<void> loadRecentPhotos() async {
    currentMode = PhotoMode.recent;
    await _loadPhotos(randomMode: false);
  }

  Future<void> loadRandomPhotos() async {
    currentMode = PhotoMode.random;
    await _loadPhotos(randomMode: true);
  }

  String get sessionTitle {
    switch (currentMode) {
      case PhotoMode.recent:
        return 'Recents';
      case PhotoMode.random:
        return 'Random';
    }
  }

  Future<void> _loadPhotos({
    required bool randomMode,
  }) async {
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
      final PermissionState permission =
          await PhotoManager.requestPermissionExtend(
        requestOption: const PermissionRequestOption(
          androidPermission: AndroidPermission(
            type: RequestType.common,
            mediaLocation: true,
          ),
        ),
      );

      if (permission != PermissionState.authorized &&
          permission != PermissionState.limited) {
        emit(
          state.copyWith(
            isLoading: false,
            loadFail: true,
          ),
        );
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final processedIds =
          prefs.getStringList(processedKey) ?? [];

      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.common,
        onlyAll: true,
        filterOption: FilterOptionGroup(
          containsLivePhotos: true,
          imageOption: const FilterOption(
            sizeConstraint: SizeConstraint(
              ignoreSize: true,
            ),
          ),
          videoOption: const FilterOption(
            sizeConstraint: SizeConstraint(
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

      final rawMedia = await albums.first.getAssetListPaged(
        page: 0,
        size: 1000,
      );

      rawMedia.sort(
        (a, b) => b.createDateTime.compareTo(a.createDateTime),
      );

      final List<MediaItem> mediaList = [];
      final now = DateTime.now();

      for (final asset in rawMedia) {
        try {
          if (asset.type != AssetType.image &&
              asset.type != AssetType.video) {
            continue;
          }

          if (processedIds.contains(asset.id)) {
            continue;
          }

          if (!randomMode) {
            final difference =
                now.difference(asset.createDateTime).inDays;
            if (difference > recentDays) {
              continue;
            }
          }

          final media = await MediaItem.fromAsset(asset);
          if (media == null) {
            continue;
          }

          mediaList.add(media);
        } catch (e) {
          debugPrint("LOAD ASSET ERROR: $e");
        }
      }

      if (randomMode) {
        mediaList.shuffle(Random());
      }

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
      debugPrint("LOAD PHOTO ERROR: $e");
      emit(
        state.copyWith(
          isLoading: false,
          loadFail: true,
        ),
      );
    }
  }

  Future<void> _markCurrentProcessed() async {
    if (state.photos.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final processedIds = prefs.getStringList(processedKey) ?? [];
    final current = state.photos[state.currentIndex];

    if (!processedIds.contains(current.asset.id)) {
      processedIds.add(current.asset.id);
      await prefs.setStringList(processedKey, processedIds);
    }
  }

  Future<void> keepPhoto() async {
    if (state.photos.isEmpty || state.isSessionComplete) return;

    final current = state.photos[state.currentIndex];
    await _markCurrentProcessed();

    _actionHistory.add(
      _SwipeAction(
        type: _SwipeActionType.keep,
        item: current,
      ),
    );

    emit(
      state.copyWith(
        keepCount: state.keepCount + 1,
        hasAction: true,
      ),
    );

    nextPhoto();
  }

  Future<void> deletePhoto() async {
    if (state.photos.isEmpty || state.isSessionComplete) return;

    final current = state.photos[state.currentIndex];
    await _markCurrentProcessed();

    final pending = List<MediaItem>.from(state.pendingDeletes)
      ..add(current);

    _actionHistory.add(
      _SwipeAction(
        type: _SwipeActionType.delete,
        item: current,
      ),
    );

    emit(
      state.copyWith(
        deleteCount: state.deleteCount + 1,
        pendingDeletes: pending,
        hasAction: true,
      ),
    );

    nextPhoto();
  }

  void nextPhoto() {
    if (state.currentIndex < state.photos.length - 1) {
      emit(
        state.copyWith(
          currentIndex: state.currentIndex + 1,
        ),
      );
    }
  }

  void undoAction() {
    if (!state.hasAction || _actionHistory.isEmpty) return;

    final last = _actionHistory.removeLast();
    var newIndex = state.currentIndex;
    var newKeep = state.keepCount;
    var newDelete = state.deleteCount;
    var pending = List<MediaItem>.from(state.pendingDeletes);

    if (newIndex > 0) {
      newIndex--;
    }

    if (last.type == _SwipeActionType.keep) {
      newKeep--;
    } else {
      newDelete--;
      pending.removeWhere(
        (e) => e.asset.id == last.item.asset.id,
      );
    }

    emit(
      state.copyWith(
        currentIndex: newIndex,
        keepCount: newKeep,
        deleteCount: newDelete,
        pendingDeletes: pending,
        hasAction: newKeep > 0 || newDelete > 0,
      ),
    );
  }

  void togglePendingDelete(String assetId) {
    final pending = List<MediaItem>.from(state.pendingDeletes);
    final index = pending.indexWhere((e) => e.asset.id == assetId);
    if (index < 0) return;

    pending.removeAt(index);
    emit(
      state.copyWith(
        pendingDeletes: pending,
        deleteCount: pending.length,
      ),
    );
  }

  Future<bool> confirmDeletePending() async {
    if (state.pendingDeletes.isEmpty) {
      return true;
    }

    emit(state.copyWith(isDeleting: true));

    try {
      await PhotoManager.editor.deleteWithIds(
        state.pendingDeletes.map((e) => e.asset.id).toList(),
      );

      emit(
        state.copyWith(
          isDeleting: false,
          pendingDeletes: [],
        ),
      );
      return true;
    } catch (e) {
      debugPrint("CONFIRM DELETE ERROR: $e");
      emit(state.copyWith(isDeleting: false));
      return false;
    }
  }
}
