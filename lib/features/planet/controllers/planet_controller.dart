import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/models/planet_model.dart';
import '../../../core/utils/constants.dart';

final planetProvider =
    AsyncNotifierProvider<PlanetNotifier, PlanetModel?>(PlanetNotifier.new);

class PlanetNotifier extends AsyncNotifier<PlanetModel?> {
  @override
  Future<PlanetModel?> build() => _fetch();

  Future<PlanetModel?> _fetch() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('planet', where: 'id = ?', whereArgs: [1]);
    if (rows.isEmpty) return null;
    return PlanetModel.fromMap(rows.first);
  }

  Future<void> addShards(int amount) async {
    final db = await DatabaseHelper.instance.database;
    final current = state.value;
    if (current == null) return;

    final newShards = current.starShards + amount;
    await db.update(
      'planet',
      {'star_shards': newShards, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [1],
    );
    state = AsyncData(current.copyWith(starShards: newShards));
  }

  /// Daily login reward
  Future<void> claimDailyLogin() async {
    await addShards(AppConstants.shardsPerDailyLogin);
  }

  Future<void> levelUp() async {
    final current = state.value;
    if (current == null || !current.canLevelUp) return;

    final db = await DatabaseHelper.instance.database;
    final newLevel = current.level + 1;
    await db.update(
      'planet',
      {'level': newLevel, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [1],
    );
    state = AsyncData(current.copyWith(level: newLevel));
  }

  Future<void> updateMood(int mood) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'planet',
      {'mood': mood, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [1],
    );
    state = AsyncData(state.value?.copyWith(mood: mood));
  }
}
