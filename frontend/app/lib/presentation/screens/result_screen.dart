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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.document.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _StatChip(
                    icon: Icons.description_outlined,
                    label: '${widget.document.pageCount} pages',
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    icon: Icons.notes_outlined,
                    label: '${widget.document.wordCount} mots',
                  ),
                ],
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 28),
              _ActionCard(
                title: 'Résumé',
                description: 'Obtiens les points clés et un résumé structuré.',
                icon: Icons.summarize_outlined,
                isLoading: _isGeneratingSummary,
                onTap: isBusy ? null : _generateSummary,
              ),
              const SizedBox(height: 16),
              _ActionCard(
                title: 'Quiz',
                description: 'Teste ta compréhension avec des QCM corrigés.',
                icon: Icons.quiz_outlined,
                isLoading: _isGeneratingQuiz,
                onTap: isBusy ? null : _generateQuiz,
              ),
            ],
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
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      backgroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFFE5E7EB)),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isLoading,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 34),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(description),
                ],
              ),
            ),
            if (isLoading)
              const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
