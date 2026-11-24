import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Menyimpan & mengubah mode tema (terang / gelap) untuk seluruh aplikasi.
/// Pilihan pengguna disimpan di perangkat, jadi tetap sama saat aplikasi dibuka lagi.
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController._() : super(ThemeMode.light);

  static final ThemeController instance = ThemeController._();
  static const _prefsKey = 'theme_mode';

  bool get isDark => value == ThemeMode.dark;

  /// Panggil sekali di main() sebelum runApp().
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey);
      if (saved == 'dark') {
        value = ThemeMode.dark;
      } else if (saved == 'light') {
        value = ThemeMode.light;
      }
    } catch (_) {
      // Kalau penyimpanan gagal, tetap pakai mode terang.
    }
  }

  Future<void> toggle() async {
    value = isDark ? ThemeMode.light : ThemeMode.dark;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, isDark ? 'dark' : 'light');
    } catch (_) {
      // Gagal menyimpan tidak boleh mengganggu pergantian tema.
    }
  }
}
