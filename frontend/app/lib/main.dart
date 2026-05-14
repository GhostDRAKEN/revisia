import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/services/auth_service.dart';
import 'data/services/document_service.dart';
import 'data/services/generation_service.dart';

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
        home: const RevisiaHomeScreen(),
      ),
    );
  }
}

class RevisiaHomeScreen extends StatelessWidget {
  const RevisiaHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.select<AuthService, bool>(
      (service) => service.isAuthenticated,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Revisia')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Révision intelligente',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                isAuthenticated
                    ? 'Session active. Les services API sont prêts.'
                    : 'Connecte-toi pour importer un cours et générer tes révisions.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
