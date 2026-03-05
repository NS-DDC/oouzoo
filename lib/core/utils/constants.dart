/// App-wide constants
class AppConstants {
  // Star shards rewards
  static const int shardsPerChat = 5;
  static const int shardsPerDiary = 20;
  static const int shardsPerDailyLogin = 10;
  static const int shardsBoostMultiplier = 2;

  // Gacha
  static const int gachaFreePerDay = 1;
  static const int gachaCostInShards = 50;

  // IAP product IDs
  static const String productAdFree = 'com.oouzoo.adfree';
  static const String productShards100 = 'com.oouzoo.shards_100';
  static const String productShards500 = 'com.oouzoo.shards_500';
  static const String productThemeGalaxy = 'com.oouzoo.theme_galaxy';
  static const String productThemeCatPlanet = 'com.oouzoo.theme_cat';

  // Interstitial ad probability (0.0 – 1.0)
  static const double interstitialProbability = 0.3;

  // Firebase channel prefix
  static const String wormholePrefix = 'wormhole';
}
