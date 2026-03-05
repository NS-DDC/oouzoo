import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/admob_service.dart';
import '../../../core/utils/constants.dart';
import '../../planet/controllers/planet_controller.dart';
import '../controllers/gacha_controller.dart';

class GachaScreen extends ConsumerWidget {
  const GachaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gacha = ref.watch(gachaProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('🎰 별자리 뽑기')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('✨', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 24),
            const Text(
              '매일 1회 무료 뽑기!\n추가 뽑기는 광고를 보거나\n별 조각으로 가능해요.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 32),
            // Free gacha button
            ElevatedButton.icon(
              onPressed: gacha.canUseFreeGacha
                  ? () => ref.read(gachaProvider.notifier).doFreeGacha()
                  : null,
              icon: const Icon(Icons.star),
              label: const Text('무료 뽑기 (1회)'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 48),
              ),
            ),
            const SizedBox(height: 12),
            // Ad gacha button
            OutlinedButton.icon(
              onPressed: () async {
                final ad = await AdmobService.loadRewardedAd();
                ad?.show(
                  onUserEarnedReward: (_, __) {
                    ref.read(gachaProvider.notifier).doAdGacha();
                  },
                );
              },
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('광고 보고 뽑기'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(200, 48),
              ),
            ),
            const SizedBox(height: 12),
            // Shard gacha button
            OutlinedButton.icon(
              onPressed: () =>
                  ref.read(gachaProvider.notifier).doShardGacha(ref),
              icon: const Text('⭐'),
              label: Text('별 조각 ${AppConstants.gachaCostInShards}개로 뽑기'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(200, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
