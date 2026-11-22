import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../core/app_routes.dart';
import '../../core/app_theme.dart';
import '../../core/user_avatar.dart';
import 'nav_search_field.dart';

// ============================================================
// NAVBAR HOME (logo, menu desktop, drawer trigger mobile, search, wishlist, keranjang, profil)
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
  final VoidCallback onChatTap;

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
    required this.onChatTap,
    required this.onSearchTap,
    required this.onSearchSubmit,
  });

  void _onMenuSelected(String label) {
    switch (label) {
      case 'Home':
        onHomeTap();
        break;
      case 'Kontak':
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
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final surfaceColor = Theme.of(context).colorScheme.surface;

    final isMobile = width < 600;
    final compactSearch = searchOpen && width < 640;
    final fieldWidth = width >= 1200 ? 320.0 : 240.0;
    final navHeight = math.max(64.0, 24.0 * textScale + 40.0);

    return Container(
      width: double.infinity,
      height: navHeight,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 20,
      ),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: const Border(
          bottom: BorderSide(color: AppColors.line),
        ),
      ),
      child: compactSearch
          ? _buildCompactSearch()
          : isMobile
              ? _buildMobileBar(context)
              : _buildDesktopOrTablet(fieldWidth),
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
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          onPressed: onSearchTap,
          icon: const Icon(Icons.close_rounded, color: AppColors.ink),
        ),
      ],
    );
  }

  // ---------------------------------------------------------
  // LAYAR MOBILE (< 600 dp)
  // Menggunakan tombol Drawer di kiri + Logo + aksi kanan tanpa overflow di 360 dp.
  // ---------------------------------------------------------

  Widget _buildMobileBar(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Buka menu navigasi',
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          onPressed: () {
            Scaffold.maybeOf(context)?.openDrawer();
          },
          icon: const Icon(Icons.menu_rounded, color: AppColors.ink),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Semantics(
              label: 'SOLEA',
              image: true,
              child: Image.asset(
                'assets/images/solea_logo2.png',
                height: 28,
                fit: BoxFit.contain,
                semanticLabel: 'SOLEA',
              ),
            ),
          ),
        ),
        IconButton(
          tooltip: searchOpen ? 'Tutup pencarian' : 'Cari sepatu',
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          onPressed: onSearchTap,
          icon: Icon(
            searchOpen ? Icons.close_rounded : Icons.search_rounded,
            color: AppColors.ink,
          ),
        ),
        _CounterIcon(
          tooltip: 'Wishlist',
          icon: Icons.favorite_border_rounded,
          count: wishlistCount,
          onTap: onWishlistTap,
        ),
        _CounterIcon(
          tooltip: 'Keranjang',
          icon: Icons.shopping_bag_outlined,
          count: cartCount,
          onTap: onCartTap,
        ),
        _ProfileMenu(name: name, email: email),
      ],
    );
  }

  // ---------------------------------------------------------
  // TAMPILAN TABLET & DESKTOP (>= 600 dp)
  // Menu horizontal tetap di tempatnya; kolom search memanjang di atas area menu.
  // ---------------------------------------------------------

  Widget _buildDesktopOrTablet(double fieldWidth) {
    return Row(
      children: [
        // LOGO
        Semantics(
          label: 'SOLEA',
          image: true,
          child: Image.asset(
            'assets/images/solea_logo2.png',
            height: 32,
            fit: BoxFit.contain,
            semanticLabel: 'SOLEA',
          ),
        ),

        // AREA TENGAH: menu + kolom search yang memanjang di atasnya
        Expanded(
          child: _NavCenter(
            searchOpen: searchOpen,
            fieldWidth: fieldWidth,
            onSearchSubmit: onSearchSubmit,
            menu: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 360;

                if (isWide) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _NavLink(label: 'Home', active: true, onTap: onHomeTap),
                      _NavLink(label: 'Kontak', onTap: onContactTap),
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
                      PopupMenuItem(value: 'Kontak', child: Text('Kontak')),
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
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          onPressed: onSearchTap,
          icon: Icon(
            searchOpen ? Icons.close_rounded : Icons.search_rounded,
            color: AppColors.ink,
          ),
        ),

        _CounterIcon(
          tooltip: 'Wishlist',
          icon: Icons.favorite_border_rounded,
          count: wishlistCount,
          onTap: onWishlistTap,
        ),

        _CounterIcon(
          tooltip: 'Keranjang',
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
// DRAWER & BOTTOM NAVIGATION BAR UNTUK MOBILE (< 600 dp)
// ============================================================

class HomeMobileDrawer extends StatelessWidget {
  final String name;
  final String email;
  final int wishlistCount;
  final int cartCount;
  final VoidCallback onHomeTap;
  final VoidCallback onContactTap;
  final VoidCallback onServicesTap;
  final VoidCallback onAboutTap;
  final VoidCallback onChatTap;
  final VoidCallback onWishlistTap;
  final VoidCallback onCartTap;

  const HomeMobileDrawer({
    super.key,
    required this.name,
    required this.email,
    required this.wishlistCount,
    required this.cartCount,
    required this.onHomeTap,
    required this.onContactTap,
    required this.onServicesTap,
    required this.onAboutTap,
    required this.onChatTap,
    required this.onWishlistTap,
    required this.onCartTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/solea_logo2.png',
                    height: 30,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const UserAvatar(radius: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                            if (email.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.line),
            _DrawerTile(
              icon: Icons.home_outlined,
              label: 'Home',
              selected: true,
              onTap: () {
                Navigator.pop(context);
                onHomeTap();
              },
            ),
            _DrawerTile(
              icon: Icons.grid_view_outlined,
              label: 'Layanan SOLEA',
              onTap: () {
                Navigator.pop(context);
                onServicesTap();
              },
            ),
            _DrawerTile(
              icon: Icons.forum_outlined,
              label: 'Chat SOLEA',
              onTap: () {
                Navigator.pop(context);
                onChatTap();
              },
            ),
            _DrawerTile(
              icon: Icons.favorite_border_rounded,
              label: 'Wishlist',
              badgeCount: wishlistCount,
              onTap: () {
                Navigator.pop(context);
                onWishlistTap();
              },
            ),
            _DrawerTile(
              icon: Icons.shopping_bag_outlined,
              label: 'Keranjang',
              badgeCount: cartCount,
              onTap: () {
                Navigator.pop(context);
                onCartTap();
              },
            ),
            _DrawerTile(
              icon: Icons.receipt_long_outlined,
              label: 'Pesanan Saya',
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(AppRoutes.orders);
              },
            ),
            const Divider(height: 16, color: AppColors.line),
            _DrawerTile(
              icon: Icons.support_agent_rounded,
              label: 'Kontak',
              onTap: () {
                Navigator.pop(context);
                onContactTap();
              },
            ),
            _DrawerTile(
              icon: Icons.info_outline_rounded,
              label: 'Tentang Kami',
              onTap: () {
                Navigator.pop(context);
                onAboutTap();
              },
            ),
            _DrawerTile(
              icon: Icons.person_outline_rounded,
              label: 'Profil & Pengaturan',
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(AppRoutes.profile);
              },
            ),
            if (AuthController.isCurrentUserAdmin) ...[
              const Divider(height: 16, color: AppColors.line),
              _DrawerTile(
                icon: Icons.admin_panel_settings_outlined,
                label: 'Dashboard Admin',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed(AppRoutes.admin);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final int badgeCount;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.label,
    this.selected = false,
    this.badgeCount = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minVerticalPadding: 12,
      leading: Icon(
        icon,
        color: selected ? AppColors.forest : AppColors.ink,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          color: selected ? AppColors.forest : AppColors.ink,
        ),
      ),
      trailing: badgeCount > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.forest,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                badgeCount > 99 ? '99+' : '$badgeCount',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}

class HomeMobileBottomNav extends StatelessWidget {
  final int wishlistCount;
  final int cartCount;
  final VoidCallback onHomeTap;
  final VoidCallback onServicesTap;
  final VoidCallback onWishlistTap;
  final VoidCallback onCartTap;
  final VoidCallback onProfileTap;

  const HomeMobileBottomNav({
    super.key,
    required this.wishlistCount,
    required this.cartCount,
    required this.onHomeTap,
    required this.onServicesTap,
    required this.onWishlistTap,
    required this.onCartTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surfaceColor,
        border: const Border(top: BorderSide(color: AppColors.line)),
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        backgroundColor: surfaceColor,
        selectedItemColor: AppColors.forest,
        unselectedItemColor: AppColors.muted,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              onHomeTap();
              break;
            case 1:
              onServicesTap();
              break;
            case 2:
              onWishlistTap();
              break;
            case 3:
              onCartTap();
              break;
            case 4:
              onProfileTap();
              break;
          }
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Layanan',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: wishlistCount > 0,
              label: Text('$wishlistCount'),
              child: const Icon(Icons.favorite_border_rounded),
            ),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            label: 'Keranjang',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profil',
          ),
        ],
      ),
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

    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);
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
          fit: StackFit.expand,
          children: [
            // MENU: selalu di posisi yang sama, tidak ikut bergeser.
            Center(child: widget.menu),

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
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
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
  final String tooltip;
  final IconData icon;
  final int count;
  final VoidCallback onTap;

  const _CounterIcon({
    required this.tooltip,
    required this.icon,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onErrorColor = Theme.of(context).colorScheme.onError;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: tooltip,
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          onPressed: onTap,
          icon: Icon(icon, color: AppColors.ink),
        ),
        if (count > 0)
          Positioned(
            top: 4,
            right: 2,
            child: IgnorePointer(
              child: Container(
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: const BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: onErrorColor,
                    ),
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
          return;
        }

        if (value == 'admin') {
          Navigator.of(context).pushNamed<void>(AppRoutes.admin);
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
        if (AuthController.isCurrentUserAdmin)
          const PopupMenuItem<String>(
            value: 'admin',
            child: Row(
              children: [
                Icon(
                  Icons.admin_panel_settings_outlined,
                  size: 18,
                  color: AppColors.muted,
                ),
                SizedBox(width: 10),
                Text('Dashboard Admin'),
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
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              UserAvatar(radius: 17),
              SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}