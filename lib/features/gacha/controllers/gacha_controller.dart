import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/data/gacha_pool.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/utils/constants.dart';
import '../../planet/controllers/planet_controller.dart';
import '../../planet/controllers/inventory_controller.dart';

class GachaState {
  final bool canUseFreeGacha;
  final GachaResult? lastResult;

  const GachaState({required this.canUseFreeGacha, this.lastResult});
}

/// 뽑기 결과
class GachaResult {
  final GachaItem item;
  final bool isDuplicate;
  final int? bonusShards; // 중복 시 보상 별 조각

  const GachaResult({
    required this.item,
    this.isDuplicate = false,
    this.bonusShards,
  });
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

    final result = await _rollAndSave();
    state = AsyncData(GachaState(canUseFreeGacha: false, lastResult: result));
  }

  Future<void> doAdGacha() async {
    final result = await _rollAndSave();
    state = AsyncData(
      GachaState(
        canUseFreeGacha: state.value?.canUseFreeGacha ?? false,
        lastResult: result,
      ),
    );
  }

  Future<void> doShardGacha() async {
    final planet = ref.read(planetProvider).value;
    if ((planet?.starShards ?? 0) < AppConstants.gachaCostInShards) return;

    await ref
        .read(planetProvider.notifier)
        .addShards(-AppConstants.gachaCostInShards);

    final result = await _rollAndSave();
    state = AsyncData(
      GachaState(
        canUseFreeGacha: state.value?.canUseFreeGacha ?? false,
        lastResult: result,
      ),
    );
  }

  /// 가중 랜덤 뽑기 (풀 데이터 기반)
  GachaItem _roll() {
    final rand = Random().nextDouble();
    double cumulative = 0;
    for (final item in gachaPool) {
      cumulative += item.dropRate;
      if (rand < cumulative) return item;
    }
    return gachaPool.last;
  }

  /// 뽑기 + 저장 + 중복 처리
  Future<GachaResult> _rollAndSave() async {
    final item = _roll();
    final db = await DatabaseHelper.instance.database;

    // 가차 로그 기록
    await db.insert('gacha_log', {
      'item_id': item.id,
      'result_type': item.rarity.name,
      'created_at': DateTime.now().toIso8601String(),
    });

    // 이미 보유 중인지 확인
    final existing = await db.query(
      'inventory',
      where: 'item_id = ?',
      whereArgs: [item.id],
    );

    if (existing.isNotEmpty) {
      // 중복: 별 조각 보상
      await ref.read(planetProvider.notifier).addShards(gachaDuplicateShards);
      // 인벤토리 새로고침
      ref.invalidate(inventoryProvider);
      return GachaResult(
        item: item,
        isDuplicate: true,
        bonusShards: gachaDuplicateShards,
      );
    }

    // 신규: 인벤토리에 추가 (올바른 타입으로 저장)
    await db.rawInsert(
      'INSERT OR IGNORE INTO inventory (item_id, item_type, equipped, obtained_at) VALUES (?, ?, 0, ?)',
      [item.id, item.type.name, DateTime.now().toIso8601String()],
    );
    // 인벤토리 새로고침
    ref.invalidate(inventoryProvider);
    return GachaResult(item: item);
  }
}
