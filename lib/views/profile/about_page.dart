import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/home_button.dart';
import '../../core/url_launcher_helper.dart';
import '../../models/team_member.dart';

class AboutPage extends StatefulWidget {
  final List<TeamMember>? members;

  const AboutPage({
    super.key,
    this.members,
  });

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage>
    with SingleTickerProviderStateMixin {
  // Palet tema gelap SOLEA (hampir hitam pekat + aksen olive/ivory)
  static const Color _bgDark = Color(0xFF060706);
  static const Color _bgGlow = Color(0xFF1A241E);
  static const Color _ivory = Color(0xFFF3EFE5);
  static const Color _olive = Color(0xFFB9BEA0);
  static const Color _muted = Color(0xFF8E9287);

  late final List<TeamMember> _members;
  late final AnimationController _slideController;
  final FocusNode _stageFocusNode = FocusNode(
    debugLabel: 'AboutTeamStageFocus',
  );

  int _selectedIndex = 0;
  double _pageOffset = 0.0;
  double _animStartOffset = 0.0;
  double _animTargetOffset = 0.0;

  bool _isDragging = false;
  bool _hasKeyboardFocus = false;
  int _focusedCardIndex = -1;
  DateTime _lastWheelTime =
      DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();

    final sourceMembers = (widget.members != null &&
            widget.members!.isNotEmpty)
        ? widget.members!
        : defaultTeamMembers;
    // Batasi maksimal jumlah anggota kelompok sesuai `maxTeamMembers` (7 orang)
    _members =
        sourceMembers.take(maxTeamMembers).toList();

    // Mulai dari kartu tengah agar susunan bertumpuk kiri-kanan langsung terlihat
    _selectedIndex =
        _members.isEmpty ? 0 : (_members.length - 1) ~/ 2;
    _pageOffset = _selectedIndex.toDouble();
    _animStartOffset = _pageOffset;
    _animTargetOffset = _pageOffset;

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..addListener(_onSlideTick);
  }

  void _onSlideTick() {
    final curved = Curves.easeOutCubic.transform(
      _slideController.value,
    );
    setState(() {
      _pageOffset = ui.lerpDouble(
            _animStartOffset,
            _animTargetOffset,
            curved,
          ) ??
          _animTargetOffset;
    });
  }

  @override
  void dispose() {
    _slideController.removeListener(_onSlideTick);
    _slideController.dispose();
    _stageFocusNode.dispose();
    super.dispose();
  }

  bool get _reduceMotion =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  void _selectMember(
    int index, {
    bool fromKeyboard = false,
  }) {
    if (_members.isEmpty) return;

    final clamped = index.clamp(0, _members.length - 1);

    setState(() {
      _selectedIndex = clamped;
      if (fromKeyboard) {
        _hasKeyboardFocus = true;
        _focusedCardIndex = clamped;
      }
    });

    if (_reduceMotion) {
      _slideController.stop();
      setState(() {
        _pageOffset = clamped.toDouble();
        _animStartOffset = _pageOffset;
        _animTargetOffset = _pageOffset;
      });
      return;
    }

    _animStartOffset = _pageOffset;
    _animTargetOffset = clamped.toDouble();
    _slideController.forward(from: 0);
  }

  void _stepSelection(
    int delta, {
    bool fromKeyboard = false,
  }) {
    if (_members.isEmpty) return;
    final next = (_selectedIndex + delta).clamp(
      0,
      _members.length - 1,
    );
    if (next != _selectedIndex || fromKeyboard) {
      _selectMember(next, fromKeyboard: fromKeyboard);
    }
  }

  // =========================================================
  // DRAG / SWIPE & MOUSE WHEEL HANDLERS
  // =========================================================

  void _onHorizontalDragStart(DragStartDetails details) {
    if (_members.length <= 1) return;
    _slideController.stop();
    setState(() {
      _isDragging = true;
    });
  }

  void _onHorizontalDragUpdate(
    DragUpdateDetails details,
    double stepX,
  ) {
    if (_members.length <= 1 || stepX <= 0) return;

    final deltaPage = -(details.primaryDelta ?? 0) / stepX;
    final maxPage = (_members.length - 1).toDouble();
    double nextOffset = _pageOffset + deltaPage;

    // Efek tahanan lembut (rubber-band) di ujung kiri/kanan
    if (nextOffset < 0) {
      nextOffset = nextOffset * 0.35;
    } else if (nextOffset > maxPage) {
      nextOffset = maxPage + (nextOffset - maxPage) * 0.35;
    }

    final nearest =
        nextOffset.round().clamp(0, _members.length - 1);

    setState(() {
      _pageOffset = nextOffset;
      _selectedIndex = nearest;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_members.isEmpty) return;
    setState(() {
      _isDragging = false;
    });

    final velocity = details.primaryVelocity ?? 0;
    int target = _pageOffset.round();

    if (velocity.abs() > 260) {
      if (velocity < 0) {
        target = _pageOffset.ceil();
      } else {
        target = _pageOffset.floor();
      }
    }

    _selectMember(target.clamp(0, _members.length - 1));
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent ||
        _members.length <= 1) {
      return;
    }

    final now = DateTime.now();
    if (now.difference(_lastWheelTime).inMilliseconds <
        180) {
      return;
    }

    final delta = event.scrollDelta.dx.abs() >
            event.scrollDelta.dy.abs()
        ? event.scrollDelta.dx
        : event.scrollDelta.dy;

    if (delta.abs() < 6) return;

    _lastWheelTime = now;
    if (delta > 0) {
      _stepSelection(1);
    } else {
      _stepSelection(-1);
    }
  }

  KeyEventResult _onKeyEvent(
    FocusNode node,
    KeyEvent event,
  ) {
    if (event is! KeyDownEvent &&
        event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey ==
        LogicalKeyboardKey.arrowLeft) {
      _stepSelection(-1, fromKeyboard: true);
      return KeyEventResult.handled;
    }

    if (event.logicalKey ==
        LogicalKeyboardKey.arrowRight) {
      _stepSelection(1, fromKeyboard: true);
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.home) {
      _selectMember(0, fromKeyboard: true);
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.end) {
      _selectMember(
        _members.length - 1,
        fromKeyboard: true,
      );
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  Future<void> _openSocialUrl(
    TeamSocialLink link,
  ) async {
    final url = link.url.trim();
    if (url.isEmpty) return;

    final opened = await openExternalUrl(url);
    if (!opened && mounted) {
      await Clipboard.setData(ClipboardData(text: url));
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Tautan disalin: $url'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeMember = _members.isNotEmpty
        ? _members[_selectedIndex]
        : const TeamMember(
            name: 'SOLEA Team',
            nim: '-',
            role: 'Developer',
          );

    return Scaffold(
      backgroundColor: _bgDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Latar hampir hitam pekat dengan sedikit cahaya radial di tengah
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _bgDark,
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.08),
                  radius: 0.78,
                  colors: [
                    _bgGlow,
                    Color(0xFF0C100D),
                    _bgDark,
                  ],
                  stops: [0.0, 0.52, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenW = constraints.maxWidth;
                final screenH = constraints.maxHeight;

                // Ukuran kartu memakai clamp() agar proporsional di HP maupun desktop (hingga 7 anggota)
                // Rasio bingkai potret tinggi 1 : 1.5
                final cardWidth = (screenW * 0.19)
                    .clamp(128.0, 192.0)
                    .toDouble();
                final cardHeight = cardWidth * 1.5;

                // Overlap negatif sekitar 24% lebar kartu -> jarak antar pusat = 76% lebar
                final stepX = cardWidth * (1.0 - 0.24);

                // Posisi vertikal selang-seling
                final staggerY =
                    (cardHeight * 0.042).clamp(8.0, 14.0);

                // Tinggi panggung kartu (menampung scale 1.08 + stagger vertikal + bayangan)
                final stageHeight =
                    cardHeight * 1.18 + staggerY * 2 + 24;

                return Column(
                  children: [
                    _buildTopBar(screenW),

                    Expanded(
                      child: SingleChildScrollView(
                        physics:
                            const BouncingScrollPhysics(),
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: math.max(
                              0,
                              screenH - 76,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              _buildPs4Header(screenW),

                              const SizedBox(height: 10),

                              // Panggung kartu horizontal (tanpa scroll horizontal pada body)
                              _buildCardStage(
                                viewportWidth: screenW,
                                stageHeight: stageHeight,
                                cardWidth: cardWidth,
                                cardHeight: cardHeight,
                                stepX: stepX,
                                staggerY: staggerY,
                              ),

                              const SizedBox(height: 14),

                              // Indikator & petunjuk navigasi
                              _buildNavigationHint(),

                              const SizedBox(height: 18),

                              // Kotak informasi anggota di bawah kartu aktif
                              Padding(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 20,
                                ),
                                child: _buildMemberInfoBox(
                                  activeMember,
                                  screenW,
                                ),
                              ),

                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // TOP BAR
  // =========================================================

  Widget _buildTopBar(double screenW) {
    final isCompact = screenW < 520;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 24,
        vertical: 8,
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Kembali',
            onPressed: () {
              Navigator.of(context).maybePop();
            },
            style: IconButton.styleFrom(
              foregroundColor: _ivory,
              backgroundColor:
                  Colors.white.withValues(alpha: 0.05),
            ),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 17,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'SOLEA',
            style: TextStyle(
              color: _ivory,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.2,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: _olive.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: _olive.withValues(alpha: 0.28),
              ),
            ),
            child: const Text(
              'ABOUT US',
              style: TextStyle(
                color: _olive,
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
          ),
          const Spacer(),
          Theme(
            data: Theme.of(context).copyWith(
              iconTheme:
                  const IconThemeData(color: _ivory),
            ),
            child: IconButtonTheme(
              data: IconButtonThemeData(
                style: IconButton.styleFrom(
                  foregroundColor: _ivory,
                ),
              ),
              child: const HomeButton(),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // HEADER ALA PS4 SELECT SCREEN
  // =========================================================

  Widget _buildPs4Header(double screenW) {
    final titleSize =
        (screenW * 0.032).clamp(18.0, 26.0).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            'SELECT TEAM MEMBER · ${_selectedIndex + 1} / ${_members.length}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _olive.withValues(alpha: 0.85),
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Para Pengembang di Balik SOLEA',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _ivory,
              fontSize: titleSize,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // HORIZONTAL OVERLAPPING CARD STAGE
  // =========================================================

  Widget _buildCardStage({
    required double viewportWidth,
    required double stageHeight,
    required double cardWidth,
    required double cardHeight,
    required double stepX,
    required double staggerY,
  }) {
    // Urutkan indeks berdasarkan jarak dari posisi aktif (terjauh di bawah,
    // kartu aktif paling atas / z-index tertinggi)
    final orderedIndices = List<int>.generate(
      _members.length,
      (i) => i,
    )..sort((a, b) {
        final distA = (a - _pageOffset).abs();
        final distB = (b - _pageOffset).abs();
        final cmp = distB.compareTo(distA);
        if (cmp != 0) return cmp;
        return a == _selectedIndex
            ? 1
            : b == _selectedIndex
                ? -1
                : a.compareTo(b);
      });

    return Focus(
      focusNode: _stageFocusNode,
      autofocus: true,
      onFocusChange: (focused) {
        setState(() {
          _hasKeyboardFocus = focused;
          if (focused && _focusedCardIndex < 0) {
            _focusedCardIndex = _selectedIndex;
          }
        });
      },
      onKeyEvent: _onKeyEvent,
      child: MouseRegion(
        cursor: _isDragging
            ? SystemMouseCursors.grabbing
            : SystemMouseCursors.grab,
        child: Listener(
          onPointerSignal: _onPointerSignal,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: _onHorizontalDragStart,
            onHorizontalDragUpdate: (details) =>
                _onHorizontalDragUpdate(details, stepX),
            onHorizontalDragEnd: _onHorizontalDragEnd,
            child: ClipRect(
              child: SizedBox(
                width: viewportWidth,
                height: stageHeight,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    for (final index in orderedIndices)
                      _buildPositionedCard(
                        index: index,
                        viewportWidth: viewportWidth,
                        stageHeight: stageHeight,
                        cardWidth: cardWidth,
                        cardHeight: cardHeight,
                        stepX: stepX,
                        staggerY: staggerY,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPositionedCard({
    required int index,
    required double viewportWidth,
    required double stageHeight,
    required double cardWidth,
    required double cardHeight,
    required double stepX,
    required double staggerY,
  }) {
    final member = _members[index];
    final delta = index - _pageOffset;
    final absDelta = delta.abs();
    final t = absDelta.clamp(0.0, 1.0);

    // Kartu aktif membesar ~8% (1.08), kartu non-aktif sedikit mengecil (0.92)
    final scale = ui.lerpDouble(1.08, 0.92, t)!;

    // Kartu aktif terang penuh (1.0), kartu non-aktif gelap (brightness ~0.30)
    final brightness = ui.lerpDouble(1.0, 0.30, t)!;

    // Posisi horizontal: bertumpuk dengan overlap ~24% lebar kartu
    final translateX = delta * stepX;

    // Posisi vertikal selang-seling (genap ke atas, ganjil ke bawah)
    final translateY =
        (index.isEven ? -staggerY : staggerY);

    final isActive = index == _selectedIndex;
    final showFocusRing = isActive &&
        (_hasKeyboardFocus || _focusedCardIndex == index);

    final left =
        (viewportWidth - cardWidth) / 2 + translateX;
    final top =
        (stageHeight - cardHeight) / 2 + translateY;

    return Positioned(
      left: left,
      top: top,
      width: cardWidth,
      height: cardHeight,
      child: Transform.scale(
        scale: scale,
        alignment: Alignment.center,
        child: _TeamPortraitCard(
          member: member,
          index: index,
          totalCount: _members.length,
          isActive: isActive,
          activeStrength: 1.0 - t,
          brightness: brightness,
          showFocusOutline: showFocusRing,
          onTap: () {
            _stageFocusNode.requestFocus();
            _selectMember(index);
          },
          onFocusChange: (focused) {
            if (focused) {
              setState(() {
                _focusedCardIndex = index;
                _hasKeyboardFocus = true;
              });
              if (_selectedIndex != index) {
                _selectMember(index, fromKeyboard: true);
              }
            } else if (_focusedCardIndex == index) {
              setState(() {
                _focusedCardIndex = -1;
              });
            }
          },
        ),
      ),
    );
  }

  // =========================================================
  // PETUNJUK INTERAKSI & INDIKATOR KARTU
  // =========================================================

  Widget _buildNavigationHint() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: 'Anggota sebelumnya (←)',
          onPressed: _selectedIndex > 0
              ? () => _stepSelection(-1)
              : null,
          visualDensity: VisualDensity.compact,
          icon: Icon(
            Icons.chevron_left_rounded,
            color: _selectedIndex > 0
                ? _ivory
                : _muted.withValues(alpha: 0.3),
            size: 22,
          ),
        ),
        const SizedBox(width: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            _members.length,
            (index) {
              final active = index == _selectedIndex;
              return GestureDetector(
                onTap: () => _selectMember(index),
                child: AnimatedContainer(
                  duration: _reduceMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 3.5,
                  ),
                  width: active ? 22 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: active
                        ? _olive
                        : Colors.white
                            .withValues(alpha: 0.18),
                    borderRadius:
                        BorderRadius.circular(999),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 6),
        IconButton(
          tooltip: 'Anggota berikutnya (→)',
          onPressed:
              _selectedIndex < _members.length - 1
                  ? () => _stepSelection(1)
                  : null,
          visualDensity: VisualDensity.compact,
          icon: Icon(
            Icons.chevron_right_rounded,
            color: _selectedIndex < _members.length - 1
                ? _ivory
                : _muted.withValues(alpha: 0.3),
            size: 22,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // KOTAK INFORMASI ANGGOTA DI BAWAH KARTU AKTIF
  // =========================================================

  Widget _buildMemberInfoBox(
    TeamMember member,
    double screenW,
  ) {
    final nameSize =
        (screenW * 0.042).clamp(22.0, 32.0).toDouble();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 640),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: screenW < 520 ? 20 : 32,
          vertical: screenW < 520 ? 22 : 26,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF0E120F)
              .withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _olive.withValues(alpha: 0.18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.65),
              blurRadius: 36,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: _reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 240),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            if (_reduceMotion) return child;
            final slide = Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(animation);
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: slide,
                child: child,
              ),
            );
          },
          child: Column(
            key: ValueKey<String>(
              '${member.nim}_${member.name}',
            ),
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nama besar
              Text(
                member.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _ivory,
                  fontSize: nameSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 8),

              // NIM & Peran
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment:
                    WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 6,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _olive.withValues(alpha: 0.14),
                      borderRadius:
                          BorderRadius.circular(999),
                    ),
                    child: Text(
                      'NIM ${member.nim}',
                      style: const TextStyle(
                        color: _olive,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  Text(
                    member.role,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              if (member.links.isNotEmpty) ...[
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final link in member.links)
                      _SocialPillButton(
                        link: link,
                        onTap: () => _openSocialUrl(link),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// KARTU POTRET ANGGOTA (RASIO 1:1.5, VIGNETTE, TANPA BORDER)
// ============================================================

class _TeamPortraitCard extends StatelessWidget {
  final TeamMember member;
  final int index;
  final int totalCount;
  final bool isActive;
  final double activeStrength;
  final double brightness;
  final bool showFocusOutline;
  final VoidCallback onTap;
  final ValueChanged<bool> onFocusChange;

  const _TeamPortraitCard({
    required this.member,
    required this.index,
    required this.totalCount,
    required this.isActive,
    required this.activeStrength,
    required this.brightness,
    required this.showFocusOutline,
    required this.onTap,
    required this.onFocusChange,
  });

  static List<double> _brightnessMatrix(double b) {
    return <double>[
      b, 0, 0, 0, 0, // R
      0, b, 0, 0, 0, // G
      0, 0, b, 0, 0, // B
      0, 0, 0, 1, 0, // A
    ];
  }

  @override
  Widget build(BuildContext context) {
    final shadowAlpha =
        ui.lerpDouble(0.35, 0.92, activeStrength)!;
    final shadowBlur =
        ui.lerpDouble(16.0, 44.0, activeStrength)!;
    final shadowSpread =
        ui.lerpDouble(2.0, 12.0, activeStrength)!;

    return Semantics(
      button: true,
      selected: isActive,
      label:
          '${member.name}, ${member.role}, NIM ${member.nim} (${index + 1} dari $totalCount)',
      child: FocusableActionDetector(
        onShowFocusHighlight: onFocusChange,
        mouseCursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            // Tanpa garis tepi pada bingkai foto; bayangan gelap jatuh ke kartu sebelah
            decoration: BoxDecoration(
              color: const Color(0xFF060706),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withValues(alpha: shadowAlpha),
                  blurRadius: shadowBlur,
                  spreadRadius: shadowSpread,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: ColorFiltered(
                colorFilter: ColorFilter.matrix(
                  _brightnessMatrix(brightness),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Foto anggota atau placeholder siluet
                    _buildPhotoOrSilhouette(),

                    // Vignette radial: pinggir foto memudar ke hitam pekat
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(0.0, -0.15),
                          radius: 0.86,
                          colors: [
                            Colors.transparent,
                            Color(0x55060706),
                            Color(0xDD060706),
                            Color(0xFF060706),
                          ],
                          stops: [0.0, 0.50, 0.80, 1.0],
                        ),
                      ),
                    ),

                    // Vignette horizontal kiri-kanan agar tepi samping menyatu ke kegelapan
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFF060706),
                            Colors.transparent,
                            Colors.transparent,
                            Color(0xFF060706),
                          ],
                          stops: [0.0, 0.16, 0.84, 1.0],
                        ),
                      ),
                    ),

                    // Vignette vertikal atas & bawah: bagian bawah memudar ke hitam
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xE6060706),
                            Colors.transparent,
                            Colors.transparent,
                            Color(0xD9060706),
                            Color(0xFF060706),
                          ],
                          stops: [
                            0.0,
                            0.14,
                            0.50,
                            0.80,
                            1.0,
                          ],
                        ),
                      ),
                    ),

                    // Nama anggota di bagian bawah foto, tanpa kotak gradasi tambahan
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 14,
                      child: Text(
                        member.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFFF3EFE5),
                          fontSize: isActive ? 14.5 : 13.0,
                          fontWeight: isActive
                              ? FontWeight.w800
                              : FontWeight.w600,
                          letterSpacing: -0.2,
                          height: 1.2,
                          shadows: const [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Focus outline yang jelas untuk navigasi keyboard
                    if (showFocusOutline)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(
                                18,
                              ),
                              border: Border.all(
                                color: const Color(
                                  0xFFB9BEA0,
                                ),
                                width: 2.4,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoOrSilhouette() {
    final photo = member.photo.trim();
    if (photo.isEmpty) {
      return const _SilhouettePlaceholder();
    }

    if (photo.startsWith('http://') ||
        photo.startsWith('https://')) {
      return Image.network(
        photo,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (_, _, _) =>
            const _SilhouettePlaceholder(),
      );
    }

    return Image.asset(
      photo,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      errorBuilder: (_, _, _) =>
          const _SilhouettePlaceholder(),
    );
  }
}

// ============================================================
// PLACEHOLDER SILUET ANGGOTA (KETIKA FOTO KOSONG / GAGAL MUAT)
// ============================================================

class _SilhouettePlaceholder extends StatelessWidget {
  const _SilhouettePlaceholder();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SilhouettePainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _SilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Latar belakang lembut agar siluet muncul dari kegelapan
    final bgPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.5, size.height * 0.38),
        size.width * 0.72,
        const [
          Color(0xFF232C26),
          Color(0xFF101512),
          Color(0xFF060706),
        ],
        const [0.0, 0.62, 1.0],
      );
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Siluet kepala & bahu
    final figurePaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(size.width * 0.5, size.height * 0.18),
        Offset(size.width * 0.5, size.height * 0.88),
        const [
          Color(0xFF4F5A52),
          Color(0xFF2B332E),
          Color(0xFF090B09),
        ],
        const [0.0, 0.55, 1.0],
      );

    final headCenter = Offset(
      size.width * 0.5,
      size.height * 0.34,
    );
    final headRadius = size.width * 0.18;

    // Kepala
    canvas.drawCircle(
      headCenter,
      headRadius,
      figurePaint,
    );

    // Leher & Bahu potret
    final bodyPath = Path()
      ..moveTo(size.width * 0.12, size.height * 0.92)
      ..quadraticBezierTo(
        size.width * 0.16,
        size.height * 0.56,
        size.width * 0.5,
        size.height * 0.56,
      )
      ..quadraticBezierTo(
        size.width * 0.84,
        size.height * 0.56,
        size.width * 0.88,
        size.height * 0.92,
      )
      ..close();

    canvas.drawPath(bodyPath, figurePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      false;
}

// ============================================================
// TOMBOL PILL SOSIAL MEDIA DENGAN LOGO SVG + TEKS
// ============================================================

class _SocialPillButton extends StatefulWidget {
  final TeamSocialLink link;
  final VoidCallback onTap;

  const _SocialPillButton({
    required this.link,
    required this.onTap,
  });

  @override
  State<_SocialPillButton> createState() =>
      _SocialPillButtonState();
}

class _SocialPillButtonState
    extends State<_SocialPillButton> {
  bool _hovered = false;
  bool _focused = false;

  String get _platformTitle {
    switch (widget.link.type.toLowerCase()) {
      case 'github':
        return 'GitHub';
      case 'instagram':
        return 'Instagram';
      case 'linkedin':
        return 'LinkedIn';
      default:
        return widget.link.type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final highlighted = _hovered || _focused;
    final labelText = widget.link.label.trim().isNotEmpty
        ? '$_platformTitle · ${widget.link.label}'
        : _platformTitle;

    return FocusableActionDetector(
      onShowHoverHighlight: (v) =>
          setState(() => _hovered = v),
      onShowFocusHighlight: (v) =>
          setState(() => _focused = v),
      mouseCursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: highlighted
                  ? const Color(0xFFB9BEA0)
                      .withValues(alpha: 0.20)
                  : Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: _focused
                    ? const Color(0xFFF3EFE5)
                    : highlighted
                        ? const Color(0xFFB9BEA0)
                        : Colors.white
                            .withValues(alpha: 0.14),
                width: _focused ? 1.8 : 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomPaint(
                  size: const Size(16, 16),
                  painter: _SocialSvgPainter(
                    type: widget.link.type.toLowerCase(),
                    color: const Color(0xFFF3EFE5),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  labelText,
                  style: const TextStyle(
                    color: Color(0xFFF3EFE5),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(width: 5),
                Icon(
                  Icons.open_in_new_rounded,
                  size: 12,
                  color: const Color(0xFFF3EFE5)
                      .withValues(alpha: 0.65),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// VEKTOR SVG PAINTER: GITHUB, INSTAGRAM, LINKEDIN
// ============================================================

class _SocialSvgPainter extends CustomPainter {
  final String type;
  final Color color;

  const _SocialSvgPainter({
    required this.type,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 24.0;
    final sy = size.height / 24.0;
    canvas.save();
    canvas.scale(sx, sy);

    switch (type) {
      case 'github':
        _paintGithub(canvas);
        break;
      case 'instagram':
        _paintInstagram(canvas);
        break;
      case 'linkedin':
        _paintLinkedin(canvas);
        break;
      default:
        _paintGithub(canvas);
    }

    canvas.restore();
  }

  void _paintGithub(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Path vektor Octocat GitHub pada koordinat 24x24
    final path = Path()
      ..moveTo(12, 2)
      ..cubicTo(6.477, 2, 2, 6.484, 2, 12.017)
      ..cubicTo(2, 16.442, 4.865, 20.197, 8.839, 21.521)
      ..cubicTo(9.339, 21.613, 9.521, 21.304, 9.521, 21.038)
      ..cubicTo(9.521, 20.801, 9.513, 20.17, 9.508, 19.335)
      ..cubicTo(6.726, 19.94, 6.139, 17.992, 6.139, 17.992)
      ..cubicTo(5.685, 16.834, 5.029, 16.526, 5.029, 16.526)
      ..cubicTo(4.121, 15.906, 5.098, 15.918, 5.098, 15.918)
      ..cubicTo(6.101, 15.988, 6.628, 16.95, 6.628, 16.95)
      ..cubicTo(7.52, 18.48, 8.969, 18.038, 9.538, 17.782)
      ..cubicTo(9.63, 17.135, 9.888, 16.694, 10.174, 16.444)
      ..cubicTo(7.954, 16.191, 5.619, 15.331, 5.619, 11.493)
      ..cubicTo(5.619, 10.4, 6.009, 9.505, 6.648, 8.805)
      ..cubicTo(6.545, 8.552, 6.202, 7.533, 6.746, 6.155)
      ..cubicTo(6.746, 6.155, 7.586, 5.885, 9.496, 7.181)
      ..cubicTo(10.296, 6.958, 11.15, 6.847, 12, 6.844)
      ..cubicTo(12.85, 6.848, 13.705, 6.959, 14.504, 7.181)
      ..cubicTo(16.413, 5.885, 17.251, 6.154, 17.251, 6.154)
      ..cubicTo(17.797, 7.533, 17.453, 8.552, 17.351, 8.805)
      ..cubicTo(17.991, 9.505, 18.379, 10.4, 18.379, 11.493)
      ..cubicTo(
        18.379,
        15.341,
        16.04,
        16.188,
        13.813,
        16.436,
      )
      ..cubicTo(
        14.172,
        16.745,
        14.491,
        17.356,
        14.491,
        18.291,
      )
      ..cubicTo(
        14.491,
        19.629,
        14.479,
        20.71,
        14.479,
        21.038,
      )
      ..cubicTo(
        14.479,
        21.306,
        14.659,
        21.618,
        15.167,
        21.52,
      )
      ..cubicTo(19.138, 20.193, 22, 16.44, 22, 12.017)
      ..cubicTo(22, 6.484, 17.522, 2, 12, 2)
      ..close();

    canvas.drawPath(path, paint);
  }

  void _paintInstagram(Canvas canvas) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Bingkai kamera rounded
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(2.5, 2.5, 19, 19),
        const Radius.circular(5.2),
      ),
      strokePaint,
    );

    // Lensa tengah
    canvas.drawCircle(
      const Offset(12, 12),
      4.2,
      strokePaint,
    );

    // Titik kanan atas
    canvas.drawCircle(
      const Offset(17.4, 6.6),
      1.25,
      fillPaint,
    );
  }

  void _paintLinkedin(Canvas canvas) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Bingkai luar LinkedIn
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(2.5, 2.5, 19, 19),
        const Radius.circular(4.2),
      ),
      strokePaint,
    );

    // Titik 'i'
    canvas.drawCircle(
      const Offset(8.0, 7.6),
      1.35,
      fillPaint,
    );

    // Batang 'i'
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(6.9, 10.2, 2.2, 7.2),
        const Radius.circular(0.8),
      ),
      fillPaint,
    );

    // Huruf 'n'
    final nPath = Path()
      ..moveTo(11.6, 17.4)
      ..lineTo(11.6, 10.2)
      ..lineTo(13.7, 10.2)
      ..lineTo(13.7, 11.3)
      ..cubicTo(14.3, 10.3, 15.2, 9.9, 16.2, 9.9)
      ..cubicTo(17.8, 9.9, 18.6, 11.0, 18.6, 12.9)
      ..lineTo(18.6, 17.4)
      ..lineTo(16.4, 17.4)
      ..lineTo(16.4, 13.3)
      ..cubicTo(16.4, 12.3, 16.0, 11.8, 15.1, 11.8)
      ..cubicTo(14.2, 11.8, 13.8, 12.4, 13.8, 13.4)
      ..lineTo(13.8, 17.4)
      ..close();

    canvas.drawPath(nPath, fillPaint);
  }

  @override
  bool shouldRepaint(
    covariant _SocialSvgPainter oldDelegate,
  ) {
    return oldDelegate.type != type ||
        oldDelegate.color != color;
  }
}
