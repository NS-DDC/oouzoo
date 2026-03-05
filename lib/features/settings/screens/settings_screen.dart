import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/services/admob_service.dart';
import '../../backup/screens/backup_screen.dart';
import '../../anniversary/screens/anniversary_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ 설정'),
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
                  onTap: () {
                    // TODO: trigger IAP for ad-free
                  },
                ),
                _tile(
                  icon: '⭐',
                  title: '별 조각 패키지 구매',
                  onTap: () {
                    // TODO: IAP shard packages
                  },
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
