import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/summary_model.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/generation_service.dart';
import 'quiz_screen.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key, required this.summary, this.documentId});

  final SummaryModel summary;
  final String? documentId;

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  bool _isGeneratingQuiz = false;
  String? _errorMessage;

  Future<void> _generateQuiz() async {
    final documentId = widget.documentId;

    if (documentId == null) {
      setState(() => _errorMessage = 'Document introuvable');
      return;
    }

    setState(() {
      _isGeneratingQuiz = true;
      _errorMessage = null;
    });

    try {
      final quiz = await context.read<GenerationService>().generateQuiz(
        documentId: documentId,
      );

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => QuizScreen(quiz: quiz)),
      );
    } on ApiException catch (error) {
      setState(() => _errorMessage = error.message);
    } catch (_) {
      setState(() => _errorMessage = 'Une erreur est survenue, réessayez');
    } finally {
      if (mounted) setState(() => _isGeneratingQuiz = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.summary.title)),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(24),
        child: GradientButton(
          onPressed: _isGeneratingQuiz ? null : _generateQuiz,
          isLoading: _isGeneratingQuiz,
          child: const Text('Générer un quiz'),
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppTheme.softBackgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Points clés',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 14),
                ...widget.summary.keyPoints.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _KeyPointCard(
                      number: entry.key + 1,
                      text: entry.value,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Résumé complet',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: AppTheme.premiumCardDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.white, Color(0xFFF8FAFC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderColor: Colors.white,
                  ),
                  child: Text(
                    widget.summary.fullSummary,
                    style: const TextStyle(height: 1.58, fontSize: 15),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KeyPointCard extends StatelessWidget {
  const _KeyPointCard({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.premiumCardDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF0FDFA), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderColor: Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.textColor,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
