import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/services/admob_service.dart';
import '../../../core/services/iap_service.dart';
import '../../../core/utils/constants.dart';
import '../../backup/screens/backup_screen.dart';
import '../../anniversary/screens/anniversary_screen.dart';

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

  @override
  Widget build(BuildContext context) {
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
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Text(icon, style: const TextStyle(fontSize: 22)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
      onTap: onTap,
    );
  }
}
