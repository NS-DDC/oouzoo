import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../pairing/controllers/user_profile_controller.dart';
import '../controllers/messages_controller.dart';
import '../widgets/message_bubble.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  final _controller = TextEditingController();
  Duration? _capsuleDelay; // null = 즉시 전달

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    DateTime? deliverAt;
    final delay = _capsuleDelay;
    if (delay != null) {
      deliverAt = DateTime.now().add(delay);
    }

    ref.read(messagesProvider.notifier).sendMessage(
          text,
          deliverAt: deliverAt,
        );
    _controller.clear();
    setState(() => _capsuleDelay = null);

    if (deliverAt != null && delay != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '시간 캡슐 전송 완료! ${_formatDelay(delay)} 후 공개됩니다'),
          backgroundColor: AppTheme.nebulaPurple,
        ),
      );
    }
  }

  void _showCapsuleOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.deepSpace,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '시간 캡슐 설정',
              style: TextStyle(
                color: AppTheme.moonWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '메시지를 캡슐에 담아 나중에 공개해요',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 20),
            _CapsuleOption(
              emoji: '⚡',
              label: '즉시 전달',
              desc: '보통 메시지처럼 바로 전달',
              selected: _capsuleDelay == null,
              onTap: () {
                setState(() => _capsuleDelay = null);
                Navigator.pop(context);
              },
            ),
            _CapsuleOption(
              emoji: '🕐',
              label: '1시간 후',
              desc: '잠깐의 설렘을 담아서',
              selected: _capsuleDelay == const Duration(hours: 1),
              onTap: () {
                setState(
                    () => _capsuleDelay = const Duration(hours: 1));
                Navigator.pop(context);
              },
            ),
            _CapsuleOption(
              emoji: '🌅',
              label: '6시간 후',
              desc: '반나절의 기다림',
              selected: _capsuleDelay == const Duration(hours: 6),
              onTap: () {
                setState(
                    () => _capsuleDelay = const Duration(hours: 6));
                Navigator.pop(context);
              },
            ),
            _CapsuleOption(
              emoji: '🌙',
              label: '24시간 후',
              desc: '내일의 나에게 보내는 편지',
              selected: _capsuleDelay == const Duration(hours: 24),
              onTap: () {
                setState(
                    () => _capsuleDelay = const Duration(hours: 24));
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatDelay(Duration d) {
    if (d.inHours >= 24) return '24시간';
    if (d.inHours >= 6) return '6시간';
    if (d.inHours >= 1) return '1시간';
    return '${d.inMinutes}분';
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(messagesProvider);
    final profile = ref.watch(userProfileProvider).value;
    final myUserId = profile?.uuid ?? '';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('웜홀 메시지'),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.when(
              data: (msgs) {
                if (msgs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🌀', style: TextStyle(fontSize: 48)),
                        SizedBox(height: 16),
                        Text(
                          '웜홀을 통해 메시지를 보내세요',
                          style:
                              TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '시간 캡슐로 특별한 메시지를 전달할 수도 있어요!',
                          style:
                              TextStyle(color: Colors.white24, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: msgs.length,
                  itemBuilder: (_, i) => MessageBubble(
                    message: msgs[i],
                    myUserId: myUserId,
                  ),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
            ),
          ),
          _buildInput(context),
        ],
      ),
    );
  }

  Widget _buildInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      color: const Color(0xFF12122A),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 시간 캡슐 활성화 표시
          if (_capsuleDelay != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.accentCyan.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accentCyan.withAlpha(80)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🕐', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    '시간 캡슐: ${_formatDelay(_capsuleDelay!)} 후 공개',
                    style: const TextStyle(
                      color: AppTheme.accentCyan,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => setState(() => _capsuleDelay = null),
                    child: const Icon(Icons.close,
                        size: 14, color: AppTheme.accentCyan),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              // 시간 캡슐 버튼
              IconButton(
                icon: Icon(
                  _capsuleDelay != null
                      ? Icons.watch_later
                      : Icons.watch_later_outlined,
                  color: _capsuleDelay != null
                      ? AppTheme.accentCyan
                      : Colors.white38,
                ),
                onPressed: _showCapsuleOptions,
                tooltip: '시간 캡슐',
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: _capsuleDelay != null
                        ? '캡슐에 담을 메시지...'
                        : '별빛을 담아 보내세요...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF1E1E3A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  _capsuleDelay != null
                      ? Icons.rocket_launch
                      : Icons.send_rounded,
                  color: const Color(0xFFFFD700),
                ),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CapsuleOption extends StatelessWidget {
  final String emoji;
  final String label;
  final String desc;
  final bool selected;
  final VoidCallback onTap;

  const _CapsuleOption({
    required this.emoji,
    required this.label,
    required this.desc,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(emoji, style: const TextStyle(fontSize: 24)),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      subtitle:
          Text(desc, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      trailing: selected
          ? const Icon(Icons.check_circle, color: AppTheme.accentCyan, size: 20)
          : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: selected ? AppTheme.accentCyan.withAlpha(20) : null,
      onTap: onTap,
    );
  }
}
