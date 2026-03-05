import 'package:flutter/material.dart';
import '../../../core/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;

  const MessageBubble({super.key, required this.message});

  bool get _isMe => message.senderId == 'me';

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: _isMe
              ? const Color(0xFF3D1A6E)
              : const Color(0xFF1E1E3A),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(_isMe ? 16 : 4),
            bottomRight: Radius.circular(_isMe ? 4 : 16),
          ),
          border: _isMe
              ? Border.all(color: const Color(0xFFFFD700).withOpacity(0.3))
              : null,
        ),
        child: Text(
          message.content,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}
