import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/constants/app_constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final isDesktop = !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux);

  if (isDesktop) {
    debugPrint(
        '${AppConstants.appName} v${AppConstants.appVersion} — Desktop mode');
  }

  runApp(
    const ProviderScope(
      child: FeedGeneratorApp(),
    ),
  );
}
