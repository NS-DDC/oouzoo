import '../models/item_model.dart';

/// 가차 아이템 정의
class GachaItem {
  final String id;
  final String name;
  final ItemType type;
  final GachaRarity rarity;
  final double dropRate; // 0.0 ~ 1.0
  final String assetPath;

  const GachaItem({
    required this.id,
    required this.name,
    required this.type,
    required this.rarity,
    required this.dropRate,
    required this.assetPath,
  });
}

enum GachaRarity {
  common, // ★
  uncommon, // ★★
  rare, // ★★★
}

/// 전체 가차 풀 — 확률 합계 = 1.0
const gachaPool = <GachaItem>[
  // ── 펫 (pet) ──────────────────────────────────
  GachaItem(
    id: 'pet_default',
    name: '별빛이',
    type: ItemType.pet,
    rarity: GachaRarity.common,
    dropRate: 0.12,
    assetPath: 'assets/images/pets/pet_default.png',
  ),
  GachaItem(
    id: 'pet_star',
    name: '반짝이',
    type: ItemType.pet,
    rarity: GachaRarity.uncommon,
    dropRate: 0.06,
    assetPath: 'assets/images/pets/pet_star.png',
  ),
  GachaItem(
    id: 'pet_rabbit',
    name: '토끼별',
    type: ItemType.pet,
    rarity: GachaRarity.uncommon,
    dropRate: 0.06,
    assetPath: 'assets/images/pets/pet_rabbit.png',
  ),
  GachaItem(
    id: 'pet_cat',
    name: '냥별이',
    type: ItemType.pet,
    rarity: GachaRarity.rare,
    dropRate: 0.03,
    assetPath: 'assets/images/pets/pet_cat.png',
  ),
  GachaItem(
    id: 'pet_bunny',
    name: '달토끼',
    type: ItemType.pet,
    rarity: GachaRarity.rare,
    dropRate: 0.03,
    assetPath: 'assets/images/pets/pet_bunny.png',
  ),

  // ── 장식 (decoration) ─────────────────────────
  GachaItem(
    id: 'common_sticker',
    name: '별 스티커',
    type: ItemType.decoration,
    rarity: GachaRarity.common,
    dropRate: 0.15,
    assetPath: 'assets/images/items/common_sticker.png',
  ),
  GachaItem(
    id: 'uncommon_decoration',
    name: '우주 장식',
    type: ItemType.decoration,
    rarity: GachaRarity.common,
    dropRate: 0.12,
    assetPath: 'assets/images/items/uncommon_decoration.png',
  ),
  GachaItem(
    id: 'deco_star',
    name: '빛나는 별',
    type: ItemType.decoration,
    rarity: GachaRarity.uncommon,
    dropRate: 0.08,
    assetPath: 'assets/images/items/deco_star.png',
  ),
  GachaItem(
    id: 'deco_moon',
    name: '초승달',
    type: ItemType.decoration,
    rarity: GachaRarity.uncommon,
    dropRate: 0.06,
    assetPath: 'assets/images/items/deco_moon.png',
  ),

  // ── 배경 (background) ─────────────────────────
  GachaItem(
    id: 'rare_background',
    name: '은하수 배경',
    type: ItemType.background,
    rarity: GachaRarity.rare,
    dropRate: 0.02,
    assetPath: 'assets/images/backgrounds/bg_galaxy.png',
  ),
  GachaItem(
    id: 'bg_nebula',
    name: '성운 배경',
    type: ItemType.background,
    rarity: GachaRarity.rare,
    dropRate: 0.02,
    assetPath: 'assets/images/backgrounds/bg_nebula.png',
  ),
];

/// 중복 아이템 시 보상할 별 조각 수
const gachaDuplicateShards = 25;

/// ID로 가차 아이템 조회
GachaItem? getGachaItemById(String id) {
  for (final item in gachaPool) {
    if (item.id == id) return item;
  }
  return null;
}
