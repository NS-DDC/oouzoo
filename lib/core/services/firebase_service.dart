import 'package:firebase_database/firebase_database.dart';

/// Firebase Realtime DB is used as a relay ONLY.
/// Messages are deleted immediately after delivery.
/// No user data is stored on the server.
class FirebaseService {
  static final FirebaseService instance = FirebaseService._();
  FirebaseService._();

  final _db = FirebaseDatabase.instance;

  /// Send a wormhole message to partner's FCM channel.
  /// The node is deleted right after writing to keep within free tier.
  Future<void> sendMessage({
    required String channelId,
    required Map<String, dynamic> payload,
  }) async {
    final ref = _db.ref('wormhole/$channelId/message');
    await ref.set(payload);

    // Self-destruct: delete after partner's FCM triggers
    await ref.onValue.first; // wait for partner to receive
    await ref.remove();
  }

  /// Send mood change notification payload (relay-only).
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
    await ref.remove();
  }

  /// Listen for incoming messages on my channel.
  Stream<DatabaseEvent> listenForMessages(String myChannelId) {
    return _db.ref('wormhole/$myChannelId/message').onValue;
  }
}
