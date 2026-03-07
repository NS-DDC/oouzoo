import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/theme_model.dart';

/// 현재 선택된 테마 (SharedPreferences 기반)
final themeProvider =
    AsyncNotifierProvider<ThemeNotifier, PlanetTheme>(ThemeNotifier.new);

class ThemeNotifier extends AsyncNotifier<PlanetTheme> {
  static const _prefKey = 'selected_theme';

  @override
  Future<PlanetTheme> build() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_prefKey) ?? 'default';
    return getThemeById(id);
  }

  Future<void> selectTheme(String themeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, themeId);
    state = AsyncData(getThemeById(themeId));
  }

  /// 테마를 소유하고 있는지 확인 (구매 여부)
  Future<bool> isOwned(PlanetTheme theme) async {
    if (!theme.isPremium) return true;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('theme_owned_${theme.id}') ?? false;
  }

  /// 테마 소유 등록 (IAP 구매 완료 시)
  Future<void> markOwned(String themeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('theme_owned_$themeId', true);
  }
}
