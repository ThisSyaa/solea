import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import 'auth_feedback_dialog.dart';

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({super.key});

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isLoading = false;

  Future<void> _handlePressed() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final error = await AuthController.signInWithGoogle();

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (error != null) {
      await showAuthFeedbackDialog(
        context: context,
        type: AuthFeedbackType.error,
        title: 'Login Google gagal',
        message: error,
        primaryLabel: 'Coba lagi',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _handlePressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          side: const BorderSide(color: Color(0xFFD8D5CD)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 21,
                height: 21,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CustomPaint(painter: _GoogleLogoPainter()),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'CONTINUE WITH GOOGLE',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Logo "G" Google empat warna, digambar langsung (tanpa asset/package).
class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  static const _blue = Color(0xFF4285F4);
  static const _red = Color(0xFFEA4335);
  static const _yellow = Color(0xFFFBBC05);
  static const _green = Color(0xFF34A853);

  double _rad(double deg) => deg * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final stroke = s * 0.2;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: s / 2 - stroke / 2);

    Paint arcPaint(Color color) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt
      ..isAntiAlias = true;

    // Sudut Flutter: 0 = kanan, positif = searah jarum jam.
    canvas.drawArc(rect, _rad(-45), _rad(-105), false, arcPaint(_red));
    canvas.drawArc(rect, _rad(-150), _rad(-60), false, arcPaint(_yellow));
    canvas.drawArc(rect, _rad(150), _rad(-100), false, arcPaint(_green));
    canvas.drawArc(rect, _rad(50), _rad(-50), false, arcPaint(_blue));

    canvas.drawRect(
      Rect.fromLTRB(
        center.dx - s * 0.02,
        center.dy - stroke / 2,
        size.width,
        center.dy + stroke / 2,
      ),
      Paint()
        ..color = _blue
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}