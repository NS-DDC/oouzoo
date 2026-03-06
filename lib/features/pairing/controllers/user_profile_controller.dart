import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/models/user_profile_model.dart';
import '../../../core/services/fcm_service.dart';

final userProfileProvider =
    AsyncNotifierProvider<UserProfileNotifier, UserProfileModel?>(
        UserProfileNotifier.new);

class UserProfileNotifier extends AsyncNotifier<UserProfileModel?> {
  @override
  Future<UserProfileModel?> build() => _fetch();

  Future<UserProfileModel?> _fetch() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('user_profile');
    if (rows.isEmpty) return null;
    return UserProfileModel.fromMap(rows.first);
  }

  /// Create a new user profile with nickname and FCM token.
  Future<void> createProfile({required String nickname}) async {
    final db = await DatabaseHelper.instance.database;
    final fcmToken = await FcmService.getToken();
    final now = DateTime.now().toIso8601String();

    await db.insert('user_profile', {
      'id': 1,
      'nickname': nickname,
      'planet_name': '우리 별',
      'fcm_token': fcmToken,
      'created_at': now,
    });

    state = AsyncData(await _fetch());
  }

  /// Save partner's FCM token after successful pairing.
  Future<void> updatePartnerFcm(String partnerFcm) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'user_profile',
      {'partner_fcm': partnerFcm},
      where: 'id = ?',
      whereArgs: [1],
    );
    state = AsyncData(await _fetch());
  }

  /// Update own FCM token (on token refresh).
  Future<void> updateFcmToken(String token) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'user_profile',
      {'fcm_token': token},
      where: 'id = ?',
      whereArgs: [1],
    );
    state = AsyncData(await _fetch());
  }
}
