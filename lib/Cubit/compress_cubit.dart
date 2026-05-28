import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';

import '../Items/media_item.dart';
import '../State/compress_state.dart';

class CompressCubit
    extends Cubit<CompressState> {
  CompressCubit()
      : super(
          const CompressState(
            isLoading: true,
          ),
        );

  Future<void> loadVideos() async {
    emit(
      state.copyWith(
        isLoading: true,
        loadFail: false,
        loadSuccess: false,
      ),
    );

    try {
      final permission =
          await PhotoManager.requestPermissionExtend(
        requestOption:
            const PermissionRequestOption(
          androidPermission:
              AndroidPermission(
            type: RequestType.video,
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

      final albums =
          await PhotoManager.getAssetPathList(
        type: RequestType.video,
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

      final rawVideos =
          await albums.first.getAssetListPaged(
        page: 0,
        size: 2000,
      );

      final List<MediaItem>
          over1GB = [];

      final List<MediaItem>
          over500MB = [];

      final List<MediaItem>
          over250MB = [];

      final List<MediaItem>
          others = [];

      for (final asset in rawVideos) {
        try {
          if (asset.type !=
              AssetType.video) {
            continue;
          }

          final file =
              await asset.file;

          if (file == null) {
            continue;
          }

          final media =
              await MediaItem.fromAsset(
            asset,
          );

          if (media == null) {
            continue;
          }

          final bytes =
              await file.length();

          /// >= 1GB
          if (bytes >=
              1024 * 1024 * 1024) {
            over1GB.add(media);
          }

          /// >= 500MB
          else if (bytes >=
              500 * 1024 * 1024) {
            over500MB.add(media);
          }

          /// >= 250MB
          else if (bytes >=
              250 * 1024 * 1024) {
            over250MB.add(media);
          }

          else {
            others.add(media);
          }
        } catch (e) {
          debugPrint(
            "COMPRESS LOAD VIDEO ERROR: $e",
          );
        }
      }

      emit(
        state.copyWith(
          isLoading: false,
          loadSuccess: true,
          loadFail: false,

          over1GB: over1GB,

          over500MB:
              over500MB,

          over250MB:
              over250MB,

          others: others,
        ),
      );
    } catch (e) {
      debugPrint(
        "COMPRESS LOAD ERROR: $e",
      );

      emit(
        state.copyWith(
          isLoading: false,
          loadFail: true,
        ),
      );
    }
  }

  Future<int> getFileSize(
    AssetEntity asset,
  ) async {
    final file =
        await asset.file;

    if (file == null) {
      return 0;
    }

    return await file.length();
  }
}