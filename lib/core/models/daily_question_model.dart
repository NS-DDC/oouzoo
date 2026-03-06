class DailyQuestionModel {
  final int? id;
  final int questionId;
  final String question;
  final String? myAnswer;
  final String? partnerAnswer;
  final DateTime? answeredAt;
  final DateTime? partnerAnsweredAt;
  final String date; // YYYY-MM-DD

  const DailyQuestionModel({
    this.id,
    required this.questionId,
    required this.question,
    this.myAnswer,
    this.partnerAnswer,
    this.answeredAt,
    this.partnerAnsweredAt,
    required this.date,
  });

  bool get iAnswered => myAnswer != null;
  bool get partnerAnswered => partnerAnswer != null;
  bool get bothAnswered => iAnswered && partnerAnswered;

  factory DailyQuestionModel.fromMap(Map<String, dynamic> map) =>
      DailyQuestionModel(
        id: map['id'] as int?,
        questionId: map['question_id'] as int,
        question: map['question'] as String,
        myAnswer: map['my_answer'] as String?,
        partnerAnswer: map['partner_answer'] as String?,
        answeredAt: map['answered_at'] != null
            ? DateTime.parse(map['answered_at'] as String)
            : null,
        partnerAnsweredAt: map['partner_answered_at'] != null
            ? DateTime.parse(map['partner_answered_at'] as String)
            : null,
        date: map['date'] as String,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'question_id': questionId,
        'question': question,
        'my_answer': myAnswer,
        'partner_answer': partnerAnswer,
        'answered_at': answeredAt?.toIso8601String(),
        'partner_answered_at': partnerAnsweredAt?.toIso8601String(),
        'date': date,
      };

  DailyQuestionModel copyWith({
    String? myAnswer,
    String? partnerAnswer,
    DateTime? answeredAt,
    DateTime? partnerAnsweredAt,
  }) =>
      DailyQuestionModel(
        id: id,
        questionId: questionId,
        question: question,
        myAnswer: myAnswer ?? this.myAnswer,
        partnerAnswer: partnerAnswer ?? this.partnerAnswer,
        answeredAt: answeredAt ?? this.answeredAt,
        partnerAnsweredAt: partnerAnsweredAt ?? this.partnerAnsweredAt,
        date: date,
      );
}
