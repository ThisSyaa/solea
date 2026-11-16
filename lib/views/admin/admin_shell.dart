import 'dart:async';

import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../core/app_theme.dart';
import '../../models/admin_models.dart';
import '../../services/admin_service.dart';
import 'admin_dashboard_page.dart';
import 'admin_orders_page.dart';
import 'admin_products_page.dart';
import 'admin_theme.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  static const _titles = ['Dashboard', 'Pesanan', 'Produk'];

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _search = TextEditingController();

  late final Future<bool> _adminCheck;
  StreamSubscription<List<AdminOrder>>? _sub;
  List<AdminOrder>? _orders;
  String? _ordersError;

  int _index = 0;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _adminCheck = AdminService.isAdmin();
    _adminCheck.then((ok) {
      if (ok && mounted) _listenOrders();
    });
  }

  void _listenOrders() {
    _sub = AdminService.ordersStream().listen(
      (list) {
        if (!mounted) return;
        setState(() {
          _orders = list;
          _ordersError = null;
        });
      },
      onError: (Object e) {
        if (!mounted) return;
        setState(() => _ordersError = '$e');
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _select(int i) {
    setState(() => _index = i);
    _scaffoldKey.currentState?.closeDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _adminCheck,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AdminColors.orange),
            ),
          );
        }
        if (snap.data != true) return const _AccessDenied();
        return _layout(context);
      },
    );
  }

  Widget _layout(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final wide = box.maxWidth >= 900;
        final pending =
            _orders?.where((o) => o.status == 'Diproses').length ?? 0;

        final nav = _Sidebar(
          index: _index,
          pending: pending,
          onSelect: _select,
        );

        final content = Column(
          children: [
            _TopBar(
              title: _titles[_index],
              wide: wide,
              search: _search,
              onQuery: (v) => setState(() => _query = v),
              onSubmit: () {
                if (_index == 0) setState(() => _index = 1);
              },
              pending: pending,
              onBell: () => setState(() => _index = 1),
              onMenu: wide ? null : () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(child: _page()),
          ],
        );

        return AdminTheme.wrap(
          context,
          Scaffold(
            key: _scaffoldKey,
            backgroundColor: wide ? AdminColors.beige : AdminColors.bg,
            drawer: wide
                ? null
                : Drawer(backgroundColor: AdminColors.sidebar, child: nav),
            body: wide
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: ColoredBox(
                        color: AdminColors.bg,
                        child: Row(
                          children: [
                            SizedBox(width: 240, child: nav),
                            Expanded(child: content),
                          ],
                        ),
                      ),
                    ),
                  )
                : SafeArea(
                    child: ColoredBox(color: AdminColors.bg, child: content),
                  ),
          ),
        );
      },
    );
  }

  Widget _page() {
    if (_index == 2) return AdminProductsPage(query: _query);

    if (_ordersError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Gagal memuat pesanan.\n'
            'Pastikan Firestore Rules untuk admin sudah dipasang.\n'
            '$_ordersError',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AdminColors.muted, fontSize: 13),
          ),
        ),
      );
    }

    final orders = _orders;
    if (orders == null) {
      return const Center(
        child: CircularProgressIndicator(color: AdminColors.orange),
      );
    }

    return _index == 0
        ? AdminDashboardPage(orders: orders)
        : AdminOrdersPage(orders: orders, query: _query);
  }
}

// =============================================================
// SIDEBAR
// =============================================================

class _Sidebar extends StatelessWidget {
  final int index;
  final int pending;
  final ValueChanged<int> onSelect;

  const _Sidebar({
    required this.index,
    required this.pending,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AdminColors.sidebar,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(8, 0, 8, 28),
                child: SoleaLogo(height: 32),
              ),
              _NavItem(
                icon: Icons.grid_view_rounded,
                label: 'Dashboard',
                selected: index == 0,
                onTap: () => onSelect(0),
              ),
              const SizedBox(height: 6),
              _NavItem(
                icon: Icons.shopping_cart_outlined,
                label: 'Pesanan',
                selected: index == 1,
                badge: pending,
                onTap: () => onSelect(1),
              ),
              const SizedBox(height: 6),
              _NavItem(
                icon: Icons.inventory_2_outlined,
                label: 'Produk',
                selected: index == 2,
                onTap: () => onSelect(2),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(height: 1, color: AdminColors.line),
              ),
              _NavItem(
                icon: Icons.storefront_outlined,
                label: 'Kembali ke toko',
                selected: false,
                onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
              ),
              const SizedBox(height: 6),
              _NavItem(
                icon: Icons.logout,
                label: 'Keluar',
                selected: false,
                onTap: () async {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                  await AuthController.logoutFromFirebase();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final int badge;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AdminColors.ink;
    return Material(
      color: selected ? AdminColors.orange : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: fg),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: fg,
                  ),
                ),
              ),
              if (badge > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : AdminColors.orange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$badge',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: selected ? AdminColors.orange : Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================
// TOP BAR
// =============================================================

class _TopBar extends StatelessWidget {
  final String title;
  final bool wide;
  final TextEditingController search;
  final ValueChanged<String> onQuery;
  final VoidCallback onSubmit;
  final int pending;
  final VoidCallback onBell;
  final VoidCallback? onMenu;

  const _TopBar({
    required this.title,
    required this.wide,
    required this.search,
    required this.onQuery,
    required this.onSubmit,
    required this.pending,
    required this.onBell,
    required this.onMenu,
  });

  Widget _searchField() {
    OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: c == Colors.transparent
              ? BorderSide.none
              : BorderSide(color: c, width: w),
        );

    return TextField(
      controller: search,
      onChanged: onQuery,
      onSubmitted: (_) => onSubmit(),
      style: const TextStyle(fontSize: 13.5),
      decoration: InputDecoration(
        hintText: 'Cari pesanan, pelanggan, produk',
        hintStyle: const TextStyle(fontSize: 13.5, color: AdminColors.muted),
        suffixIcon: const Icon(
          Icons.search,
          size: 20,
          color: AdminColors.muted,
        ),
        isDense: true,
        filled: true,
        fillColor: AdminColors.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        border: b(Colors.transparent),
        enabledBorder: b(Colors.transparent),
        focusedBorder: b(AdminColors.orange, 1.2),
      ),
    );
  }

  Widget _bell() {
    return Tooltip(
      message: pending > 0
          ? '$pending pesanan perlu diproses'
          : 'Tidak ada pesanan baru',
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(
          side: BorderSide(color: AdminColors.line),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onBell,
          child: SizedBox(
            width: 42,
            height: 42,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  size: 21,
                  color: AdminColors.ink,
                ),
                if (pending > 0)
                  Positioned(
                    top: 9,
                    right: 11,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: AdminColors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _profile(BuildContext context) {
    final name = AuthController.currentName ??
        AuthController.firebaseUser?.displayName ??
        'Admin';
    final initial = name.trim().isEmpty ? 'A' : name.trim()[0].toUpperCase();

    return PopupMenuButton<String>(
      tooltip: 'Akun',
      offset: const Offset(0, 48),
      onSelected: (v) async {
        Navigator.of(context).popUntil((r) => r.isFirst);
        if (v == 'logout') await AuthController.logoutFromFirebase();
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'shop', child: Text('Kembali ke toko')),
        PopupMenuItem(value: 'logout', child: Text('Keluar')),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AdminColors.peach,
            child: Text(
              initial,
              style: const TextStyle(
                color: AdminColors.orange,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          if (wide) ...[
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 140),
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AdminColors.ink,
                    ),
                  ),
                ),
                const Text(
                  'Admin',
                  style: TextStyle(fontSize: 11.5, color: AdminColors.muted),
                ),
              ],
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: AdminColors.ink,
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (wide) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 16),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: AdminColors.ink,
              ),
            ),
            const Spacer(),
            SizedBox(width: 330, child: _searchField()),
            const SizedBox(width: 20),
            _bell(),
            const SizedBox(width: 16),
            _profile(context),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onMenu,
                icon: const Icon(Icons.menu_rounded, color: AdminColors.ink),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AdminColors.ink,
                  ),
                ),
              ),
              _bell(),
              const SizedBox(width: 12),
              _profile(context),
            ],
          ),
          const SizedBox(height: 10),
          _searchField(),
        ],
      ),
    );
  }
}

// =============================================================
// AKSES DITOLAK
// =============================================================

class _AccessDenied extends StatelessWidget {
  const _AccessDenied();

  @override
  Widget build(BuildContext context) {
    final uid = AuthController.currentUid ?? '(belum login)';
    return Scaffold(
      backgroundColor: AdminColors.beige,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 40,
                    color: AdminColors.muted,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Akses admin ditolak',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AdminColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Akun ini belum terdaftar sebagai admin. Tambahkan '
                    'dokumen di koleksi "admins" dengan ID berikut:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: AdminColors.muted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    uid,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  OutlinedButton(
                    onPressed: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                    child: const Text('Kembali ke toko'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}