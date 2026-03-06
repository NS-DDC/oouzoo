import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../utils/constants.dart';

/// AdMob 광고 서비스
/// - Rewarded : 가챠 추가 뽑기, 별 조각 2배
/// - Banner   : 설정창 / 일기 목록 하단
/// - Interstitial: 일기/별자리 생성 완료 후 (30% 확률)
///
/// AppConstants.isSandbox = true → Google 공식 테스트 ID 자동 사용 (실제 과금 없음)
/// 배포 시 isSandbox = false + 실제 Ad Unit ID 입력
class AdmobService {
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  // ── Rewarded Ad ───────────────────────────────────────────────────────────
  static Future<RewardedAd?> loadRewardedAd() async {
    RewardedAd? ad;
    await RewardedAd.load(
      adUnitId: AppConstants.adRewarded,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (loadedAd) => ad = loadedAd,
        onAdFailedToLoad: (error) => ad = null,
      ),
    );
    return ad;
  }

  // ── Banner Ad ─────────────────────────────────────────────────────────────
  static BannerAd createBannerAd() => BannerAd(
        adUnitId: AppConstants.adBanner,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: const BannerAdListener(),
      );

  // ── Interstitial Ad ───────────────────────────────────────────────────────
  static Future<InterstitialAd?> loadInterstitialAd() async {
    InterstitialAd? ad;
    await InterstitialAd.load(
      adUnitId: AppConstants.adInterstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (loadedAd) => ad = loadedAd,
        onAdFailedToLoad: (_) => ad = null,
      ),
    );
    return ad;
  }
}
