import 'package:flutter/material.dart';

/// Logo SOLEA yang tetap terbaca di mode gelap.
/// File logo berwarna gelap di atas latar transparan, jadi di latar gelap
/// kecerahannya dibalik (hue tetap). Di mode terang gambar ditampilkan apa adanya.
class ThemedLogo extends StatelessWidget {
  final double height;
  final String? semanticLabel;

  const ThemedLogo({super.key, required this.height, this.semanticLabel});

  static const ColorFilter _invertKeepHue = ColorFilter.matrix(<double>[
    0.574, -1.430, -0.144, 0, 255, //
    -0.426, -0.430, -0.144, 0, 255, //
    -0.426, -1.430, 0.856, 0, 255, //
    0, 0, 0, 1, 0, //
  ]);

  @override
  Widget build(BuildContext context) {
    final logo = Image.asset(
      'assets/images/solea_logo2.png',
      height: height,
      fit: BoxFit.contain,
      semanticLabel: semanticLabel,
    );
    if (Theme.of(context).brightness == Brightness.dark) {
      return ColorFiltered(colorFilter: _invertKeepHue, child: logo);
    }
    return logo;
  }
}
