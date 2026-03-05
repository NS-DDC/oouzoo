import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/models/anniversary_model.dart';

final anniversaryListProvider =
    AsyncNotifierProvider<AnniversaryNotifier, List<AnniversaryModel>>(
        AnniversaryNotifier.new);

/// 커플 시작일 (D+Day 기준)
final coupleStartAnniversaryProvider = Provider<AsyncValue<AnniversaryModel?>>((ref) {
  return ref.watch(anniversaryListProvider).whenData(
        (list) => list.where((a) => a.isCoupleStart).firstOrNull,
      );
});

class AnniversaryNotifier extends AsyncNotifier<List<AnniversaryModel>> {
  @override
  Future<List<AnniversaryModel>> build() => _fetchAll();

  Future<List<AnniversaryModel>> _fetchAll() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('anniversary', orderBy: 'date ASC');
    return rows.map(AnniversaryModel.fromMap).toList();
  }

  Future<void> addAnniversary(AnniversaryModel ann) async {
    final db = await DatabaseHelper.instance.database;
    // Only one couple start date
    if (ann.isCoupleStart) {
      await db.delete('anniversary',
          where: 'is_couple_start = ?', whereArgs: [1]);
    }
    await db.insert('anniversary', ann.toMap());
    state = AsyncData(await _fetchAll());
  }

  Future<void> deleteAnniversary(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('anniversary', where: 'id = ?', whereArgs: [id]);
    state = AsyncData(
      state.value?.where((a) => a.id != id).toList() ?? [],
    );
  }
}
