import 'package:flutter/material.dart';

import 'theme_controller.dart';

/// Tombol ikon bulan/matahari untuk mengganti mode gelap & terang.
/// Mode terang -> tampil bulan (klik untuk gelap).
/// Mode gelap  -> tampil matahari (klik untuk terang).
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ThemeController.instance;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: controller,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;

        return IconButton(
          tooltip: isDark ? 'Ganti ke mode terang' : 'Ganti ke mode gelap',
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          onPressed: controller.toggle,
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) => RotationTransition(
              turns: Tween<double>(begin: 0.75, end: 1.0).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              key: ValueKey<bool>(isDark),
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        );
      },
    );
  }
}
