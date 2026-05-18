import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/document_model.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/generation_service.dart';
import 'quiz_screen.dart';
import 'summary_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.document});

  final DocumentModel document;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isGeneratingSummary = false;
  bool _isGeneratingQuiz = false;
  String? _errorMessage;

  Future<void> _generateSummary() async {
    setState(() {
      _isGeneratingSummary = true;
      _errorMessage = null;
    });

    try {
      final summary = await context.read<GenerationService>().generateSummary(
        documentId: widget.document.documentId,
      );

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SummaryScreen(
            summary: summary,
            documentId: widget.document.documentId,
          ),
        ),
      );
    } on ApiException catch (error) {
      setState(() => _errorMessage = error.message);
    } catch (_) {
      setState(() => _errorMessage = 'Une erreur est survenue, réessayez');
    } finally {
      if (mounted) setState(() => _isGeneratingSummary = false);
    }
  }

  Future<void> _generateQuiz() async {
    setState(() {
      _isGeneratingQuiz = true;
      _errorMessage = null;
    });

    try {
      final quiz = await context.read<GenerationService>().generateQuiz(
        documentId: widget.document.documentId,
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
    final isBusy = _isGeneratingSummary || _isGeneratingQuiz;

    return Scaffold(
      appBar: AppBar(title: const Text('Résultat')),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppTheme.softBackgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.document.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _StatChip(
                      icon: Icons.description_rounded,
                      label: '${widget.document.pageCount} pages',
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      icon: Icons.notes_rounded,
                      label: '${widget.document.wordCount} mots',
                    ),
                  ],
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                const SizedBox(height: 30),
                _ActionCard(
                  title: 'Résumé',
                  description: 'Points clés, idées fortes et synthèse claire.',
                  icon: Icons.auto_stories_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEFF6FF), Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  iconColor: AppTheme.primaryColor,
                  isLoading: _isGeneratingSummary,
                  onTap: isBusy ? null : _generateSummary,
                ),
                const SizedBox(height: 18),
                _ActionCard(
                  title: 'Quiz',
                  description: 'Questions ciblées avec corrections immédiates.',
                  icon: Icons.quiz_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF0FDFA), Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  iconColor: AppTheme.secondaryColor,
                  isLoading: _isGeneratingQuiz,
                  onTap: isBusy ? null : _generateQuiz,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryColor),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.iconColor,
    required this.isLoading,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Gradient gradient;
  final Color iconColor;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.premiumCardDecoration(
          gradient: gradient,
          borderColor: Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppTheme.mutedTextColor,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(Icons.chevron_right_rounded, color: iconColor, size: 30),
          ],
        ),
      ),
    );
  }
}
