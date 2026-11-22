import 'package:flutter/material.dart';

/// Semua warna aplikasi dikumpulkan di sini supaya gampang diganti
/// dari satu tempat, tidak tersebar di banyak file.
class AppColors {
  static const ink = Color(0xFF14201B); // teks utama
  static const forest = Color(0xFF2D5F4F); // warna aksen utama
  static const forestDeep = Color(0xFF1E4237); // aksen gelap
  static const sand = Color(0xFFF7F5F0); // background halaman
  static const chatBubbleReceived = Color(0xFFF2F0EA); // bubble pesan diterima
  static const line = Color(0xFFE3DFD7); // garis / border
  static const muted = Color(0xFF6E736F); // teks sekunder
  static const danger = Color(0xFFB3261E);
  static const warning = Color(0xFFE1A12B); // warna bintang rating & aksen hangat

  /// Menghasilkan warna nama pengirim dengan rasio kontras WCAG AA (>= 4.5:1)
  /// di atas latar bubble abu muda (`#F2F0EA`).
  /// - Bot (`solea_bot`) & Admin (`solea_admin`) menggunakan warna merek tetap.
  /// - User lain menggunakan hue dari hash `userId`, saturation 0.55, lightness 0.28.
  static Color senderNameColor(String userId) {
    if (userId == 'solea_bot') {
      return forestDeep; // #1E4237 -> Kontras 9.84:1 di atas #F2F0EA
    }
    if (userId == 'solea_admin') {
      return ink; // #14201B -> Kontras 14.51:1 di atas #F2F0EA
    }

    var hash = 0;
    for (var i = 0; i < userId.length; i++) {
      hash = (hash * 31 + userId.codeUnitAt(i)) & 0x7fffffff;
    }
    final hue = (hash % 360).toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.55, 0.28).toColor();
  }
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      scaffoldBackgroundColor: AppColors.sand,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.forest,
        primary: AppColors.forest,
        secondary: AppColors.forestDeep,
        surface: Colors.white,
        surfaceContainerHighest: AppColors.chatBubbleReceived,
        onSurface: AppColors.ink,
        onSurfaceVariant: AppColors.muted,
        outline: AppColors.line,
        error: AppColors.danger,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),

      textTheme: const TextTheme(
        // Judul besar di panel brand
        displaySmall: TextStyle(
          fontSize: 38,
          height: 1.15,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
          color: Colors.white,
        ),
        // Judul form
        headlineSmall: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          color: AppColors.ink,
        ),
        bodyMedium: TextStyle(fontSize: 14, color: AppColors.ink),
        bodySmall: TextStyle(fontSize: 13, color: AppColors.muted),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        // Label dibuat tampil di atas field (bukan mengambang di dalam)
        floatingLabelBehavior: FloatingLabelBehavior.never,
        hintStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
        prefixIconColor: AppColors.muted,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.forest, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.6),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.forest,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.forest,
          disabledForegroundColor: Colors.white70,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.forest,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
    );
  }
}

/// Label kecil di atas setiap input, supaya form terlihat rapi & mudah dibaca.
class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
      ),
    );
  }
}

class SoleaLogo extends StatelessWidget {
  final double iconSize;
  final double? height;
  final Object? variant;
  final Color? wordmarkColor;

  const SoleaLogo({
    super.key,
    this.iconSize = 34,
    this.height,
    this.variant,
    this.wordmarkColor,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'SOLEA',
      image: true,
      child: Image.asset(
        'assets/images/solea_logo2.png',
        height: height ?? iconSize + 6,
        fit: BoxFit.contain,
        semanticLabel: 'SOLEA',
      ),
    );
  }
}
