import 'package:flutter/material.dart';

/// 레이어 방식으로 도트 에셋을 중첩하여 행성을 표현.
/// 에셋은 Kenney.nl 등 CC0 라이선스 소스 사용.
class PlanetView extends StatelessWidget {
  final int level;  // 1–5
  final int mood;   // 1–5

  const PlanetView({super.key, required this.level, required this.mood});

  String get _basePlanet => 'assets/images/planets/planet_lv$level.png';
  String get _moodOverlay => 'assets/images/planets/mood_$mood.png';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Base planet sprite
          Image.asset(
            _basePlanet,
            width: 200,
            height: 200,
            filterQuality: FilterQuality.none, // keep pixel-art crisp
            errorBuilder: (_, __, ___) => _placeholder(),
          ),
          // Mood overlay
          Image.asset(
            _moodOverlay,
            width: 200,
            height: 200,
            filterQuality: FilterQuality.none,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 200,
        height: 200,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF3D1A6E),
        ),
        child: const Center(
          child: Text('🪐', style: TextStyle(fontSize: 80)),
        ),
      );
}
