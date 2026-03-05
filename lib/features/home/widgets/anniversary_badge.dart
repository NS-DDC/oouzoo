import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../anniversary/controllers/anniversary_controller.dart';

/// 메인 화면 상단에 표시되는 D+Day / D-Day 배지
class AnniversaryBadge extends ConsumerWidget {
  const AnniversaryBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anniversary = ref.watch(coupleStartAnniversaryProvider);

    return anniversary.when(
      data: (ann) {
        if (ann == null) return const SizedBox.shrink();
        final days = DateTime.now().difference(ann.date).inDays + 1;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '✨ D+$days',
            style: const TextStyle(color: Color(0xFFFFD700), fontSize: 12),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
