import '../models/swipe_photo_item.dart';

/// Ảnh demo — có thể thay bằng [PhotoManager.getAssetPathList] sau khi được quyền.
final List<SwipePhotoItem> kMockSwipePhotos = [
  SwipePhotoItem(
    id: 'm1',
    previewUrl: 'https://picsum.photos/id/237/900/1200',
    createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
    byteSize: 1843200,
    pixelWidth: 900,
    pixelHeight: 1200,
    title: 'Chó trên cỏ',
  ),
  SwipePhotoItem(
    id: 'm2',
    previewUrl: 'https://picsum.photos/id/1003/900/1300',
    createdAt: DateTime.now().subtract(const Duration(hours: 5, minutes: 3)),
    byteSize: 2105344,
    pixelWidth: 900,
    pixelHeight: 1300,
    title: 'Gấu',
  ),
  SwipePhotoItem(
    id: 'm3',
    previewUrl: 'https://picsum.photos/id/1062/950/1260',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    byteSize: 1536000,
    pixelWidth: 950,
    pixelHeight: 1260,
  ),
  SwipePhotoItem(
    id: 'm4',
    previewUrl: 'https://picsum.photos/id/1025/920/1380',
    createdAt: DateTime.now().subtract(const Duration(days: 7, hours: 2)),
    byteSize: 2654208,
    pixelWidth: 920,
    pixelHeight: 1380,
  ),
  SwipePhotoItem(
    id: 'm5',
    previewUrl: 'https://picsum.photos/id/1035/930/1240',
    createdAt: DateTime.now().subtract(const Duration(days: 31)),
    byteSize: 998400,
    pixelWidth: 930,
    pixelHeight: 1240,
  ),
];
