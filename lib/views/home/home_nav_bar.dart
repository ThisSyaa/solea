import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../core/app_routes.dart';
import '../../core/app_theme.dart';
import 'nav_search_field.dart';

// ============================================================
// NAVBAR HOME (logo, menu, search, wishlist, keranjang, profil)
// ============================================================

class HomeNavBar extends StatelessWidget {
  final String name;
  final String email;
  final int wishlistCount;
  final int cartCount;

  /// true = kolom search sedang terbuka.
  final bool searchOpen;

  final VoidCallback onWishlistTap;
  final VoidCallback onCartTap;
  final VoidCallback onHomeTap;
  final VoidCallback onContactTap;
  final VoidCallback onServicesTap;
  final VoidCallback onAboutTap;

  /// Ikon search ditekan (buka / tutup kolom search).
  final VoidCallback onSearchTap;

  /// Pengguna menekan Enter atau memilih rekomendasi pencarian.
  final ValueChanged<String> onSearchSubmit;

  const HomeNavBar({
    super.key,
    required this.name,
    required this.email,
    required this.wishlistCount,
    required this.cartCount,
    required this.searchOpen,
    required this.onWishlistTap,
    required this.onCartTap,
    required this.onHomeTap,
    required this.onContactTap,
    required this.onServicesTap,
    required this.onAboutTap,
    required this.onSearchTap,
    required this.onSearchSubmit,
  });

  void _onMenuSelected(String label) {
    switch (label) {
      case 'Home':
        onHomeTap();
        break;

      case 'Contact':
        onContactTap();
        break;

      case 'Layanan':
        onServicesTap();
        break;

      case 'Tentang':
        onAboutTap();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    // Layar HP: saat search terbuka, kolom search mengambil seluruh navbar
    // (tanpa animasi) karena ruangnya tidak cukup.
    final isCompact = width < 640;
    final compactSearch = searchOpen && isCompact;

    // Lebar kolom search saat terbuka (layar lebar / sedang).
    final fieldWidth = width >= 1200 ? 320.0 : 240.0;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: compactSearch ? _buildCompactSearch() : _buildNormal(fieldWidth),
    );
  }

  // ---------------------------------------------------------
  // LAYAR HP + SEARCH TERBUKA
  // ---------------------------------------------------------

  Widget _buildCompactSearch() {
    return Row(
      children: [
        Expanded(child: NavSearchField(onSubmit: onSearchSubmit)),
        IconButton(
          tooltip: 'Tutup pencarian',
          onPressed: onSearchTap,
          icon: const Icon(Icons.close_rounded, color: AppColors.ink),
        ),
      ],
    );
  }

  // ---------------------------------------------------------
  // TAMPILAN NORMAL
  // Menu tetap di tempatnya; kolom search memanjang di atas area menu.
  // ---------------------------------------------------------

  Widget _buildNormal(double fieldWidth) {
    return Row(
      children: [
        // LOGO
        Image.asset(
          'assets/images/solea_logo2.png',
          height: 32,
          fit: BoxFit.contain,
        ),

        // AREA TENGAH: menu + kolom search yang memanjang di atasnya
        Expanded(
          child: _NavCenter(
            searchOpen: searchOpen,
            fieldWidth: fieldWidth,
            onSearchSubmit: onSearchSubmit,
            menu: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 420;

                if (isWide) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _NavLink(label: 'Home', active: true, onTap: onHomeTap),
                      _NavLink(label: 'Contact', onTap: onContactTap),
                      _NavLink(label: 'Layanan', onTap: onServicesTap),
                      _NavLink(label: 'Tentang', onTap: onAboutTap),
                    ],
                  );
                }

                return Align(
                  alignment: Alignment.center,
                  child: PopupMenuButton<String>(
                    tooltip: 'Menu navigasi',
                    icon: const Icon(Icons.menu, color: AppColors.ink),
                    onSelected: _onMenuSelected,
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'Home', child: Text('Home')),
                      PopupMenuItem(value: 'Contact', child: Text('Contact')),
                      PopupMenuItem(value: 'Layanan', child: Text('Layanan')),
                      PopupMenuItem(value: 'Tentang', child: Text('Tentang')),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        // IKON SEARCH (posisinya tetap; klik = buka, klik lagi = tutup)
        IconButton(
          tooltip: searchOpen ? 'Tutup pencarian' : 'Cari sepatu',
          onPressed: onSearchTap,
          icon: Icon(
            searchOpen ? Icons.close_rounded : Icons.search_rounded,
            color: AppColors.ink,
          ),
        ),

        _CounterIcon(
          icon: Icons.favorite_border_rounded,
          count: wishlistCount,
          onTap: onWishlistTap,
        ),

        _CounterIcon(
          icon: Icons.shopping_bag_outlined,
          count: cartCount,
          onTap: onCartTap,
        ),

        const SizedBox(width: 4),

        _ProfileMenu(name: name, email: email),
      ],
    );
  }
}

// ============================================================
// AREA TENGAH NAVBAR: MENU + KOLOM SEARCH (ANIMASI MEMANJANG)
// ============================================================

class _NavCenter extends StatefulWidget {
  final bool searchOpen;
  final double fieldWidth;
  final ValueChanged<String> onSearchSubmit;
  final Widget menu;

  const _NavCenter({
    required this.searchOpen,
    required this.fieldWidth,
    required this.onSearchSubmit,
    required this.menu,
  });

  @override
  State<_NavCenter> createState() => _NavCenterState();
}

class _NavCenterState extends State<_NavCenter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curve;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: widget.searchOpen ? 1 : 0,
    );

    _curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void didUpdateWidget(covariant _NavCenter oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.searchOpen != oldWidget.searchOpen) {
      if (widget.searchOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Lebar kolom tidak boleh melebihi area tengah.
        final maxField = widget.fieldWidth < constraints.maxWidth
            ? widget.fieldWidth
            : constraints.maxWidth;

        return Stack(
          children: [
            // MENU: selalu di posisi yang sama, tidak ikut bergeser.
            Positioned.fill(child: widget.menu),

            // KOLOM SEARCH: memanjang ke kiri dari tepi kanan area tengah.
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: AnimatedBuilder(
                animation: _curve,
                child: NavSearchField(onSubmit: widget.onSearchSubmit),
                builder: (context, child) {
                  final t = _curve.value;

                  // Dilepas saat sudah tertutup sepenuhnya.
                  if (t == 0) return const SizedBox.shrink();

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRect(
                        child: SizedBox(
                          width: maxField * t,
                          child: OverflowBox(
                            alignment: Alignment.centerRight,
                            minWidth: 0,
                            maxWidth: maxField,
                            child: SizedBox(width: maxField, child: child),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================
// NAV LINK
// ============================================================

class _NavLink extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavLink({
    required this.label,
    this.active = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: active ? AppColors.forest : AppColors.muted,
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

// ============================================================
// COUNTER ICON
// ============================================================

class _CounterIcon extends StatelessWidget {
  final IconData icon;
  final int count;
  final VoidCallback onTap;

  const _CounterIcon({
    required this.icon,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: AppColors.ink),
        ),

        if (count > 0)
          Positioned(
            top: 4,
            right: 2,
            child: Container(
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: const BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ============================================================
// PROFILE MENU
// ============================================================

class _ProfileMenu extends StatelessWidget {
  final String name;
  final String email;

  const _ProfileMenu({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Akun',
      offset: const Offset(0, 46),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) async {
        if (value == 'logout') {
          final navigator = Navigator.of(context);

          await AuthController.logoutFromFirebase();

          navigator.popUntil((route) => route.isFirst);
          return;
        }

        if (value == 'profile') {
          Navigator.of(context).pushNamed<void>(AppRoutes.profile);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                email,
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
        ),

        const PopupMenuDivider(),

        const PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 18,
                color: AppColors.muted,
              ),
              SizedBox(width: 10),
              Text('Profile'),
            ],
          ),
        ),

        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout_rounded, size: 18, color: AppColors.danger),
              SizedBox(width: 10),
              Text('Logout', style: TextStyle(color: AppColors.danger)),
            ],
          ),
        ),
      ],
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 17,
              backgroundColor: Color(0xFFE8F0EC),
              child: Icon(
                Icons.person_rounded,
                size: 19,
                color: AppColors.forest,
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}