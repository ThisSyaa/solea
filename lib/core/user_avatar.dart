import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import 'app_theme.dart';

/// Avatar pengguna yang otomatis ikut berubah saat foto profil diganti.
/// Dipakai di navbar (pojok kanan atas), halaman profil, dan info pribadi.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.radius});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Uint8List?>(
      valueListenable: AuthController.photoNotifier,
      builder: (context, bytes, _) {
        return CircleAvatar(
          radius: radius,
          backgroundColor: const Color(0xFFE8F0EC),
          backgroundImage: bytes != null ? MemoryImage(bytes) : null,
          child: bytes == null
              ? Icon(
                  Icons.person_rounded,
                  size: radius * 1.1,
                  color: AppColors.forest,
                )
              : null,
        );
      },
    );
  }
}