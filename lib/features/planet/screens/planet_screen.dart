import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/planet_controller.dart';
import '../widgets/planet_view.dart';
import '../widgets/mood_selector.dart';
import '../../gacha/screens/gacha_screen.dart';

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
            const Spacer(),
            // Gacha button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GachaScreen()),
                ),
                icon: const Text('🎰', style: TextStyle(fontSize: 20)),
                label: const Text('별자리 뽑기'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
      ),
    );
  }
}
