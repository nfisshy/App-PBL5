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
      /// =========================
      /// PERMISSION
      /// =========================
      final permission =
          await PhotoManager.requestPermissionExtend(
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

      /// =========================
      /// LOAD ALBUM
      /// =========================
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

      /// =========================
      /// LOAD ASSETS
      /// =========================
      final assets =
          await albums.first.getAssetListPaged(
        page: 0,
        size: 5000,
      );

      /// =========================
      /// UNIQUE LOCATIONS
      /// =========================
      final Set<String> locations =
          <String>{};

      /// cache reverse geocoding
      final Map<String, String> cache =
          {};

      for (final asset in assets) {
        try {
          /// =========================
          /// LAT LNG
          /// =========================
          final latlng =
              await asset.latlngAsync();

          if (latlng == null) {
            continue;
          }

          final lat =
              latlng.latitude;
          final lng =
              latlng.longitude;

          /// invalid GPS
          if (lat == 0 && lng == 0) {
            continue;
          }

          /// =========================
          /// CACHE KEY
          /// =========================
          final key =
              "${lat.toStringAsFixed(2)},${lng.toStringAsFixed(2)}";

          /// already resolved
          if (cache.containsKey(key)) {
            locations.add(cache[key]!);
            continue;
          }

          /// =========================
          /// REVERSE GEOCODING
          /// =========================
          final placemarks =
              await placemarkFromCoordinates(
            lat,
            lng,
          );

          if (placemarks.isEmpty) {
            continue;
          }

          final place =
              placemarks.first;

          String? location;

          /// CITY
          if ((place.locality ?? "")
              .isNotEmpty) {
            location =
                place.locality!;
          }

          /// DISTRICT
          else if ((place
                      .subAdministrativeArea ??
                  "")
              .isNotEmpty) {
            location =
                place
                    .subAdministrativeArea!;
          }

          /// STATE
          else if ((place
                      .administrativeArea ??
                  "")
              .isNotEmpty) {
            location =
                place
                    .administrativeArea!;
          }

          if (location == null) {
            continue;
          }

          cache[key] = location;

          locations.add(location);
        } catch (e) {
          debugPrint(
            "PLACE ERROR: $e",
          );
        }
      }

      /// =========================
      /// SUCCESS
      /// =========================
      emit(
        state.copyWith(
          isLoading: false,
          loadFail: false,
          loadSuccess: true,
          places:
              locations.toList()
                ..sort(),
        ),
      );
    } catch (e) {
      debugPrint(
        "LOAD PLACES ERROR: $e",
      );

      emit(
        state.copyWith(
          isLoading: false,
          loadFail: true,
        ),
      );
    }
  }
}