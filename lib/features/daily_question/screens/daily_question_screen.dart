import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/question_pool.dart';
import '../../../shared/theme/app_theme.dart';
import '../controllers/daily_question_controller.dart';
import '../widgets/answer_reveal.dart';
import '../widgets/question_card.dart';
import 'question_history_screen.dart';

class DailyQuestionScreen extends ConsumerStatefulWidget {
  const DailyQuestionScreen({super.key});

  @override
  ConsumerState<DailyQuestionScreen> createState() =>
      _DailyQuestionScreenState();
}

class _DailyQuestionScreenState extends ConsumerState<DailyQuestionScreen> {
  final _answerCtrl = TextEditingController();

  @override
  void dispose() {
    _answerCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitAnswer() async {
    final answer = _answerCtrl.text.trim();
    if (answer.isEmpty) return;

    await ref.read(dailyQuestionProvider.notifier).submitAnswer(answer);
    _answerCtrl.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('답변 완료! ⭐ 별 조각 +15'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionAsync = ref.watch(dailyQuestionProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('오늘의 질문'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: '질문 기록',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const QuestionHistoryScreen(),
              ),
            ),
          ),
        ],
      ),
      body: questionAsync.when(
        data: (question) {
          if (question == null) {
            return const Center(
              child: Text(
                '질문을 불러오는 중...',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          // Find category for this question
          final entry = questionPool
              .where((q) => q.id == question.questionId)
              .firstOrNull;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Date
                Text(
                  question.date,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),

                // Question card
                QuestionCard(
                  question: question.question,
                  category: entry?.category,
                ),
                const SizedBox(height: 32),

                // ── State-based content ──
                if (question.bothAnswered)
                  // Both answered: show reveal
                  _buildBothAnswered(question.myAnswer!, question.partnerAnswer!)
                else if (question.iAnswered)
                  // I answered, waiting for partner
                  _buildWaitingForPartner(question.myAnswer!)
                else
                  // Not answered yet: show input
                  _buildAnswerInput(),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.starYellow),
        ),
        error: (e, _) => Center(
          child: Text('$e', style: const TextStyle(color: Colors.redAccent)),
        ),
      ),
    );
  }

  Widget _buildAnswerInput() {
    return Column(
      children: [
        TextField(
          controller: _answerCtrl,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          maxLines: 4,
          maxLength: 300,
          decoration: InputDecoration(
            hintText: '나의 답변을 적어주세요...',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF1E1E3A),
            counterStyle: const TextStyle(color: Colors.white24),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(20),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _submitAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.nebulaPurple,
              foregroundColor: AppTheme.moonWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('답변 보내기 ✨', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildWaitingForPartner(String myAnswer) {
    return Column(
      children: [
        // My answer (visible)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.nebulaPurple.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.starYellow.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '나의 답변',
                style: TextStyle(
                  color: AppTheme.starYellow,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                myAnswer,
                style: const TextStyle(
                  color: AppTheme.moonWhite,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Waiting indicator
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E3A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white12,
            ),
          ),
          child: const Column(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.accentPink,
                ),
              ),
              SizedBox(height: 12),
              Text(
                '상대방의 답변을 기다리는 중...',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                '답변이 도착하면 함께 공개돼요 ✨',
                style: TextStyle(color: Colors.white24, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBothAnswered(String myAnswer, String partnerAnswer) {
    return Column(
      children: [
        // Celebration
        const Text(
          '🎉 둘 다 답변 완료!',
          style: TextStyle(
            color: AppTheme.starYellow,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '보너스 별 조각 +10 ⭐',
          style: TextStyle(color: AppTheme.accentPink, fontSize: 12),
        ),
        const SizedBox(height: 20),

        // Animated reveal
        AnswerReveal(
          myAnswer: myAnswer,
          partnerAnswer: partnerAnswer,
        ),
      ],
    );
  }
}
