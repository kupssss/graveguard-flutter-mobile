// ============================================================================
// main.dart
// ============================================================================
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'pages/splash.dart';

void main() => runApp(const GraveGuardApp());

class GraveGuardApp extends StatelessWidget {
  const GraveGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GraveGuard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const SplashPage(),
    );
  }
}