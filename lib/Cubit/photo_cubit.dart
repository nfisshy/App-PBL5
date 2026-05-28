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

  /// =========================
  /// SESSION
  /// =========================

  PhotoSessionType currentSession = PhotoSessionType.anything;

  static const int recentDays = 5;

  /// =========================
  /// STORAGE KEYS
  /// =========================

  static const String processedKey = "processed_assets";
  static const String pendingDeleteKey = "pending_delete_assets";

  /// =========================
  /// HISTORY
  /// =========================

  final List<_SwipeAction> _actionHistory = [];

  /// =========================
  /// LOAD SESSION
  /// =========================

  Future<void> loadSession(PhotoSessionType type) async {
    currentSession = type;
    await _loadPhotos();
  }

  /// =========================
  /// SESSION TITLE
  /// =========================

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

  /// =========================
  /// HOME STATUS
  /// =========================

  Future<void> loadRecentHomeStatus() async {
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
        return;
      }

      final prefs = await SharedPreferences.getInstance();

      final processedIds = prefs.getStringList(processedKey) ?? [];
      final pendingDeleteIds = prefs.getStringList(pendingDeleteKey) ?? [];

      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.common,
        onlyAll: true,
      );

      if (albums.isEmpty) return;

      final rawMedia = await albums.first.getAssetListPaged(
        page: 0,
        size: 1000,
      );

      int recentCount = 0;

      for (final asset in rawMedia) {
        final difference =
            DateTime.now().difference(asset.createDateTime).inDays;

        final isRecent = difference <= recentDays;
        final isValid = asset.type == AssetType.image ||
            asset.type == AssetType.video;

        if (!isRecent || !isValid) continue;
        if (processedIds.contains(asset.id)) continue;

        recentCount++;
      }

      final hasPendingSummary = pendingDeleteIds.isNotEmpty;
      final recentCompleted = recentCount == 0 && !hasPendingSummary;

      emit(
        state.copyWith(
          recentUnreviewedCount: recentCount,
          hasPendingSummary: hasPendingSummary,
          recentCompleted: recentCompleted,
        ),
      );
    } catch (e) {
      debugPrint("LOAD HOME STATUS ERROR: $e");
    }
  }

  /// =========================
  /// CHECK SCREENSHOT (không đọc file, dùng metadata)
  /// =========================

  bool _isScreenshotFast(AssetEntity asset) {
    // Dùng relativePath + title thay vì await asset.file → nhanh hơn ~20x
    final path = (asset.relativePath ?? "").toLowerCase();
    final title = (asset.title ?? "").toLowerCase();

    return path.contains("screenshot") ||
        title.contains("screenshot") ||
        path.contains("screen_shot") ||
        title.contains("screen_shot");
  }

  /// =========================
  /// FILTER (sync — không async, không đọc file)
  /// =========================

  bool _shouldIncludeAssetFast(AssetEntity asset) {
    switch (currentSession) {
      case PhotoSessionType.anything:
        return asset.type == AssetType.image ||
            asset.type == AssetType.video;

      case PhotoSessionType.photos:
        return asset.type == AssetType.image;

      case PhotoSessionType.videos:
        return asset.type == AssetType.video;

      case PhotoSessionType.recent:
        final difference =
            DateTime.now().difference(asset.createDateTime).inDays;
        return (asset.type == AssetType.image ||
                asset.type == AssetType.video) &&
            difference <= recentDays;

      case PhotoSessionType.random:
        return asset.type == AssetType.image ||
            asset.type == AssetType.video;

      case PhotoSessionType.screenshots:
        if (asset.type != AssetType.image) return false;
        return _isScreenshotFast(asset);

      case PhotoSessionType.livePhotos:
        return asset.isLivePhoto;
    }
  }

  /// =========================
  /// SAVE PENDING
  /// =========================

  Future<void> _savePendingDeletes(List<MediaItem> pending) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = pending.map((e) => e.asset.id).toList();
    await prefs.setStringList(pendingDeleteKey, ids);
  }

  /// =========================
  /// LOAD PHOTOS — 2-PHASE
  /// =========================

  Future<void> _loadPhotos() async {
    _actionHistory.clear();

    emit(
      state.copyWith(
        isLoading: true,
        loadFail: false,
        loadSuccess: false,
        currentIndex: 0,
        photos: [],
        totalCount: 0,
        deleteCount: 0,
        keepCount: 0,
        hasAction: false,
        isDeleting: false,
      ),
    );

    try {
      // ─── PERMISSION ───────────────────────────────────────────
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
        emit(state.copyWith(isLoading: false, loadFail: true));
        return;
      }

      // ─── PREFS ────────────────────────────────────────────────
      final prefs = await SharedPreferences.getInstance();
      final processedIds = prefs.getStringList(processedKey) ?? [];
      final pendingDeleteIds = prefs.getStringList(pendingDeleteKey) ?? [];

      // ─── ALBUMS ───────────────────────────────────────────────
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.common,
        onlyAll: true,
        filterOption: FilterOptionGroup(containsLivePhotos: true),
      );

      if (albums.isEmpty) {
        emit(state.copyWith(isLoading: false, loadFail: true));
        return;
      }

      // ─── RAW MEDIA ────────────────────────────────────────────
      final rawMedia = await albums.first.getAssetListPaged(
        page: 0,
        size: currentSession == PhotoSessionType.recent ? 1000 : 200,
      );

      rawMedia.sort(
        (a, b) => b.createDateTime.compareTo(a.createDateTime),
      );

      // ─── PHASE 1: SCAN METADATA (sync, không đọc file) ────────
      // Mục tiêu: lọc nhanh để biết totalCount + danh sách assets cần load
      final List<AssetEntity> filteredAssets = [];
      final List<AssetEntity> pendingAssets = [];

      for (final asset in rawMedia) {
        if (!_shouldIncludeAssetFast(asset)) continue;

        if (pendingDeleteIds.contains(asset.id)) {
          pendingAssets.add(asset);
        }

        if (!processedIds.contains(asset.id)) {
          filteredAssets.add(asset);
        }
      }

      // Shuffle trước khi limit (random mode)
      if (currentSession == PhotoSessionType.random) {
        filteredAssets.shuffle(Random());
      }

      // Giới hạn số lượng cần load thumbnail
      final List<AssetEntity> assetsToLoad =
          currentSession == PhotoSessionType.recent
              ? filteredAssets
              : filteredAssets.take(20).toList();

      final int totalCount = assetsToLoad.length;

      if (totalCount == 0) {
        // Restore pending deletes nếu có
        final List<MediaItem> restoredPending = [];
        for (final asset in pendingAssets) {
          final media = await MediaItem.fromAsset(asset);
          if (media != null) restoredPending.add(media);
        }

        emit(
          state.copyWith(
            isLoading: false,
            loadFail: false,
            loadSuccess: true,
            photos: [],
            totalCount: 0,
            currentIndex: 0,
            pendingDeletes: restoredPending,
            totalReviewedCount: processedIds.length,
            deleteCount: 0,
            keepCount: 0,
          ),
        );
        await loadRecentHomeStatus();
        return;
      }

      // ─── PHASE 2A: Load ảnh đầu tiên ngay lập tức ─────────────
      // Emit ngay với totalCount đúng → UI hiện ảnh đầu + số lượng
      final MediaItem? firstItem =
          await MediaItem.fromAsset(assetsToLoad.first);

      if (firstItem == null) {
        emit(state.copyWith(isLoading: false, loadFail: true));
        return;
      }

      emit(
        state.copyWith(
          isLoading: false,
          loadFail: false,
          loadSuccess: true,
          photos: [firstItem],
          totalCount: totalCount,   // ← số đúng ngay từ đầu
          currentIndex: 0,
          pendingDeletes: [],
          totalReviewedCount: processedIds.length,
          deleteCount: 0,
          keepCount: 0,
        ),
      );

      // ─── PHASE 2B: Load phần còn lại theo batch (background) ──
      // User đã thấy ảnh đầu tiên, ta load tiếp các ảnh còn lại
      const int batchSize = 5;
      final List<MediaItem> allLoaded = [firstItem];

      // Load pending deletes song song trong background
      final List<MediaItem> restoredPendingDeletes = [];
      final pendingFuture = Future(() async {
        for (final asset in pendingAssets) {
          final media = await MediaItem.fromAsset(asset);
          if (media != null) restoredPendingDeletes.add(media);
        }
      });

      // Load batch từ index 1 trở đi
      final remainingAssets = assetsToLoad.skip(1).toList();

      for (int i = 0; i < remainingAssets.length; i += batchSize) {
        final batch = remainingAssets.skip(i).take(batchSize).toList();

        // Load song song trong batch
        final batchResults = await Future.wait(
          batch.map((asset) => MediaItem.fromAsset(asset)),
        );

        for (final item in batchResults) {
          if (item != null) allLoaded.add(item);
        }

        // Emit sau mỗi batch để UI cập nhật dần
        // (quan trọng: totalCount không đổi → UI không nhảy số)
        emit(
          state.copyWith(
            photos: List.from(allLoaded),
            totalCount: totalCount,
          ),
        );
      }

      // Chờ pending deletes xong rồi emit lần cuối
      await pendingFuture;

      emit(
        state.copyWith(
          photos: List.from(allLoaded),
          totalCount: totalCount,
          pendingDeletes: restoredPendingDeletes,
        ),
      );

      await loadRecentHomeStatus();
    } catch (e) {
      debugPrint("LOAD PHOTO ERROR: $e");
      emit(state.copyWith(isLoading: false, loadFail: true));
    }
  }

  /// =========================
  /// MARK PROCESSED
  /// =========================

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

  /// =========================
  /// KEEP
  /// =========================

  Future<void> keepPhoto() async {
    if (state.photos.isEmpty || state.isSessionComplete) return;

    await _markCurrentProcessed();

    final current = state.photos[state.currentIndex];

    _actionHistory.add(
      _SwipeAction(type: _SwipeActionType.keep, item: current),
    );

    emit(
      state.copyWith(
        keepCount: state.keepCount + 1,
        totalReviewedCount: state.totalReviewedCount + 1,
        hasAction: true,
      ),
    );

    nextPhoto();
    await loadRecentHomeStatus();
  }

  /// =========================
  /// DELETE
  /// =========================

  Future<void> deletePhoto() async {
    if (state.photos.isEmpty || state.isSessionComplete) return;

    await _markCurrentProcessed();

    final current = state.photos[state.currentIndex];
    final pending = List<MediaItem>.from(state.pendingDeletes)..add(current);

    _actionHistory.add(
      _SwipeAction(type: _SwipeActionType.delete, item: current),
    );

    emit(
      state.copyWith(
        deleteCount: state.deleteCount + 1,
        totalReviewedCount: state.totalReviewedCount + 1,
        pendingDeletes: pending,
        hasAction: true,
      ),
    );

    await _savePendingDeletes(pending);
    nextPhoto();
    await loadRecentHomeStatus();
  }

  /// =========================
  /// NEXT
  /// =========================

  void nextPhoto() {
    if (state.currentIndex < state.photos.length - 1) {
      emit(state.copyWith(currentIndex: state.currentIndex + 1));
    }
  }

  /// =========================
  /// UNDO
  /// =========================

  Future<void> undoAction() async {
    if (!state.hasAction || _actionHistory.isEmpty) return;

    final last = _actionHistory.removeLast();

    int newIndex = state.currentIndex;
    int newKeep = state.keepCount;
    int newDelete = state.deleteCount;
    int totalReviewed = state.totalReviewedCount;
    final pending = List<MediaItem>.from(state.pendingDeletes);

    if (newIndex > 0) newIndex--;
    totalReviewed--;

    if (last.type == _SwipeActionType.keep) {
      newKeep--;
    } else {
      newDelete--;
      pending.removeWhere((e) => e.asset.id == last.item.asset.id);
    }

    emit(
      state.copyWith(
        currentIndex: newIndex,
        keepCount: newKeep,
        deleteCount: newDelete,
        totalReviewedCount: totalReviewed,
        pendingDeletes: pending,
        hasAction: newKeep > 0 || newDelete > 0,
      ),
    );

    await _savePendingDeletes(pending);
    await loadRecentHomeStatus();
  }

  /// =========================
  /// TOGGLE DELETE
  /// =========================

  Future<void> togglePendingDelete(String assetId) async {
    final pending = List<MediaItem>.from(state.pendingDeletes);
    final index = pending.indexWhere((e) => e.asset.id == assetId);

    if (index < 0) return;

    pending.removeAt(index);

    emit(state.copyWith(pendingDeletes: pending));
    await _savePendingDeletes(pending);
    await loadRecentHomeStatus();
  }

  /// =========================
  /// CONFIRM DELETE
  /// =========================

  Future<bool> confirmDeletePending() async {
    emit(state.copyWith(isDeleting: true));

    try {
      if (state.pendingDeletes.isNotEmpty) {
        await PhotoManager.editor.deleteWithIds(
          state.pendingDeletes.map((e) => e.asset.id).toList(),
        );
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(pendingDeleteKey);

      emit(
        state.copyWith(
          isDeleting: false,
          pendingDeletes: [],
          hasPendingSummary: false,
        ),
      );

      await loadRecentHomeStatus();
      return true;
    } catch (e) {
      debugPrint("CONFIRM DELETE ERROR: $e");
      emit(state.copyWith(isDeleting: false));
      return false;
    }
  }

  /// =========================
  /// ADD SAVED BYTES
  /// =========================

  Future<void> addSavedBytes(int bytes) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('total_saved_bytes') ?? 0;
    final updated = current + bytes;

    await prefs.setInt('total_saved_bytes', updated);

    emit(state.copyWith(totalSavedBytes: updated));
  }
}