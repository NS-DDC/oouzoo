import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../controllers/daily_question_controller.dart';

class QuestionHistoryScreen extends ConsumerWidget {
  const QuestionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(questionHistoryProvider);

    return Scaffold(
      backgroundColor: AppTheme.starBlack,
      appBar: AppBar(
        title: const Text('질문 기록'),
        backgroundColor: AppTheme.deepSpace,
      ),
      body: historyAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('📝', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 16),
                  Text(
                    '아직 기록이 없어요',
                    style: TextStyle(color: Colors.white54, fontSize: 15),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '오늘의 질문에 답변해보세요!',
                    style: TextStyle(color: Colors.white24, fontSize: 12),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final q = list[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E3A),
                  borderRadius: BorderRadius.circular(16),
                  border: q.bothAnswered
                      ? Border.all(
                          color: AppTheme.starYellow.withOpacity(0.3),
                        )
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date + completion status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          q.date,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                        if (q.bothAnswered)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.starYellow.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '완료',
                              style: TextStyle(
                                color: AppTheme.starYellow,
                                fontSize: 10,
                              ),
                            ),
                          )
                        else if (q.iAnswered)
                          const Text(
                            '대기 중...',
                            style: TextStyle(
                              color: Colors.white24,
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Question
                    Text(
                      q.question,
                      style: const TextStyle(
                        color: AppTheme.moonWhite,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Answers
                    if (q.iAnswered) ...[
                      _HistoryAnswer(
                        label: '나',
                        answer: q.myAnswer!,
                        color: AppTheme.starYellow,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (q.partnerAnswered)
                      _HistoryAnswer(
                        label: '상대',
                        answer: q.partnerAnswer!,
                        color: AppTheme.accentPink,
                      )
                    else if (q.iAnswered)
                      const Text(
                        '상대방 답변 대기 중...',
                        style: TextStyle(
                          color: Colors.white24,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                    if (!q.iAnswered)
                      const Text(
                        '답변하지 않음',
                        style: TextStyle(
                          color: Colors.white24,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              );
            },
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
}

class _HistoryAnswer extends StatelessWidget {
  final String label;
  final String answer;
  final Color color;

  const _HistoryAnswer({
    required this.label,
    required this.answer,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: TextStyle(color: color, fontSize: 11),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            answer,
            style: const TextStyle(
              color: AppTheme.moonWhite,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
