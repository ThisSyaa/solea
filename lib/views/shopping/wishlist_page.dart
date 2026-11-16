import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../controllers/cart_controller.dart';
import '../../controllers/wishlist_controller.dart';
import '../../core/app_helpers.dart';
import '../../core/app_network_image.dart';
import '../../core/app_routes.dart';
import '../../core/app_theme.dart';
import '../../core/home_button.dart';
import '../../models/product.dart';

// ============================================================
// WARNA PER KATEGORI
// Dipakai untuk label di foto, chip filter, bayangan saat hover,
// dan warna tombol keranjang. Kategori yang tidak dikenal memakai
// warna utama aplikasi.
// ============================================================

Color _categoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'running':
      return const Color(0xFF3F7D20);
    case 'basketball':
      return const Color(0xFFC4561A);
    case 'training':
      return const Color(0xFF2F5FA8);
    case 'casual':
      return const Color(0xFF6B5B95);
    case 'outdoor':
      return const Color(0xFF8A5A2B);
    case 'lifestyle':
      return const Color(0xFF9A6410);
    default:
      return AppColors.forest;
  }
}

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  /// Kategori yang sedang dipilih di chip filter. null = semua.
  String? _filter;

  // =========================================================
  // AKSI
  // =========================================================

  void _snack(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 2400),
          persist: false,
          action: action,
        ),
      );
  }

  void _remove(Product product) {
    final controller = WishlistController.instance;

    controller.toggle(product);

    _snack(
      '${product.name} dihapus dari wishlist.',
      action: SnackBarAction(
        label: 'Batalkan',
        onPressed: () {
          if (!controller.contains(product)) controller.toggle(product);
        },
      ),
    );
  }

  Future<void> _confirmClearAll() async {
    final controller = WishlistController.instance;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus semua wishlist?'),
          content: Text('${controller.count} sepatu akan dihapus dari wishlist.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Hapus semua'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    // products adalah salinan daftar, jadi aman di-loop sambil menghapus.
    for (final product in controller.products) {
      controller.toggle(product);
    }
  }

  Future<void> _addToCart(Product product) async {
    final size = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      constraints: const BoxConstraints(maxWidth: 520),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SizePickerSheet(product: product),
    );

    if (size == null || !mounted) return;

    CartController.instance.add(product, size);

    _snack(
      '${product.name} (size $size) masuk ke keranjang.',
      action: SnackBarAction(
        label: 'Lihat',
        onPressed: () {
          Navigator.of(context).pushNamed<void>(AppRoutes.cart);
        },
      ),
    );
  }

  void _openProduct(Product product) {
    Navigator.of(context).pushNamed<void>(AppRoutes.product(product));
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand,
      appBar: AppBar(
        backgroundColor: AppColors.sand,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: const Text(
          'Wishlist',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 12), child: HomeButton()),
        ],
      ),
      body: AnimatedBuilder(
        animation: WishlistController.instance,
        builder: (context, _) {
          final products = WishlistController.instance.products;

          if (products.isEmpty) {
            return const _WishlistEmpty();
          }

          // Daftar kategori (urut kemunculan) + jumlahnya.
          final categories = <String>[];
          final counts = <String, int>{};
          for (final p in products) {
            if (!counts.containsKey(p.category)) categories.add(p.category);
            counts[p.category] = (counts[p.category] ?? 0) + 1;
          }

          // Kalau kategori yang dipilih sudah tidak ada, kembali ke "Semua".
          final active = (_filter != null && counts.containsKey(_filter))
              ? _filter
              : null;

          final visible = active == null
              ? products
              : products.where((p) => p.category == active).toList();

          final total = products.fold<int>(0, (sum, p) => sum + p.price);

          return LayoutBuilder(
            builder: (context, constraints) {
              const maxContentWidth = 1180.0;
              const gap = 16.0;

              final basePadding = constraints.maxWidth < 700 ? 16.0 : 24.0;
              final centered = (constraints.maxWidth - maxContentWidth) / 2;
              final side = centered > basePadding ? centered : basePadding;

              final inner = constraints.maxWidth - side * 2;
              final columns = inner >= 900
                  ? 4
                  : inner >= 600
                      ? 3
                      : 2;
              final cardWidth = (inner - gap * (columns - 1)) / columns;

              return CustomScrollView(
                slivers: [
                  // HEADER: jumlah item, estimasi total, hapus semua
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(side, 8, side, 14),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  child: Text(
                                    '${products.length} sepatu tersimpan',
                                    key: ValueKey<int>(products.length),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Estimasi total ${formatRupiah(total)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.muted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _confirmClearAll,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.danger,
                            ),
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                            ),
                            label: const Text('Hapus semua'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // CHIP FILTER KATEGORI
                  if (categories.length > 1)
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: side),
                          itemCount: categories.length + 1,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            if (i == 0) {
                              return _FilterChip(
                                label: 'Semua',
                                count: products.length,
                                color: AppColors.forest,
                                selected: active == null,
                                onTap: () => setState(() => _filter = null),
                              );
                            }
                            final category = categories[i - 1];
                            return _FilterChip(
                              label: category,
                              count: counts[category] ?? 0,
                              color: _categoryColor(category),
                              selected: active == category,
                              onTap: () => setState(() => _filter = category),
                            );
                          },
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // GRID KARTU
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(side, 0, side, 36),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: gap,
                        mainAxisSpacing: gap,
                        mainAxisExtent: cardWidth + 142,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = visible[index];

                          return _WishlistCard(
                            key: ValueKey<String>('wish_${product.name}'),
                            product: product,
                            compact: cardWidth < 200,
                            // Muncul bergelombang per baris (kolom ke-1, ke-2, ...).
                            enterDelay: Duration(
                              milliseconds: (index % columns) * 70,
                            ),
                            onTap: () => _openProduct(product),
                            onRemove: () => _remove(product),
                            onAddToCart: () => _addToCart(product),
                          );
                        },
                        childCount: visible.length,
                        findChildIndexCallback: (key) {
                          if (key is! ValueKey<String>) return null;
                          final i = visible.indexWhere(
                            (p) => 'wish_${p.name}' == key.value,
                          );
                          return i < 0 ? null : i;
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

// ============================================================
// CHIP FILTER KATEGORI
// ============================================================

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected ? color : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? color : AppColors.line),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!selected) ...[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : AppColors.ink,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? Colors.white.withValues(alpha: 0.8)
                        : AppColors.muted,
                  ),
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
// KARTU WISHLIST
// ============================================================

class _WishlistCard extends StatefulWidget {
  final Product product;
  final bool compact;
  final Duration enterDelay;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final VoidCallback onAddToCart;

  const _WishlistCard({
    super.key,
    required this.product,
    required this.compact,
    required this.enterDelay,
    required this.onTap,
    required this.onRemove,
    required this.onAddToCart,
  });

  @override
  State<_WishlistCard> createState() => _WishlistCardState();
}

class _WishlistCardState extends State<_WishlistCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 480),
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _enter,
    curve: Curves.easeOut,
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.06),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _enter, curve: Curves.easeOutCubic));

  bool _hover = false;
  bool _removing = false;

  @override
  void initState() {
    super.initState();

    // Hormati pengaturan "kurangi animasi" dari sistem.
    final reduceMotion = WidgetsBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations;

    if (reduceMotion) {
      _enter.value = 1;
    } else {
      Future<void>.delayed(widget.enterDelay, () {
        if (mounted) _enter.forward();
      });
    }
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  /// Kartu mengecil dan memudar dulu, baru dihapus dari wishlist.
  void _handleRemove() {
    if (_removing) return;
    setState(() => _removing = true);
    Future<void>.delayed(const Duration(milliseconds: 240), () {
      if (mounted) widget.onRemove();
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final accent = _categoryColor(product.category);
    final lifted = _hover && !_removing;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: AnimatedScale(
          scale: _removing ? 0.92 : 1,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeInCubic,
          child: AnimatedOpacity(
            opacity: _removing ? 0 : 1,
            duration: const Duration(milliseconds: 240),
            child: MouseRegion(
              onEnter: (_) => setState(() => _hover = true),
              onExit: (_) => setState(() => _hover = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                transform: Matrix4.translationValues(0, lifted ? -6 : 0, 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: lifted
                        ? accent.withValues(alpha: 0.6)
                        : AppColors.line,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: lifted ? 0.20 : 0.0),
                      blurRadius: lifted ? 28 : 0,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(19),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onTap,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // FOTO + label kategori + tombol hati
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Container(
                                      color: AppColors.sand,
                                      child: AnimatedScale(
                                        scale: lifted ? 1.07 : 1.0,
                                        duration: const Duration(
                                          milliseconds: 450,
                                        ),
                                        curve: Curves.easeOutCubic,
                                        child: AppNetworkImage(
                                          imageUrl: product.imageUrl,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 0,
                                      right: 0,
                                      bottom: 0,
                                      height: 64,
                                      child: IgnorePointer(
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withValues(
                                                  alpha: 0.28,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 8,
                                      bottom: 8,
                                      child: _CategoryTag(
                                        label: product.category,
                                        color: accent,
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: _HeartButton(
                                        onTap: _handleRemove,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14.5,
                                color: AppColors.ink,
                                fontWeight: FontWeight.w800,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    formatRupiah(product.price),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      color: AppColors.forestDeep,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF4DC),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        size: 14,
                                        color: Color(0xFFE1A12B),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        product.rating.toString(),
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          color: Color(0xFF7A5A12),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: FilledButton.icon(
                                onPressed: widget.onAddToCart,
                                style: FilledButton.styleFrom(
                                  // Saat kartu di-hover, tombol ikut warna kategori.
                                  backgroundColor: lifted
                                      ? accent
                                      : AppColors.forest,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 17,
                                ),
                                label: Text(
                                  widget.compact
                                      ? 'Keranjang'
                                      : 'Tambah ke keranjang',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// LABEL KATEGORI DI ATAS FOTO
// ============================================================

class _CategoryTag extends StatelessWidget {
  final String label;
  final Color color;

  const _CategoryTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ============================================================
// TOMBOL HATI (berubah merah + membesar saat di-hover)
// ============================================================

class _HeartButton extends StatefulWidget {
  final VoidCallback onTap;

  const _HeartButton({required this.onTap});

  @override
  State<_HeartButton> createState() => _HeartButtonState();
}

class _HeartButtonState extends State<_HeartButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Tooltip(
        message: 'Hapus dari wishlist',
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _hover ? 1.12 : 1,
            duration: const Duration(milliseconds: 160),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _hover
                    ? AppColors.danger
                    : Colors.white.withValues(alpha: 0.94),
              ),
              child: Icon(
                _hover
                    ? Icons.heart_broken_rounded
                    : Icons.favorite_rounded,
                size: 17,
                color: _hover ? Colors.white : AppColors.danger,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PILIH UKURAN (bottom sheet) SEBELUM MASUK KERANJANG
// ============================================================

class _SizePickerSheet extends StatelessWidget {
  final Product product;

  const _SizePickerSheet({required this.product});

  @override
  Widget build(BuildContext context) {
    final sizes = product.sizes.isEmpty
        ? const [39, 40, 41, 42, 43]
        : product.sizes;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formatRupiah(product.price),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.forestDeep,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Pilih ukuran',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final size in sizes)
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context, size),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(56, 44),
                      foregroundColor: AppColors.ink,
                      side: const BorderSide(color: AppColors.line),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '$size',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// TAMPILAN WISHLIST KOSONG
// Ilustrasi hati beranimasi (digambar dengan kode, jadi tidak
// butuh file GIF/Lottie dan tetap tajam di semua ukuran layar).
// Gayanya disamakan dengan tampilan keranjang kosong.
// ============================================================

class _WishlistEmpty extends StatefulWidget {
  const _WishlistEmpty();

  @override
  State<_WishlistEmpty> createState() => _WishlistEmptyState();
}

class _WishlistEmptyState extends State<_WishlistEmpty>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  @override
  void initState() {
    super.initState();

    // Hormati pengaturan "kurangi animasi" dari sistem.
    final reduceMotion = WidgetsBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations;

    if (!reduceMotion) _loop.repeat();
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 16 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ilustrasi hanya dekorasi: tidak perlu dibacakan screen reader.
                ExcludeSemantics(
                  child: RepaintBoundary(
                    child: SizedBox(
                      width: 230,
                      height: 170,
                      child: CustomPaint(painter: _EmptyWishlistPainter(_loop)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Wishlist masih kosong',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Simpan sepatu yang kamu suka untuk dibeli nanti.\n'
                  'Tap ikon hati di katalog untuk menambahkannya.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.55,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: 240,
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.maybePop(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.forest,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    icon: const Icon(Icons.storefront_outlined, size: 19),
                    label: const Text('Mulai belanja'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Hati besar yang melayang naik-turun pelan sambil berdetak, dengan
/// bayangan yang mengecil saat naik, hati-hati kecil yang melayang naik,
/// dan kilauan bintang.
class _EmptyWishlistPainter extends CustomPainter {
  final Animation<double> loop;

  _EmptyWishlistPainter(this.loop) : super(repaint: loop);

  static const _ink = AppColors.ink;
  static const _forest = AppColors.forest;
  static const _rose = AppColors.danger;
  static const _amber = Color(0xFFE1A12B);

  @override
  void paint(Canvas canvas, Size size) {
    final t = loop.value;
    final wave = math.sin(t * 2 * math.pi);
    final lift = (wave + 1) / 2; // 0 = turun, 1 = naik
    final cx = size.width / 2;

    _paintBackdrop(canvas, size);
    _paintShadow(canvas, size, lift);

    // Hati kecil yang melayang naik di kiri dan kanan hati besar.
    _floatingHeart(canvas, Offset(cx - 76, 0), 0.20, _rose, t, 0.00);
    _floatingHeart(canvas, Offset(cx + 78, 0), 0.16, _forest, t, 0.50);

    // Hati besar: melayang + miring sedikit + berdetak dua kali per putaran.
    final beat = math.pow(math.max(0.0, math.sin(t * 4 * math.pi)), 4);
    final scale = 1 + 0.05 * beat;

    canvas.save();
    canvas.translate(cx, 78 - 12 * lift);
    canvas.rotate(0.035 * math.sin(t * 2 * math.pi + 0.8));
    canvas.scale(scale.toDouble());
    canvas.translate(-55, -46);
    _paintHeart(canvas);
    canvas.restore();

    // Kilauan di sekitar hati.
    _sparkle(canvas, Offset(cx - 90, 40), 9, _amber, t, 0.00);
    _sparkle(canvas, Offset(cx + 92, 48), 7, _forest, t, 0.33);
    _sparkle(canvas, Offset(cx + 60, 14), 5, _amber, t, 0.62);
    _sparkle(canvas, Offset(cx - 56, 12), 5, _forest, t, 0.80);
  }

  void _paintBackdrop(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, 82);
    canvas.drawCircle(
      center,
      74,
      Paint()..color = _forest.withValues(alpha: 0.07),
    );
    canvas.drawCircle(
      center,
      52,
      Paint()..color = _forest.withValues(alpha: 0.07),
    );
  }

  void _paintShadow(Canvas canvas, Size size, double lift) {
    final width = 104 - 28 * lift;
    final alpha = 0.16 - 0.07 * lift;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height - 14),
        width: width,
        height: 12,
      ),
      Paint()..color = _ink.withValues(alpha: alpha),
    );
  }

  /// Bentuk hati pada kotak lokal 110 x 92 (titik tengah 55, 46).
  Path _heartPath() {
    return Path()
      ..moveTo(55, 90)
      ..cubicTo(18, 62, 4, 44, 4, 28)
      ..cubicTo(4, 12, 16, 2, 30, 2)
      ..cubicTo(42, 2, 51, 8, 55, 18)
      ..cubicTo(59, 8, 68, 2, 80, 2)
      ..cubicTo(94, 2, 106, 12, 106, 28)
      ..cubicTo(106, 44, 92, 62, 55, 90)
      ..close();
  }

  void _paintHeart(Canvas canvas) {
    final heart = _heartPath();

    canvas.drawPath(heart, Paint()..color = Colors.white);

    // Garis kilap di lengkungan kiri atas, seperti kisi-kisi pada keranjang.
    final shine = Paint()
      ..color = _ink.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(
      Path()
        ..moveTo(18, 30)
        ..cubicTo(18, 21, 24, 15, 32, 15),
      shine,
    );

    // Hati kecil berwarna di tengah.
    canvas.save();
    canvas.translate(55, 44);
    canvas.scale(0.34);
    canvas.translate(-55, -46);
    canvas.drawPath(_heartPath(), Paint()..color = _forest);
    canvas.restore();

    canvas.drawPath(
      heart,
      Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  /// Hati kecil yang naik pelan, bergoyang, lalu memudar.
  void _floatingHeart(
    Canvas canvas,
    Offset anchor,
    double scale,
    Color color,
    double t,
    double phase,
  ) {
    final p = (t + phase) % 1.0;
    final alpha = math.sin(p * math.pi);
    if (alpha < 0.02) return;

    final x = anchor.dx + 5 * math.sin(p * 2 * math.pi * 1.5);
    final y = 128 - 78 * p;

    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale * (0.8 + 0.2 * alpha));
    canvas.translate(-55, -46);
    canvas.drawPath(
      _heartPath(),
      Paint()..color = color.withValues(alpha: 0.75 * alpha),
    );
    canvas.restore();
  }

  void _sparkle(
    Canvas canvas,
    Offset c,
    double r,
    Color color,
    double t,
    double phase,
  ) {
    final pulse = math.max(0.0, math.sin((t + phase) * 2 * math.pi));
    final radius = r * (0.35 + 0.65 * pulse);
    if (radius < 0.5) return;

    final path = Path()
      ..moveTo(c.dx, c.dy - radius)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + radius, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + radius)
      ..quadraticBezierTo(c.dx, c.dy, c.dx - radius, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - radius)
      ..close();

    canvas.drawPath(
      path,
      Paint()..color = color.withValues(alpha: 0.35 + 0.65 * pulse),
    );
  }

  @override
  bool shouldRepaint(covariant _EmptyWishlistPainter oldDelegate) =>
      oldDelegate.loop != loop;
}