import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/item_model.dart';
import '../../../shared/theme/app_theme.dart';
import '../controllers/inventory_controller.dart';
import '../controllers/theme_controller.dart';

/// 행성 뷰 — 글로우, 궤도 위성, 장착 펫/데코 표시
class PlanetView extends ConsumerStatefulWidget {
  final int level; // 1–5
  final int mood; // 1–5

  const PlanetView({super.key, required this.level, required this.mood});

  @override
  ConsumerState<PlanetView> createState() => _PlanetViewState();
}

class _PlanetViewState extends ConsumerState<PlanetView>
    with TickerProviderStateMixin {
  static const _moods = ['😢', '😕', '😐', '😊', '😍'];

  late AnimationController _glowController;
  late AnimationController _orbitController;
  late AnimationController _petFloatController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _petFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _orbitController.dispose();
    _petFloatController.dispose();
    super.dispose();
  }

  Color _glowColor(int level) {
    switch (level) {
      case 1:
        return AppTheme.accentCyan;
      case 2:
        return AppTheme.accentPink;
      case 3:
        return AppTheme.starYellow;
      case 4:
        return AppTheme.nebulaPurple;
      case 5:
        return AppTheme.starYellow;
      default:
        return AppTheme.accentCyan;
    }
  }

  Color _moodGlowColor(int mood) {
    switch (mood) {
      case 1:
        return Colors.blueAccent;
      case 2:
        return AppTheme.nebulaPurple;
      case 3:
        return Colors.white;
      case 4:
        return AppTheme.accentPink;
      case 5:
        return AppTheme.starYellow;
      default:
        return Colors.white;
    }
  }

  List<String> _orbitAssets(int level) {
    switch (level) {
      case 2:
        return ['assets/pixel/moon.png'];
      case 3:
        return ['assets/pixel/moon.png', 'assets/pixel/asteroid.png'];
      case 4:
        return [
          'assets/pixel/moon.png',
          'assets/pixel/moon2.png',
          'assets/pixel/asteroid.png'
        ];
      case 5:
        return [
          'assets/pixel/moon.png',
          'assets/pixel/moon2.png',
          'assets/pixel/moon3.png',
          'assets/pixel/sun1.png'
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeAsync = ref.watch(themeProvider);
    final equippedAsync = ref.watch(equippedItemsProvider);

    return themeAsync.when(
      data: (theme) {
        final idx =
            (widget.level - 1).clamp(0, theme.planetAssets.length - 1);
        final asset = theme.planetAssets[idx];
        final glow = _glowColor(widget.level);
        final orbitItems = _orbitAssets(widget.level);

        final equipped = equippedAsync.valueOrNull ?? {};
        final equippedPet = equipped[ItemType.pet];
        final equippedDeco = equipped[ItemType.decoration];

        return SizedBox(
          width: 320,
          height: 320,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // ── 글로우 오라 ──
              AnimatedBuilder(
                animation: _glowController,
                builder: (_, __) {
                  final opacity = 0.15 + (_glowController.value * 0.25);
                  return Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: glow.withAlpha((opacity * 255).toInt()),
                          blurRadius: 40,
                          spreadRadius: 15,
                        ),
                        if (widget.level >= 5)
                          BoxShadow(
                            color: AppTheme.accentPink
                                .withAlpha((opacity * 180).toInt()),
                            blurRadius: 60,
                            spreadRadius: 8,
                          ),
                      ],
                    ),
                  );
                },
              ),

              // ── 궤도 위성 ──
              ...List.generate(orbitItems.length, (i) {
                final orbitRadius = 130.0 + (i * 15);
                final speed = 1.0 + (i * 0.3);
                final startOffset = i * (2 * pi / orbitItems.length);
                return AnimatedBuilder(
                  animation: _orbitController,
                  builder: (_, __) {
                    final angle =
                        (_orbitController.value * 2 * pi / speed) +
                            startOffset;
                    final dx = cos(angle) * orbitRadius;
                    final dy = sin(angle) * orbitRadius * 0.35;
                    return Transform.translate(
                      offset: Offset(dx, dy),
                      child: Image.asset(
                        orbitItems[i],
                        width: 28,
                        height: 28,
                        filterQuality: FilterQuality.none,
                        errorBuilder: (_, __, ___) =>
                            const Text('🌙', style: TextStyle(fontSize: 14)),
                      ),
                    );
                  },
                );
              }),

              // ── 행성 본체 ──
              Image.asset(
                asset,
                width: 240,
                height: 240,
                filterQuality: FilterQuality.none,
                errorBuilder: (_, __, ___) => _placeholder(),
              ),

              // ── 장착 데코 (좌상단) ──
              if (equippedDeco != null)
                Positioned(
                  top: 20,
                  left: 30,
                  child: AnimatedBuilder(
                    animation: _glowController,
                    builder: (_, __) => Opacity(
                      opacity: 0.7 + (_glowController.value * 0.3),
                      child: Image.asset(
                        'assets/images/items/${equippedDeco.itemId}.png',
                        width: 48,
                        height: 48,
                        filterQuality: FilterQuality.none,
                        errorBuilder: (_, __, ___) =>
                            const Text('✨', style: TextStyle(fontSize: 28)),
                      ),
                    ),
                  ),
                ),

              // ── 장착 펫 (우하단, 떠다니기) ──
              if (equippedPet != null)
                Positioned(
                  right: 15,
                  bottom: 40,
                  child: AnimatedBuilder(
                    animation: _petFloatController,
                    builder: (_, __) {
                      final dy = -4 + (_petFloatController.value * 8);
                      return Transform.translate(
                        offset: Offset(0, dy),
                        child: Image.asset(
                          'assets/images/pets/${equippedPet.itemId}.png',
                          width: 64,
                          height: 64,
                          filterQuality: FilterQuality.none,
                          errorBuilder: (_, __, ___) => const Text('🐾',
                              style: TextStyle(fontSize: 32)),
                        ),
                      );
                    },
                  ),
                ),

              // ── 기분 버블 (하단) ──
              Positioned(
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _moodGlowColor(widget.mood).withAlpha(180),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _moodGlowColor(widget.mood).withAlpha(60),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Text(
                    _moods[(widget.mood - 1).clamp(0, 4)],
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        width: 320,
        height: 320,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => _placeholder(),
    );
  }

  static Widget _placeholder() => Container(
        width: 240,
        height: 240,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF3D1A6E),
        ),
        child: const Center(
          child: Text('🪐', style: TextStyle(fontSize: 80)),
        ),
      );
}
