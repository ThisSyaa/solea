import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'controllers/product_controller.dart';
import 'core/app_routes.dart';
import 'core/app_theme.dart';
import 'core/auth_gate.dart';
import 'firebase_options.dart';
import 'views/landing/landing_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await ProductController.load();

  final restoredUser = await FirebaseAuth.instance.authStateChanges().first;
  final isLoggedIn = restoredUser != null;

  AppRoutes.restorePath = isLoggedIn
      ? WidgetsBinding.instance.platformDispatcher.defaultRouteName
      : null;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOLEA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      onGenerateInitialRoutes: (_) => [
        MaterialPageRoute<void>(
          settings: const RouteSettings(name: '/'),
          builder: (_) => isLoggedIn ? const AuthGate() : const LandingPage(),
        ),
      ],
    );
  }
}