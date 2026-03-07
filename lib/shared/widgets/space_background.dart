import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/planet/controllers/theme_controller.dart';

/// 메인 화면 배경 — 픽셀 아트 우주 타일 배경 + 반짝이는 별 오버레이
class SpaceBackground extends ConsumerStatefulWidget {
  final Widget child;

  const SpaceBackground({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<SpaceBackground> createState() => _SpaceBackgroundState();
}

class _SpaceBackgroundState extends ConsumerState<SpaceBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _twinkle;
  late List<_Star> _stars;

  @override
  void initState() {
    super.initState();
    _twinkle = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    final rng = Random();
    _stars = List.generate(
      40,
      (_) => _Star(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        size: rng.nextDouble() * 2 + 0.5,
        opacity: rng.nextDouble() * 0.5 + 0.2,
        phase: rng.nextDouble(),
      ),
    );
  }

  @override
  void dispose() {
    _twinkle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeAsync = ref.watch(themeProvider);
    final bgAsset = themeAsync.valueOrNull?.backgroundAsset;

    return Stack(
      children: [
        // 픽셀 아트 타일 배경 (테마 기반)
        if (bgAsset != null)
          Positioned.fill(
            child: Image.asset(
              bgAsset,
              repeat: ImageRepeat.repeat,
              filterQuality: FilterQuality.none,
              errorBuilder: (_, __, ___) => _gradientFallback(),
            ),
          )
        else
          Positioned.fill(child: _gradientFallback()),

        // 반짝이는 별 오버레이
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _twinkle,
            builder: (_, __) => CustomPaint(
              painter: _TwinklePainter(_stars, _twinkle.value),
            ),
          ),
        ),

        // 실제 컨텐츠
        widget.child,
      ],
    );
  }

  Widget _gradientFallback() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A1A), Color(0xFF1A0A2E)],
          ),
        ),
      );
}

class _Star {
  final double x, y, size, opacity, phase;
  const _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.phase,
  });
}

class _TwinklePainter extends CustomPainter {
  final List<_Star> stars;
  final double t;
  _TwinklePainter(this.stars, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final star in stars) {
      final twinkle = (sin((t + star.phase) * pi * 2) + 1) / 2;
      final alpha = (star.opacity * (0.3 + 0.7 * twinkle) * 255).toInt();
      paint.color = Color.fromARGB(alpha, 255, 255, 230);
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_TwinklePainter old) => old.t != t;
}
