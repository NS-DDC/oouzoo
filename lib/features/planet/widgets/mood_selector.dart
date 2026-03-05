import 'package:flutter/material.dart';

/// 기분 선택 위젯 (1–5 이모지)
class MoodSelector extends StatelessWidget {
  final int currentMood;
  final ValueChanged<int> onMoodChanged;

  static const _moods = ['😢', '😕', '😐', '😊', '😍'];

  const MoodSelector({
    super.key,
    required this.currentMood,
    required this.onMoodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final mood = i + 1;
        final selected = mood == currentMood;
        return GestureDetector(
          onTap: () => onMoodChanged(mood),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected
                  ? const Color(0xFF3D1A6E)
                  : Colors.transparent,
              border: selected
                  ? Border.all(color: const Color(0xFFFFD700), width: 2)
                  : null,
            ),
            child: Text(
              _moods[i],
              style: TextStyle(fontSize: selected ? 28 : 22),
            ),
          ),
        );
      }),
    );
  }
}
