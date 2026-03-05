import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../planet/controllers/planet_controller.dart';

class StarShardsIndicator extends ConsumerWidget {
  const StarShardsIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planet = ref.watch(planetProvider);
    return planet.when(
      data: (p) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⭐', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Text(
              '${p?.starShards ?? 0}',
              style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
