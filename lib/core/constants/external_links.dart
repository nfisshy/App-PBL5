/// Thay các URL placeholder bằng link thật khi publish.
abstract final class ExternalLinks {
  static const faq = 'https://example.com/faq'; // FAQ
  static const instagram = 'https://www.instagram.com/';
  static const terms = 'https://example.com/terms';
  static const privacy = 'https://example.com/privacy';

  /// Deep link cửa hàng — cập nhật theo app id của bạn.
  static const rateUsAndroid =
      'https://play.google.com/store/apps/details?id=com.example.photo_cleaner';
  static const rateUsIos =
      'https://apps.apple.com/app/id0000000000'; // placeholder
}
