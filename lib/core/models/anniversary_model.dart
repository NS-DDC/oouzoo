class AnniversaryModel {
  final int? id;
  final String label;
  final DateTime date;
  final bool isCoupleStart; // D+Day 기준 날짜 여부

  const AnniversaryModel({
    this.id,
    required this.label,
    required this.date,
    this.isCoupleStart = false,
  });

  /// D+N: days since couple start date
  int daysFrom(DateTime from) => DateTime.now().difference(from).inDays;

  /// D-Day: days until upcoming anniversary
  int daysUntil() {
    final now = DateTime.now();
    final next = DateTime(now.year, date.month, date.day);
    final diff = next.difference(DateTime(now.year, now.month, now.day)).inDays;
    return diff >= 0 ? diff : diff + 365;
  }

  factory AnniversaryModel.fromMap(Map<String, dynamic> map) =>
      AnniversaryModel(
        id: map['id'] as int?,
        label: map['label'] as String,
        date: DateTime.parse(map['date'] as String),
        isCoupleStart: (map['is_couple_start'] as int) == 1,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'label': label,
        'date': date.toIso8601String(),
        'is_couple_start': isCoupleStart ? 1 : 0,
      };
}
