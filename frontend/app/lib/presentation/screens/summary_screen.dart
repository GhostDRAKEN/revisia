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
        child: ElevatedButton(
          onPressed: _isGeneratingQuiz ? null : _generateQuiz,
          child: _isGeneratingQuiz
              ? const Text('Génération en cours...')
              : const Text('Générer un quiz'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Points clés',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.summary.keyPoints
                    .map(
                      (point) => Chip(
                        label: Text(point),
                        backgroundColor: AppTheme.secondaryColor.withValues(
                          alpha: 0.1,
                        ),
                        side: BorderSide.none,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 28),
              Text(
                'Résumé complet',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Text(
                  widget.summary.fullSummary,
                  style: const TextStyle(height: 1.5),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
