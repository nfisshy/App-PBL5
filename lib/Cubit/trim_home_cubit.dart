import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';

import '../Items/media_item.dart';
import '../State/trim_state.dart';

class TrimHomeCubit extends Cubit<TrimState> {
  TrimHomeCubit()
      : super(
          const TrimState(isLoading: true),
        );

  Future<void> loadVideos() async {
    emit(
      state.copyWith(
        isLoading: true,
        loadFail: false,
        loadSuccess: false,
        over10Minutes: [],
        over5Minutes: [],
        over3Minutes: [],
        others: [],
      ),
    );

    try {
      // ─── PERMISSION ───────────────────────────────────────────
      final permission = await PhotoManager.requestPermissionExtend(
        requestOption: const PermissionRequestOption(
          androidPermission: AndroidPermission(
            type: RequestType.video,
            mediaLocation: true,
          ),
        ),
      );

      if (permission != PermissionState.authorized &&
          permission != PermissionState.limited) {
        emit(state.copyWith(isLoading: false, loadFail: true));
        return;
      }

      // ─── LOAD ALBUM ───────────────────────────────────────────
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.video,
        onlyAll: true,
      );

      if (albums.isEmpty) {
        emit(state.copyWith(isLoading: false, loadFail: true));
        return;
      }

      // ─── LOAD ASSETS (metadata only, không load thumbnail) ───
      final rawVideos = await albums.first.getAssetListPaged(
        page: 0,
        size: 500, // video ít hơn ảnh nhiều, 500 là đủ
      );

      rawVideos.sort((a, b) => b.duration.compareTo(a.duration));

      // ─── PHASE 1: Phân loại bằng metadata (instant) ──────────
      // asset.duration là metadata sẵn, không cần đọc file
      final List<AssetEntity> raw10 = [];
      final List<AssetEntity> raw5 = [];
      final List<AssetEntity> raw3 = [];
      final List<AssetEntity> rawOthers = [];

      for (final asset in rawVideos) {
        if (asset.type != AssetType.video) continue;
        final d = asset.duration;
        if (d >= 600) {
          raw10.add(asset);
        } else if (d >= 300) {
          raw5.add(asset);
        } else if (d >= 180) {
          raw3.add(asset);
        } else {
          rawOthers.add(asset);
        }
      }

      // Emit ngay với danh sách rỗng nhưng isLoading = false
      // → UI hiện skeleton/empty sections ngay lập tức
      emit(
        state.copyWith(
          isLoading: false,
          loadSuccess: true,
          loadFail: false,
          over10Minutes: [],
          over5Minutes: [],
          over3Minutes: [],
          others: [],
        ),
      );

      // ─── PHASE 2: Load thumbnail song song theo batch ─────────
      // Ưu tiên load section trên trước (10min) vì user thấy trước
      const int batchSize = 6; // 3 cột × 2 hàng = 6, vừa đủ 1 màn hình

      Future<List<MediaItem>> loadSection(List<AssetEntity> assets) async {
        final List<MediaItem> result = [];

        for (int i = 0; i < assets.length; i += batchSize) {
          final batch = assets.skip(i).take(batchSize).toList();

          final batchResults = await Future.wait(
            batch.map((asset) => MediaItem.fromAsset(asset)),
          );

          for (final item in batchResults) {
            if (item != null) result.add(item);
          }

          // Emit sau mỗi batch để UI cập nhật dần
          emit(state.copyWith());
        }

        return result;
      }

      // Load từng section tuần tự nhưng thumbnail trong section song song
      // Over 10min trước vì nằm trên cùng
      final loaded10 = await loadSection(raw10);
      emit(state.copyWith(over10Minutes: loaded10));

      final loaded5 = await loadSection(raw5);
      emit(state.copyWith(over5Minutes: loaded5));

      final loaded3 = await loadSection(raw3);
      emit(state.copyWith(over3Minutes: loaded3));

      final loadedOthers = await loadSection(rawOthers);
      emit(state.copyWith(others: loadedOthers));
    } catch (e) {
      debugPrint("TRIM LOAD ERROR: $e");
      emit(state.copyWith(isLoading: false, loadFail: true));
    }
  }
}
