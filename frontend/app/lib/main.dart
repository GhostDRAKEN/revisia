import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/services/auth_service.dart';
import 'data/services/document_service.dart';
import 'data/services/generation_service.dart';
import 'presentation/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RevisiaApp());
}

class RevisiaApp extends StatelessWidget {
  const RevisiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService()..loadToken(),
        ),
        Provider<DocumentService>(create: (_) => DocumentService()),
        Provider<GenerationService>(create: (_) => GenerationService()),
      ],
      child: MaterialApp(
        title: 'Revisia',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
