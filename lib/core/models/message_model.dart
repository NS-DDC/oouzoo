/// Wormhole message — relayed via Firebase Realtime DB and immediately deleted.
/// Never persisted on the server.
class MessageModel {
  final String id;
  final String senderId;
  final String content;
  final MessageType type;
  final DateTime sentAt;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.content,
    required this.type,
    required this.sentAt,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) => MessageModel(
        id: map['id'] as String,
        senderId: map['sender_id'] as String,
        content: map['content'] as String,
        type: MessageType.values.firstWhere(
          (e) => e.name == map['type'],
          orElse: () => MessageType.text,
        ),
        sentAt: DateTime.parse(map['sent_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'sender_id': senderId,
        'content': content,
        'type': type.name,
        'sent_at': sentAt.toIso8601String(),
      };
}

enum MessageType { text, mood, sticker }
