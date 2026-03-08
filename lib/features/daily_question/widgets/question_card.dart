import 'package:flutter/material.dart';

import '../../../core/data/question_pool.dart';
import '../../../shared/theme/app_theme.dart';

class QuestionCard extends StatelessWidget {
  final String question;
  final QuestionCategory? category;

  const QuestionCard({
    super.key,
    required this.question,
    this.category,
  });

  String get _categoryEmoji {
    switch (category) {
      case QuestionCategory.love:
        return '💕';
      case QuestionCategory.memory:
        return '📸';
      case QuestionCategory.future:
        return '🚀';
      case QuestionCategory.fun:
        return '🎲';
      case QuestionCategory.deep:
        return '🌊';
      case null:
        return '✨';
    }
  }

  String get _categoryLabel {
    switch (category) {
      case QuestionCategory.love:
        return '사랑';
      case QuestionCategory.memory:
        return '추억';
      case QuestionCategory.future:
        return '미래';
      case QuestionCategory.fun:
        return '재미';
      case QuestionCategory.deep:
        return '깊은 대화';
      case null:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.nebulaPurple.withAlpha(102),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.starYellow.withAlpha(102),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.nebulaPurple.withAlpha(77),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Category badge
          if (category != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.deepSpace,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_categoryEmoji $_categoryLabel',
                style: const TextStyle(
                  color: AppTheme.moonWhite,
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(height: 20),

          // Question text
          Text(
            question,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.moonWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
