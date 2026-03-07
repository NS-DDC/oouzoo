import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/theme_controller.dart';

/// 현재 테마의 레벨별 행성 픽셀아트를 표시.
class PlanetView extends ConsumerWidget {
  final int level; // 1–5
  final int mood; // 1–5

  const PlanetView({super.key, required this.level, required this.mood});

  static const _moods = ['😢', '😕', '😐', '😊', '😍'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeAsync = ref.watch(themeProvider);

    return themeAsync.when(
      data: (theme) {
        final idx = (level - 1).clamp(0, theme.planetAssets.length - 1);
        final asset = theme.planetAssets[idx];

        return SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 행성 픽셀 아트 (crisp rendering)
              Image.asset(
                asset,
                width: 180,
                height: 180,
                filterQuality: FilterQuality.none,
                errorBuilder: (_, __, ___) => _placeholder(),
              ),
              // 기분 이모지 버블 (하단)
              Positioned(
                bottom: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFFFFD700), width: 1),
                  ),
                  child: Text(
                    _moods[(mood - 1).clamp(0, 4)],
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        width: 220,
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => _placeholder(),
    );
  }

  static Widget _placeholder() => Container(
        width: 180,
        height: 180,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF3D1A6E),
        ),
        child: const Center(
          child: Text('🪐', style: TextStyle(fontSize: 80)),
        ),
      );
}
