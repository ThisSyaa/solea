import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'controllers/product_controller.dart';
import 'core/app_theme.dart';
import 'firebase_options.dart';
import 'views/landing/landing_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Ambil data produk dari API (pakai Dio). Kalau gagal, pakai data lokal.
  await ProductController.load();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOLEA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const LandingPage(),
    );
  }
}