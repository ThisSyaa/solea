import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/product_controller.dart';
import '../core/app_theme.dart';
import '../models/product.dart';
import 'login_page.dart';
import 'profile_page.dart';

// ============================================================
// BANNER DATA
// ============================================================

class _BannerData {
  final String title;
  final String subtitle;
  final String cta;
  final String imageUrl;

  const _BannerData({
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.imageUrl,
  });
}

const List<_BannerData> _banners = [
  _BannerData(
    title: 'Step Into\nYour Style',
    subtitle:
        'Koleksi sepatu terbaru untuk langkah yang lebih percaya diri.',
    cta: 'Belanja sekarang',
    imageUrl:
        'https://images.unsplash.com/photo-1512374382149-233c42b6a83b?auto=format&fit=crop&w=1600&q=90',
  ),
  _BannerData(
    title: 'Fresh Kicks,\nFresh Start',
    subtitle:
        'Temukan sneakers pilihan dengan harga spesial minggu ini.',
    cta: 'Lihat koleksi',
    imageUrl:
        'https://images.unsplash.com/photo-1551107696-a4b0c5a0d9a2?auto=format&fit=crop&w=1600&q=90',
  ),
  _BannerData(
    title: 'Move\nWithout Limits',
    subtitle:
        'Performa ringan, nyaman dipakai sepanjang hari.',
    cta: 'Jelajahi sepatu',
    imageUrl:
        'https://images.unsplash.com/photo-1460353581641-37baddab0fa2?auto=format&fit=crop&w=1600&q=90',
  ),
];

// ============================================================
// HOME PAGE
// ============================================================

class HomePage extends StatefulWidget {
  final String name;
  final String email;

  const HomePage({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedCategory = 'Semua';

  final Set<String> _wishlist = {};
  final Map<String, int> _cart = {};

  final ScrollController _scrollController = ScrollController();

  // ==========================================================
  // FILTER PRODUCT
  // ==========================================================

  List<Product> get _filteredProducts {
    if (_selectedCategory == 'Semua') {
      return ProductController.products;
    }

    return ProductController.products
        .where(
          (product) =>
              product.category == _selectedCategory,
        )
        .toList();
  }

  List<Product> get _wishlistProducts {
    return ProductController.products
        .where(
          (product) =>
              _wishlist.contains(product.name),
        )
        .toList();
  }

  List<Product> get _cartProducts {
    return ProductController.products
        .where(
          (product) =>
              _cart.containsKey(product.name),
        )
        .toList();
  }

  int get _cartTotalItems {
    return _cart.values.fold(
      0,
      (sum, quantity) => sum + quantity,
    );
  }

  // ==========================================================
  // CATEGORY
  // ==========================================================

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  // ==========================================================
  // WISHLIST
  // ==========================================================

  void _toggleWishlist(Product product) {
    setState(() {
      if (_wishlist.contains(product.name)) {
        _wishlist.remove(product.name);
      } else {
        _wishlist.add(product.name);
      }
    });

    _showSnackBar(
      _wishlist.contains(product.name)
          ? '${product.name} ditambahkan ke wishlist.'
          : '${product.name} dihapus dari wishlist.',
    );
  }

  // ==========================================================
  // CART
  // ==========================================================

  void _addToCart(Product product) {
    setState(() {
      _cart[product.name] =
          (_cart[product.name] ?? 0) + 1;
    });

    _showSnackBar(
      '${product.name} ditambahkan ke keranjang.',
    );
  }

  void _removeFromCart(Product product) {
    setState(() {
      final current = _cart[product.name] ?? 0;

      if (current <= 1) {
        _cart.remove(product.name);
      } else {
        _cart[product.name] = current - 1;
      }
    });
  }

  void _deleteFromCart(Product product) {
    setState(() {
      _cart.remove(product.name);
    });
  }

  // ==========================================================
  // SNACKBAR
  // ==========================================================

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(
            milliseconds: 900,
          ),
        ),
      );
  }

  // ==========================================================
  // WISHLIST MODAL
  // ==========================================================

  void _openWishlist() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              18,
              20,
              25,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.line,
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Wishlist',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 14),
                if (_wishlistProducts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 30,
                    ),
                    child: Center(
                      child: Text(
                        'Wishlist masih kosong.',
                        style: TextStyle(
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount:
                          _wishlistProducts.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder:
                          (context, index) {
                        final product =
                            _wishlistProducts[index];

                        return _WishlistTile(
                          product: product,
                          onRemove: () {
                            _toggleWishlist(
                              product,
                            );
                            Navigator.pop(context);
                          },
                          onAddToCart: () {
                            _addToCart(product);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // CART MODAL - REALTIME + / -
  // ==========================================================

  void _openCart() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            final cartProducts =
                ProductController.products
                    .where(
                      (product) =>
                          _cart.containsKey(
                            product.name,
                          ),
                    )
                    .toList();

            final totalItems =
                _cart.values.fold(
              0,
              (sum, quantity) => sum + quantity,
            );

            return SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  25,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.line,
                          borderRadius:
                              BorderRadius.circular(
                            10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // HEADER
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Keranjang',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight:
                                  FontWeight.w800,
                              color:
                                  AppColors.ink,
                            ),
                          ),
                        ),
                        Text(
                          '$totalItems item',
                          style: const TextStyle(
                            color:
                                AppColors.muted,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // EMPTY
                    if (cartProducts.isEmpty)
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(
                          vertical: 30,
                        ),
                        child: Center(
                          child: Text(
                            'Keranjang masih kosong.',
                            style: TextStyle(
                              color:
                                  AppColors.muted,
                            ),
                          ),
                        ),
                      )

                    // LIST CART
                    else
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount:
                              cartProducts.length,
                          separatorBuilder:
                              (_, __) =>
                                  const SizedBox(
                            height: 10,
                          ),
                          itemBuilder:
                              (context, index) {
                            final product =
                                cartProducts[index];

                            return _CartTile(
                              product: product,
                              quantity:
                                  _cart[
                                          product
                                              .name] ??
                                      1,

                              // TAMBAH
                              onAdd: () {
                                setState(() {
                                  _cart[
                                          product
                                              .name] =
                                      (_cart[
                                                  product
                                                      .name] ??
                                              0) +
                                          1;
                                });

                                // REFRESH MODAL
                                modalSetState(() {});
                              },

                              // KURANG
                              onRemove: () {
                                setState(() {
                                  final current =
                                      _cart[
                                              product
                                                  .name] ??
                                          0;

                                  if (current <= 1) {
                                    _cart.remove(
                                      product.name,
                                    );
                                  } else {
                                    _cart[
                                            product
                                                .name] =
                                        current - 1;
                                  }
                                });

                                // REFRESH MODAL
                                modalSetState(() {});
                              },

                              // HAPUS
                              onDelete: () {
                                setState(() {
                                  _cart.remove(
                                    product.name,
                                  );
                                });

                                // REFRESH MODAL
                                modalSetState(() {});
                              },
                            );
                          },
                        ),
                      ),

                    // CHECKOUT
                    if (cartProducts.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);

                            _showSnackBar(
                              'Checkout belum terhubung ke pembayaran.',
                            );
                          },
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColors.ink,
                            foregroundColor:
                                Colors.white,
                            elevation: 0,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                12,
                              ),
                            ),
                          ),
                          child: const Text(
                            'CHECKOUT',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================================
  // PRODUCT DETAIL
  // ==========================================================

  void _showProductDetail(Product product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              18,
              20,
              28,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.line,
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(18),
                  child: AspectRatio(
                    aspectRatio: 1.25,
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) {
                        return Container(
                          color: AppColors.sand,
                          child: const Icon(
                            Icons
                                .image_not_supported_outlined,
                            size: 50,
                            color:
                                AppColors.muted,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  product.category.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.3,
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      product.price,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w800,
                        color:
                            AppColors.forestDeep,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: Color(0xFFE1A12B),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      product.rating.toString(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w600,
                        color:
                            AppColors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Sepatu nyaman dengan desain modern untuk menemani aktivitas sehari-hari.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.55,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child:
                          OutlinedButton.icon(
                        onPressed: () {
                          _toggleWishlist(
                            product,
                          );
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          _wishlist.contains(
                            product.name,
                          )
                              ? Icons
                                  .favorite_rounded
                              : Icons
                                  .favorite_border_rounded,
                        ),
                        label:
                            const Text('Wishlist'),
                        style: OutlinedButton
                            .styleFrom(
                          foregroundColor:
                              AppColors.ink,
                          minimumSize:
                              const Size
                                  .fromHeight(
                            52,
                          ),
                          side:
                              const BorderSide(
                            color:
                                AppColors.line,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              10,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          _addToCart(product);
                          Navigator.pop(context);
                        },
                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              AppColors.ink,
                          foregroundColor:
                              Colors.white,
                          elevation: 0,
                          minimumSize:
                              const Size
                                  .fromHeight(
                            52,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              10,
                            ),
                          ),
                        ),
                        child: const Text(
                          'TAMBAH KE KERANJANG',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // SCROLL
  // ==========================================================

  void _scrollToProducts() {
    _scrollController.animateTo(
      520,
      duration:
          const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand,
      body: SafeArea(
        child: Column(
          children: [
            _NavBar(
              name: widget.name,
              email: widget.email,
              wishlistCount: _wishlist.length,
              cartCount: _cartTotalItems,
              onWishlistTap: _openWishlist,
              onCartTap: _openCart,
            ),

            Expanded(
              child: LayoutBuilder(
                builder:
                    (context, constraints) {
                  final maxWidth =
                      constraints.maxWidth >
                              1200
                          ? 1180.0
                          : 1000.0;

                  final horizontalPadding =
                      constraints.maxWidth <
                              700
                          ? 16.0
                          : 24.0;

                  return SingleChildScrollView(
                    controller:
                        _scrollController,
                    physics:
                        const BouncingScrollPhysics(),
                    padding:
                        EdgeInsets.fromLTRB(
                      horizontalPadding,
                      20,
                      horizontalPadding,
                      36,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(
                          maxWidth: maxWidth,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            _HeroCarousel(
                              onAction:
                                  _scrollToProducts,
                            ),

                            const SizedBox(
                              height: 28,
                            ),

                            _SectionHeader(
                              title: 'Kategori',
                              action:
                                  'Lihat semua',
                              onAction: () {
                                _selectCategory(
                                  'Semua',
                                );
                                _scrollToProducts();
                              },
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            _CategoryList(
                              selectedCategory:
                                  _selectedCategory,
                              onSelected:
                                  _selectCategory,
                            ),

                            const SizedBox(
                              height: 30,
                            ),

                            _SectionHeader(
                              title: _selectedCategory ==
                                      'Semua'
                                  ? 'Sepatu Pilihan'
                                  : _selectedCategory,
                              action:
                                  'Lihat semua',
                              onAction: () {
                                _selectCategory(
                                  'Semua',
                                );
                              },
                            ),

                            const SizedBox(
                              height: 14,
                            ),

                            ProductList(
                              products:
                                  _filteredProducts,
                              wishlist:
                                  _wishlist,
                              onWishlistTap:
                                  _toggleWishlist,
                              onProductTap:
                                  _showProductDetail,
                            ),

                            const SizedBox(
                              height: 30,
                            ),

                            _SectionHeader(
                              title:
                                  'Popular Sekarang',
                              action:
                                  'Lihat semua',
                              onAction: () {
                                _selectCategory(
                                  'Semua',
                                );
                              },
                            ),

                            const SizedBox(
                              height: 14,
                            ),

                            ProductList(
                              products:
                                  ProductController
                                      .products,
                              wishlist:
                                  _wishlist,
                              onWishlistTap:
                                  _toggleWishlist,
                              onProductTap:
                                  _showProductDetail,
                            ),
                          ],
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
    );
  }
}

// ============================================================
// HERO CAROUSEL
// ============================================================

class _HeroCarousel extends StatefulWidget {
  final VoidCallback onAction;

  const _HeroCarousel({
    required this.onAction,
  });

  @override
  State<_HeroCarousel> createState() =>
      _HeroCarouselState();
}

class _HeroCarouselState
    extends State<_HeroCarousel> {
  late final PageController _pageController;

  Timer? _timer;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _pageController =
        PageController();

    _timer = Timer.periodic(
      const Duration(seconds: 4),
      (_) {
        if (!_pageController.hasClients) {
          return;
        }

        final nextPage =
            (_currentIndex + 1) %
                _banners.length;

        _pageController.animateToPage(
          nextPage,
          duration:
              const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 2.25,
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(22),
            child: PageView.builder(
              controller:
                  _pageController,
              itemCount:
                  _banners.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder:
                  (context, index) {
                return _HeroBanner(
                  data: _banners[index],
                  onAction:
                      widget.onAction,
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children:
              List.generate(
            _banners.length,
            (index) {
              final active =
                  index == _currentIndex;

              return AnimatedContainer(
                duration:
                    const Duration(
                  milliseconds: 250,
                ),
                margin:
                    const EdgeInsets.symmetric(
                  horizontal: 3,
                ),
                width:
                    active ? 22 : 7,
                height: 7,
                decoration:
                    BoxDecoration(
                  color: active
                      ? AppColors.forest
                      : AppColors.line,
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ============================================================
// HERO BANNER
// ============================================================

class _HeroBanner extends StatelessWidget {
  final _BannerData data;
  final VoidCallback onAction;

  const _HeroBanner({
    required this.data,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final width =
        MediaQuery.sizeOf(context).width;

    final isSmall = width < 560;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          data.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(
              color:
                  AppColors.forestDeep,
            );
          },
        ),

        DecoratedBox(
          decoration: BoxDecoration(
            gradient:
                LinearGradient(
              begin:
                  Alignment.centerLeft,
              end:
                  Alignment.centerRight,
              colors: [
                Colors.black
                    .withOpacity(0.72),
                Colors.black
                    .withOpacity(0.30),
                Colors.transparent,
              ],
              stops: const [
                0.0,
                0.58,
                1.0,
              ],
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.all(
            isSmall ? 24 : 38,
          ),
          child: Align(
            alignment:
                Alignment.centerLeft,
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(
                maxWidth:
                    isSmall
                        ? 250
                        : 430,
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    data.title,
                    style:
                        TextStyle(
                      color:
                          Colors.white,
                      fontSize:
                          isSmall
                              ? 26
                              : 42,
                      height: 1.02,
                      fontWeight:
                          FontWeight.w800,
                      letterSpacing:
                          -1,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Text(
                    data.subtitle,
                    maxLines:
                        isSmall
                            ? 2
                            : 3,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        TextStyle(
                      color: Colors
                          .white
                          .withOpacity(
                        0.88,
                      ),
                      fontSize:
                          isSmall
                              ? 12
                              : 14.5,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  ElevatedButton(
                    onPressed:
                        onAction,
                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          Colors.white,
                      foregroundColor:
                          AppColors
                              .ink,
                      elevation: 0,
                      minimumSize:
                          const Size(
                        0,
                        44,
                      ),
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal:
                            20,
                        vertical:
                            12,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),
                    ),
                    child: Text(
                      data.cta,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// SECTION HEADER
// ============================================================

class _SectionHeader
    extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment
              .spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 21,
            fontWeight:
                FontWeight.w800,
            letterSpacing: -0.4,
            color:
                AppColors.ink,
          ),
        ),
        TextButton(
          onPressed: onAction,
          style:
              TextButton.styleFrom(
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 4,
            ),
            foregroundColor:
                AppColors.forest,
          ),
          child:
              Text(action),
        ),
      ],
    );
  }
}

// ============================================================
// CATEGORY LIST
// ============================================================

class _CategoryList
    extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String>
      onSelected;

  const _CategoryList({
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child:
          ListView.builder(
        scrollDirection:
            Axis.horizontal,
        primary: false,
        physics:
            const BouncingScrollPhysics(),
        itemCount:
            ProductController
                .categories.length,
        itemBuilder:
            (context, index) {
          final category =
              ProductController
                  .categories[index];

          final isActive =
              category ==
                  selectedCategory;

          return Padding(
            padding:
                const EdgeInsets.only(
              right: 10,
            ),
            child:
                ChoiceChip(
              selected:
                  isActive,
              onSelected:
                  (_) {
                onSelected(
                    category);
              },
              label:
                  Text(category),
              selectedColor:
                  AppColors.forest,
              backgroundColor:
                  Colors.white,
              side:
                  BorderSide(
                color: isActive
                    ? AppColors
                        .forest
                    : AppColors
                        .line,
              ),
              labelStyle:
                  TextStyle(
                color: isActive
                    ? Colors.white
                    : AppColors
                        .muted,
                fontWeight:
                    FontWeight.w600,
                fontSize: 13,
              ),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius
                        .circular(
                  14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// PRODUCT LIST
// ============================================================

class ProductList
    extends StatelessWidget {
  final List<Product>
      products;

  final Set<String>
      wishlist;

  final ValueChanged<Product>
      onWishlistTap;

  final ValueChanged<Product>
      onProductTap;

  const ProductList({
    super.key,
    required this.products,
    required this.wishlist,
    required this.onWishlistTap,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    final width =
        MediaQuery.sizeOf(context)
            .width;

    final cardWidth =
        width < 500
            ? 168.0
            : width < 800
                ? 205.0
                : 224.0;

    if (products.isEmpty) {
      return Container(
        width: double.infinity,
        padding:
            const EdgeInsets
                .symmetric(
          vertical: 35,
        ),
        child: const Center(
          child: Text(
            'Belum ada produk di kategori ini.',
            style: TextStyle(
              color:
                  AppColors.muted,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: cardWidth + 150,
      child:
          ListView.builder(
        scrollDirection:
            Axis.horizontal,
        primary: false,
        physics:
            const BouncingScrollPhysics(),
        itemCount:
            products.length,
        itemBuilder:
            (context, index) {
          final product =
              products[index];

          return Padding(
            padding:
                EdgeInsets.only(
              right:
                  index ==
                          products.length -
                              1
                      ? 0
                      : 14,
            ),
            child:
                ProductCard(
              product:
                  product,
              width:
                  cardWidth,
              isFavorite:
                  wishlist.contains(
                product.name,
              ),
              onFavoriteTap:
                  () =>
                      onWishlistTap(
                    product,
                  ),
              onTap: () =>
                  onProductTap(
                product,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// PRODUCT CARD
// ============================================================

class ProductCard
    extends StatelessWidget {
  final Product product;
  final double width;
  final bool isFavorite;
  final VoidCallback
      onFavoriteTap;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.width,
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color:
            Colors.white,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        child: InkWell(
          borderRadius:
              BorderRadius.circular(
            18,
          ),
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets
                    .fromLTRB(
              10,
              10,
              10,
              12,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Expanded(
                  child:
                      ClipRRect(
                    borderRadius:
                        BorderRadius
                            .circular(
                      14,
                    ),
                    child: Stack(
                      fit:
                          StackFit.expand,
                      children: [
                        Container(
                          color:
                              AppColors
                                  .sand,
                          child:
                              Image.network(
                            product
                                .imageUrl,
                            fit: BoxFit
                                .cover,
                            errorBuilder:
                                (_, __, ___) {
                              return const Center(
                                child:
                                    Icon(
                                  Icons
                                      .image_not_supported_outlined,
                                  color:
                                      AppColors.muted,
                                  size:
                                      34,
                                ),
                              );
                            },
                          ),
                        ),

                        Positioned(
                          top: 8,
                          right: 8,
                          child:
                              Material(
                            color: Colors
                                .white
                                .withOpacity(
                              0.94,
                            ),
                            shape:
                                const CircleBorder(),
                            child:
                                InkWell(
                              customBorder:
                                  const CircleBorder(),
                              onTap:
                                  onFavoriteTap,
                              child:
                                  Padding(
                                padding:
                                    const EdgeInsets.all(
                                  7,
                                ),
                                child:
                                    Icon(
                                  isFavorite
                                      ? Icons
                                          .favorite_rounded
                                      : Icons
                                          .favorite_border_rounded,
                                  size:
                                      17,
                                  color: isFavorite
                                      ? AppColors
                                          .danger
                                      : AppColors
                                          .ink,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(
                  height: 11,
                ),

                Text(
                  product
                      .category,
                  style:
                      const TextStyle(
                    fontSize:
                        11.5,
                    color:
                        AppColors
                            .muted,
                    fontWeight:
                        FontWeight
                            .w600,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  product.name,
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      const TextStyle(
                    fontSize:
                        14,
                    color:
                        AppColors
                            .ink,
                    fontWeight:
                        FontWeight
                            .w700,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                Row(
                  children: [
                    Expanded(
                      child:
                          Text(
                        product.price,
                        maxLines:
                            1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          fontSize:
                              13.5,
                          color:
                              AppColors
                                  .forestDeep,
                          fontWeight:
                              FontWeight
                                  .w800,
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 6,
                    ),

                    const Icon(
                      Icons
                          .star_rounded,
                      size:
                          15,
                      color:
                          Color(
                        0xFFE1A12B,
                      ),
                    ),

                    const SizedBox(
                      width: 2,
                    ),

                    Text(
                      product
                          .rating
                          .toString(),
                      style:
                          const TextStyle(
                        fontSize:
                            11.5,
                        color:
                            AppColors
                                .muted,
                        fontWeight:
                            FontWeight
                                .w600,
                      ),
                    ),
                  ],
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
// WISHLIST TILE
// ============================================================

class _WishlistTile
    extends StatelessWidget {
  final Product product;
  final VoidCallback onRemove;
  final VoidCallback
      onAddToCart;

  const _WishlistTile({
    required this.product,
    required this.onRemove,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(
        10,
      ),
      decoration:
          BoxDecoration(
        color:
            AppColors.sand,
        borderRadius:
            BorderRadius.circular(
          14,
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                BorderRadius.circular(
              10,
            ),
            child:
                Image.network(
              product.imageUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) {
                return Container(
                  width: 64,
                  height: 64,
                  color:
                      AppColors.line,
                );
              },
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight
                            .w700,
                    color:
                        AppColors
                            .ink,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  product.price,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight
                            .w800,
                    color:
                        AppColors
                            .forestDeep,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed:
                onAddToCart,
            icon:
                const Icon(
              Icons
                  .shopping_bag_outlined,
            ),
            color:
                AppColors.ink,
          ),

          IconButton(
            onPressed:
                onRemove,
            icon:
                const Icon(
              Icons
                  .favorite_rounded,
            ),
            color:
                AppColors
                    .danger,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CART TILE
// ============================================================

class _CartTile
    extends StatelessWidget {
  final Product product;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback
      onRemove;
  final VoidCallback
      onDelete;

  const _CartTile({
    required this.product,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(
        10,
      ),
      decoration:
          BoxDecoration(
        color:
            AppColors.sand,
        borderRadius:
            BorderRadius.circular(
          14,
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                BorderRadius.circular(
              10,
            ),
            child:
                Image.network(
              product.imageUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) {
                return Container(
                  width: 64,
                  height: 64,
                  color:
                      AppColors.line,
                );
              },
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight
                            .w700,
                    color:
                        AppColors
                            .ink,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  product.price,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight
                            .w800,
                    color:
                        AppColors
                            .forestDeep,
                  ),
                ),

                const SizedBox(
                  height: 7,
                ),

                Row(
                  children: [
                    _QtyButton(
                      icon: Icons
                          .remove_rounded,
                      onTap:
                          onRemove,
                    ),

                    Padding(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal:
                            10,
                      ),
                      child:
                          Text(
                        quantity
                            .toString(),
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight
                                  .w800,
                          color:
                              AppColors
                                  .ink,
                        ),
                      ),
                    ),

                    _QtyButton(
                      icon: Icons
                          .add_rounded,
                      onTap:
                          onAdd,
                    ),
                  ],
                ),
              ],
            ),
          ),

          IconButton(
            onPressed:
                onDelete,
            icon:
                const Icon(
              Icons
                  .delete_outline_rounded,
              color:
                  AppColors
                      .danger,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// QTY BUTTON
// ============================================================

class _QtyButton
    extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
          Colors.white,
      borderRadius:
          BorderRadius.circular(
        8,
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(
          8,
        ),
        onTap: onTap,
        child: SizedBox(
          width: 28,
          height: 28,
          child: Center(
            child: Icon(
              icon,
              size: 16,
              color:
                  AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// NAVBAR
// ============================================================

class _NavBar
    extends StatelessWidget {
  final String name;
  final String email;
  final int wishlistCount;
  final int cartCount;
  final VoidCallback
      onWishlistTap;
  final VoidCallback onCartTap;

  const _NavBar({
    required this.name,
    required this.email,
    required this.wishlistCount,
    required this.cartCount,
    required this.onWishlistTap,
    required this.onCartTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      decoration:
          const BoxDecoration(
        color:
            Colors.white,
        border:
            Border(
          bottom:
              BorderSide(
            color:
                AppColors.line,
          ),
        ),
      ),
      child: Row(
        children: [
          Row(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                alignment:
                    Alignment.center,
                decoration:
                    BoxDecoration(
                  color:
                      Colors.black,
                  borderRadius:
                      BorderRadius
                          .circular(
                    9,
                  ),
                ),
                child:
                    const Icon(
                  Icons
                      .directions_run_rounded,
                  size: 18,
                  color:
                      Colors.white,
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              const Text(
                'SOLEA',
                style:
                    TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight
                          .w800,
                  letterSpacing:
                      1.4,
                  color:
                      AppColors
                          .ink,
                ),
              ),
            ],
          ),

          Expanded(
            child:
                LayoutBuilder(
              builder:
                  (context,
                      constraints) {
                final isWide =
                    constraints
                            .maxWidth >
                        420;

                return Align(
                  alignment:
                      Alignment.center,
                  child: isWide
                      ? Row(
                          mainAxisSize:
                              MainAxisSize
                                  .min,
                          children: [
                            _NavLink(
                              label:
                                  'Home',
                              active:
                                  true,
                              onTap:
                                  () {},
                            ),
                            _NavLink(
                              label:
                                  'Contact',
                              onTap:
                                  () =>
                                      _showComingSoon(
                                context,
                                'Contact',
                              ),
                            ),
                            _NavLink(
                              label:
                                  'Layanan',
                              onTap:
                                  () =>
                                      _showComingSoon(
                                context,
                                'Layanan',
                              ),
                            ),
                            _NavLink(
                              label:
                                  'Tentang',
                              onTap:
                                  () =>
                                      _showComingSoon(
                                context,
                                'Tentang',
                              ),
                            ),
                          ],
                        )
                      : PopupMenuButton<
                          String>(
                          icon:
                              const Icon(
                            Icons.menu,
                            color:
                                AppColors
                                    .ink,
                          ),
                          onSelected:
                              (label) {
                            if (label !=
                                'Home') {
                              _showComingSoon(
                                context,
                                label,
                              );
                            }
                          },
                          itemBuilder:
                              (context) =>
                                  const [
                            PopupMenuItem(
                              value:
                                  'Home',
                              child:
                                  Text(
                                'Home',
                              ),
                            ),
                            PopupMenuItem(
                              value:
                                  'Contact',
                              child:
                                  Text(
                                'Contact',
                              ),
                            ),
                            PopupMenuItem(
                              value:
                                  'Layanan',
                              child:
                                  Text(
                                'Layanan',
                              ),
                            ),
                            PopupMenuItem(
                              value:
                                  'Tentang',
                              child:
                                  Text(
                                'Tentang',
                              ),
                            ),
                          ],
                        ),
                );
              },
            ),
          ),

          _CounterIcon(
            icon:
                Icons.favorite_border_rounded,
            count:
                wishlistCount,
            onTap:
                onWishlistTap,
          ),

          _CounterIcon(
            icon:
                Icons.shopping_bag_outlined,
            count:
                cartCount,
            onTap:
                onCartTap,
          ),

          const SizedBox(
            width: 4,
          ),

          _ProfileMenu(
            name:
                name,
            email:
                email,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// NAV LINK
// ============================================================

class _NavLink
    extends StatelessWidget {
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
      padding:
          const EdgeInsets.symmetric(
        horizontal: 6,
      ),
      child:
          TextButton(
        onPressed:
            onTap,
        style:
            TextButton.styleFrom(
          foregroundColor:
              active
                  ? AppColors
                      .forest
                  : AppColors
                      .muted,
          textStyle:
              TextStyle(
            fontSize: 14,
            fontWeight:
                active
                    ? FontWeight
                        .w700
                    : FontWeight
                        .w500,
          ),
        ),
        child:
            Text(label),
      ),
    );
  }
}

// ============================================================
// COUNTER ICON
// ============================================================

class _CounterIcon
    extends StatelessWidget {
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
      clipBehavior:
          Clip.none,
      children: [
        IconButton(
          onPressed:
              onTap,
          icon:
              Icon(
            icon,
            color:
                AppColors.ink,
          ),
        ),

        if (count > 0)
          Positioned(
            top: 4,
            right: 2,
            child:
                Container(
              constraints:
                  const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 4,
              ),
              decoration:
                  const BoxDecoration(
                color:
                    AppColors
                        .danger,
                shape:
                    BoxShape.circle,
              ),
              child:
                  Center(
                child:
                    Text(
                  count > 99
                      ? '99+'
                      : count
                          .toString(),
                  style:
                      const TextStyle(
                    fontSize: 8,
                    fontWeight:
                        FontWeight
                            .w800,
                    color:
                        Colors.white,
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

class _ProfileMenu
    extends StatelessWidget {
  final String name;
  final String email;

  const _ProfileMenu({
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<
        String>(
      tooltip: 'Akun',
      offset:
          const Offset(0, 46),
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          12,
        ),
      ),
      onSelected:
          (value) {
        if (value ==
            'logout') {
          Navigator.of(context)
              .pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) =>
                  const LoginPage(),
            ),
            (route) => false,
          );
        }

        if (value ==
            'profile') {
          Navigator.of(context)
              .push(
            MaterialPageRoute(
              builder: (_) =>
                  ProfilePage(
                name:
                    name,
                email:
                    email,
              ),
            ),
          );
        }
      },
      itemBuilder:
          (context) => [
        PopupMenuItem<
            String>(
          enabled:
              false,
          child:
              Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            mainAxisSize:
                MainAxisSize
                    .min,
            children: [
              Text(
                name,
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight
                          .w700,
                  fontSize:
                      14,
                  color:
                      AppColors
                          .ink,
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                email,
                style:
                    const TextStyle(
                  fontSize:
                      12,
                  color:
                      AppColors
                          .muted,
                ),
              ),
            ],
          ),
        ),

        const PopupMenuDivider(),

        const PopupMenuItem<
            String>(
          value:
              'profile',
          child:
              Row(
            children: [
              Icon(
                Icons
                    .person_outline_rounded,
                size:
                    18,
                color:
                    AppColors
                        .muted,
              ),
              SizedBox(
                width:
                    10,
              ),
              Text(
                'Profil',
              ),
            ],
          ),
        ),

        const PopupMenuItem<
            String>(
          value:
              'logout',
          child:
              Row(
            children: [
              Icon(
                Icons
                    .logout_rounded,
                size:
                    18,
                color:
                    AppColors
                        .danger,
              ),
              SizedBox(
                width:
                    10,
              ),
              Text(
                'Logout',
                style:
                    TextStyle(
                  color:
                      AppColors
                          .danger,
                ),
              ),
            ],
          ),
        ),
      ],
      child:
          const Padding(
        padding:
            EdgeInsets.symmetric(
          horizontal:
              4,
        ),
        child:
            Row(
          mainAxisSize:
              MainAxisSize
                  .min,
          children: [
            CircleAvatar(
              radius:
                  17,
              backgroundColor:
                  Color(
                0xFFE8F0EC,
              ),
              child:
                  Icon(
                Icons
                    .person_rounded,
                size:
                    19,
                color:
                    AppColors
                        .forest,
              ),
            ),
            SizedBox(
              width:
                  4,
            ),
            Icon(
              Icons
                  .keyboard_arrow_down_rounded,
              size:
                  18,
              color:
                  AppColors
                      .muted,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// COMING SOON
// ============================================================

void _showComingSoon(
  BuildContext context,
  String label,
) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          'Halaman "$label" belum tersedia.',
        ),
        behavior:
            SnackBarBehavior
                .floating,
      ),
    );
}