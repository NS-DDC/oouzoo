class DiaryModel {
  final int? id;
  final String title;
  final String content;
  final int mood; // 1–5 (😢 → 😍)
  final DateTime createdAt;

  const DiaryModel({
    this.id,
    required this.title,
    required this.content,
    required this.mood,
    required this.createdAt,
  });

  factory DiaryModel.fromMap(Map<String, dynamic> map) => DiaryModel(
        id: map['id'] as int?,
        title: map['title'] as String,
        content: map['content'] as String,
        mood: map['mood'] as int,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'title': title,
        'content': content,
        'mood': mood,
        'created_at': createdAt.toIso8601String(),
      };

  DiaryModel copyWith({String? title, String? content, int? mood}) =>
      DiaryModel(
        id: id,
        title: title ?? this.title,
        content: content ?? this.content,
        mood: mood ?? this.mood,
        createdAt: createdAt,
      );
}
