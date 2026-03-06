import 'package:flutter/material.dart';

import '../../../shared/theme/app_theme.dart';

class AnswerReveal extends StatefulWidget {
  final String myAnswer;
  final String partnerAnswer;

  const AnswerReveal({
    super.key,
    required this.myAnswer,
    required this.partnerAnswer,
  });

  @override
  State<AnswerReveal> createState() => _AnswerRevealState();
}

class _AnswerRevealState extends State<AnswerReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _mySlide;
  late Animation<Offset> _partnerSlide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _mySlide = Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    ));

    _partnerSlide = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.9, curve: Curves.easeOutCubic),
    ));

    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeIn),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Column(
        children: [
          // My answer
          SlideTransition(
            position: _mySlide,
            child: FadeTransition(
              opacity: _fade,
              child: _AnswerCard(
                label: '나의 답변',
                answer: widget.myAnswer,
                color: AppTheme.nebulaPurple,
                borderColor: AppTheme.starYellow,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Partner answer
          SlideTransition(
            position: _partnerSlide,
            child: FadeTransition(
              opacity: _fade,
              child: _AnswerCard(
                label: '상대방의 답변',
                answer: widget.partnerAnswer,
                color: AppTheme.accentPink.withOpacity(0.2),
                borderColor: AppTheme.accentPink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  final String label;
  final String answer;
  final Color color;
  final Color borderColor;

  const _AnswerCard({
    required this.label,
    required this.answer,
    required this.color,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor.withOpacity(0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: borderColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: const TextStyle(
              color: AppTheme.moonWhite,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
