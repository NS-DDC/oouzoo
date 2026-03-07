import 'package:flutter/material.dart';
import '../../../core/models/message_model.dart';
import '../../../shared/theme/app_theme.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final String myUserId;

  const MessageBubble({
    super.key,
    required this.message,
    required this.myUserId,
  });

  bool get _isMe => message.senderId == myUserId;

  @override
  Widget build(BuildContext context) {
    // 시간 캡슐이 아직 공개 안 된 경우
    if (message.isTimeCapsule && !message.isCapsuleReady) {
      return _buildCapsuleLocked(context);
    }

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
              ? Border.all(color: const Color(0xFFFFD700).withAlpha(77))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 시간 캡슐 공개된 메시지 표시
            if (message.isTimeCapsule)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🕐', style: TextStyle(fontSize: 10)),
                    const SizedBox(width: 4),
                    Text(
                      '시간 캡슐 공개됨',
                      style: TextStyle(
                        color: AppTheme.accentCyan.withAlpha(180),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              message.content,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapsuleLocked(BuildContext context) {
    final remaining = message.deliverAt!.difference(DateTime.now());
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    final timeText = hours > 0 ? '$hours시간 $minutes분 후 공개' : '$minutes분 후 공개';

    return Align(
      alignment: _isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: AppTheme.accentCyan.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.accentCyan.withAlpha(60)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔒', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 6),
            const Text(
              '시간 캡슐',
              style: TextStyle(
                color: AppTheme.accentCyan,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              timeText,
              style: TextStyle(
                color: AppTheme.accentCyan.withAlpha(150),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
