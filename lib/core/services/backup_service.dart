import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

import '../database/database_helper.dart';

/// 로컬 SQLite → JSON 내보내기/가져오기
/// 클라우드 서버 없이 기기 간 데이터 이전 지원.
class BackupService {
  static final BackupService instance = BackupService._();
  BackupService._();

  /// Export all tables to JSON and share via OS share sheet.
  Future<void> exportBackup() async {
    final db = await DatabaseHelper.instance.database;

    final backup = {
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'user_profile': await db.query('user_profile'),
      'planet': await db.query('planet'),
      'inventory': await db.query('inventory'),
      'diary': await db.query('diary'),
      'anniversary': await db.query('anniversary'),
      'purchases': await db.query('purchases'),
    };

    final json = jsonEncode(backup);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/oouzoo_backup.json');
    await file.writeAsString(json);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'OOUZOO 백업 파일',
    );
  }

  /// Import JSON backup and overwrite local DB.
  Future<bool> importBackup() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.single.path == null) return false;

    final file = File(result.files.single.path!);
    final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;

    if ((json['version'] as int?) != 1) return false;

    final db = await DatabaseHelper.instance.database;
    await db.transaction((txn) async {
      for (final table in [
        'user_profile',
        'planet',
        'inventory',
        'diary',
        'anniversary',
        'purchases',
      ]) {
        await txn.delete(table);
        for (final row in (json[table] as List)) {
          await txn.insert(table, Map<String, dynamic>.from(row as Map));
        }
      }
    });

    return true;
  }
}
