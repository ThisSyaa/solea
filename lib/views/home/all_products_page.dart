import 'package:flutter/material.dart';

import '../../controllers/product_controller.dart';
import '../../controllers/wishlist_controller.dart';
import '../../core/app_helpers.dart';
import '../../core/app_theme.dart';
import '../../models/product.dart';
import 'product_detail_page.dart';

enum AllProductsMode { categories, featured, popular }

enum _ProductSort { recommended, priceLowToHigh, priceHighToLow, rating }

class AllProductsPage extends StatefulWidget {
  final AllProductsMode mode;

  const AllProductsPage({super.key, required this.mode});

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  String? _selectedCategory;

  _ProductSort _sort = _ProductSort.recommended;

  bool _showCategoryOverview = true;

  List<String> get _categories => ProductController.categories
      .where((category) => category != 'Semua')
      .toList(growable: false);

  String get _pageTitle {
    switch (widget.mode) {
      case AllProductsMode.categories:
        if (_showCategoryOverview) {
          return 'Semua Kategori';
        }

        return _selectedCategory ?? 'Semua Sepatu';

      case AllProductsMode.featured:
        return 'Sepatu Pilihan';

      case AllProductsMode.popular:
        return 'Popular Sekarang';
    }
  }

  // =========================================================
  // DATA PRODUK
  // =========================================================

  List<Product> get _products {
    Iterable<Product> result = ProductController.products;

    final category = _selectedCategory;

    if (category != null) {
      result = result.where((product) => product.category == category);
    }

    final products = result.toList();

    if (widget.mode == AllProductsMode.popular) {
      products.sort((a, b) => b.rating.compareTo(a.rating));

      return products;
    }

    switch (_sort) {
      case _ProductSort.recommended:
        // Menggunakan urutan asli ProductController.
        break;

      case _ProductSort.priceLowToHigh:
        products.sort((a, b) => a.price.compareTo(b.price));
        break;

      case _ProductSort.priceHighToLow:
        products.sort((a, b) => b.price.compareTo(a.price));
        break;

      case _ProductSort.rating:
        products.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }

    return products;
  }

  Product? _categoryCover(String category) {
    for (final product in ProductController.products) {
      if (product.category == category) {
        return product;
      }
    }

    return null;
  }

  // =========================================================
  // NAVIGASI
  // =========================================================

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _showCategoryOverview = false;
      _sort = _ProductSort.recommended;
    });
  }

  void _backAction() {
    if (widget.mode == AllProductsMode.categories && !_showCategoryOverview) {
      setState(() {
        _showCategoryOverview = true;
        _selectedCategory = null;
        _sort = _ProductSort.recommended;
      });

      return;
    }

    Navigator.of(context).pop();
  }

  Future<void> _openProduct(Product product) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailPage(product: product),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  void _toggleWishlist(Product product) {
    final controller = WishlistController.instance;
    final wasFavorite = controller.contains(product);

    controller.toggle(product);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            wasFavorite
                ? '${product.name} dihapus dari wishlist.'
                : '${product.name} ditambahkan ke wishlist.',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1000),
        ),
      );
  }

  // =========================================================
  // PAGE
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final horizontalPadding = width < 600
        ? 16.0
        : width < 900
        ? 24.0
        : 32.0;

    return Scaffold(
      backgroundColor: AppColors.sand,
      appBar: AppBar(
        backgroundColor: AppColors.sand,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: _backAction,
          tooltip: 'Kembali',
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
        ),
        title: Text(
          _pageTitle,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          12,
          horizontalPadding,
          36,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1220),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIntro(),
                const SizedBox(height: 24),

                if (widget.mode == AllProductsMode.categories &&
                    _showCategoryOverview)
                  _buildCategoryGrid()
                else ...[
                  _buildCategoryFilters(),
                  const SizedBox(height: 18),
                  _buildResultsHeader(),
                  const SizedBox(height: 14),
                  _buildProductsGrid(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // INTRO
  // =========================================================

  Widget _buildIntro() {
    late final String eyebrow;
    late final String subtitle;
    late final String heading;

    switch (widget.mode) {
      case AllProductsMode.categories:
        eyebrow = _showCategoryOverview
            ? 'TEMUKAN GAYA KAMU'
            : 'KOLEKSI KATEGORI';

        heading = _showCategoryOverview
            ? 'Jelajahi Kategori'
            : _selectedCategory ?? 'Semua Sepatu';

        subtitle = _showCategoryOverview
            ? 'Pilih kategori yang sesuai dengan aktivitas dan gayamu.'
            : 'Temukan sepatu yang cocok untuk setiap langkah.';

      case AllProductsMode.featured:
        eyebrow = 'CURATED FOR YOU';
        heading = 'Sepatu Pilihan';
        subtitle = 'Jelajahi koleksi sepatu dari katalog SOLEA.';

      case AllProductsMode.popular:
        eyebrow = 'FAVORIT PENGGUNA';
        heading = 'Popular Sekarang';
        subtitle = 'Produk diurutkan berdasarkan rating tertinggi.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: AppColors.forest,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          heading,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 29,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 13,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // CATEGORY GRID
  // =========================================================

  Widget _buildCategoryGrid() {
    final width = MediaQuery.sizeOf(context).width;

    final columns = width >= 1100
        ? 4
        : width >= 700
        ? 3
        : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _categories.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: width < 500 ? 0.82 : 0.95,
      ),
      itemBuilder: (context, index) {
        final category = _categories[index];
        final cover = _categoryCover(category);

        final productCount = ProductController.byCategory(category).length;

        return _CategoryCard(
          category: category,
          imageUrl: cover?.imageUrl,
          productCount: productCount,
          onTap: () => _selectCategory(category),
        );
      },
    );
  }

  // =========================================================
  // CATEGORY FILTERS
  // =========================================================

  Widget _buildCategoryFilters() {
    final categories = <String>['Semua', ..._categories];

    final selected = _selectedCategory ?? 'Semua';

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isActive = category == selected;

          return ChoiceChip(
            selected: isActive,
            onSelected: (_) {
              setState(() {
                _selectedCategory = category == 'Semua' ? null : category;
              });
            },
            label: Text(category),
            selectedColor: AppColors.forest,
            backgroundColor: Colors.white,
            side: BorderSide(
              color: isActive ? AppColors.forest : AppColors.line,
            ),
            labelStyle: TextStyle(
              color: isActive ? Colors.white : AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          );
        },
      ),
    );
  }

  // =========================================================
  // RESULT COUNT + SORT
  // =========================================================

  Widget _buildResultsHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            '${_products.length} produk',
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (widget.mode != AllProductsMode.popular)
          Container(
            padding: const EdgeInsets.only(left: 10, right: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.line),
              borderRadius: BorderRadius.circular(11),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<_ProductSort>(
                value: _sort,
                isDense: true,
                borderRadius: BorderRadius.circular(11),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                items: const [
                  DropdownMenuItem(
                    value: _ProductSort.recommended,
                    child: Text('Rekomendasi'),
                  ),
                  DropdownMenuItem(
                    value: _ProductSort.priceLowToHigh,
                    child: Text('Harga terendah'),
                  ),
                  DropdownMenuItem(
                    value: _ProductSort.priceHighToLow,
                    child: Text('Harga tertinggi'),
                  ),
                  DropdownMenuItem(
                    value: _ProductSort.rating,
                    child: Text('Rating tertinggi'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    _sort = value;
                  });
                },
              ),
            ),
          ),
      ],
    );
  }

  // =========================================================
  // COMPACT PRODUCT GRID
  // =========================================================

  Widget _buildProductsGrid() {
    final products = _products;
    final width = MediaQuery.sizeOf(context).width;

    final columns = width >= 1200
        ? 4
        : width >= 850
        ? 3
        : 2;

    final imageHeight = width < 500
        ? 140.0
        : width < 850
        ? 170.0
        : width < 1200
        ? 190.0
        : 215.0;

    // Tinggi kartu disesuaikan dengan gambar dan teks.
    // Tidak ada Spacer yang mendorong harga ke bawah.
    final cardHeight = imageHeight + 112.0;

    if (products.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 42),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 36, color: AppColors.muted),
            SizedBox(height: 10),
            Text(
              'Belum ada produk di kategori ini.',
              style: TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: cardHeight,
      ),
      itemBuilder: (context, index) {
        final product = products[index];

        return _CompactProductCard(
          product: product,
          imageHeight: imageHeight,
          onTap: () => _openProduct(product),
          onWishlistTap: () => _toggleWishlist(product),
        );
      },
    );
  }
}

// ============================================================
// CATEGORY CARD
// ============================================================

class _CategoryCard extends StatelessWidget {
  final String category;
  final String? imageUrl;
  final int productCount;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.imageUrl,
    required this.productCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl != null)
                    Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const _CategoryImageFallback(),
                    )
                  else
                    const _CategoryImageFallback(),

                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.58),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    left: 12,
                    right: 9,
                    bottom: 12,
                    child: Text(
                      category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),

                  Positioned(
                    top: 9,
                    right: 9,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_outward_rounded,
                        size: 16,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '$productCount produk',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.forest,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryImageFallback extends StatelessWidget {
  const _CategoryImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFECE9E1),
      alignment: Alignment.center,
      child: const Icon(
        Icons.directions_run_rounded,
        size: 44,
        color: AppColors.forest,
      ),
    );
  }
}

// ============================================================
// COMPACT PRODUCT CARD
// ============================================================

class _CompactProductCard extends StatelessWidget {
  final Product product;
  final double imageHeight;
  final VoidCallback onTap;
  final VoidCallback onWishlistTap;

  const _CompactProductCard({
    required this.product,
    required this.imageHeight,
    required this.onTap,
    required this.onWishlistTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // GAMBAR
              SizedBox(
                width: double.infinity,
                height: imageHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: const Color(0xFFECE9E1),
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return const Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                size: 32,
                                color: AppColors.muted,
                              ),
                            );
                          },
                        ),
                      ),

                      Positioned(
                        top: 7,
                        right: 7,
                        child: AnimatedBuilder(
                          animation: WishlistController.instance,
                          builder: (context, _) {
                            final isFavorite = WishlistController.instance
                                .contains(product);

                            return Material(
                              color: Colors.white.withValues(alpha: 0.95),
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: onWishlistTap,
                                child: Padding(
                                  padding: const EdgeInsets.all(7),
                                  child: Icon(
                                    isFavorite
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    size: 17,
                                    color: isFavorite
                                        ? AppColors.danger
                                        : AppColors.ink,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // KATEGORI
              Text(
                product.category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 3),

              // NAMA PRODUK
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 8),

              // HARGA + RATING LANGSUNG DI BAWAH NAMA
              Row(
                children: [
                  Expanded(
                    child: Text(
                      formatRupiah(product.price),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.forestDeep,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFE1A12B),
                    size: 15,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    product.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
