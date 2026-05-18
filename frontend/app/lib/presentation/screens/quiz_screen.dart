import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/quiz_model.dart';
import 'score_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.quiz});

  final QuizModel quiz;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  String? _selectedOption;

  QuizQuestionModel get _currentQuestion => widget.quiz.quiz[_currentIndex];
  bool get _hasAnswered => _selectedOption != null;

  void _selectOption(String option) {
    if (_hasAnswered) return;

    setState(() {
      _selectedOption = option;
      if (option == _currentQuestion.answer) _score += 1;
    });
  }

  void _nextQuestion() {
    if (_currentIndex == widget.quiz.quiz.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ScoreScreen(score: _score, total: widget.quiz.quiz.length),
        ),
      );
      return;
    }

    setState(() {
      _currentIndex += 1;
      _selectedOption = null;
    });
  }

  Color _optionColor(String option) {
    if (!_hasAnswered) return Colors.white;
    if (option == _currentQuestion.answer) return const Color(0xFFE7F8EF);
    if (option == _selectedOption) return const Color(0xFFFFECEC);
    return Colors.white;
  }

  Color _optionBorderColor(String option) {
    if (!_hasAnswered) return Colors.white;
    if (option == _currentQuestion.answer) return const Color(0xFF16A34A);
    if (option == _selectedOption) return const Color(0xFFDC2626);
    return Colors.white;
  }

  IconData? _optionIcon(String option) {
    if (!_hasAnswered) return null;
    if (option == _currentQuestion.answer) return Icons.check_circle_rounded;
    if (option == _selectedOption) return Icons.cancel_rounded;
    return null;
  }

  Color _optionIconColor(String option) {
    if (option == _currentQuestion.answer) return const Color(0xFF16A34A);
    return const Color(0xFFDC2626);
  }

  @override
  Widget build(BuildContext context) {
    final question = _currentQuestion;
    final progress = (_currentIndex + 1) / widget.quiz.quiz.length;

    return Scaffold(
      appBar: AppBar(title: Text(widget.quiz.title)),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppTheme.softBackgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Question ${_currentIndex + 1}/${widget.quiz.quiz.length}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    color: AppTheme.primaryColor,
                    backgroundColor: const Color(0xFFDDE7FF),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  question.question,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textColor,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 24),
                ...question.options.map(
                  (option) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _OptionCard(
                      option: option,
                      isSelected: option == _selectedOption,
                      color: _optionColor(option),
                      borderColor: _optionBorderColor(option),
                      icon: _optionIcon(option),
                      iconColor: _optionIconColor(option),
                      onTap: () => _selectOption(option),
                    ),
                  ),
                ),
                if (_hasAnswered) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: AppTheme.premiumCardDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.white, Color(0xFFEFF6FF)],
                      ),
                      borderColor: Colors.white,
                    ),
                    child: Text(
                      question.explanation,
                      style: const TextStyle(height: 1.45),
                    ),
                  ),
                ],
                const Spacer(),
                GradientButton(
                  onPressed: _hasAnswered ? _nextQuestion : null,
                  child: Text(
                    _currentIndex == widget.quiz.quiz.length - 1
                        ? 'Voir le score'
                        : 'Question suivante',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.option,
    required this.isSelected,
    required this.color,
    required this.borderColor,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  final String option;
  final bool isSelected;
  final Color color;
  final Color borderColor;
  final IconData? icon;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedScale(
        scale: isSelected ? 1.02 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.4),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  option,
                  style: const TextStyle(
                    color: AppTheme.textColor,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ),
              if (icon != null) Icon(icon, color: iconColor),
            ],
          ),
        ),
      ),
    );
  }
}
