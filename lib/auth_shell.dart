import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Kerangka halaman untuk Login & Register.
///
/// Di layar lebar (browser desktop) tampil 2 kolom: panel brand di kiri,
/// form di kanan. Di layar sempit (HP) otomatis jadi 1 kolom dengan
/// header ringkas di atas.
class AuthShell extends StatelessWidget {
  final String headline;
  final String tagline;
  final Widget child;

  const AuthShell({
    super.key,
    required this.headline,
    required this.tagline,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 880;

          final form = Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 28,
                vertical: isWide ? 48 : 32,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: child,
              ),
            ),
          );

          if (isWide) {
            return Row(
              children: [
                Expanded(
                  flex: 5,
                  child: _BrandPanel(headline: headline, tagline: tagline),
                ),
                Expanded(flex: 6, child: form),
              ],
            );
          }

          // Layar sempit: header ringkas + form di bawahnya
          return Column(
            children: [
              const _CompactBrandBar(),
              Expanded(child: form),
            ],
          );
        },
      ),
    );
  }
}

/// Panel kiri untuk layar lebar.
class _BrandPanel extends StatelessWidget {
  final String headline;
  final String tagline;

  const _BrandPanel({required this.headline, required this.tagline});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.forestDeep,
      child: Stack(
        children: [
          // Lingkaran dekoratif samar di latar
          Positioned(
            top: -80,
            right: -60,
            child: _Circle(size: 260, color: Color(0x14FFFFFF)),
          ),
          Positioned(
            bottom: -110,
            left: -70,
            child: _Circle(size: 300, color: Color(0x0DFFFFFF)),
          ),

          Padding(
            padding: const EdgeInsets.all(56),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _Logo(),
                const SizedBox(height: 40),
                Text(headline, style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 18),
                SizedBox(
                  width: 320,
                  child: Text(
                    tagline,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Color(0xCCFFFFFF),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Header ringkas untuk layar sempit (HP).
class _CompactBrandBar extends StatelessWidget {
  const _CompactBrandBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.forestDeep,
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: const Center(child: _Logo()),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(
            Icons.bolt_rounded,
            size: 20,
            color: AppColors.forestDeep,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Nimbus',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _Circle extends StatelessWidget {
  final double size;
  final Color color;
  const _Circle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}