import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../home/screens/home_screen.dart';
import '../../settings/controllers/notification_settings_controller.dart';
import '../controllers/pairing_controller.dart';
import '../controllers/user_profile_controller.dart';

class PairingScreen extends ConsumerStatefulWidget {
  const PairingScreen({super.key});

  @override
  ConsumerState<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends ConsumerState<PairingScreen> {
  final _nicknameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  bool _profileCreated = false;

  @override
  void initState() {
    super.initState();
    // Check if profile already exists (returning user without partner)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(userProfileProvider).value;
      if (profile != null) {
        setState(() => _profileCreated = true);
      }
    });
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _createProfile() async {
    final nickname = _nicknameCtrl.text.trim();
    if (nickname.isEmpty) return;

    await ref.read(userProfileProvider.notifier).createProfile(
          nickname: nickname,
        );
    if (mounted) setState(() => _profileCreated = true);
  }

  Future<void> _generateCode() async {
    await ref.read(pairingProvider.notifier).generateInviteCode();
  }

  Future<void> _enterCode() async {
    final code = _codeCtrl.text.trim();
    if (code.length != 6) return;
    await ref.read(pairingProvider.notifier).enterPartnerCode(code);
  }

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  Future<void> _showNotificationTimePicker() async {
    final currentTime =
        ref.read(notificationTimeProvider).value ?? const TimeOfDay(hour: 20, minute: 0);

    final picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
      helpText: '매일 질문 알림을 받을 시간',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accentCyan,
              surface: Color(0xFF1E1E3A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      await ref.read(notificationTimeProvider.notifier).setTime(picked);
    }

    if (mounted) _goHome();
  }

  @override
  Widget build(BuildContext context) {
    final pairingState = ref.watch(pairingProvider);

    // Navigate to home when pairing succeeds (show notification time picker first)
    ref.listen(pairingProvider, (prev, next) {
      final value = next.value;
      if (value != null && value.isPaired) {
        _showNotificationTimePicker();
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: !_profileCreated
              ? _buildNicknameStep()
              : _buildPairingStep(pairingState),
        ),
      ),
    );
  }

  Widget _buildNicknameStep() {
    return Column(
      children: [
        const SizedBox(height: 48),
        // Planet icon
        const Text('🪐', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 24),
        const Text(
          '우주에 오신 걸 환영해요',
          style: TextStyle(
            color: AppTheme.moonWhite,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '먼저 이름을 알려주세요',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
        const SizedBox(height: 48),
        TextField(
          controller: _nicknameCtrl,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
          maxLength: 10,
          decoration: InputDecoration(
            hintText: '닉네임 입력',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF1E1E3A),
            counterStyle: const TextStyle(color: Colors.white38),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _createProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.nebulaPurple,
              foregroundColor: AppTheme.moonWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('시작하기', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildPairingStep(AsyncValue<PairingState> pairingState) {
    final state = pairingState.value;
    final error = state?.error;
    final inviteCode = state?.inviteCode;
    final isWaiting = state?.isWaiting ?? false;

    return Column(
      children: [
        const SizedBox(height: 32),
        const Text('🌌', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 24),
        const Text(
          '우주를 연결해요',
          style: TextStyle(
            color: AppTheme.moonWhite,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '상대방과 초대 코드를 교환해주세요',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
        const SizedBox(height: 40),

        // ── Generate code section ──
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: isWaiting ? null : _generateCode,
            icon: const Icon(Icons.link),
            label: Text(isWaiting ? '대기 중...' : '초대 코드 생성'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.nebulaPurple,
              foregroundColor: AppTheme.moonWhite,
              disabledBackgroundColor: AppTheme.nebulaPurple.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),

        // Show generated code
        if (inviteCode != null) ...[
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E3A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.starYellow.withOpacity(0.5),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  '초대 코드',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  inviteCode,
                  style: const TextStyle(
                    color: AppTheme.starYellow,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: inviteCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('코드가 복사되었습니다'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('복사'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.accentCyan,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '상대방에게 이 코드를 알려주세요\n연결을 기다리는 중...',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 32),

        // ── Divider ──
        const Row(
          children: [
            Expanded(child: Divider(color: Colors.white24)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('또는', style: TextStyle(color: Colors.white38)),
            ),
            Expanded(child: Divider(color: Colors.white24)),
          ],
        ),
        const SizedBox(height: 32),

        // ── Enter partner code section ──
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '상대방의 코드 입력',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _codeCtrl,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            letterSpacing: 6,
          ),
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: '000000',
            hintStyle: const TextStyle(
              color: Colors.white24,
              fontSize: 24,
              letterSpacing: 6,
            ),
            filled: true,
            fillColor: const Color(0xFF1E1E3A),
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _enterCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentPink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('연결하기', style: TextStyle(fontSize: 16)),
          ),
        ),

        // Error message
        if (error != null) ...[
          const SizedBox(height: 16),
          Text(
            error,
            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
          ),
        ],

        // Skip pairing option
        const SizedBox(height: 40),
        TextButton(
          onPressed: _goHome,
          child: const Text(
            '나중에 연결하기',
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
