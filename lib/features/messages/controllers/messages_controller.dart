import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/models/message_model.dart';
import '../../../core/services/firebase_service.dart';

final messagesProvider =
    AsyncNotifierProvider<MessagesNotifier, List<MessageModel>>(
        MessagesNotifier.new);

class MessagesNotifier extends AsyncNotifier<List<MessageModel>> {
  @override
  Future<List<MessageModel>> build() async => [];

  Future<void> sendMessage(String content) async {
    final msg = MessageModel(
      id: const Uuid().v4(),
      senderId: 'me', // replace with actual user ID
      content: content,
      type: MessageType.text,
      sentAt: DateTime.now(),
    );

    // Optimistic UI update
    final current = state.value ?? [];
    state = AsyncData([msg, ...current]);

    // Relay via Firebase (auto-deleted after delivery)
    await FirebaseService.instance.sendMessage(
      channelId: 'channel_id_placeholder', // replace with real channel ID
      payload: msg.toMap(),
    );
  }
}
