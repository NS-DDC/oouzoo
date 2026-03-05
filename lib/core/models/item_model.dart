class ItemModel {
  final String itemId;
  final ItemType itemType;
  final bool equipped;
  final DateTime obtainedAt;

  const ItemModel({
    required this.itemId,
    required this.itemType,
    required this.equipped,
    required this.obtainedAt,
  });

  factory ItemModel.fromMap(Map<String, dynamic> map) => ItemModel(
        itemId: map['item_id'] as String,
        itemType: ItemType.values.firstWhere((e) => e.name == map['item_type']),
        equipped: (map['equipped'] as int) == 1,
        obtainedAt: DateTime.parse(map['obtained_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'item_id': itemId,
        'item_type': itemType.name,
        'equipped': equipped ? 1 : 0,
        'obtained_at': obtainedAt.toIso8601String(),
      };
}

enum ItemType {
  background,   // 행성 배경
  planetSkin,   // 행성 스킨
  pet,          // 펫
  decoration,   // 장식 아이템
  theme,        // 프리미엄 테마 (유료)
}
