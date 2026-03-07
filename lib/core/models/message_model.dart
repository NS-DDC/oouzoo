/// Wormhole message — relayed via Firebase Realtime DB.
/// Supports time capsule mode (deliverAt != null).
class MessageModel {
  final String id;
  final String senderId;
  final String content;
  final MessageType type;
  final DateTime sentAt;
  final DateTime? deliverAt; // 시간 캡슐: null이면 즉시 전달

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.content,
    required this.type,
    required this.sentAt,
    this.deliverAt,
  });

  bool get isTimeCapsule => deliverAt != null;
  bool get isCapsuleReady =>
      deliverAt == null || DateTime.now().isAfter(deliverAt!);

  factory MessageModel.fromMap(Map<String, dynamic> map) => MessageModel(
        id: map['id'] as String,
        senderId: map['sender_id'] as String,
        content: map['content'] as String,
        type: MessageType.values.firstWhere(
          (e) => e.name == map['type'],
          orElse: () => MessageType.text,
        ),
        sentAt: DateTime.parse(map['sent_at'] as String),
        deliverAt: map['deliver_at'] != null
            ? DateTime.parse(map['deliver_at'] as String)
            : null,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'sender_id': senderId,
        'content': content,
        'type': type.name,
        'sent_at': sentAt.toIso8601String(),
        if (deliverAt != null) 'deliver_at': deliverAt!.toIso8601String(),
      };
}

enum MessageType { text, mood, sticker, timeCapsule }
