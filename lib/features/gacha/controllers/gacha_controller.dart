import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/utils/constants.dart';
import '../../planet/controllers/planet_controller.dart';

class GachaState {
  final bool canUseFreeGacha;
  final String? lastResult;

  const GachaState({required this.canUseFreeGacha, this.lastResult});
}

final gachaProvider =
    AsyncNotifierProvider<GachaNotifier, GachaState>(GachaNotifier.new);

class GachaNotifier extends AsyncNotifier<GachaState> {
  static const _prefKey = 'last_free_gacha_date';

  @override
  Future<GachaState> build() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString(_prefKey);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return GachaState(canUseFreeGacha: lastDate != today);
  }

  Future<void> doFreeGacha() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await prefs.setString(_prefKey, today);

    final item = _roll();
    await _saveResult(item);
    state = AsyncData(GachaState(canUseFreeGacha: false, lastResult: item));
  }

  Future<void> doAdGacha() async {
    final item = _roll();
    await _saveResult(item);
    state = AsyncData(
      GachaState(
          canUseFreeGacha: state.value?.canUseFreeGacha ?? false,
          lastResult: item),
    );
  }

  Future<void> doShardGacha() async {
    final planet = ref.read(planetProvider).value;
    if ((planet?.starShards ?? 0) < AppConstants.gachaCostInShards) return;

    await ref
        .read(planetProvider.notifier)
        .addShards(-AppConstants.gachaCostInShards);

    final item = _roll();
    await _saveResult(item);
    state = AsyncData(
      GachaState(
          canUseFreeGacha: state.value?.canUseFreeGacha ?? false,
          lastResult: item),
    );
  }

  /// Simple weighted roll — replace with actual item pool
  String _roll() {
    final r = Random().nextDouble();
    if (r < 0.05) return 'rare_background';
    if (r < 0.20) return 'uncommon_decoration';
    return 'common_sticker';
  }

  Future<void> _saveResult(String itemId) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('gacha_log', {
      'item_id': itemId,
      'result_type': 'normal',
      'created_at': DateTime.now().toIso8601String(),
    });
    // Also add to inventory if not already owned
    await db.rawInsert(
      'INSERT OR IGNORE INTO inventory (item_id, item_type, equipped, obtained_at) VALUES (?, ?, 0, ?)',
      [itemId, 'decoration', DateTime.now().toIso8601String()],
    );
  }
}
