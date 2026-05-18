import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'home_screen.dart';

class ScoreScreen extends StatefulWidget {
  const ScoreScreen({super.key, required this.score, required this.total});

  final int score;
  final int total;

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scoreAnimation;

  int get _percent =>
      widget.total == 0 ? 0 : ((widget.score / widget.total) * 100).round();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scoreAnimation = Tween<double>(
      begin: 0,
      end: _percent.toDouble(),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isGreatScore = _percent > 70;
    final scoreColor = isGreatScore ? const Color(0xFF16A34A) : Colors.orange;
    final message = isGreatScore
        ? 'Superbe maîtrise. Tu peux avancer avec confiance.'
        : 'Tu progresses. Relis les points clés et retente le quiz.';

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppTheme.softBackgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.primaryGradient,
                      boxShadow: AppTheme.softShadow,
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: AnimatedBuilder(
                        animation: _scoreAnimation,
                        builder: (context, _) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${_scoreAnimation.value.round()}%',
                                style: TextStyle(
                                  color: scoreColor,
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.score}/${widget.total}',
                                style: const TextStyle(
                                  color: AppTheme.mutedTextColor,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'Score final',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.mutedTextColor,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 34),
                GradientButton(
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
      ),
    );
  }
}
