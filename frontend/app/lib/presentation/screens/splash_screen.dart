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

class _SplashScreenState extends State<SplashScreen> {
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();
    _redirectTimer = Timer(const Duration(seconds: 2), _redirect);
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
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
    return const Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RevisiaLogo(size: 88, fontSize: 42),
            SizedBox(height: 24),
            Text(
              'Revisia',
              style: TextStyle(
                color: AppTheme.textColor,
                fontSize: 34,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "L'IA qui révise avec toi",
              style: TextStyle(color: Colors.black54, fontSize: 14),
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
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
        shape: BoxShape.circle,
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
