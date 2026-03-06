import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/database/database_helper.dart';
import 'core/services/fcm_service.dart';
import 'core/services/admob_service.dart';
import 'core/services/iap_service.dart';
import 'features/home/screens/home_screen.dart';
import 'features/pairing/controllers/user_profile_controller.dart';
import 'features/pairing/screens/pairing_screen.dart';
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
      home: const SpaceBackground(child: _AppRouter()),
    );
  }
}

/// Routes to PairingScreen or HomeScreen based on user profile state.
class _AppRouter extends ConsumerWidget {
  const _AppRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      data: (profile) {
        if (profile == null) {
          // No profile yet — show onboarding + pairing
          return const PairingScreen();
        }
        // Profile exists — go to home (pairing is optional)
        return const HomeScreen();
      },
      loading: () => const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🪐', style: TextStyle(fontSize: 48)),
              SizedBox(height: 16),
              CircularProgressIndicator(color: AppTheme.starYellow),
            ],
          ),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: Text('$e')),
      ),
    );
  }
}
