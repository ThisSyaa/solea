import 'package:flutter/material.dart';
import 'themed_logo.dart';

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

  // ---- Palet mode gelap ----
  static const darkBackground = Color(0xFF111412); // background halaman
  static const darkSurface = Color(0xFF191D1B); // kartu, navbar, input
  static const darkSurfaceHigh = Color(0xFF232826); // bubble chat, area terangkat
  static const darkInk = Color(0xFFECEFED); // teks utama
  static const darkMuted = Color(0xFF9CA3A0); // teks sekunder
  static const darkLine = Color(0xFF2F3532); // garis / border
  static const forestLight = Color(0xFF6FB89C); // aksen utama di atas gelap
  static const dangerLight = Color(0xFFF28B82); // merah yang terbaca di gelap

  /// Menghasilkan warna nama pengirim dengan rasio kontras WCAG AA (>= 4.5:1)
  /// di atas latar bubble abu muda (`#F2F0EA`).
  /// - Bot (`solea_bot`) & Admin (`solea_admin`) menggunakan warna merek tetap.
  /// - User lain menggunakan hue dari hash `userId`, saturation 0.55, lightness 0.28.
  static Color senderNameColor(
    String userId, {
    Brightness brightness = Brightness.light,
  }) {
    final isDark = brightness == Brightness.dark;
    if (userId == 'solea_bot') {
      if (isDark) return forestLight;
      return forestDeep; // #1E4237 -> Kontras 9.84:1 di atas #F2F0EA
    }
    if (userId == 'solea_admin') {
      if (isDark) return darkInk;
      return ink; // #14201B -> Kontras 14.51:1 di atas #F2F0EA
    }

    var hash = 0;
    for (var i = 0; i < userId.length; i++) {
      hash = (hash * 31 + userId.codeUnitAt(i)) & 0x7fffffff;
    }
    final hue = (hash % 360).toDouble();
    // Mode gelap memakai lightness tinggi agar kontras di atas bubble gelap.
    return HSLColor.fromAHSL(1.0, hue, 0.55, isDark ? 0.72 : 0.28).toColor();
  }
}

class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final background = isDark ? AppColors.darkBackground : AppColors.sand;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final surfaceHigh =
        isDark ? AppColors.darkSurfaceHigh : AppColors.chatBubbleReceived;
    final ink = isDark ? AppColors.darkInk : AppColors.ink;
    final muted = isDark ? AppColors.darkMuted : AppColors.muted;
    final line = isDark ? AppColors.darkLine : AppColors.line;
    final primary = isDark ? AppColors.forestLight : AppColors.forest;
    final onPrimary = isDark ? AppColors.darkBackground : Colors.white;
    final danger = isDark ? AppColors.dangerLight : AppColors.danger;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.forest,
        brightness: brightness,
        primary: primary,
        onPrimary: onPrimary,
        secondary: isDark ? AppColors.forestLight : AppColors.forestDeep,
        surface: surface,
        surfaceContainerHighest: surfaceHigh,
        onSurface: ink,
        onSurfaceVariant: muted,
        outline: line,
        error: danger,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),

      textTheme: TextTheme(
        // Judul besar di panel brand
        displaySmall: const TextStyle(
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
          color: ink,
        ),
        bodyMedium: TextStyle(fontSize: 14, color: ink),
        bodySmall: TextStyle(fontSize: 13, color: muted),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        // Label dibuat tampil di atas field (bukan mengambang di dalam)
        floatingLabelBehavior: FloatingLabelBehavior.never,
        hintStyle: TextStyle(color: muted, fontSize: 14),
        prefixIconColor: muted,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: danger, width: 1.6),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          disabledBackgroundColor: primary,
          disabledForegroundColor: onPrimary.withValues(alpha: 0.7),
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
          foregroundColor: primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? AppColors.darkSurfaceHigh : AppColors.ink,
        contentTextStyle: const TextStyle(color: Colors.white),
      ),
    );
  }
}

/// Warna aplikasi yang ikut berganti sesuai mode terang/gelap.
/// Di mode terang nilainya SAMA PERSIS dengan `AppColors.*` yang lama,
/// jadi mengganti `AppColors.ink` -> `context.ink` tidak mengubah tampilan.
extension AppColorsContext on BuildContext {
  ColorScheme get _scheme => Theme.of(this).colorScheme;

  Color get ink => _scheme.onSurface; // teks utama
  Color get muted => _scheme.onSurfaceVariant; // teks sekunder
  Color get line => _scheme.outline; // garis / border
  Color get sand => Theme.of(this).scaffoldBackgroundColor; // background halaman
  Color get card => _scheme.surface; // kartu / panel (dulu Colors.white)
  Color get bubble => _scheme.surfaceContainerHighest; // bubble chat
  Color get forest => _scheme.primary; // aksen utama
  Color get forestDeep => _scheme.secondary; // aksen gelap
  Color get danger => _scheme.error; // merah

  /// Teks/ikon di atas warna `forest` (putih di mode terang).
  Color get onForest => _scheme.onPrimary;

  /// Teks/ikon di atas warna `danger` (putih di mode terang).
  Color get onDanger => pick(Colors.white, AppColors.darkBackground);

  /// Hitam murni di mode terang, terang di mode gelap (teks/tautan/border auth).
  Color get strongInk => pick(Colors.black, AppColors.darkInk);

  /// Pasangan strongInk: ikon/ceklis di atas warna strongInk.
  Color get onStrongInk => pick(Colors.white, AppColors.darkBackground);

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Untuk warna literal khusus: nilai terang dipakai apa adanya di mode terang.
  Color pick(Color light, Color dark) => isDarkMode ? dark : light;
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
      child: ThemedLogo(
        height: height ?? iconSize + 6,
        semanticLabel: 'SOLEA',
      ),
    );
  }
}
