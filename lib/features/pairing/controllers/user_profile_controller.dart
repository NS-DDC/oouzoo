import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

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

    var profile = UserProfileModel.fromMap(rows.first);

    // Generate UUID for existing profiles that don't have one (v2 → v3 migration)
    if (profile.uuid.isEmpty) {
      final uuid = const Uuid().v4();
      await db.update(
        'user_profile',
        {'uuid': uuid},
        where: 'id = ?',
        whereArgs: [1],
      );
      profile = profile.copyWith(uuid: uuid);
    }

    return profile;
  }

  /// Create a new user profile with nickname and FCM token.
  Future<void> createProfile({required String nickname}) async {
    final db = await DatabaseHelper.instance.database;
    final fcmToken = await FcmService.getToken();
    final now = DateTime.now().toIso8601String();
    final userUuid = const Uuid().v4();

    await db.insert('user_profile', {
      'id': 1,
      'uuid': userUuid,
      'nickname': nickname,
      'planet_name': '우리 별',
      'fcm_token': fcmToken,
      'created_at': now,
    });

    state = AsyncData(await _fetch());
  }

  /// Save partner's FCM token and UUID after successful pairing.
  Future<void> updatePartnerInfo({
    required String partnerFcm,
    required String partnerUuid,
  }) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'user_profile',
      {'partner_fcm': partnerFcm, 'partner_uuid': partnerUuid},
      where: 'id = ?',
      whereArgs: [1],
    );
    state = AsyncData(await _fetch());
  }

  /// Save partner's FCM token only (legacy backward compatibility).
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
