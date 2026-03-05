import 'package:flutter/material.dart';

import '../../../core/services/backup_service.dart';

class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('💾 데이터 백업/복구')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '모든 데이터는 기기에 저장됩니다.\n새 기기로 이전할 때 백업 파일을 공유하세요.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload),
              label: const Text('백업 내보내기 (JSON)'),
              onPressed: () async {
                await BackupService.instance.exportBackup();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('백업 파일이 생성되었습니다.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('백업 가져오기 (복원)'),
              onPressed: () async {
                final ok = await BackupService.instance.importBackup();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok ? '복원이 완료되었습니다.' : '복원에 실패했습니다.'),
                    ),
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
