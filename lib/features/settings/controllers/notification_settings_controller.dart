import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 매일 푸시 알림 시간 설정 (SharedPreferences 기반)
final notificationTimeProvider =
    AsyncNotifierProvider<NotificationTimeNotifier, TimeOfDay>(
        NotificationTimeNotifier.new);

class NotificationTimeNotifier extends AsyncNotifier<TimeOfDay> {
  static const _hourKey = 'notification_hour';
  static const _minuteKey = 'notification_minute';
  static const _defaultHour = 20; // 오후 8시
  static const _defaultMinute = 0;

  @override
  Future<TimeOfDay> build() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_hourKey) ?? _defaultHour;
    final minute = prefs.getInt(_minuteKey) ?? _defaultMinute;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> setTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_hourKey, time.hour);
    await prefs.setInt(_minuteKey, time.minute);
    state = AsyncData(time);
  }
}
