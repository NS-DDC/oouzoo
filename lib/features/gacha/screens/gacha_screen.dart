import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/gacha_pool.dart';
import '../../../core/services/admob_service.dart';
import '../../../core/utils/constants.dart';
import '../../../shared/theme/app_theme.dart';
import '../../planet/controllers/planet_controller.dart';
import '../controllers/gacha_controller.dart';

class GachaScreen extends ConsumerStatefulWidget {
  const GachaScreen({super.key});

  @override
  ConsumerState<GachaScreen> createState() => _GachaScreenState();
}

class _GachaScreenState extends ConsumerState<GachaScreen>
    with TickerProviderStateMixin {
  bool _isSpinning = false;
  GachaResult? _result;
  late AnimationController _spinController;
  late AnimationController _revealController;
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _revealController, curve: Curves.elasticOut),
    );
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _revealController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  Future<void> _doGacha(Future<void> Function() action) async {
    if (_isSpinning) return;
    setState(() {
      _isSpinning = true;
      _result = null;
    });
    _revealController.reset();
    _spinController.repeat();

    await action();

    // 레어일수록 더 오래 스핀
    final result = ref.read(gachaProvider).value?.lastResult;
    final spinMs = result?.item.rarity == GachaRarity.rare ? 2000 : 1200;
    await Future.delayed(Duration(milliseconds: spinMs));
    _spinController.stop();

    setState(() {
      _isSpinning = false;
      _result = result;
    });
    _revealController.forward();
  }

  Color _rarityColor(GachaRarity rarity) {
    switch (rarity) {
      case GachaRarity.rare:
        return AppTheme.starYellow;
      case GachaRarity.uncommon:
        return AppTheme.accentCyan;
      case GachaRarity.common:
        return AppTheme.accentPink;
    }
  }

  String _rarityLabel(GachaRarity rarity) {
    switch (rarity) {
      case GachaRarity.rare:
        return '★★★ 레어';
      case GachaRarity.uncommon:
        return '★★ 언커먼';
      case GachaRarity.common:
        return '★ 커먼';
    }
  }

  String _typeLabel(GachaItem item) {
    switch (item.type.name) {
      case 'pet':
        return '🐾 펫';
      case 'decoration':
        return '✨ 장식';
      case 'background':
        return '🌌 배경';
      default:
        return item.type.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gacha = ref.watch(gachaProvider);
    final planet = ref.watch(planetProvider);
    final shards = planet.valueOrNull?.starShards ?? 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('별자리 뽑기'),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── 뽑기 머신 영역 ──
              SizedBox(
                height: 220,
                width: 220,
                child: _result != null ? _buildReveal() : _buildSpinOrIdle(),
              ),
              const SizedBox(height: 24),

              // ── 결과 텍스트 ──
              if (_result != null) ...[
                Text(
                  _result!.isDuplicate
                      ? '이미 보유! 별 조각 +${_result!.bonusShards} ⭐'
                      : '${_result!.item.name} 획득!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _result!.isDuplicate
                        ? AppTheme.accentCyan
                        : AppTheme.starYellow,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _typeLabel(_result!.item),
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _rarityLabel(_result!.item.rarity),
                      style: TextStyle(
                        color: _rarityColor(_result!.item.rarity),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ] else
                Text(
                  _isSpinning ? '뽑는 중...' : '매일 1회 무료 뽑기!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),

              const SizedBox(height: 32),

              // ── 뽑기 버튼들 ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed:
                      (gacha.value?.canUseFreeGacha ?? false) && !_isSpinning
                          ? () => _doGacha(() =>
                              ref.read(gachaProvider.notifier).doFreeGacha())
                          : null,
                  icon: const Icon(Icons.star),
                  label: const Text('무료 뽑기 (1회)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.starYellow,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.white12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _isSpinning
                      ? null
                      : () async {
                          final ad = await AdmobService.loadRewardedAd();
                          if (ad == null) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('광고를 불러올 수 없어요')),
                              );
                            }
                            return;
                          }
                          ad.show(
                            onUserEarnedReward: (_, __) => _doGacha(() =>
                                ref.read(gachaProvider.notifier).doAdGacha()),
                          );
                        },
                  icon: const Icon(Icons.play_circle_outline),
                  label: const Text('광고 보고 뽑기'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _isSpinning ||
                          shards < AppConstants.gachaCostInShards
                      ? null
                      : () => _doGacha(() =>
                          ref.read(gachaProvider.notifier).doShardGacha()),
                  icon: const Text('⭐'),
                  label: Text(
                      '별 조각 ${AppConstants.gachaCostInShards}개 (보유: $shards)'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 스핀 / 대기 상태 ──
  Widget _buildSpinOrIdle() {
    return AnimatedBuilder(
      animation: _spinController,
      builder: (_, __) {
        final angle = _spinController.value * pi * 6;
        return Transform.rotate(
          angle: _isSpinning ? angle : 0,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [AppTheme.nebulaPurple, AppTheme.deepSpace],
              ),
              border: Border.all(
                color: _isSpinning
                    ? AppTheme.starYellow
                    : AppTheme.starYellow.withAlpha(80),
                width: _isSpinning ? 3 : 1.5,
              ),
              boxShadow: _isSpinning
                  ? [
                      BoxShadow(
                        color: AppTheme.starYellow.withAlpha(80),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ]
                  : null,
            ),
            child: const Center(
              child: Text('?',
                  style:
                      TextStyle(fontSize: 64, color: AppTheme.starYellow)),
            ),
          ),
        );
      },
    );
  }

  // ── 결과 리빌 ──
  Widget _buildReveal() {
    final item = _result!.item;
    final color = _rarityColor(item.rarity);

    return AnimatedBuilder(
      animation: _revealController,
      builder: (_, __) => Transform.scale(
        scale: _scaleAnim.value,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color.withAlpha(60), AppTheme.deepSpace],
            ),
            border: Border.all(color: color, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha((_glowAnim.value * 150).toInt()),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  item.assetPath,
                  width: 80,
                  height: 80,
                  filterQuality: FilterQuality.none,
                  errorBuilder: (_, __, ___) => Text(
                    item.type.name == 'pet' ? '🐾' : '✨',
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_result!.isDuplicate) ...[
                  const SizedBox(height: 4),
                  Text(
                    '중복! +${_result!.bonusShards}⭐',
                    style: const TextStyle(
                      color: AppTheme.accentCyan,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
