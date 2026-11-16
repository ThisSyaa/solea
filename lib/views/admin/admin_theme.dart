import 'package:flutter/material.dart';

class AdminColors {
  static const beige = Color(0xFFE8DCCB); // latar luar frame
  static const bg = Color(0xFFFEFDFC); // area konten
  static const sidebar = Color(0xFFF9F7F4);
  static const card = Color(0xFFFAF7F3);
  static const line = Color(0xFFEBE6DF);

  static const orange = Color(0xFFFF8A00);
  static const orangeLight = Color(0xFFFFB566);
  static const peach = Color(0xFFFDE9D6); // kartu sorotan
  static const peachMid = Color(0xFFFFD6AD);
  static const peachSoft = Color(0xFFFFF1E2);

  static const ink = Color(0xFF191919);
  static const muted = Color(0xFF8A8680);

  static const green = Color(0xFF1FA463);
  static const greenBg = Color(0xFFE3F6EA);
  static const red = Color(0xFFE5484D);
  static const redBg = Color(0xFFFDE8E8);
  static const blue = Color(0xFF2A5B8C);
  static const blueBg = Color(0xFFE3EEF9);
}

const kCardTitle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: AdminColors.ink,
);

const kMutedText = TextStyle(fontSize: 12.5, color: AdminColors.muted);

class AdminTheme {
  /// Membungkus halaman admin dengan aksen oranye (input, popup, dialog).
  static Widget wrap(BuildContext context, Widget child) {
    final base = Theme.of(context);

    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c, width: w),
        );

    return Theme(
      data: base.copyWith(
        colorScheme: base.colorScheme.copyWith(primary: AdminColors.orange),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: AdminColors.orange,
        ),
        inputDecorationTheme: base.inputDecorationTheme.copyWith(
          filled: true,
          fillColor: AdminColors.card,
          border: border(AdminColors.line),
          enabledBorder: border(AdminColors.line),
          focusedBorder: border(AdminColors.orange, 1.4),
          errorBorder: border(AdminColors.red),
          focusedErrorBorder: border(AdminColors.red, 1.4),
        ),
        popupMenuTheme: const PopupMenuThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.white,
        ),
      ),
      child: child,
    );
  }
}