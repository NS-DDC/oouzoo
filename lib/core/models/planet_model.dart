class PlanetModel {
  final int id;
  final int level;
  final int starShards;
  final int mood; // 1–5 scale
  final DateTime updatedAt;

  const PlanetModel({
    required this.id,
    required this.level,
    required this.starShards,
    required this.mood,
    required this.updatedAt,
  });

  /// Growth thresholds per level (star shards needed to advance)
  static const List<int> levelThresholds = [
    0,    // Lv 1 → 2
    100,  // Lv 2 → 3
    300,  // Lv 3 → 4
    600,  // Lv 4 → 5
    1000, // Lv 5 (max)
  ];

  bool get canLevelUp =>
      level < 5 && starShards >= levelThresholds[level - 1];

  factory PlanetModel.fromMap(Map<String, dynamic> map) => PlanetModel(
        id: map['id'] as int,
        level: map['level'] as int,
        starShards: map['star_shards'] as int,
        mood: map['mood'] as int,
        updatedAt: DateTime.parse(map['updated_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'level': level,
        'star_shards': starShards,
        'mood': mood,
        'updated_at': updatedAt.toIso8601String(),
      };

  PlanetModel copyWith({
    int? level,
    int? starShards,
    int? mood,
    DateTime? updatedAt,
  }) =>
      PlanetModel(
        id: id,
        level: level ?? this.level,
        starShards: starShards ?? this.starShards,
        mood: mood ?? this.mood,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
