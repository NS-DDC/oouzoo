import 'dart:math';
import 'package:flutter/material.dart';

/// 메인 화면 배경 — 별이 반짝이는 우주
/// 도트 에셋이 없을 때도 코드로 배경 제공
class SpaceBackground extends StatefulWidget {
  final Widget child;
  final int starCount;

  const SpaceBackground({
    super.key,
    required this.child,
    this.starCount = 80,
  });

  @override
  State<SpaceBackground> createState() => _SpaceBackgroundState();
}

class _SpaceBackgroundState extends State<SpaceBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Star> _stars;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    final rng = Random();
    _stars = List.generate(
      widget.starCount,
      (_) => _Star(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        size: rng.nextDouble() * 2.5 + 0.5,
        opacity: rng.nextDouble() * 0.7 + 0.3,
        phase: rng.nextDouble(), // twinkle phase offset
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) => CustomPaint(
        painter: _StarPainter(_stars, _controller.value),
        child: child,
      ),
      child: widget.child,
    );
  }
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

class _StarPainter extends CustomPainter {
  final List<_Star> stars;
  final double t;

  _StarPainter(this.stars, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    // Deep space gradient
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A0A1A), Color(0xFF1A0A2E)],
        ).createShader(rect),
    );

    // Stars
    final paint = Paint()..style = PaintingStyle.fill;
    for (final star in stars) {
      final twinkle = (sin((t + star.phase) * pi * 2) + 1) / 2;
      final alpha = (star.opacity * (0.4 + 0.6 * twinkle) * 255).toInt();
      paint.color = Color.fromARGB(alpha, 255, 255, 240);
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.t != t;
}
