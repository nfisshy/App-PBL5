import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/external_links.dart';

Future<void> launchExternalUrl(Uri uri) async {
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && kDebugMode) {
    debugPrint('Could not launch $uri');
  }
}

Future<void> launchFaq() => launchExternalUrl(Uri.parse(ExternalLinks.faq));
Future<void> launchInstagram() =>
    launchExternalUrl(Uri.parse(ExternalLinks.instagram));
Future<void> launchTerms() => launchExternalUrl(Uri.parse(ExternalLinks.terms));
Future<void> launchPrivacy() =>
    launchExternalUrl(Uri.parse(ExternalLinks.privacy));

Future<void> launchRateUs() async {
  final ios = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  final uri = Uri.parse(
    ios ? ExternalLinks.rateUsIos : ExternalLinks.rateUsAndroid,
  );
  await launchExternalUrl(uri);
}
