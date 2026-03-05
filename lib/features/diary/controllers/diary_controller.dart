import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/models/diary_model.dart';

final diaryListProvider =
    AsyncNotifierProvider<DiaryNotifier, List<DiaryModel>>(DiaryNotifier.new);

class DiaryNotifier extends AsyncNotifier<List<DiaryModel>> {
  @override
  Future<List<DiaryModel>> build() => _fetchAll();

  Future<List<DiaryModel>> _fetchAll() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('diary', orderBy: 'created_at DESC');
    return rows.map(DiaryModel.fromMap).toList();
  }

  Future<void> addDiary(DiaryModel diary) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('diary', diary.toMap());
    state = AsyncData([diary, ...?state.value]);
  }

  Future<void> deleteDiary(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('diary', where: 'id = ?', whereArgs: [id]);
    state = AsyncData(
      state.value?.where((d) => d.id != id).toList() ?? [],
    );
  }
}
