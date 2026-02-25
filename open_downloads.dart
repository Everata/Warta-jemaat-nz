import 'dart:io' show Platform;
import 'package:android_intent_plus/android_intent.dart';

Future<void> openDownloadsApp() async {
  if (!Platform.isAndroid) return;
  const intent = AndroidIntent(action: 'android.intent.action.VIEW_DOWNLOADS');
  await intent.launch();
}
