import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:photo_manager/photo_manager.dart';

import '../State/place_state.dart';

class PlacesCubit extends Cubit<PlacesState> {
  PlacesCubit()
      : super(
          const PlacesState(
            isLoading: true,
          ),
        );

  Future<void> loadPlaces() async {
    emit(
      state.copyWith(
        isLoading: true,
        loadFail: false,
        loadSuccess: false,
        places: [],
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
      // Giảm từ 5000 → 2000, ảnh có GPS thường ít hơn nhiều
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
            places: [],
          ),
        );
        return;
      }

      // ─── PHASE 1: Batch parallel latlng ───────────────────────
      // Gộp tọa độ gần nhau (2 chữ số thập phân ≈ ~1km)
      // → giảm số lần reverse geocoding cần thực hiện
      const int latlngBatchSize = 20;

      // cache key → location name (tránh geocode trùng)
      final Map<String, String> geocodeCache = {};

      // key → có trong set chưa (tránh geocode trùng key)
      final Set<String> resolvedKeys = {};

      // Danh sách unique keys cần geocode (chưa có trong cache)
      final List<({String key, double lat, double lng})> pendingGeocode = [];

      // ─── Thu thập tất cả unique keys trước ───────────────────
      // Batch latlng song song để nhanh
      for (int i = 0; i < assets.length; i += latlngBatchSize) {
        final batch = assets.skip(i).take(latlngBatchSize).toList();

        final latlngResults = await Future.wait(
          batch.map((asset) async {
            try {
              return await asset.latlngAsync();
            } catch (_) {
              return null;
            }
          }),
        );

        for (final latlng in latlngResults) {
          if (latlng == null) continue;
          final lat = latlng.latitude;
          final lng = latlng.longitude;
          if (lat == 0 && lng == 0) continue;

          final key =
              "${lat.toStringAsFixed(2)},${lng.toStringAsFixed(2)}";

          if (resolvedKeys.contains(key)) continue;
          resolvedKeys.add(key);

          // Chưa có trong cache → cần geocode
          if (!geocodeCache.containsKey(key)) {
            pendingGeocode.add((key: key, lat: lat, lng: lng));
          }
        }
      }

      if (pendingGeocode.isEmpty) {
        emit(
          state.copyWith(
            isLoading: false,
            loadFail: false,
            loadSuccess: true,
            places: [],
          ),
        );
        return;
      }

      // ─── PHASE 2: Batch parallel reverse geocoding ────────────
      // Geocoding là network call → batch nhỏ hơn (5) để tránh rate limit
      // Emit sau mỗi batch để UI hiện places dần
      const int geocodeBatchSize = 5;
      final Set<String> locationSet = {};

      for (int i = 0; i < pendingGeocode.length; i += geocodeBatchSize) {
        final batch =
            pendingGeocode.skip(i).take(geocodeBatchSize).toList();

        final batchResults = await Future.wait(
          batch.map((item) async {
            try {
              final placemarks = await placemarkFromCoordinates(
                item.lat,
                item.lng,
              );

              if (placemarks.isEmpty) return null;

              final place = placemarks.first;
              String? location;

              if ((place.locality ?? "").isNotEmpty) {
                location = place.locality!;
              } else if ((place.subAdministrativeArea ?? "").isNotEmpty) {
                location = place.subAdministrativeArea!;
              } else if ((place.administrativeArea ?? "").isNotEmpty) {
                location = place.administrativeArea!;
              }

              if (location != null) {
                geocodeCache[item.key] = location;
              }

              return location;
            } catch (e) {
              debugPrint("GEOCODE ERROR: $e");
              return null;
            }
          }),
        );

        for (final loc in batchResults) {
          if (loc != null) locationSet.add(loc);
        }

        // Emit sau mỗi batch → UI hiện places ngay khi có
        if (locationSet.isNotEmpty) {
          emit(
            state.copyWith(
              isLoading: false,
              loadFail: false,
              loadSuccess: true,
              places: locationSet.toList()..sort(),
            ),
          );
        }
      }

      // ─── Final emit đầy đủ ────────────────────────────────────
      emit(
        state.copyWith(
          isLoading: false,
          loadFail: false,
          loadSuccess: true,
          places: locationSet.toList()..sort(),
        ),
      );
    } catch (e) {
      debugPrint("LOAD PLACES ERROR: $e");
      emit(state.copyWith(isLoading: false, loadFail: true));
    }
  }
}