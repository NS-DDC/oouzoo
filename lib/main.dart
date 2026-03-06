import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/database/database_helper.dart';
import 'core/services/fcm_service.dart';
import 'core/services/admob_service.dart';
import 'core/services/iap_service.dart';
import 'features/home/screens/home_screen.dart';
import 'shared/theme/app_theme.dart';
import 'shared/widgets/space_background.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('[Firebase] init error: $e');
  }

  await DatabaseHelper.instance.database; // init SQLite
  await AdmobService.initialize();

  try {
    await FcmService.initialize();
  } catch (e) {
    debugPrint('[FCM] init error: $e');
  }

  await IapService.instance.initialize();

  runApp(const ProviderScope(child: OouzooApp()));
}

class OouzooApp extends StatelessWidget {
  const OouzooApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OOUZOO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SpaceBackground(child: HomeScreen()),
    );
  }
}
