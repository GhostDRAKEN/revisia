import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'home_screen.dart';

class ScoreScreen extends StatelessWidget {
  const ScoreScreen({super.key, required this.score, required this.total});

  final int score;
  final int total;

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0 : ((score / total) * 100).round();
    final scoreColor = percent > 70 ? const Color(0xFF16A34A) : Colors.orange;
    final message = percent > 70
        ? 'Excellent travail, tu maîtrises bien ce cours.'
        : 'Bon effort, relis le résumé puis retente le quiz.';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.emoji_events_outlined, size: 72, color: scoreColor),
              const SizedBox(height: 24),
              Text(
                'Score final',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$score/$total',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: scoreColor,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                '$percent%',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: scoreColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                },
                child: const Text("Retour à l'accueil"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
