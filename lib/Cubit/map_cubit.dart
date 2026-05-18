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

      if (!permission.hasAccess) {
        emit(
          state.copyWith(
            isLoading: false,
            loadFail: true,
          ),
        );

        return;
      }

      /// LOAD ALBUM
      final albums =
          await PhotoManager.getAssetPathList(
        type: RequestType.image,
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

      /// LOAD ASSETS
      final assets =
          await albums.first
              .getAssetListPaged(
        page: 0,
        size: 5000,
      );

      /// GROUPS
      final Map<
              String,
              List<AssetEntity>>
          grouped = {};

      for (final asset in assets) {
        try {
          final latlng =
              await asset.latlngAsync();

          if (latlng == null) {
            continue;
          }

          final lat =
              latlng.latitude;
          final lng =
              latlng.longitude;

          if (lat == 0 && lng == 0) {
            continue;
          }

          /// GROUP NEARBY
          final key =
              "${lat.toStringAsFixed(1)},${lng.toStringAsFixed(1)}";

          grouped.putIfAbsent(
            key,
            () => [],
          );

          grouped[key]!.add(asset);
        } catch (_) {}
      }

      final List<MapPhotoGroup>
          results = [];

      for (final entry
          in grouped.entries) {
        final assets =
            entry.value;

        if (assets.isEmpty) {
          continue;
        }

        final first =
            assets.first;

        final latlng =
            await first.latlngAsync();

        if (latlng == null) {
          continue;
        }

        final Uint8List? thumb =
            await first.thumbnailDataWithSize(
          const ThumbnailSize(
            220,
            220,
          ),
        );

        results.add(
          MapPhotoGroup(
            latitude:
                latlng.latitude,
            longitude:
                latlng.longitude,
            count: assets.length,
            thumbnail: thumb,
          ),
        );
      }

      emit(
        state.copyWith(
          isLoading: false,
          loadFail: false,
          loadSuccess: true,
          groups: results,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          loadFail: true,
        ),
      );
    }
  }
}