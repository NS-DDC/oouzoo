import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/admob_service.dart';
import '../../../core/utils/constants.dart';
import '../controllers/planet_controller.dart';

class BoostScreen extends ConsumerStatefulWidget {
  const BoostScreen({super.key});

  @override
  ConsumerState<BoostScreen> createState() => _BoostScreenState();
}

class _BoostScreenState extends ConsumerState<BoostScreen> {
  static const _prefKey = 'boost_used_date';
  bool _boostUsed = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkBoostUsed();
  }

  Future<void> _checkBoostUsed() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString(_prefKey) ?? '';
    final today = DateTime.now().toIso8601String().substring(0, 10);
    setState(() {
      _boostUsed = lastDate == today;
      _loading = false;
    });
  }

  Future<void> _applyBoost() async {
    final planet = ref.read(planetProvider).value;
    if (planet == null) return;

    // 오늘 획득한 별 조각을 2배로 — 여기서는 현재 보유량의 일부를 보너스로 지급
    // 실제 구현 시 오늘 하루 획득량을 별도 트래킹해서 정확히 2배 처리 가능
    final bonus = AppConstants.shardsPerDailyLogin * (AppConstants.shardsBoostMultiplier - 1);
    await ref.read(planetProvider.notifier).addShards(bonus);

    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await prefs.setString(_prefKey, today);

    setState(() => _boostUsed = true);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⭐ 별 조각 +$bonus 획득! 오늘 하루 2배 부스트!'),
          backgroundColor: const Color(0xFF3D1A6E),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('⭐ 별 조각 2배 부스트')),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 80)),
                  const SizedBox(height: 24),
                  Text(
                    _boostUsed
                        ? '오늘 이미 부스트를 사용했어요!\n내일 다시 도전하세요 🌙'
                        : '광고를 보고\n오늘 하루 별 조각을 2배로 받아요!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, height: 1.6),
                  ),
                  const SizedBox(height: 32),
                  if (!_boostUsed)
                    ElevatedButton.icon(
                      onPressed: () async {
                        final ad = await AdmobService.loadRewardedAd();
                        if (ad == null) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('광고를 불러올 수 없어요. 잠시 후 다시 시도해주세요.')),
                            );
                          }
                          return;
                        }
                        ad.show(
                          onUserEarnedReward: (_, __) => _applyBoost(),
                        );
                      },
                      icon: const Icon(Icons.play_circle_outline),
                      label: const Text('광고 보고 2배 받기'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(220, 52),
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
