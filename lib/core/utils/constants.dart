/// App-wide constants
class AppConstants {
  // ── Dev/Sandbox mode ─────────────────────────────────────────────────────
  /// true = 테스트 광고 + IAP sandbox 사용. 배포 전 false로 변경.
  static const bool isSandbox = true;

  // ── Star shards rewards ───────────────────────────────────────────────────
  static const int shardsPerChat = 5;
  static const int shardsPerDiary = 20;
  static const int shardsPerDailyLogin = 10;
  static const int shardsBoostMultiplier = 2;

  // ── Gacha ─────────────────────────────────────────────────────────────────
  static const int gachaFreePerDay = 1;
  static const int gachaCostInShards = 50;

  // ── IAP product IDs ───────────────────────────────────────────────────────
  // Android: Google Play Console에서 동일한 ID로 상품 등록 필요
  // iOS: App Store Connect에서 동일한 ID로 상품 등록 필요
  static const String productAdFree        = 'com.oouzoo.adfree';
  static const String productShards100     = 'com.oouzoo.shards_100';
  static const String productShards500     = 'com.oouzoo.shards_500';
  static const String productThemeGalaxy   = 'com.oouzoo.theme_galaxy';
  static const String productThemeCatPlanet = 'com.oouzoo.theme_cat';

  // ── Ad Unit IDs ───────────────────────────────────────────────────────────
  // isSandbox = true 이면 Google 공식 테스트 ID 사용 (실제 과금 없음)
  // 배포 시 AdMob 콘솔에서 발급받은 실제 ID로 교체
  static const String _testRewarded     = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testBanner       = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitial = 'ca-app-pub-3940256099942544/1033173712';

  static const String _prodRewarded     = 'ca-app-pub-XXXXXXXXXXXXXXXX/AAAAAAAAAA';
  static const String _prodBanner       = 'ca-app-pub-XXXXXXXXXXXXXXXX/BBBBBBBBBB';
  static const String _prodInterstitial = 'ca-app-pub-XXXXXXXXXXXXXXXX/CCCCCCCCCC';

  static String get adRewarded     => isSandbox ? _testRewarded     : _prodRewarded;
  static String get adBanner       => isSandbox ? _testBanner       : _prodBanner;
  static String get adInterstitial => isSandbox ? _testInterstitial : _prodInterstitial;

  // ── Interstitial show probability ─────────────────────────────────────────
  static const double interstitialProbability = 0.3;

  // ── Firebase ──────────────────────────────────────────────────────────────
  static const String wormholePrefix = 'wormhole';

  // ── Assets ────────────────────────────────────────────────────────────────
  static String planetAsset(int level) => 'assets/images/planets/planet_lv$level.png';
  static String moodAsset(int mood)    => 'assets/images/planets/mood_$mood.png';
  static String petAsset(String id)    => 'assets/images/pets/$id.png';
  static String itemAsset(String id)   => 'assets/images/items/$id.png';
  static String bgAsset(String id)     => 'assets/images/backgrounds/$id.png';
}
