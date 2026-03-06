import 'package:firebase_database/firebase_database.dart';

/// Firebase Realtime DB is used as a relay ONLY.
/// Data persists until the receiver processes and deletes it.
/// No user data is stored long-term on the server.
class FirebaseService {
  static final FirebaseService instance = FirebaseService._();
  FirebaseService._();

  final _db = FirebaseDatabase.instance;

  /// Send a wormhole message to partner's channel.
  /// The receiver is responsible for deleting after processing.
  Future<void> sendMessage({
    required String channelId,
    required Map<String, dynamic> payload,
  }) async {
    final ref = _db.ref('wormhole/$channelId/message');
    await ref.set(payload);
    // Receiver will delete after processing
  }

  /// Send mood change notification payload (relay-only).
  /// Mood is fire-and-forget; receiver deletes after processing.
  Future<void> sendMoodUpdate({
    required String channelId,
    required int mood,
    required String senderId,
  }) async {
    final ref = _db.ref('wormhole/$channelId/mood');
    await ref.set({
      'sender_id': senderId,
      'mood': mood,
      'sent_at': DateTime.now().toIso8601String(),
    });
    // Receiver will delete after processing
  }

  /// Send daily question answer to partner (relay-only).
  /// Receiver deletes after processing — guarantees delivery even if offline.
  Future<void> sendDailyAnswer({
    required String channelId,
    required Map<String, dynamic> payload,
  }) async {
    final ref = _db.ref('wormhole/$channelId/daily_answer');
    await ref.set(payload);
    // Receiver will delete after processing
  }

  /// Listen for incoming messages on my channel.
  Stream<DatabaseEvent> listenForMessages(String myChannelId) {
    return _db.ref('wormhole/$myChannelId/message').onValue;
  }

  /// Listen for incoming daily question answers.
  Stream<DatabaseEvent> listenForDailyAnswers(String channelId) {
    return _db.ref('wormhole/$channelId/daily_answer').onValue;
  }
}
