import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/question_pool.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/daily_question_model.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/utils/channel_utils.dart';
import '../../../core/utils/constants.dart';
import '../../pairing/controllers/user_profile_controller.dart';
import '../../planet/controllers/planet_controller.dart';

// ── Today's question ──
final dailyQuestionProvider =
    AsyncNotifierProvider<DailyQuestionNotifier, DailyQuestionModel?>(
        DailyQuestionNotifier.new);

class DailyQuestionNotifier extends AsyncNotifier<DailyQuestionModel?> {
  StreamSubscription? _answerListener;

  @override
  Future<DailyQuestionModel?> build() async {
    ref.onDispose(() => _answerListener?.cancel());
    final result = await _fetchToday();
    _startListeningForPartnerAnswer();
    return result;
  }

  Future<DailyQuestionModel?> _fetchToday() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'daily_question',
      where: 'date = ?',
      whereArgs: [today],
    );

    if (rows.isNotEmpty) {
      return DailyQuestionModel.fromMap(rows.first);
    }

    // First access today: create today's question row
    final qId = getTodayQuestionId();
    final entry = questionPool.firstWhere((q) => q.id == qId);
    final model = DailyQuestionModel(
      questionId: qId,
      question: entry.question,
      date: today,
    );
    await db.insert('daily_question', model.toMap());

    final inserted = await db.query(
      'daily_question',
      where: 'date = ?',
      whereArgs: [today],
    );
    return DailyQuestionModel.fromMap(inserted.first);
  }

  /// Submit my answer for today's question.
  Future<void> submitAnswer(String answer) async {
    final db = await DatabaseHelper.instance.database;
    final current = state.value;
    if (current == null || current.iAnswered) return;

    final now = DateTime.now().toIso8601String();
    await db.update(
      'daily_question',
      {'my_answer': answer, 'answered_at': now},
      where: 'id = ?',
      whereArgs: [current.id],
    );

    // Award star shards for answering
    await ref
        .read(planetProvider.notifier)
        .addShards(AppConstants.shardsPerDailyAnswer);

    final updated = current.copyWith(
      myAnswer: answer,
      answeredAt: DateTime.parse(now),
    );

    // Check if both answered for bonus
    if (updated.bothAnswered) {
      await ref
          .read(planetProvider.notifier)
          .addShards(AppConstants.shardsPerBothAnswered);
    }

    state = AsyncData(updated);

    // Relay answer to partner via Firebase
    _relayAnswerToPartner(answer, current.date);
  }

  /// Relay my answer to partner via Firebase.
  Future<void> _relayAnswerToPartner(String answer, String date) async {
    final profile = ref.read(userProfileProvider).value;
    if (profile == null || !profile.isPaired) return;

    try {
      final channelId = generateChannelId(
        profile.id.toString(),
        profile.partnerFcm!,
      );
      await FirebaseService.instance.sendDailyAnswer(
        channelId: channelId,
        payload: {
          'sender_id': profile.id.toString(),
          'answer': answer,
          'date': date,
          'sent_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('[DailyQuestion] relay error: $e');
    }
  }

  /// Receive partner's answer from Firebase relay.
  Future<void> receivePartnerAnswer(String answer, String date) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now().toIso8601String();

    // Update the matching date row
    await db.update(
      'daily_question',
      {'partner_answer': answer, 'partner_answered_at': now},
      where: 'date = ?',
      whereArgs: [date],
    );

    // If this is today's question, update state
    final current = state.value;
    if (current != null && current.date == date) {
      final updated = current.copyWith(
        partnerAnswer: answer,
        partnerAnsweredAt: DateTime.parse(now),
      );

      // Bonus if both answered
      if (updated.bothAnswered && current.iAnswered) {
        await ref
            .read(planetProvider.notifier)
            .addShards(AppConstants.shardsPerBothAnswered);
      }

      state = AsyncData(updated);
    }

    // Refresh history if it's being watched
    ref.invalidate(questionHistoryProvider);
  }

  /// Listen for partner's daily answer via Firebase.
  void _startListeningForPartnerAnswer() {
    final profile = ref.read(userProfileProvider).value;
    if (profile == null || !profile.isPaired) return;

    final channelId = generateChannelId(
      profile.id.toString(),
      profile.partnerFcm!,
    );

    _answerListener?.cancel();
    _answerListener =
        FirebaseService.instance.listenForDailyAnswers(channelId).listen(
      (event) {
        if (event.snapshot.value == null) return;
        final data = event.snapshot.value as Map;
        final answer = data['answer'] as String;
        final date = data['date'] as String;
        receivePartnerAnswer(answer, date);
      },
    );
  }
}

// ── Question history ──
final questionHistoryProvider =
    AsyncNotifierProvider<QuestionHistoryNotifier, List<DailyQuestionModel>>(
        QuestionHistoryNotifier.new);

class QuestionHistoryNotifier
    extends AsyncNotifier<List<DailyQuestionModel>> {
  @override
  Future<List<DailyQuestionModel>> build() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('daily_question', orderBy: 'date DESC');
    return rows.map(DailyQuestionModel.fromMap).toList();
  }
}
