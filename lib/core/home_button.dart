import 'package:flutter/material.dart';

class HomeButton extends StatelessWidget {
  const HomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Kembali ke Beranda',
      child: IconButton(
        tooltip: 'Kembali ke Beranda',
        constraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
        onPressed: () {
          Navigator.of(context).popUntil(
            (route) => route.isFirst,
          );
        },
        icon: const Icon(
          Icons.home_outlined,
        ),
      ),
    );
  }
}
