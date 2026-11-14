import '../../core/app_network_image.dart';
import 'package:flutter/material.dart';

import '../../controllers/cart_controller.dart';
import '../../controllers/wishlist_controller.dart';
import '../../core/app_helpers.dart';
import '../../core/app_routes.dart';
import '../../core/app_theme.dart';
import '../../core/home_button.dart';
import '../../models/product.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  // =========================================================
  // AKSI
  // =========================================================

  void _snack(BuildContext context, String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 2400),
          action: action,
        ),
      );
  }

  void _remove(BuildContext context, Product product) {
    final controller = WishlistController.instance;

    controller.toggle(product);

    _snack(
      context,
      '${product.name} dihapus dari wishlist.',
      action: SnackBarAction(
        label: 'Batalkan',
        onPressed: () {
          if (!controller.contains(product)) controller.toggle(product);
        },
      ),
    );
  }

  Future<void> _confirmClearAll(BuildContext context) async {
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

  Future<void> _addToCart(BuildContext context, Product product) async {
    final size = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      constraints: const BoxConstraints(maxWidth: 520),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SizePickerSheet(product: product),
    );

    if (size == null || !context.mounted) return;

    CartController.instance.add(product, size);

    _snack(
      context,
      '${product.name} (size $size) masuk ke keranjang.',
      action: SnackBarAction(
        label: 'Lihat',
        onPressed: () {
          Navigator.of(context).pushNamed<void>(AppRoutes.cart);
        },
      ),
    );
  }

  void _openProduct(BuildContext context, Product product) {
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
                  // HEADER: jumlah item + hapus semua
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(side, 8, side, 16),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${products.length} sepatu tersimpan',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _confirmClearAll(context),
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
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final product = products[index];

                        return _WishlistCard(
                          product: product,
                          compact: cardWidth < 200,
                          onTap: () => _openProduct(context, product),
                          onRemove: () => _remove(context, product),
                          onAddToCart: () => _addToCart(context, product),
                        );
                      }, childCount: products.length),
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
// KARTU WISHLIST
// ============================================================

class _WishlistCard extends StatelessWidget {
  final Product product;
  final bool compact;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final VoidCallback onAddToCart;

  const _WishlistCard({
    required this.product,
    required this.compact,
    required this.onTap,
    required this.onRemove,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FOTO + tombol hati
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: AppColors.sand,
                        child: AppNetworkImage(imageUrl: product.imageUrl),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Tooltip(
                          message: 'Hapus dari wishlist',
                          child: Material(
                            color: Colors.white.withValues(alpha: 0.94),
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: onRemove,
                              child: const Padding(
                                padding: EdgeInsets.all(7),
                                child: Icon(
                                  Icons.favorite_rounded,
                                  size: 17,
                                  color: AppColors.danger,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                product.category,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
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
                  const Icon(
                    Icons.star_rounded,
                    size: 15,
                    color: Color(0xFFE1A12B),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    product.rating.toString(),
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 40,
                child: FilledButton.icon(
                  onPressed: onAddToCart,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.forest,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    textStyle: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.shopping_bag_outlined, size: 17),
                  label: Text(
                    compact ? 'Keranjang' : 'Tambah ke keranjang',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
// TAMPILAN KOSONG
// ============================================================

class _WishlistEmpty extends StatelessWidget {
  const _WishlistEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: AppColors.line),
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 38,
                color: AppColors.forest,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Wishlist masih kosong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Simpan sepatu yang kamu suka untuk dibeli nanti.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.forest,
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Mulai belanja'),
            ),
          ],
        ),
      ),
    );
  }
}