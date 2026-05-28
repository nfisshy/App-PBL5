import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';

import '../State/map_state.dart';

class MapCubit extends Cubit<MapState> {
  MapCubit()
      : super(
          const MapState(
            isLoading: true,
          ),
        );

  Future<void> loadMap() async {
    emit(
      state.copyWith(
        isLoading: true,
        loadFail: false,
        loadSuccess: false,
        groups: [],
      ),
    );

    try {
      // ─── PERMISSION ───────────────────────────────────────────
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

      // ─── LOAD ALBUM ───────────────────────────────────────────
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
      );

      if (albums.isEmpty) {
        emit(state.copyWith(isLoading: false, loadFail: true));
        return;
      }

      // ─── LOAD ASSETS ──────────────────────────────────────────
      // Giới hạn 2000 thay vì 5000 — ảnh có GPS thường không nhiều,
      // 2000 là đủ và nhanh hơn đáng kể
      final assets = await albums.first.getAssetListPaged(
        page: 0,
        size: 2000,
      );

      if (assets.isEmpty) {
        emit(
          state.copyWith(
            isLoading: false,
            loadFail: false,
            loadSuccess: true,
            groups: [],
          ),
        );
        return;
      }

      // ─── PHASE 1: Batch parallel latlng ───────────────────────
      // Thay vì await từng cái tuần tự, gọi song song theo batch 20
      // Mỗi batch xong → group ngay → emit markers (không cần thumbnail)
      const int latlngBatchSize = 20;

      final Map<String, List<AssetEntity>> grouped = {};

      for (int i = 0; i < assets.length; i += latlngBatchSize) {
        final batch = assets.skip(i).take(latlngBatchSize).toList();

        // Gọi latlngAsync song song trong batch
        final latlngResults = await Future.wait(
          batch.map((asset) async {
            try {
              return await asset.latlngAsync();
            } catch (_) {
              return null;
            }
          }),
        );

        for (int j = 0; j < batch.length; j++) {
          final latlng = latlngResults[j];
          if (latlng == null) continue;

          final lat = latlng.latitude;
          final lng = latlng.longitude;
          if (lat == 0 && lng == 0) continue;

          final key =
              "${lat.toStringAsFixed(1)},${lng.toStringAsFixed(1)}";
          grouped.putIfAbsent(key, () => []);
          grouped[key]!.add(batch[j]);
        }

        // Sau batch đầu tiên → emit markers ngay (không có thumbnail,
        // dùng null trước) để UI hiện map với markers ngay lập tức
        if (i == 0 && grouped.isNotEmpty) {
          final earlyGroups = await _buildGroupsNoThumbnail(grouped);

          emit(
            state.copyWith(
              isLoading: false,
              loadFail: false,
              loadSuccess: true,
              groups: earlyGroups,
            ),
          );
        }
      }

      // Nếu không có ảnh nào có GPS
      if (grouped.isEmpty) {
        emit(
          state.copyWith(
            isLoading: false,
            loadFail: false,
            loadSuccess: true,
            groups: [],
          ),
        );
        return;
      }

      // ─── PHASE 2: Load thumbnail song song ────────────────────
      // Tất cả groups đã biết → load thumbnail song song cho tất cả
      const int thumbBatchSize = 10;
      final entries = grouped.entries.toList();
      final List<MapPhotoGroup> finalGroups = [];

      for (int i = 0; i < entries.length; i += thumbBatchSize) {
        final batch = entries.skip(i).take(thumbBatchSize).toList();

        final batchGroups = await Future.wait(
          batch.map((entry) async {
            final assets = entry.value;
            if (assets.isEmpty) return null;

            final first = assets.first;

            try {
              final latlng = await first.latlngAsync();
              if (latlng == null) return null;

              final Uint8List? thumb =
                  await first.thumbnailDataWithSize(
                const ThumbnailSize(220, 220),
              );

              return MapPhotoGroup(
                latitude: latlng.latitude,
                longitude: latlng.longitude,
                count: assets.length,
                thumbnail: thumb,
              );
            } catch (_) {
              return null;
            }
          }),
        );

        for (final g in batchGroups) {
          if (g != null) finalGroups.add(g);
        }

        // Emit sau mỗi batch thumbnail → markers hiện ảnh dần dần
        emit(
          state.copyWith(
            groups: List.from(finalGroups),
          ),
        );
      }

      // Emit final đầy đủ
      emit(
        state.copyWith(
          isLoading: false,
          loadFail: false,
          loadSuccess: true,
          groups: finalGroups,
        ),
      );
    } catch (_) {
      emit(state.copyWith(isLoading: false, loadFail: true));
    }
  }

  // Build groups không có thumbnail để emit nhanh sau batch latlng đầu tiên
  Future<List<MapPhotoGroup>> _buildGroupsNoThumbnail(
    Map<String, List<AssetEntity>> grouped,
  ) async {
    final List<MapPhotoGroup> result = [];

    for (final entry in grouped.entries) {
      final assets = entry.value;
      if (assets.isEmpty) continue;

      try {
        final latlng = await assets.first.latlngAsync();
        if (latlng == null) continue;

        result.add(
          MapPhotoGroup(
            latitude: latlng.latitude,
            longitude: latlng.longitude,
            count: assets.length,
            thumbnail: null, // placeholder, thumbnail load ở Phase 2
          ),
        );
      } catch (_) {}
    }

    return result;
  }
}