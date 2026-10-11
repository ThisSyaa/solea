import 'package:flutter/material.dart';

enum AuthFeedbackType {
  error,
  success,
  warning,
  info,
}

class AuthFeedbackStyle {
  final Color background;
  final Color foreground;
  final IconData icon;
  final IconData badgeIcon;

  const AuthFeedbackStyle({
    required this.background,
    required this.foreground,
    required this.icon,
    required this.badgeIcon,
  });
}

AuthFeedbackStyle _getFeedbackStyle(AuthFeedbackType type) {
  switch (type) {
    case AuthFeedbackType.error:
      return const AuthFeedbackStyle(
        background: Color(0xFFFFEAE5),
        foreground: Color(0xFFB84B42),
        icon: Icons.lock_outline_rounded,
        badgeIcon: Icons.close_rounded,
      );

    case AuthFeedbackType.success:
      return const AuthFeedbackStyle(
        background: Color(0xFFE5F3E8),
        foreground: Color(0xFF2D6A4F),
        icon: Icons.check_circle_outline_rounded,
        badgeIcon: Icons.auto_awesome_rounded,
      );

    case AuthFeedbackType.warning:
      return const AuthFeedbackStyle(
        background: Color(0xFFFFF2D9),
        foreground: Color(0xFF967126),
        icon: Icons.info_outline_rounded,
        badgeIcon: Icons.priority_high_rounded,
      );

    case AuthFeedbackType.info:
      return const AuthFeedbackStyle(
        background: Color(0xFFEAF0F8),
        foreground: Color(0xFF47658A),
        icon: Icons.mark_email_unread_outlined,
        badgeIcon: Icons.info_outline_rounded,
      );
  }
}

Future<void> showAuthFeedbackDialog({
  required BuildContext context,
  required AuthFeedbackType type,
  required String title,
  required String message,
  String primaryLabel = 'Mengerti',
  String? secondaryLabel,
}) async {
  final style = _getFeedbackStyle(type);

  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 24,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 360,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              24,
              18,
              24,
              22,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFEFC),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: const Color(0xFFF0EDE6),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 35,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tombol tutup
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      tooltip: 'Tutup',
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFF5F3EE),
                        foregroundColor: const Color(0xFF77736B),
                      ),
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 19,
                      ),
                    ),
                  ),

                  const SizedBox(height: 2),

                  // Ilustrasi lembut
                  _FeedbackIllustration(style: style),

                  const SizedBox(height: 24),

                  // Judul
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      height: 1.25,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: Color(0xFF191919),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Pesan
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.65,
                      color: Color(0xFF77736B),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Tombol utama
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF171717),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        primaryLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),

                  if (secondaryLabel != null) ...[
                    const SizedBox(height: 8),

                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF77736B),
                        minimumSize: const Size(
                          double.infinity,
                          42,
                        ),
                      ),
                      child: Text(
                        secondaryLabel,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _FeedbackIllustration extends StatelessWidget {
  final AuthFeedbackStyle style;

  const _FeedbackIllustration({
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 122,
      height: 108,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Bentuk latar utama
          Container(
            width: 106,
            height: 94,
            decoration: BoxDecoration(
              color: style.background,
              borderRadius: BorderRadius.circular(30),
            ),
          ),

          // Lingkaran dekoratif
          Positioned(
            top: 0,
            left: 1,
            child: Container(
              width: 17,
              height: 17,
              decoration: BoxDecoration(
                color: style.foreground.withOpacity(0.14),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            bottom: 2,
            right: 0,
            child: Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: style.foreground.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Ikon utama
          Icon(
            style.icon,
            size: 48,
            color: style.foreground,
          ),

          // Lencana kecil di sudut ilustrasi
          Positioned(
            top: 5,
            right: 0,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFEFC),
                shape: BoxShape.circle,
                border: Border.all(
                  color: style.background,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                style.badgeIcon,
                size: 17,
                color: style.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}