import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../planet/screens/planet_screen.dart';
import '../../daily_question/screens/daily_question_screen.dart';
import '../../messages/screens/messages_screen.dart';
import '../../diary/screens/diary_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../pairing/controllers/user_profile_controller.dart';
import '../../pairing/screens/pairing_screen.dart';
import '../widgets/anniversary_badge.dart';
import '../widgets/star_shards_indicator.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  static const _screens = [
    PlanetScreen(),
    DailyQuestionScreen(),
    MessagesScreen(),
    DiaryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final isPaired = profile?.isPaired ?? false;

    return Scaffold(
      body: Stack(
        children: [
          _screens[_selectedIndex],

          // 커플 연동 상태 배너 (미연동 시)
          if (!isPaired)
            Positioned(
              top: 44,
              left: 16,
              right: 16,
              child: _PairingBanner(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PairingScreen()),
                ),
              ),
            )
          else ...[
            // D-Day badge overlay (top-right)
            const Positioned(
              top: 48,
              right: 16,
              child: AnniversaryBadge(),
            ),
            // Star shards (top-left)
            const Positioned(
              top: 48,
              left: 16,
              child: StarShardsIndicator(),
            ),
          ],
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        backgroundColor: const Color(0xFF12122A),
        indicatorColor: AppTheme.nebulaPurple.withAlpha(100),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.public_outlined),
            selectedIcon: Icon(Icons.public),
            label: '우리 별',
          ),
          NavigationDestination(
            icon: Icon(Icons.question_answer_outlined),
            selectedIcon: Icon(Icons.question_answer),
            label: '오늘의 질문',
          ),
          NavigationDestination(
            icon: Icon(Icons.mail_outline),
            selectedIcon: Icon(Icons.mail),
            label: '웜홀',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: '일기',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
      ),
    );
  }
}

/// 커플 미연동 시 상단에 표시되는 연결 유도 배너
class _PairingBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _PairingBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.accentPink.withAlpha(200),
              AppTheme.nebulaPurple.withAlpha(200),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.accentPink.withAlpha(100)),
        ),
        child: const Row(
          children: [
            Text('💫', style: TextStyle(fontSize: 20)),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '커플 연동이 필요해요!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '터치하여 상대방과 우주를 연결하세요',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 14),
          ],
        ),
      ),
    );
  }
}
