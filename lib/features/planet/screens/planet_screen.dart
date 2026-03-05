import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/planet_controller.dart';
import '../widgets/planet_view.dart';
import '../widgets/mood_selector.dart';
import '../widgets/level_progress_bar.dart';
import '../../gacha/screens/gacha_screen.dart';
import 'inventory_screen.dart';
import 'boost_screen.dart';

class PlanetScreen extends ConsumerWidget {
  const PlanetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planet = ref.watch(planetProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: planet.when(
        data: (p) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Planet pixel art view
            PlanetView(level: p?.level ?? 1, mood: p?.mood ?? 3),
            const SizedBox(height: 24),
            // Mood selector
            MoodSelector(
              currentMood: p?.mood ?? 3,
              onMoodChanged: (mood) {
                ref.read(planetProvider.notifier).updateMood(mood);
              },
            ),
            const SizedBox(height: 12),
            // Level progress bar
            LevelProgressBar(
              level: p?.level ?? 1,
              starShards: p?.starShards ?? 0,
            ),
            const Spacer(),
            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const GachaScreen())),
                      icon: const Text('🎰'),
                      label: const Text('뽑기'),
                      style: ElevatedButton.styleFrom(minimumSize: const Size(0, 48)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const InventoryScreen())),
                      icon: const Text('🎒'),
                      label: const Text('꾸미기'),
                      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const BoostScreen())),
                      icon: const Text('⭐'),
                      label: const Text('2배'),
                      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
      ),
    );
  }
}
