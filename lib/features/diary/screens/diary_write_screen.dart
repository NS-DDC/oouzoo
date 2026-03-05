import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/diary_model.dart';
import '../../../core/services/admob_service.dart';
import '../../../core/utils/constants.dart';
import '../../planet/controllers/planet_controller.dart';
import '../controllers/diary_controller.dart';
import '../../planet/widgets/mood_selector.dart';

class DiaryWriteScreen extends ConsumerStatefulWidget {
  const DiaryWriteScreen({super.key});

  @override
  ConsumerState<DiaryWriteScreen> createState() => _DiaryWriteScreenState();
}

class _DiaryWriteScreenState extends ConsumerState<DiaryWriteScreen> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  int _mood = 3;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty) return;

    final diary = DiaryModel(
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      mood: _mood,
      createdAt: DateTime.now(),
    );

    await ref.read(diaryListProvider.notifier).addDiary(diary);
    await ref
        .read(planetProvider.notifier)
        .addShards(AppConstants.shardsPerDiary);

    // Probabilistic interstitial ad
    if (Random().nextDouble() < AppConstants.interstitialProbability) {
      final ad = await AdmobService.loadInterstitialAd();
      ad?.show();
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('✍️ 일기 쓰기'),
        actions: [
          TextButton(
            onPressed: _submit,
            child: const Text('저장', style: TextStyle(color: Color(0xFFFFD700))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: const InputDecoration(
                hintText: '제목',
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
              ),
            ),
            const Divider(color: Colors.white24),
            const SizedBox(height: 8),
            MoodSelector(
              currentMood: _mood,
              onMoodChanged: (m) => setState(() => _mood = m),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentCtrl,
              style: const TextStyle(color: Colors.white),
              maxLines: null,
              minLines: 10,
              decoration: const InputDecoration(
                hintText: '오늘 우주에서 있었던 일을 기록해요...',
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
