import 'package:flutter/material.dart';

import '../../../core/models/planet_model.dart';

/// 행성 레벨 & 별 조각 진행도 바
class LevelProgressBar extends StatelessWidget {
  final int level;
  final int starShards;

  const LevelProgressBar({
    super.key,
    required this.level,
    required this.starShards,
  });

  @override
  Widget build(BuildContext context) {
    final isMax = level >= 5;
    final threshold = isMax
        ? PlanetModel.levelThresholds.last
        : PlanetModel.levelThresholds[level - 1];
    final progress = isMax ? 1.0 : (starShards / threshold).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lv.$level',
                style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
              Text(
                isMax ? 'MAX ✨' : '$starShards / $threshold ⭐',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
            ),
          ),
        ],
      ),
    );
  }
}
