import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';

/// Xin quyền thư viện ảnh (Android / iOS). Chỉ gọi khi sắp load ảnh thật bằng photo_manager.
Future<PermissionState> requestPhotoLibraryAccess() async {
  try {
    return await PhotoManager.requestPermissionExtend();
  } catch (e, st) {
    debugPrint('requestPhotoLibraryAccess: $e\n$st');
    return PermissionState.denied;
  }
}
