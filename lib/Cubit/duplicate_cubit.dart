// duplicate_cubit.dart — sửa bug _pHash + _cos
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image/image.dart' as img;
import 'package:photo_manager/photo_manager.dart';

import '../Items/media_item.dart';
import '../State/duplicate_state.dart';
import '../core/bk_tree.dart';
import '../core/hash_cache.dart';

class DuplicateCubit extends Cubit<DuplicatePhotoState> {
  DuplicateCubit() : super(const DuplicatePhotoState(isLoading: true));

  // ─────────────────────────────────────────────
  // Cos cache — tính 1 lần, dùng mãi
  // ─────────────────────────────────────────────
  static final _cosCache = <int, double>{};

  double _cachedCos(int n, int k) {
    final key = n * 32 + k;
    return _cosCache.putIfAbsent(
      key,
      () => math.cos(math.pi * (2 * n + 1) * k / 64.0),
    );
  }

  // ─────────────────────────────────────────────
  // pHash: resize 32x32 → DCT → hash 63 bit
  // ─────────────────────────────────────────────
  int _pHash(img.Image image) {
    final resized = img.copyResize(image, width: 32, height: 32);
    final gray = img.grayscale(resized);

    // Pixel matrix
    final pixels = List.generate(
      32,
      (y) => List.generate(32, (x) => gray.getPixel(x, y).r.toDouble()),
    );

    // DCT 2D — chỉ tính 8x8 góc trên trái
    final dct = List.generate(8, (u) {
      return List.generate(8, (v) {
        double sum = 0.0;
        for (int x = 0; x < 32; x++) {
          for (int y = 0; y < 32; y++) {
            sum += pixels[y][x] * _cachedCos(x, u) * _cachedCos(y, v);
          }
        }
        return sum;
      });
    });

    // Mean 8x8, bỏ DC component [0][0]
    double sum = 0.0;
    for (int u = 0; u < 8; u++) {
      for (int v = 0; v < 8; v++) {
        if (u == 0 && v == 0) continue;
        sum += dct[u][v];
      }
    }
    final mean = sum / 63.0;

    // Build hash 63 bit
    int hash = 0;
    int bit = 0;
    for (int u = 0; u < 8; u++) {
      for (int v = 0; v < 8; v++) {
        if (u == 0 && v == 0) continue;
        if (dct[u][v] > mean) hash |= (1 << bit);
        bit++;
      }
    }
    return hash;
  }

  // ─────────────────────────────────────────────
  // Hash 1 asset
  // ─────────────────────────────────────────────
  Future<int?> _hashAsset(AssetEntity asset) async {
    try {
      final thumb = await asset.thumbnailDataWithSize(
        const ThumbnailSize(32, 32),
        quality: 85,
      );
      if (thumb == null) return null;
      final decoded = img.decodeImage(thumb);
      if (decoded == null) return null;
      return _pHash(decoded);
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // Load duplicates
  // ─────────────────────────────────────────────
  Future<void> loadDuplicates() async {
    emit(state.copyWith(
      isLoading: true,
      loadFail: false,
      loadSuccess: false,
      duplicateGroups: [],
      selectedIds: {},
      progress: 0.0,
    ));

    try {
      // ── Permission ───────────────────────────
      final permission = await PhotoManager.requestPermissionExtend(
        requestOption: const PermissionRequestOption(
          androidPermission: AndroidPermission(
            type: RequestType.common,
            mediaLocation: true,
          ),
        ),
      );
      if (!permission.hasAccess) {
        emit(state.copyWith(isLoading: false, loadFail: true));
        return;
      }

      // ── Load assets ──────────────────────────
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
      );
      if (albums.isEmpty) {
        emit(state.copyWith(isLoading: false, loadFail: true));
        return;
      }
      final assets = await albums.first.getAssetListPaged(page: 0, size: 10000);

      // ── Load hash cache ──────────────────────
      final hashMap = Map<String, int>.from(await HashCache.load());

      // ── Tính hash cho ảnh chưa có cache ──────
      final needHash = assets.where((a) => !hashMap.containsKey(a.id)).toList();
      const batchSize = 20;

      for (int i = 0; i < needHash.length; i += batchSize) {
        final batch = needHash.sublist(
          i,
          (i + batchSize).clamp(0, needHash.length),
        );

        final results = await Future.wait(batch.map(_hashAsset));

        for (int j = 0; j < batch.length; j++) {
          final h = results[j];
          if (h != null) hashMap[batch[j].id] = h;
        }

        emit(state.copyWith(
          progress: ((i + batchSize) / needHash.length).clamp(0.0, 0.9),
        ));
      }

      await HashCache.save(hashMap);

      // ── Load MediaItem song song ─────────────
      final mediaMap = <String, MediaItem>{};
      await Future.wait(assets.map((a) async {
        if (!hashMap.containsKey(a.id)) return;
        final media = await MediaItem.fromAsset(a);
        if (media != null) mediaMap[a.id] = media;
      }));

      // ── BK-Tree grouping ─────────────────────
      final groups = _buildGroups(assets, hashMap, mediaMap);

      // ── Auto-select duplicates ───────────────
      final selected = _autoSelect(groups);

      emit(state.copyWith(
        isLoading: false,
        loadSuccess: true,
        duplicateGroups: groups,
        selectedIds: selected,
        progress: 1.0,
      ));
    } catch (_) {
      emit(state.copyWith(isLoading: false, loadFail: true));
    }
  }

  // ─────────────────────────────────────────────
  // BK-Tree grouping
  // ─────────────────────────────────────────────
  List<List<MediaItem>> _buildGroups(
    List<AssetEntity> assets,
    Map<String, int> hashMap,
    Map<String, MediaItem> mediaMap,
  ) {
    final tree = BKTree(_hammingDistance);

    for (final asset in assets) {
      final hash = hashMap[asset.id];
      if (hash == null || mediaMap[asset.id] == null) continue;
      tree.add(hash, asset.id);
    }

    const threshold = 8;
    final visited = <String>{};
    final groups = <List<MediaItem>>[];

    for (final asset in assets) {
      if (visited.contains(asset.id)) continue;
      final hash = hashMap[asset.id];
      if (hash == null) continue;

      final matches = tree.search(hash, threshold);
      if (matches.length <= 1) continue;

      final group = <MediaItem>[];
      for (final m in matches) {
        if (visited.contains(m.id)) continue;
        final media = mediaMap[m.id];
        if (media != null) {
          group.add(media);
          visited.add(m.id);
        }
      }

      if (group.length > 1) groups.add(group);
    }

    return groups;
  }

  // ─────────────────────────────────────────────
  // Auto-select: mark tất cả trừ ảnh lớn nhất
  // ─────────────────────────────────────────────
  Set<String> _autoSelect(List<List<MediaItem>> groups) {
    final selected = <String>{};
    for (final group in groups) {
      final sorted = [...group]..sort((a, b) => b.fileSize.compareTo(a.fileSize));
      for (int i = 1; i < sorted.length; i++) {
        selected.add(sorted[i].asset.id);
      }
    }
    return selected;
  }

  int _hammingDistance(int a, int b) {
    int xor = a ^ b;
    int count = 0;
    while (xor != 0) {
      count++;
      xor &= xor - 1;
    }
    return count;
  }

  // ─────────────────────────────────────────────
  // Actions
  // ─────────────────────────────────────────────
  void toggleSelect(String assetId) {
    final current = Set<String>.from(state.selectedIds);
    current.contains(assetId) ? current.remove(assetId) : current.add(assetId);
    emit(state.copyWith(selectedIds: current));
  }

  void selectAll() {
    final all = <String>{};
    for (final group in state.duplicateGroups) {
      for (final item in group) all.add(item.asset.id);
    }
    emit(state.copyWith(selectedIds: all));
  }

  void clearSelection() => emit(state.copyWith(selectedIds: {}));

  Future<void> deleteSelected() async {
    try {
      final toDelete = <AssetEntity>[];
      for (final group in state.duplicateGroups) {
        for (final item in group) {
          if (state.selectedIds.contains(item.asset.id)) {
            toDelete.add(item.asset);
          }
        }
      }
      if (toDelete.isEmpty) return;

      emit(state.copyWith(isDeleting: true));
      await PhotoManager.editor.deleteWithIds(toDelete.map((e) => e.id).toList());
      await HashCache.invalidate(toDelete.map((e) => e.id).toList());
      emit(state.copyWith(isDeleting: false));
      await loadDuplicates();
    } catch (_) {
      emit(state.copyWith(isDeleting: false));
    }
  }

  int get totalDuplicates =>
      state.duplicateGroups.fold(0, (sum, g) => sum + g.length);

  int get totalSelected => state.selectedIds.length;

  Future<String> calculateSelectedSize() async {
    int totalBytes = 0;
    for (final group in state.duplicateGroups) {
      for (final item in group) {
        if (state.selectedIds.contains(item.asset.id)) {
          totalBytes += item.fileSize;
        }
      }
    }
    if (totalBytes < 1024 * 1024) {
      return "${(totalBytes / 1024).toStringAsFixed(1)} KB";
    }
    if (totalBytes < 1024 * 1024 * 1024) {
      return "${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB";
    }
    return "${(totalBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB";
  }
}