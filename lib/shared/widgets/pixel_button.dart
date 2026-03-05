import 'package:flutter/material.dart';

/// 도트 아트 감성의 픽셀 버튼
class PixelButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final double fontSize;

  const PixelButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color = const Color(0xFFFFD700),
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: onPressed != null ? color : Colors.grey,
          // Pixel border (2px offset shadow)
          boxShadow: onPressed != null
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    offset: const Offset(3, 3),
                    blurRadius: 0,
                  ),
                  const BoxShadow(
                    color: Colors.black45,
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.black,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: 'DotGothic16',
          ),
        ),
      ),
    );
  }
}
