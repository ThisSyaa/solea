import 'dart:async';

import '../models/product.dart';
import 'package:flutter/material.dart';

import '../controllers/product_controller.dart';
import '../core/app_theme.dart';
import 'login_page.dart';
import 'profile_page.dart';

// ============================================================
// GENERAL HELPER
// ============================================================

void _showComingSoon(BuildContext context, String label) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('Halaman "$label" belum tersedia.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
}

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
    subtitle: 'Koleksi sepatu terbaru untuk langkah yang lebih percaya diri.',
    cta: 'Belanja sekarang',
    imageUrl: 'https://images.unsplash.com/photo-1512374382149-233c42b6a83b?auto=format&fit=crop&w=1600&q=90',
  ),
  _BannerData(
    title: 'Fresh Kicks,\nFresh Start',
    subtitle: 'Temukan sneakers pilihan dengan harga spesial minggu ini.',
    cta: 'Lihat koleksi',
    imageUrl: 'https://images.unsplash.com/photo-1551107696-a4b0c5a0d9a2?auto=format&fit=crop&w=1600&q=90',
  ),
  _BannerData(
    title: 'Move\nWithout Limits',
    subtitle: 'Performa ringan, nyaman dipakai sepanjang hari.',
    cta: 'Jelajahi sepatu',
    imageUrl: 'https://images.unsplash.com/photo-1460353581641-37baddab0fa2?auto=format&fit=crop&w=1600&q=90',
  ),
];

// ============================================================
// HOME PAGE
// ============================================================

class HomePage extends StatelessWidget {
  final String name;
  final String email;

  const HomePage({super.key, required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand,
      body: SafeArea(
        child: Column(
          children: [
            _NavBar(name: name, email: email),

            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final contentMaxWidth = constraints.maxWidth > 1200
                      ? 1180.0
                      : 1000.0;

                  final horizontalPadding = constraints.maxWidth < 700
                      ? 16.0
                      : 24.0;

                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      20,
                      horizontalPadding,
                      36,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: contentMaxWidth),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _HeroCarousel(),

                            SizedBox(height: 28),

                            _SectionHeader(
                              title: 'Kategori',
                              action: 'Lihat semua',
                            ),

                            SizedBox(height: 12),

                            _CategoryList(),

                            SizedBox(height: 30),

                            _SectionHeader(
                              title: 'Sepatu Pilihan',
                              action: 'Lihat semua',
                            ),

                            SizedBox(height: 14),

                            ProductList(title: 'Sepatu Pilihan'),

                            SizedBox(height: 30),

                            _SectionHeader(
                              title: 'Popular Sekarang',
                              action: 'Lihat semua',
                            ),

                            SizedBox(height: 14),

                            ProductList(title: 'Popular Sekarang'),
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
  const _HeroCarousel();

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  late final PageController _pageController;
  Timer? _timer;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_pageController.hasClients) return;

      final nextPage = (_currentIndex + 1) % _banners.length;

      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    if (!mounted) return;

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 2.25,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _banners.length,
              itemBuilder: (context, index) {
                return _HeroBanner(data: _banners[index]);
              },
            ),
          ),
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (index) {
            final active = index == _currentIndex;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 22 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: active ? AppColors.forest : AppColors.line,
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }),
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

  const _HeroBanner({required this.data});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final isSmall = width < 560;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          data.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(color: AppColors.forestDeep);
          },
        ),

        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.black.withOpacity(0.72),
                Colors.black.withOpacity(0.30),
                Colors.transparent,
              ],
              stops: const [0.0, 0.58, 1.0],
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.all(isSmall ? 24 : 38),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isSmall ? 250 : 430),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmall ? 26 : 42,
                      height: 1.02,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    data.subtitle,
                    maxLines: isSmall ? 2 : 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.88),
                      fontSize: isSmall ? 12 : 14.5,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 18),

                  ElevatedButton(
                    onPressed: () {
                      _showComingSoon(context, data.cta);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.ink,
                      elevation: 0,
                      minimumSize: const Size(0, 44),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(data.cta),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final String action;

  const _SectionHeader({required this.title, required this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: AppColors.ink,
          ),
        ),

        TextButton(
          onPressed: () {
            _showComingSoon(context, title);
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            foregroundColor: AppColors.forest,
          ),
          child: Text(action),
        ),
      ],
    );
  }
}

// ============================================================
// CATEGORY LIST - REAL INTERACTION
// ============================================================

class _CategoryList extends StatefulWidget {
  const _CategoryList();

  @override
  State<_CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<_CategoryList> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: ProductController.categories.length,
        itemBuilder: (context, index) {
          final isActive = index == _selectedIndex;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              selected: isActive,

              onSelected: (_) {
                setState(() {
                  _selectedIndex = index;
                });

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        'Kategori "${ProductController.categories[index]}" dipilih.',
                      ),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(milliseconds: 900),
                    ),
                  );
              },

              label: Text(ProductController.categories[index]),

              selectedColor: AppColors.forest,

              backgroundColor: Colors.white,

              side: BorderSide(
                color: isActive ? AppColors.forest : AppColors.line,
              ),

              labelStyle: TextStyle(
                color: isActive ? Colors.white : AppColors.muted,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProductList extends StatelessWidget {
  final String title;

  const ProductList({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final cardWidth = width < 500
        ? 168.0
        : width < 800
        ? 205.0
        : 224.0;

    return SizedBox(
      height: cardWidth + 150,

      child: ListView.builder(
        scrollDirection: Axis.horizontal,

        itemCount: ProductController.products.length,

        itemBuilder: (context, index) {
          final product = ProductController.products[index];

          return Padding(
            padding: EdgeInsets.only(
              right: index == ProductController.products.length - 1 ? 0 : 14,
            ),

            child: ProductCard(product: product, width: cardWidth),
          );
        },
      ),
    );
  }
}

// ============================================================
// PRODUCT CARD - CLICKABLE
// ============================================================

class ProductCard extends StatefulWidget {
  final Product product;
  final double width;

  const ProductCard({required this.product, required this.width});

  @override
  State<ProductCard> createState() => ProductCardState();
}

class ProductCardState extends State<ProductCard> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return SizedBox(
      width: widget.width,

      child: Material(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        child: InkWell(
          borderRadius: BorderRadius.circular(18),

          onTap: () {
            _showProductDetail(context, product);
          },

          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // ==================================================
                // PRODUCT IMAGE
                // ==================================================

                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),

                    child: Stack(
                      fit: StackFit.expand,

                      children: [
                        Container(
                          color: AppColors.sand,

                          child: Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,

                            errorBuilder: (_, __, ___) {
                              return const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: AppColors.muted,
                                  size: 34,
                                ),
                              );
                            },
                          ),
                        ),

                        // ==================================================
                        // FAVORITE BUTTON
                        // ==================================================
                        Positioned(
                          top: 8,
                          right: 8,

                          child: Material(
                            color: Colors.white.withOpacity(0.94),
                            shape: const CircleBorder(),

                            child: InkWell(
                              customBorder: const CircleBorder(),

                              onTap: () {
                                setState(() {
                                  _isFavorite = !_isFavorite;
                                });

                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        _isFavorite
                                            ? '${product.name} ditambahkan ke wishlist.'
                                            : '${product.name} dihapus dari wishlist.',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(
                                        milliseconds: 900,
                                      ),
                                    ),
                                  );
                              },

                              child: Padding(
                                padding: const EdgeInsets.all(7),

                                child: Icon(
                                  _isFavorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,

                                  size: 17,

                                  color: _isFavorite
                                      ? AppColors.danger
                                      : AppColors.ink,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 11),

                // ==================================================
                // CATEGORY
                // ==================================================
                Text(
                  product.category,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                // ==================================================
                // PRODUCT NAME
                // ==================================================
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

                const SizedBox(height: 6),

                // ==================================================
                // PRICE + RATING
                // ==================================================
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.price,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PRODUCT DETAIL
// ============================================================

void _showProductDetail(BuildContext context, Product product) {
  showModalBottomSheet(
    context: context,

    backgroundColor: Colors.white,

    isScrollControlled: true,

    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),

    builder: (context) {
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // HANDLE

              Center(
                child: Container(
                  width: 42,
                  height: 4,

                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(18),

                child: AspectRatio(
                  aspectRatio: 1.25,

                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,

                    errorBuilder: (_, __, ___) {
                      return Container(
                        color: AppColors.sand,

                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          size: 50,
                          color: AppColors.muted,
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // CATEGORY
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

              // NAME
              Text(
                product.name,

                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),

              const SizedBox(height: 8),

              // PRICE + RATING
              Row(
                children: [
                  Text(
                    product.price,

                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.forestDeep,
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
                      fontWeight: FontWeight.w600,
                      color: AppColors.muted,
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

              const SizedBox(height: 22),

              // ADD TO CART
              SizedBox(
                width: double.infinity,

                height: 52,

                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();

                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(
                            '${product.name} ditambahkan ke keranjang.',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ink,
                    foregroundColor: Colors.white,
                    elevation: 0,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  child: const Text(
                    'TAMBAH KE KERANJANG',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// ============================================================
// NAVBAR
// ============================================================

class _NavBar extends StatelessWidget {
  final String name;
  final String email;

  const _NavBar({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,

      padding: const EdgeInsets.symmetric(horizontal: 20),

      decoration: const BoxDecoration(
        color: Colors.white,

        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),

      child: Row(
        children: [
          // ==================================================
          // BRAND
          // ==================================================

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,

                alignment: Alignment.center,

                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(9),
                ),

                child: const Icon(
                  Icons.directions_run_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 10),

              const Text(
                'SOLEA',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),

          // ==================================================
          // NAVIGATION
          // ==================================================
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 320;

                return Align(
                  alignment: Alignment.center,

                  child: isWide
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _NavLink(label: 'Home', active: true, onTap: () {}),

                            _NavLink(
                              label: 'Contact',
                              onTap: () => _showComingSoon(context, 'Contact'),
                            ),

                            _NavLink(
                              label: 'Layanan',
                              onTap: () => _showComingSoon(context, 'Layanan'),
                            ),

                            _NavLink(
                              label: 'Tentang',
                              onTap: () => _showComingSoon(context, 'Tentang'),
                            ),
                          ],
                        )
                      : PopupMenuButton<String>(
                          icon: const Icon(Icons.menu, color: AppColors.ink),

                          onSelected: (label) {
                            if (label != 'Home') {
                              _showComingSoon(context, label);
                            }
                          },

                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 'Home', child: Text('Home')),
                            PopupMenuItem(
                              value: 'Contact',
                              child: Text('Contact'),
                            ),
                            PopupMenuItem(
                              value: 'Layanan',
                              child: Text('Layanan'),
                            ),
                            PopupMenuItem(
                              value: 'Tentang',
                              child: Text('Tentang'),
                            ),
                          ],
                        ),
                );
              },
            ),
          ),

          // ==================================================
          // PROFILE
          // ==================================================
          _ProfileMenu(name: name, email: email),
        ],
      ),
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

      onSelected: (value) {
        if (value == 'logout') {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        }

        if (value == 'profile') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProfilePage(name: name, email: email),
            ),
          );
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
              Text('Profil'),
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
