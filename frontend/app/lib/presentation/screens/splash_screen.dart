import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/services/auth_service.dart';
import 'auth/login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  Timer? _redirectTimer;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.16), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
    _redirectTimer = Timer(const Duration(seconds: 2), _redirect);
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _redirect() {
    if (!mounted) return;

    final authService = context.read<AuthService>();
    final nextScreen = authService.isAuthenticated
        ? const HomeScreen()
        : const LoginScreen();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppTheme.softBackgroundGradient,
        ),
        child: Stack(
          children: [
            // Cercles très doux pour donner de la profondeur au fond.
            const Positioned(
              top: -80,
              right: -60,
              child: _SoftGlow(size: 190, color: AppTheme.primaryColor),
            ),
            const Positioned(
              bottom: -90,
              left: -70,
              child: _SoftGlow(size: 210, color: AppTheme.secondaryColor),
            ),
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _RevisiaLogo(size: 96, fontSize: 46),
                      SizedBox(height: 26),
                      Text(
                        'Revisia',
                        style: TextStyle(
                          color: AppTheme.textColor,
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "L'IA qui révise avec toi",
                        style: TextStyle(
                          color: AppTheme.mutedTextColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevisiaLogo extends StatelessWidget {
  const _RevisiaLogo({required this.size, required this.fontSize});

  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: AppTheme.softShadow,
      ),
      alignment: Alignment.center,
      child: Text(
        'R',
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SoftGlow extends StatelessWidget {
  const _SoftGlow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.10),
      ),
    );
  }
}
