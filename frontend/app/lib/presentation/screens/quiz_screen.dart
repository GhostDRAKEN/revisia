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
    if (option == _currentQuestion.answer) return const Color(0xFFDCFCE7);
    if (option == _selectedOption) return const Color(0xFFFEE2E2);
    return Colors.white;
  }

  Color _optionBorderColor(String option) {
    if (!_hasAnswered) return const Color(0xFFE5E7EB);
    if (option == _currentQuestion.answer) return const Color(0xFF16A34A);
    if (option == _selectedOption) return const Color(0xFFDC2626);
    return const Color(0xFFE5E7EB);
  }

  @override
  Widget build(BuildContext context) {
    final question = _currentQuestion;
    final progress = (_currentIndex + 1) / widget.quiz.quiz.length;

    return Scaffold(
      appBar: AppBar(title: Text(widget.quiz.title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Question ${_currentIndex + 1}/${widget.quiz.quiz.length}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 28),
              Text(
                question.question,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 24),
              ...question.options.map(
                (option) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => _selectOption(option),
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _optionColor(option),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _optionBorderColor(option)),
                      ),
                      child: Text(
                        option,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ),
              if (_hasAnswered) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(question.explanation),
                ),
              ],
              const Spacer(),
              ElevatedButton(
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
    );
  }
}
