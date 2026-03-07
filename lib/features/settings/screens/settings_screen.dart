import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/models/theme_model.dart';
import '../../../core/services/admob_service.dart';
import '../../../core/services/iap_service.dart';
import '../../../core/utils/constants.dart';
import '../../../shared/theme/app_theme.dart';
import '../../backup/screens/backup_screen.dart';
import '../../anniversary/screens/anniversary_screen.dart';
import '../../planet/controllers/theme_controller.dart';
import '../controllers/notification_settings_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  BannerAd? _bannerAd;
  bool _bannerLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner() {
    _bannerAd = AdmobService.createBannerAd()
      ..load().then((_) {
        if (mounted) setState(() => _bannerLoaded = true);
      });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _buyAdFree() async {
    final products = await IapService.instance.loadProducts();
    final adFree = products.where(
      (p) => p.id == AppConstants.productAdFree,
    );
    if (adFree.isNotEmpty) {
      await IapService.instance.buyProduct(adFree.first);
    }
  }

  Future<void> _showShardPackages() async {
    final products = await IapService.instance.loadProducts();
    final shardProducts = products.where(
      (p) =>
          p.id == AppConstants.productShards100 ||
          p.id == AppConstants.productShards500,
    ).toList();

    if (!mounted || shardProducts.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF12122A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '별 조각 패키지',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...shardProducts.map((product) => ListTile(
                  leading: const Text('⭐', style: TextStyle(fontSize: 22)),
                  title: Text(
                    product.title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    product.price,
                    style: const TextStyle(color: Color(0xFFFFD700)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    IapService.instance.buyConsumable(product);
                  },
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _changeNotificationTime() async {
    final currentTime = ref.read(notificationTimeProvider).value ??
        const TimeOfDay(hour: 20, minute: 0);

    final picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
      helpText: '매일 질문 알림 시간',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accentCyan,
              surface: Color(0xFF1E1E3A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      await ref.read(notificationTimeProvider.notifier).setTime(picked);
    }
  }

  void _showThemeSelector() {
    final currentTheme = ref.read(themeProvider).value;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF12122A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.85,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '행성 테마',
                style: TextStyle(
                  color: AppTheme.moonWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '우리 별의 모습을 바꿔보세요',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: allThemes.length,
                  itemBuilder: (_, i) {
                    final theme = allThemes[i];
                    final isSelected = theme.id == (currentTheme?.id ?? 'default');
                    return _ThemeCard(
                      theme: theme,
                      isSelected: isSelected,
                      onTap: () async {
                        if (theme.isPremium) {
                          final owned = await ref
                              .read(themeProvider.notifier)
                              .isOwned(theme);
                          if (!owned) {
                            _buyTheme(theme);
                            return;
                          }
                        }
                        await ref
                            .read(themeProvider.notifier)
                            .selectTheme(theme.id);
                        if (context.mounted) Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _buyTheme(PlanetTheme theme) async {
    if (theme.iapProductId == null) return;

    final products = await IapService.instance.loadProducts();
    final product = products.where((p) => p.id == theme.iapProductId);
    if (product.isNotEmpty) {
      await IapService.instance.buyProduct(product.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifTime = ref.watch(notificationTimeProvider).value;
    final currentTheme = ref.watch(themeProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                // ── 테마 ──
                _tile(
                  icon: '🎨',
                  title: '행성 테마',
                  subtitle: currentTheme?.name,
                  onTap: _showThemeSelector,
                ),
                // ── 알림 시간 ──
                _tile(
                  icon: '🔔',
                  title: '일일 질문 알림 시간',
                  subtitle: notifTime != null
                      ? '${notifTime.hour.toString().padLeft(2, '0')}:${notifTime.minute.toString().padLeft(2, '0')}'
                      : null,
                  onTap: _changeNotificationTime,
                ),
                const Divider(color: Colors.white12, height: 1),
                _tile(
                  icon: '💾',
                  title: '데이터 백업/복구',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const BackupScreen())),
                ),
                _tile(
                  icon: '🗓️',
                  title: '기념일 관리',
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AnniversaryScreen())),
                ),
                const Divider(color: Colors.white12, height: 1),
                _tile(
                  icon: '🚫',
                  title: '광고 제거 (₩3,000)',
                  onTap: _buyAdFree,
                ),
                _tile(
                  icon: '⭐',
                  title: '별 조각 패키지 구매',
                  onTap: _showShardPackages,
                ),
              ],
            ),
          ),
          // Banner ad at the bottom of settings
          if (_bannerLoaded && _bannerAd != null)
            SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }

  Widget _tile({
    required String icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Text(icon, style: const TextStyle(fontSize: 22)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12))
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
      onTap: onTap,
    );
  }
}

/// 테마 선택 카드
class _ThemeCard extends StatelessWidget {
  final PlanetTheme theme;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected
          ? AppTheme.accentCyan.withAlpha(30)
          : const Color(0xFF1E1E3A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected
            ? const BorderSide(color: AppTheme.accentCyan)
            : BorderSide.none,
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(theme.previewEmoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          theme.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (theme.isPremium) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.starYellow.withAlpha(30),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'PREMIUM',
                              style: TextStyle(
                                color: AppTheme.starYellow,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      theme.description,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle,
                    color: AppTheme.accentCyan, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
