import 'dart:io';
import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';

class MediaItem {
  final AssetEntity asset;

  final Uint8List? thumbnail;

  final bool isVideo;

  final bool isLivePhoto;

  final int fileSize;

  final DateTime createdAt;

  final String? deviceName;

  const MediaItem({
    required this.asset,
    required this.thumbnail,
    required this.isVideo,
    required this.isLivePhoto,
    required this.fileSize,
    required this.createdAt,
    required this.deviceName,
  });

  String get formattedSize {
    if (fileSize < 1024) {
      return "$fileSize B";
    }

    if (fileSize < 1024 * 1024) {
      return "${(fileSize / 1024).toStringAsFixed(1)} KB";
    }

    if (fileSize < 1024 * 1024 * 1024) {
      return "${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB";
    }

    return "${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB";
  }

  static Future<MediaItem?> fromAsset(
    AssetEntity asset,
  ) async {
    try {
      final bool isVideo =
          asset.type ==
              AssetType.video;

      Uint8List? thumb;

      /// IMAGE THUMB
      if (!isVideo) {
        try {
          thumb =
              await asset.thumbnailDataWithSize(
            const ThumbnailSize(
              500,
              500,
            ),
          );
        } catch (_) {}
      }

      int size = 0;

      /// TRY GET FILE SIZE
      try {
        final file =
            await asset.file;

        if (file != null) {
          size =
              await file.length();
        }
      } catch (_) {}

      return MediaItem(
        asset: asset,
        thumbnail: thumb,
        isVideo: isVideo,
        isLivePhoto: false,
        fileSize: size,
        createdAt:
            asset.createDateTime,
        deviceName:
            asset.title,
      );
    } catch (e) {
      return null;
    }
  }
}