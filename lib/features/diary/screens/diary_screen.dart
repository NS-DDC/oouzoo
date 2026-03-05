import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/diary_controller.dart';
import '../screens/diary_write_screen.dart';
import '../widgets/diary_list_item.dart';

class DiaryScreen extends ConsumerWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diaries = ref.watch(diaryListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('📖 우주 일기'),
        backgroundColor: Colors.transparent,
      ),
      body: diaries.when(
        data: (list) => list.isEmpty
            ? const Center(
                child: Text(
                  '아직 기록이 없어요.\n첫 번째 우주 일기를 작성해보세요 ✨',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (_, i) => DiaryListItem(diary: list[i]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DiaryWriteScreen()),
        ),
        backgroundColor: const Color(0xFFFFD700),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
