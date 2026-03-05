import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob 광고 서비스
/// - Rewarded: 가챠 추가 뽑기, 별 조각 2배
/// - Banner: 설정창 / 일기 목록 하단
/// - Interstitial: 일기/별자리 생성 완료 후 (확률적)
class AdmobService {
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  // ── Test IDs (replace with real IDs in production) ──────────────────────
  static const String _rewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917'; // test
  static const String _bannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111'; // test
  static const String _interstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712'; // test

  // ── Rewarded Ad ──────────────────────────────────────────────────────────
  static Future<RewardedAd?> loadRewardedAd() async {
    RewardedAd? ad;
    await RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (loadedAd) => ad = loadedAd,
        onAdFailedToLoad: (error) => ad = null,
      ),
    );
    return ad;
  }

  // ── Banner Ad ────────────────────────────────────────────────────────────
  static BannerAd createBannerAd() => BannerAd(
        adUnitId: _bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: const BannerAdListener(),
      );

  // ── Interstitial Ad (probabilistic: 30% chance) ─────────────────────────
  static Future<InterstitialAd?> loadInterstitialAd() async {
    InterstitialAd? ad;
    await InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (loadedAd) => ad = loadedAd,
        onAdFailedToLoad: (_) => ad = null,
      ),
    );
    return ad;
  }
}
