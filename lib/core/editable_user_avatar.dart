import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/auth_controller.dart';
import 'app_theme.dart';
import 'user_avatar.dart';

/// Membuka pilihan ganti / hapus foto, lalu menyimpannya ke Firestore.
Future<void> changeProfilePhoto(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);

  final action = await showDialog<String>(
    context: context,
    builder: (_) => _PhotoSheet(
      hasPhoto: AuthController.photoNotifier.value != null,
    ),
  );

  if (action == null) return;

  String? error;

  if (action == 'remove') {
    error = await AuthController.updateProfilePhoto(null);
  } else {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (file == null) return; // pengguna membatalkan

    final bytes = await file.readAsBytes();
    error = await AuthController.updateProfilePhoto(bytes);
  }

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(error ?? 'Foto profil berhasil diperbarui.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
}

/// Avatar yang bisa diklik untuk mengganti foto (ada ikon kamera kecil).
class EditableUserAvatar extends StatelessWidget {
  const EditableUserAvatar({super.key, required this.radius});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => changeProfilePhoto(context),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            UserAvatar(radius: radius),
            Positioned(
              right: -3,
              bottom: -3,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog di tengah layar: pratinjau avatar + pilihan ganti / hapus foto.
class _PhotoSheet extends StatelessWidget {
  const _PhotoSheet({required this.hasPhoto});

  final bool hasPhoto;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.line, width: 1.4),
                ),
                child: const UserAvatar(radius: 44),
              ),
              const SizedBox(height: 16),
              const Text(
                'Foto profil',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              const Text(
                'Foto akan tampil di akun dan pojok kanan atas.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.muted),
              ),
              const SizedBox(height: 20),
              _PhotoOptionTile(
                icon: Icons.photo_library_outlined,
                title: hasPhoto ? 'Ganti foto' : 'Pilih foto',
                subtitle: 'Dari galeri atau folder perangkat',
                onTap: () => Navigator.pop(context, 'pick'),
              ),
              if (hasPhoto) ...[
                const SizedBox(height: 10),
                _PhotoOptionTile(
                  icon: Icons.delete_outline_rounded,
                  title: 'Hapus foto',
                  subtitle: 'Kembali ke ikon bawaan',
                  color: const Color(0xFFB3261E),
                  onTap: () => Navigator.pop(context, 'remove'),
                ),
              ],
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoOptionTile extends StatelessWidget {
  const _PhotoOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? AppColors.forest;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: tint.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: tint, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}