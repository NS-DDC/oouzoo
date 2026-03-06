import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/models/message_model.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/utils/channel_utils.dart';
import '../../pairing/controllers/user_profile_controller.dart';

final messagesProvider =
    AsyncNotifierProvider<MessagesNotifier, List<MessageModel>>(
        MessagesNotifier.new);

class MessagesNotifier extends AsyncNotifier<List<MessageModel>> {
  @override
  Future<List<MessageModel>> build() async => [];

  Future<void> sendMessage(String content) async {
    final profile = ref.read(userProfileProvider).value;
    if (profile == null || !profile.isPaired) return;

    final msg = MessageModel(
      id: const Uuid().v4(),
      senderId: profile.uuid,
      content: content,
      type: MessageType.text,
      sentAt: DateTime.now(),
    );

    // Optimistic UI update
    final current = state.value ?? [];
    state = AsyncData([msg, ...current]);

    // Relay via Firebase (receiver deletes after processing)
    final channelId = generateChannelId(
      profile.uuid,
      profile.channelPartnerId!,
    );
    await FirebaseService.instance.sendMessage(
      channelId: channelId,
      payload: msg.toMap(),
    );
  }
}
