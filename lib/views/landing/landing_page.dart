import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/auth_gate.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  static const Color _background = Color(0xFF080A08);
  static const Color _ivory = Color(0xFFF3EFE5);
  static const Color _muted = Color(0xFF999B91);
  static const Color _olive = Color(0xFFB9BEA0);
  static const Color _line = Color(0xFF373B32);

  // Gambar ini merupakan komposisi sneaker + shoebox transparan.
  static const String _heroAsset = 'assets/images/solea_sneaker.png';

  late final AnimationController _introController;
  late final AnimationController _floatController;
  late final AnimationController _orbitController;

  late final Animation<double> _copyFade;
  late final Animation<Offset> _copySlide;
  late final Animation<double> _heroFade;
  late final Animation<double> _heroScale;
  late final Animation<double> _heroRise;
  late final Animation<double> _floatY;

  bool _started = false;
  bool _reduceMotion = false;
  bool _isEntering = false;
  bool _buttonHovered = false;

  double _pointerX = 0;
  double _pointerY = 0;

  int _activeNav = 0;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    );

    _copyFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.24, 0.85, curve: Curves.easeOutCubic),
    );

    _copySlide = Tween<Offset>(begin: const Offset(0, 0.075), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _introController,
            curve: const Interval(0.24, 0.90, curve: Curves.easeOutCubic),
          ),
        );

    _heroFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.0, 0.66, curve: Curves.easeOut),
    );

    _heroScale = Tween<double>(begin: 0.88, end: 1).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _heroRise = Tween<double>(begin: 42, end: 0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.78, curve: Curves.easeOutCubic),
      ),
    );

    _floatY = Tween<double>(begin: -7, end: 7).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_started) return;
    _started = true;

    _reduceMotion = MediaQuery.of(context).disableAnimations;

    if (_reduceMotion) {
      _introController.value = 1;
      _floatController.value = 0.5;
      _orbitController.value = 0;
      return;
    }

    _introController.forward();
    _floatController.repeat(reverse: true);
    _orbitController.repeat();
  }

  @override
  void dispose() {
    _introController.dispose();
    _floatController.dispose();
    _orbitController.dispose();
    super.dispose();
  }

  // =========================================================
  // ENTER SOLEA
  // =========================================================

  void _enterSolea() {
    if (_isEntering) return;

    setState(() {
      _isEntering = true;
    });

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (context, animation, secondaryAnimation) {
          return const AuthGate();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
      ),
    );
  }

  // =========================================================
  // NAVIGATION ACTIONS
  // =========================================================

  void _onNavTap(int index) {
    if (index == 0) {
      setState(() {
        _activeNav = 0;
      });

      if (!_reduceMotion) {
        _introController.forward(from: 0);
      }

      return;
    }

    if (index == 1) {
      setState(() {
        _activeNav = 1;
      });

      // Buka aplikasi agar pengguna bisa menjelajahi katalog.
      _enterSolea();
      return;
    }

    if (index == 2) {
      setState(() {
        _activeNav = 2;
      });

      _showBrandStory();
      return;
    }

    setState(() {
      _activeNav = 3;
    });

    _showContactInfo();
  }

  void _showBrandStory() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFF171A15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: _line),
          ),
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'OUR PHILOSOPHY',
                  style: TextStyle(
                    color: _olive,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Designed to move.',
                  style: TextStyle(
                    color: _ivory,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'SOLEA hadir untuk menemani setiap langkah '
                  'dengan gaya yang sederhana, nyaman, dan '
                  'penuh karakter.',
                  style: TextStyle(color: _muted, fontSize: 14, height: 1.8),
                ),
                const SizedBox(height: 22),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('Tutup', style: TextStyle(color: _ivory)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showContactInfo() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFF171A15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: _line),
          ),
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CONTACT SOLEA',
                  style: TextStyle(
                    color: _olive,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Let’s get moving.',
                  style: TextStyle(
                    color: _ivory,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Informasi kontak dan layanan pelanggan '
                  'dapat ditambahkan di bagian berikutnya '
                  'saat halaman SOLEA dikembangkan.',
                  style: TextStyle(color: _muted, fontSize: 14, height: 1.8),
                ),
                const SizedBox(height: 22),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('Tutup', style: TextStyle(color: _ivory)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================================================
  // ROOT PAGE
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF11140F),
                    Color(0xFF090B09),
                    Color(0xFF070807),
                  ],
                ),
              ),
            ),
          ),

          // Soft spotlight.
          Positioned(
            right: -180,
            top: -280,
            child: IgnorePointer(
              child: Container(
                width: 720,
                height: 720,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _olive.withValues(alpha: 0.13),
                      _olive.withValues(alpha: 0.045),
                      Colors.transparent,
                    ],
                    stops: const [0, 0.44, 1],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop =
                    constraints.maxWidth >= 1050 &&
                    constraints.maxHeight >= 560;

                if (isDesktop) {
                  return _buildDesktop(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                }

                return _buildMobile(constraints.maxWidth);
              },
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // DESKTOP LAYOUT
  // =========================================================

  Widget _buildDesktop(double width, double height) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        math.min(width * 0.045, 74),
        16,
        math.min(width * 0.045, 74),
        10,
      ),
      child: Column(
        children: [
          _buildHeader(desktop: true),
          const SizedBox(height: 4),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 5, child: _buildMessage(desktop: true)),
                const SizedBox(width: 12),
                Expanded(
                  flex: 7,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return _buildHeroStage(
                        constraints.maxWidth,
                        constraints.maxHeight,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  // =========================================================
  // MOBILE / TABLET LAYOUT
  // =========================================================

  Widget _buildMobile(double width) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(desktop: false),
          const SizedBox(height: 12),
          SizedBox(
            height: width < 380 ? 300 : 370,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return _buildHeroStage(
                  constraints.maxWidth,
                  constraints.maxHeight,
                );
              },
            ),
          ),
          _buildMessage(desktop: false),
          const SizedBox(height: 28),
          _buildFooter(),
        ],
      ),
    );
  }

  // =========================================================
  // HEADER + NAVIGATION
  // =========================================================

  Widget _buildHeader({required bool desktop}) {
    return Row(
      children: [
        // LOGO SOLEA + SOFT GLOW
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF3EFE5).withValues(alpha: 0.12),
                blurRadius: 24,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: const Color(0xFFB9BEA0).withValues(alpha: 0.07),
                blurRadius: 40,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/solea_logo.png',
            width: desktop ? 150 : 112,
            height: desktop ? 46 : 36,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) {
              return const Text(
                'SOLEA',
                style: TextStyle(
                  color: Color(0xFFF3EFE5),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              );
            },
          ),
        ),

        const Spacer(),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.035),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, color: Color(0xFFB9BEA0), size: 6),
              SizedBox(width: 8),
              Text(
                'FOOTWEAR / VOL. 01',
                style: TextStyle(
                  color: Color(0xFFC1C3B9),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _navLink(String label, int index) {
    final isActive = _activeNav == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 11),
      child: TextButton(
        onPressed: () => _onNavTap(index),
        style: TextButton.styleFrom(
          foregroundColor: isActive ? _ivory : _muted,
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 12),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 5),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: isActive ? 16 : 0,
              height: 2,
              decoration: BoxDecoration(
                color: _olive,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // LEFT HERO COPY
  // =========================================================

  Widget _buildMessage({required bool desktop}) {
    return FadeTransition(
      opacity: _copyFade,
      child: SlideTransition(
        position: _copySlide,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final titleSize = desktop
                ? (constraints.maxWidth * 0.145).clamp(47.0, 82.0).toDouble()
                : (constraints.maxWidth * 0.115).clamp(38.0, 58.0).toDouble();

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: _olive.withValues(alpha: 0.35)),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, color: _olive, size: 13),
                      SizedBox(width: 8),
                      Text(
                        'THE ART OF EVERYDAY MOVEMENT',
                        style: TextStyle(
                          color: _olive,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'STEP INTO\n'),
                      TextSpan(
                        text: 'YOUR WORLD.',
                        style: TextStyle(
                          color: _olive,
                          shadows: [
                            Shadow(
                              color: _olive.withValues(alpha: 0.16),
                              blurRadius: 25,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  style: TextStyle(
                    color: _ivory,
                    fontSize: titleSize,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -2.4,
                    height: 0.99,
                  ),
                ),

                const SizedBox(height: 22),

                const SizedBox(
                  width: 380,
                  child: Text(
                    'Bukan sekadar langkah. Ini tentang cara kamu '
                    'mengekspresikan diri.',
                    style: TextStyle(color: _muted, fontSize: 14, height: 1.9),
                  ),
                ),

                const SizedBox(height: 29),

                _buildEnterButton(),

                const SizedBox(height: 22),

                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_downward_rounded,
                      color: Color(0xFF777D72),
                      size: 16,
                    ),
                    SizedBox(width: 9),
                    Text(
                      'MADE TO MOVE WITH YOU',
                      style: TextStyle(
                        color: Color(0xFF777D72),
                        fontSize: 9,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                _buildBrandStats(desktop: desktop),
              ],
            );
          },
        ),
      ),
    );
  }

  // =========================================================
  // BRAND STATS
  // =========================================================

  Widget _buildBrandStats({required bool desktop}) {
    return Row(
      children: [
        Expanded(child: _stat('01', 'PREMIUM\nQUALITY')),
        Container(
          width: 1,
          height: 46,
          color: _line,
          margin: const EdgeInsets.symmetric(horizontal: 12),
        ),
        Expanded(child: _stat('∞', 'EVERYDAY\nMOVEMENT')),
        Container(
          width: 1,
          height: 46,
          color: _line,
          margin: const EdgeInsets.symmetric(horizontal: 12),
        ),
        Expanded(child: _stat('◎', 'MADE\nFOR YOU')),
      ],
    );
  }

  Widget _stat(String number, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: const TextStyle(
            color: _ivory,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: _muted,
            fontSize: 9,
            height: 1.6,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // ENTER SOLEA CTA
  // =========================================================

  Widget _buildEnterButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _buttonHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _buttonHovered = false;
        });
      },
      child: AnimatedScale(
        scale: _buttonHovered ? 1.035 : 1,
        duration: const Duration(milliseconds: 220),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isEntering ? null : _enterSolea,
            borderRadius: BorderRadius.circular(15),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 19),
              decoration: BoxDecoration(
                color: _buttonHovered ? const Color(0xFFDDE1C9) : _ivory,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: _olive.withValues(
                      alpha: _buttonHovered ? 0.20 : 0.06,
                    ),
                    blurRadius: _buttonHovered ? 34 : 18,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isEntering ? 'ENTERING...' : 'ENTER SOLEA',
                    style: const TextStyle(
                      color: _background,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.7,
                    ),
                  ),
                  const SizedBox(width: 25),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: _background,
                    size: 19,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // RIGHT HERO STAGE
  // =========================================================

  Widget _buildHeroStage(double width, double height) {
    // Aset berisi sneaker dan shoebox sekaligus.
    // Karena itu tidak ada CustomPainter untuk menggambar kotak.
    final imageWidth = math.min(width * 1.06, 790.0);

    return MouseRegion(
      onHover: (event) {
        if (_reduceMotion) return;

        final x = (event.localPosition.dx / width - 0.5)
            .clamp(-0.5, 0.5)
            .toDouble();

        final y = (event.localPosition.dy / height - 0.5)
            .clamp(-0.5, 0.5)
            .toDouble();

        setState(() {
          _pointerX = x;
          _pointerY = y;
        });
      },
      onExit: (_) {
        setState(() {
          _pointerX = 0;
          _pointerY = 0;
        });
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _introController,
          _floatController,
          _orbitController,
        ]),
        builder: (context, _) {
          final floatY = _reduceMotion ? 0.0 : _floatY.value;

          final pointerX = _reduceMotion ? 0.0 : _pointerX;

          final pointerY = _reduceMotion ? 0.0 : _pointerY;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Background orbit.
              Positioned.fill(
                child: CustomPaint(
                  painter: _OrbitPainter(
                    progress: _orbitController.value,
                    accent: _olive,
                  ),
                ),
              ),

              // Main studio glow.
              Positioned(
                left: width * 0.17,
                top: height * 0.12,
                child: IgnorePointer(
                  child: Container(
                    width: math.min(width * 0.63, 470.0),
                    height: math.min(width * 0.63, 470.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _olive.withValues(alpha: 0.13),
                          _olive.withValues(alpha: 0.035),
                          Colors.transparent,
                        ],
                        stops: const [0, 0.48, 1],
                      ),
                    ),
                  ),
                ),
              ),

              // Oversized background typography.
              Positioned(
                top: height * 0.02,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Text(
                    'SOLEA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.045),
                      fontSize: math.min(width * 0.105, 82.0),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 12,
                    ),
                  ),
                ),
              ),

              // One coherent transparent image:
              // sneaker + open box + detached lid.
              Positioned.fill(
                child: FadeTransition(
                  opacity: _heroFade,
                  child: Align(
                    alignment: const Alignment(0.02, 0.10),
                    child: Transform.translate(
                      offset: Offset(
                        pointerX * 18,
                        _heroRise.value + floatY + pointerY * 10,
                      ),
                      child: Transform.scale(
                        scale: _heroScale.value,
                        child: Transform.rotate(
                          angle: pointerX * 0.025,
                          child: Image.asset(
                            _heroAsset,
                            width: imageWidth,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                            errorBuilder: (context, error, stackTrace) {
                              return SizedBox(
                                width: imageWidth,
                                height: height * 0.70,
                                child: const Center(
                                  child: Icon(
                                    Icons.directions_run_rounded,
                                    color: _ivory,
                                    size: 100,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Vertical campaign labels.
              Positioned(
                right: 2,
                top: height * 0.26,
                child: _verticalMarker('01', 'MOVEMENT'),
              ),

              Positioned(
                right: 2,
                top: height * 0.49,
                child: _verticalMarker('02', 'LIFESTYLE'),
              ),

              Positioned(
                right: 2,
                top: height * 0.72,
                child: _verticalMarker('03', 'YOU'),
              ),

              // Small orbit particles.
              Positioned(
                top: height * 0.18,
                left: width * 0.20,
                child: _glowDot(4),
              ),

              Positioned(
                top: height * 0.28,
                right: width * 0.18,
                child: _glowDot(5),
              ),

              Positioned(
                top: height * 0.44,
                left: width * 0.11,
                child: _glowDot(3),
              ),

              Positioned(
                top: height * 0.58,
                right: width * 0.13,
                child: _glowDot(4),
              ),

              // Decorative colorway-inspired chips.
              Positioned(
                right: 3,
                bottom: height * 0.015,
                child: _buildColorwayPanel(),
              ),
            ],
          );
        },
      ),
    );
  }

  // =========================================================
  // VERTICAL MARKERS
  // =========================================================

  Widget _verticalMarker(String number, String label) {
    return IgnorePointer(
      child: SizedBox(
        width: 72,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              number,
              style: const TextStyle(
                color: _ivory,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                color: _muted,
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 14),
            Container(width: 1, height: 40, color: _line),
          ],
        ),
      ),
    );
  }

  Widget _glowDot(double size) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _olive,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: _olive.withValues(alpha: 0.65), blurRadius: 13),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // COLORWAY PANEL
  // =========================================================

  Widget _buildColorwayPanel() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF10120F).withValues(alpha: 0.88),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _colorwayTile(const Color(0xFFF0ECE2), selected: true),
          const SizedBox(width: 6),
          _colorwayTile(const Color(0xFF2D302B), selected: false),
          const SizedBox(width: 6),
          _colorwayTile(const Color(0xFF858A70), selected: false),
        ],
      ),
    );
  }

  Widget _colorwayTile(Color color, {required bool selected}) {
    return Container(
      width: 46,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        border: Border.all(
          color: selected ? _olive : Colors.white12,
          width: selected ? 1.2 : 0.7,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.directions_run_rounded, size: 24, color: color),
    );
  }

  // =========================================================
  // FOOTER
  // =========================================================

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        children: [
          const Text(
            'DESIGNED FOR EVERYDAY MOVEMENT',
            style: TextStyle(
              color: Color(0xFF71756B),
              fontSize: 8,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Container(height: 1, color: _line)),
          const SizedBox(width: 16),
          const Text(
            'EST. SOLEA',
            style: TextStyle(
              color: Color(0xFF71756B),
              fontSize: 8,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ANIMATED ORBIT PAINTER
// ============================================================

class _OrbitPainter extends CustomPainter {
  final double progress;
  final Color accent;

  const _OrbitPainter({required this.progress, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.49, size.height * 0.47);

    final firstRect = Rect.fromCenter(
      center: center,
      width: size.width * 0.79,
      height: size.height * 0.67,
    );

    final secondRect = Rect.fromCenter(
      center: center,
      width: size.width * 0.62,
      height: size.height * 0.53,
    );

    final thirdRect = Rect.fromCenter(
      center: center,
      width: size.width * 0.90,
      height: size.height * 0.77,
    );

    final thinPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final softPaint = Paint()
      ..color = accent.withValues(alpha: 0.09)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.19);
    canvas.translate(-center.dx, -center.dy);

    canvas.drawOval(firstRect, thinPaint);
    canvas.drawOval(secondRect, thinPaint);
    canvas.drawOval(thirdRect, softPaint);

    final orbitPaint = Paint()
      ..color = accent.withValues(alpha: 0.64)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(thirdRect, progress * math.pi * 2, 0.58, false, orbitPaint);

    final secondaryPaint = Paint()
      ..color = accent.withValues(alpha: 0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawArc(
      firstRect,
      -progress * math.pi * 2 + 1.4,
      0.36,
      false,
      secondaryPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.accent != accent;
  }
}
