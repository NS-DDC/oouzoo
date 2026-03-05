import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/anniversary_model.dart';
import '../controllers/anniversary_controller.dart';

class AnniversaryScreen extends ConsumerWidget {
  const AnniversaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(anniversaryListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('🗓️ 기념일')),
      body: list.when(
        data: (anns) => ListView.builder(
          itemCount: anns.length,
          itemBuilder: (_, i) {
            final ann = anns[i];
            final daysUntil = ann.daysUntil();
            return ListTile(
              leading: Text(ann.isCoupleStart ? '💑' : '🎉',
                  style: const TextStyle(fontSize: 24)),
              title: Text(ann.label,
                  style: const TextStyle(color: Colors.white)),
              subtitle: Text(
                DateFormat('MM.dd').format(ann.date),
                style: const TextStyle(color: Colors.white54),
              ),
              trailing: Text(
                daysUntil == 0 ? 'D-Day! 🎊' : 'D-$daysUntil',
                style: TextStyle(
                  color: daysUntil == 0
                      ? const Color(0xFFFFD700)
                      : Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final labelCtrl = TextEditingController();
    DateTime? picked = DateTime.now();
    bool isCoupleStart = false;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E3A),
        title: const Text('기념일 추가', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: '기념일 이름',
                hintStyle: TextStyle(color: Colors.white38),
              ),
            ),
            const SizedBox(height: 12),
            StatefulBuilder(
              builder: (_, setState) => CheckboxListTile(
                title: const Text('커플 시작일 (D+Day 기준)',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                value: isCoupleStart,
                onChanged: (v) => setState(() => isCoupleStart = v ?? false),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (labelCtrl.text.trim().isEmpty || picked == null) return;
              await ref.read(anniversaryListProvider.notifier).addAnniversary(
                    AnniversaryModel(
                      label: labelCtrl.text.trim(),
                      date: picked!,
                      isCoupleStart: isCoupleStart,
                    ),
                  );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }
}
