import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  String? _revealedItem;
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
      _revealedItem = null;
    });
    _revealController.reset();
    _spinController.repeat();

    await action();

    // Wait for spin to feel dramatic
    await Future.delayed(const Duration(milliseconds: 1200));
    _spinController.stop();

    final result = ref.read(gachaProvider).value?.lastResult;
    setState(() {
      _isSpinning = false;
      _revealedItem = result;
    });
    _revealController.forward();
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
                height: 200,
                width: 200,
                child: _revealedItem != null
                    ? _buildReveal()
                    : _buildSpinOrIdle(),
              ),
              const SizedBox(height: 32),

              // ── 설명 ──
              Text(
                _revealedItem != null
                    ? '${_getItemName(_revealedItem!)} 획득!'
                    : _isSpinning
                        ? '뽑는 중...'
                        : '매일 1회 무료 뽑기!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _revealedItem != null
                      ? AppTheme.starYellow
                      : Colors.white70,
                  fontSize: 16,
                  fontWeight: _revealedItem != null
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              if (_revealedItem != null) ...[
                const SizedBox(height: 4),
                Text(
                  _getRarity(_revealedItem!),
                  style: TextStyle(
                    color: _getRarityColor(_revealedItem!),
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 32),

              // ── 뽑기 버튼들 ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: (gacha.value?.canUseFreeGacha ?? false) &&
                          !_isSpinning
                      ? () => _doGacha(
                          () => ref.read(gachaProvider.notifier).doFreeGacha())
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
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('광고를 불러올 수 없어요')),
                              );
                            }
                            return;
                          }
                          ad.show(
                            onUserEarnedReward: (_, __) => _doGacha(
                                () => ref
                                    .read(gachaProvider.notifier)
                                    .doAdGacha()),
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
                      : () => _doGacha(
                          () => ref.read(gachaProvider.notifier).doShardGacha()),
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
        final angle = _spinController.value * pi * 6; // 3 full rotations
        return Transform.rotate(
          angle: _isSpinning ? angle : 0,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.nebulaPurple,
                  AppTheme.deepSpace,
                ],
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
              child: Text('?', style: TextStyle(fontSize: 64, color: AppTheme.starYellow)),
            ),
          ),
        );
      },
    );
  }

  // ── 결과 리빌 ──
  Widget _buildReveal() {
    return AnimatedBuilder(
      animation: _revealController,
      builder: (_, __) => Transform.scale(
        scale: _scaleAnim.value,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                _getRarityColor(_revealedItem!).withAlpha(100),
                AppTheme.deepSpace,
              ],
            ),
            border: Border.all(
              color: _getRarityColor(_revealedItem!),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _getRarityColor(_revealedItem!)
                    .withAlpha((_glowAnim.value * 150).toInt()),
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
                  'assets/images/items/${_revealedItem!}.png',
                  width: 64,
                  height: 64,
                  filterQuality: FilterQuality.none,
                  errorBuilder: (_, __, ___) => Text(
                    _getItemEmoji(_revealedItem!),
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getItemName(_revealedItem!),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getItemName(String id) {
    switch (id) {
      case 'rare_background':
        return '레어 배경';
      case 'uncommon_decoration':
        return '장식 아이템';
      case 'common_sticker':
        return '스티커';
      default:
        return id;
    }
  }

  String _getItemEmoji(String id) {
    switch (id) {
      case 'rare_background':
        return '🌌';
      case 'uncommon_decoration':
        return '⭐';
      case 'common_sticker':
        return '✨';
      default:
        return '🎁';
    }
  }

  String _getRarity(String id) {
    switch (id) {
      case 'rare_background':
        return '★★★ 레어';
      case 'uncommon_decoration':
        return '★★ 언커먼';
      default:
        return '★ 커먼';
    }
  }

  Color _getRarityColor(String id) {
    switch (id) {
      case 'rare_background':
        return AppTheme.starYellow;
      case 'uncommon_decoration':
        return AppTheme.accentCyan;
      default:
        return AppTheme.accentPink;
    }
  }
}
