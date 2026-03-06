import 'dart:async';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/fcm_service.dart';
import '../../../core/utils/constants.dart';
import 'user_profile_controller.dart';

class PairingState {
  final String? inviteCode;
  final bool isPaired;
  final bool isWaiting;
  final String? partnerNickname;
  final String? error;

  const PairingState({
    this.inviteCode,
    this.isPaired = false,
    this.isWaiting = false,
    this.partnerNickname,
    this.error,
  });

  PairingState copyWith({
    String? inviteCode,
    bool? isPaired,
    bool? isWaiting,
    String? partnerNickname,
    String? error,
  }) =>
      PairingState(
        inviteCode: inviteCode ?? this.inviteCode,
        isPaired: isPaired ?? this.isPaired,
        isWaiting: isWaiting ?? this.isWaiting,
        partnerNickname: partnerNickname ?? this.partnerNickname,
        error: error,
      );
}

final pairingProvider =
    AsyncNotifierProvider<PairingNotifier, PairingState>(PairingNotifier.new);

class PairingNotifier extends AsyncNotifier<PairingState> {
  StreamSubscription<DatabaseEvent>? _partnerListener;
  final _db = FirebaseDatabase.instance;

  static const _maxCodeRetries = 5;

  @override
  Future<PairingState> build() async {
    ref.onDispose(() => _partnerListener?.cancel());
    final profile = ref.read(userProfileProvider).value;
    return PairingState(isPaired: profile?.isPaired ?? false);
  }

  /// Generate a 6-digit invite code and write to Firebase.
  Future<void> generateInviteCode() async {
    final profile = ref.read(userProfileProvider).value;
    if (profile == null) return;

    final fcmToken = await FcmService.getToken();

    // Retry loop with depth limit to avoid stack overflow
    for (int attempt = 0; attempt < _maxCodeRetries; attempt++) {
      final code = _generateCode();
      final codeRef = _db.ref('${AppConstants.pairingPrefix}/$code');

      final existing = await codeRef.get();
      if (existing.exists) continue; // Collision — try next code

      await codeRef.set({
        'fcm_token': fcmToken,
        'uuid': profile.uuid,
        'nickname': profile.nickname,
        'created_at': DateTime.now().toIso8601String(),
      });

      state = AsyncData(PairingState(
        inviteCode: code,
        isWaiting: true,
      ));

      // Listen for partner to claim this code
      _listenForPartner(code);
      return;
    }

    // All attempts collided (extremely unlikely)
    state = AsyncData(const PairingState(
      error: '코드 생성에 실패했습니다. 다시 시도해주세요.',
    ));
  }

  /// Enter partner's invite code to pair.
  Future<void> enterPartnerCode(String code) async {
    final profile = ref.read(userProfileProvider).value;
    if (profile == null) return;

    final codeRef = _db.ref('${AppConstants.pairingPrefix}/$code');
    final snapshot = await codeRef.get();

    if (!snapshot.exists) {
      state = AsyncData(const PairingState(
        error: '존재하지 않는 코드입니다.',
      ));
      return;
    }

    final data = snapshot.value as Map;

    // Check TTL
    final createdAt = DateTime.tryParse(data['created_at']?.toString() ?? '');
    if (createdAt != null) {
      final elapsed = DateTime.now().difference(createdAt).inMinutes;
      if (elapsed > AppConstants.inviteCodeTtlMinutes) {
        await codeRef.remove();
        state = AsyncData(const PairingState(
          error: '만료된 코드입니다. 새 코드를 요청해주세요.',
        ));
        return;
      }
    }

    final partnerFcm = data['fcm_token'] as String;
    final partnerUuid = data['uuid'] as String;
    final partnerNickname = data['nickname'] as String;

    // Write my info as response so partner can receive it
    final myFcmToken = await FcmService.getToken();
    await codeRef.child('partner').set({
      'fcm_token': myFcmToken,
      'uuid': profile.uuid,
      'nickname': profile.nickname,
    });

    // Save partner info locally (both UUID and FCM)
    await ref.read(userProfileProvider.notifier).updatePartnerInfo(
          partnerFcm: partnerFcm,
          partnerUuid: partnerUuid,
        );

    state = AsyncData(PairingState(
      isPaired: true,
      partnerNickname: partnerNickname,
    ));
  }

  /// Listen for partner to respond to our invite code.
  void _listenForPartner(String code) {
    _partnerListener?.cancel();
    final partnerRef =
        _db.ref('${AppConstants.pairingPrefix}/$code/partner');

    _partnerListener = partnerRef.onValue.listen((event) async {
      if (event.snapshot.value == null) return;

      final data = event.snapshot.value as Map;
      final partnerFcm = data['fcm_token'] as String;
      final partnerUuid = data['uuid'] as String;
      final partnerNickname = data['nickname'] as String;

      // Save partner info locally (both UUID and FCM)
      await ref.read(userProfileProvider.notifier).updatePartnerInfo(
            partnerFcm: partnerFcm,
            partnerUuid: partnerUuid,
          );

      // Cleanup Firebase
      try {
        await _db.ref('${AppConstants.pairingPrefix}/$code').remove();
      } catch (e) {
        debugPrint('[Pairing] cleanup error: $e');
      }

      _partnerListener?.cancel();

      state = AsyncData(PairingState(
        isPaired: true,
        partnerNickname: partnerNickname,
      ));
    });
  }

  String _generateCode() {
    final rng = Random();
    final code = List.generate(
      AppConstants.inviteCodeLength,
      (_) => rng.nextInt(10),
    ).join();
    return code;
  }
}
