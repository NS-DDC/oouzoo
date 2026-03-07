/// 판매용 행성 테마 — 각 테마는 레벨별 행성 5개 + 배경 1개로 구성.
class PlanetTheme {
  final String id;
  final String name;
  final String description;
  final List<String> planetAssets; // 5 images for levels 1-5
  final String backgroundAsset;
  final bool isPremium;
  final String? iapProductId;
  final String previewEmoji;

  const PlanetTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.planetAssets,
    required this.backgroundAsset,
    this.isPremium = false,
    this.iapProductId,
    this.previewEmoji = '🪐',
  });
}

/// 모든 테마 정의
const allThemes = <PlanetTheme>[
  // ── 무료 기본 테마 ──
  PlanetTheme(
    id: 'default',
    name: '우주 기본',
    description: '시안, 핑크, 그린, 오렌지... 그리고 지구!',
    previewEmoji: '🌍',
    planetAssets: [
      'assets/pixel/planet_cyan.png',
      'assets/pixel/planet_pink_ring.png',
      'assets/pixel/planet_green.png',
      'assets/pixel/planet_orange.png',
      'assets/pixel/earth.png',
    ],
    backgroundAsset: 'assets/pixel/bg_stars.png',
  ),

  // ── 유료 테마 1: 은하수 ──
  PlanetTheme(
    id: 'galaxy',
    name: '은하수',
    description: '신비로운 마젠타, 얼음 결정, 토성형 행성',
    previewEmoji: '🌌',
    isPremium: true,
    iapProductId: 'com.oouzoo.theme_galaxy',
    planetAssets: [
      'assets/pixel/planet_aqua.png',
      'assets/pixel/planet_magenta.png',
      'assets/pixel/planet_fuchsia.png',
      'assets/pixel/planet_ice.png',
      'assets/pixel/planet_orange_ring.png',
    ],
    backgroundAsset: 'assets/pixel/bg_stars2.png',
  ),

  // ── 유료 테마 2: 파괴된 우주 ──
  PlanetTheme(
    id: 'shattered',
    name: '파괴된 우주',
    description: '갈라진 행성들... 마그마가 드러나는 지구',
    previewEmoji: '💥',
    isPremium: true,
    iapProductId: 'com.oouzoo.theme_shattered',
    planetAssets: [
      'assets/pixel/shattered_cyan.png',
      'assets/pixel/shattered_magenta.png',
      'assets/pixel/shattered_green.png',
      'assets/pixel/shattered_orange.png',
      'assets/pixel/shattered_earth.png',
    ],
    backgroundAsset: 'assets/pixel/bg_cool.png',
  ),

  // ── 유료 테마 3: 블랙홀 ──
  PlanetTheme(
    id: 'blackhole',
    name: '블랙홀',
    description: '어둠 속에서 빛나는 사건의 지평선',
    previewEmoji: '🕳️',
    isPremium: true,
    iapProductId: 'com.oouzoo.theme_blackhole',
    planetAssets: [
      'assets/pixel/shattered_moon.png',
      'assets/pixel/shattered_ice.png',
      'assets/pixel/blackhole2.png',
      'assets/pixel/blackhole1.png',
      'assets/pixel/blackhole3.png',
    ],
    backgroundAsset: 'assets/pixel/bg_warm.png',
  ),
];

PlanetTheme getThemeById(String id) =>
    allThemes.firstWhere((t) => t.id == id, orElse: () => allThemes.first);
