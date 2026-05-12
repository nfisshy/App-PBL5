import 'dart:typed_data';

/// Một ảnh trong hàng chờ swipe (mock hoặc map từ [AssetEntity] sau này).
class SwipePhotoItem {
  const SwipePhotoItem({
    required this.id,
    required this.previewUrl,
    required this.createdAt,
    required this.byteSize,
    required this.pixelWidth,
    required this.pixelHeight,
    this.title,
    this.thumbnailBytes,
  });

  final String id;

  /// URL hoặc `file://` — mock đang dùng network.
  final String previewUrl;
  final DateTime createdAt;
  final int byteSize;
  final int pixelWidth;
  final int pixelHeight;
  final String? title;

  /// Cho future: bytes từ gallery thay cho URL (optional).
  final Uint8List? thumbnailBytes;

  String formattedSize() {
    if (byteSize < 1024) return '$byteSize B';
    final kb = byteSize / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024;
    if (mb < 1024) return '${mb.toStringAsFixed(1)} MB';
    final gb = mb / 1024;
    return '${gb.toStringAsFixed(2)} GB';
  }
}
