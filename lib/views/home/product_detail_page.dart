import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/wishlist_controller.dart';
import '../../core/app_helpers.dart';
import '../../core/app_network_image.dart';
import '../../core/app_routes.dart';
import '../../core/app_theme.dart';
import '../../models/product.dart';

// ============================================================
// KONSTANTA HALAMAN
// ============================================================

const _kStar = Color(0xFFF5B301);
const _kStarEmpty = Color(0xFFDAD6CC);
const _kImageBg = Color(0xFFEDEAE2);
const _kWideBreakpoint = 900.0;

const _kShippingFlat = 15000;
enum _DetailTab { details, reviews }
enum _ReviewSort { newest, highest, lowest }

// ============================================================
// HALAMAN
// ============================================================

class ProductDetailPage extends StatefulWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int? _selectedSize;
  int _imageIndex = 0;
  bool _showAllThumbs = false;
  _DetailTab _tab = _DetailTab.details;
  _ReviewSort _sort = _ReviewSort.newest;

  final _tabsKey = GlobalKey();

  late final List<String> _gallery = _buildGallery(widget.product);
  late final Stream<List<_Review>> _reviewStream =
      _ReviewRepo.watch(widget.product);

  static List<String> _buildGallery(Product p) {
    final seen = <String>{};
    return [p.imageUrl, ...p.images]
        .where((url) => url.isNotEmpty && seen.add(url))
        .toList();
  }

  void _addToCart() {
    if (_selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih ukuran sepatu dulu.')),
      );
      return;
    }
    CartController.instance.add(widget.product, _selectedSize!, 1);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produk ditambahkan ke keranjang.')),
    );
  }

  void _openReviews() {
    setState(() => _tab = _DetailTab.reviews);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _tabsKey.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _showSizeGuide() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Panduan ukuran'),
        content: const Text(
          'Ukuran memakai standar EU. Ukur panjang kaki dari tumit sampai '
          'ujung jari terpanjang di sore hari, lalu cocokkan dengan ukuran '
          'sepatu. Kalau berada di antara dua ukuran, pilih yang lebih besar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: AppColors.sand,
      appBar: AppBar(
        backgroundColor: AppColors.sand,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const SoleaLogo(iconSize: 30),
        actions: [
          _CartButton(
            onTap: () => Navigator.pushNamed(context, AppRoutes.cart),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<List<_Review>>(
        stream: _reviewStream,
        builder: (context, snapshot) {
          final reviews = _ReviewData(snapshot.data ?? const []);
          final failed = snapshot.hasError;
          final rating = reviews.average ?? product.rating;

          return LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= _kWideBreakpoint;
              final pad = constraints.maxWidth >= 600 ? 24.0 : 16.0;

              final gallery = _Gallery(
                images: _gallery,
                index: math.min(_imageIndex, math.max(0, _gallery.length - 1)),
                heroTag: product.name,
                showAll: _showAllThumbs,
                onSelect: (i) => setState(() => _imageIndex = i),
                onToggleAll: () =>
                    setState(() => _showAllThumbs = !_showAllThumbs),
              );

              final info = _InfoPanel(
                product: product,
                rating: rating,
                reviews: reviews,
                selectedSize: _selectedSize,
                onSizeChanged: (size) => setState(() => _selectedSize = size),
                onSizeGuide: _showSizeGuide,
                onAddToCart: _addToCart,
                onReviewsTap: _openReviews,
              );

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(pad, 8, pad, 48),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Breadcrumb(product: product),
                        const SizedBox(height: 16),
                        if (wide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 11, child: gallery),
                              const SizedBox(width: 56),
                              Expanded(flex: 9, child: info),
                            ],
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              gallery,
                              const SizedBox(height: 24),
                              info,
                            ],
                          ),
                        SizedBox(height: wide ? 56 : 36),
                        _TabsSection(
                          key: _tabsKey,
                          wide: wide,
                          tab: _tab,
                          onTab: (t) => setState(() => _tab = t),
                          product: product,
                          rating: rating,
                          reviews: reviews,
                          failed: failed,
                          sort: _sort,
                          onSort: (s) => setState(() => _sort = s),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ============================================================
// APP BAR & BREADCRUMB
// ============================================================

class _CartButton extends StatelessWidget {
  const _CartButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CartController.instance,
      builder: (context, _) {
        final count = CartController.instance.totalItems;
        return IconButton(
          onPressed: onTap,
          tooltip: 'Keranjang',
          icon: Badge(
            isLabelVisible: count > 0,
            label: Text('$count'),
            child: const Icon(Icons.shopping_bag_outlined),
          ),
        );
      },
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 12, color: AppColors.muted);
    const chevron =
        Icon(Icons.chevron_right_rounded, size: 15, color: AppColors.muted);

    return Row(
      children: [
        const Text('Beranda', style: style),
        chevron,
        Text(product.category, style: style),
        chevron,
        Flexible(
          child: Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style.copyWith(color: AppColors.ink),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// GALERI GAMBAR
// ============================================================

class _Gallery extends StatelessWidget {
  const _Gallery({
    required this.images,
    required this.index,
    required this.heroTag,
    required this.showAll,
    required this.onSelect,
    required this.onToggleAll,
  });

  final List<String> images;
  final int index;
  final String heroTag;
  final bool showAll;
  final ValueChanged<int> onSelect;
  final VoidCallback onToggleAll;

  static const int _slots = 5;
  static const double _gap = 12;
  static const double _ratio = 1.15;

  @override
  Widget build(BuildContext context) {
    const emptyIcon = Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 60,
        color: AppColors.muted,
      ),
    );

    final main = AspectRatio(
      aspectRatio: _ratio,
      child: Hero(
        tag: heroTag,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ColoredBox(
            color: _kImageBg,
            child: images.isEmpty
                ? emptyIcon
                : AppNetworkImage(
                    key: ValueKey(images[index]),
                    imageUrl: images[index],
                    errorBuilder: (_) => emptyIcon,
                  ),
          ),
        ),
      ),
    );

    if (images.length <= 1) return main;

    final collapsed = !showAll && images.length > _slots;
    final visible = collapsed ? _slots - 1 : images.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        main,
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, c) {
            final size = ((c.maxWidth - _gap * (_slots - 1)) / _slots)
                .floorToDouble();
            return Wrap(
              spacing: _gap,
              runSpacing: _gap,
              children: [
                for (var i = 0; i < visible; i++)
                  _Thumb(
                    url: images[i],
                    size: size,
                    selected: i == index,
                    onTap: () => onSelect(i),
                  ),
                if (collapsed)
                  _MoreThumb(
                    size: size,
                    count: images.length - visible,
                    onTap: onToggleAll,
                  ),
              ],
            );
          },
        ),
        if (showAll && images.length > _slots)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: TextButton(
              onPressed: onToggleAll,
              child: const Text('Tampilkan lebih sedikit'),
            ),
          ),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.url,
    required this.size,
    required this.selected,
    required this.onTap,
  });

  final String url;
  final double size;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Lihat gambar produk',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: _kImageBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected ? AppColors.ink : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: AppNetworkImage(imageUrl: url),
          ),
        ),
      ),
    );
  }
}

class _MoreThumb extends StatelessWidget {
  const _MoreThumb({
    required this.size,
    required this.count,
    required this.onTap,
  });

  final double size;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Tampilkan $count gambar lainnya',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.line),
            ),
            child: Text(
              '+$count lagi',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PANEL INFO PRODUK
// ============================================================

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.product,
    required this.rating,
    required this.reviews,
    required this.selectedSize,
    required this.onSizeChanged,
    required this.onSizeGuide,
    required this.onAddToCart,
    required this.onReviewsTap,
  });

  final Product product;
  final double rating;
  final _ReviewData reviews;
  final VoidCallback onReviewsTap;
  final int? selectedSize;
  final ValueChanged<int> onSizeChanged;
  final VoidCallback onSizeGuide;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.forest,
                shape: BoxShape.circle,
              ),
              child: const Text(
                'S',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Solea',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              product.category,
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          product.name,
          style: const TextStyle(
            fontSize: 28,
            height: 1.15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 10),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onReviewsTap,
            child: Row(
              children: [
                _Stars(rating: rating, size: 16),
                const SizedBox(width: 8),
                Text(
                  reviews.total == 0
                      ? 'Belum ada ulasan'
                      : '${reviews.total} ulasan',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          formatRupiah(product.price),
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 28),
        const Row(
          children: [
            Text(
              'Ukuran',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(width: 6),
            Text(
              'EU',
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final size in product.sizes)
              _SizeBox(
                size: size,
                selected: size == selectedSize,
                onTap: () => onSizeChanged(size),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextButton(
          onPressed: onSizeGuide,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            alignment: Alignment.centerLeft,
            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          child: const Text('Panduan ukuran'),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: onAddToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ink,
                  ),
                  icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                  label: const Text('Tambah ke keranjang'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            _WishlistButton(product: product),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const Icon(
              Icons.local_shipping_outlined,
              size: 18,
              color: AppColors.muted,
            ),
            const SizedBox(width: 8),
            Text(
              'Ongkir flat ${formatRupiah(_kShippingFlat)}',
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ],
        ),
      ],
    );
  }
}

class _SizeBox extends StatelessWidget {
  const _SizeBox({
    required this.size,
    required this.selected,
    required this.onTap,
  });

  final int size;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Ukuran $size',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 60,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AppColors.ink : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: selected ? AppColors.ink : AppColors.line,
              ),
            ),
            child: Text(
              '$size',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WishlistButton extends StatelessWidget {
  const _WishlistButton({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: WishlistController.instance,
      builder: (context, _) {
        final liked = WishlistController.instance.contains(product);
        return Tooltip(
          message: liked ? 'Hapus dari favorit' : 'Simpan ke favorit',
          child: Material(
            color: const Color(0xFFE9E7E1),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => WishlistController.instance.toggle(product),
              child: SizedBox(
                width: 52,
                height: 52,
                child: Icon(
                  liked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: liked ? AppColors.danger : AppColors.ink,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// RATING BINTANG (package flutter_rating_bar)
// ============================================================

class _Stars extends StatelessWidget {
  const _Stars({required this.rating, this.size = 16, this.gap = 2});

  final double rating;
  final double size;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Rating ${rating.toStringAsFixed(1)} dari 5',
      child: ExcludeSemantics(
        child: RatingBarIndicator(
          rating: math.min(5.0, math.max(0.0, rating)),
          itemCount: 5,
          itemSize: size,
          itemPadding: EdgeInsets.only(right: gap),
          unratedColor: _kStarEmpty,
          itemBuilder: (context, _) =>
              Icon(Icons.star_rounded, size: size, color: _kStar),
        ),
      ),
    );
  }
}

// ============================================================
// TAB: DETAIL & ULASAN
// ============================================================

class _TabsSection extends StatelessWidget {
  const _TabsSection({
    super.key,
    required this.wide,
    required this.tab,
    required this.onTab,
    required this.product,
    required this.rating,
    required this.reviews,
    required this.failed,
    required this.sort,
    required this.onSort,
  });

  final bool wide;
  final _DetailTab tab;
  final ValueChanged<_DetailTab> onTab;
  final Product product;
  final double rating;
  final _ReviewData reviews;
  final bool failed;
  final _ReviewSort sort;
  final ValueChanged<_ReviewSort> onSort;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.line)),
          ),
          child: Row(
            children: [
              _TabLabel(
                label: 'Detail',
                selected: tab == _DetailTab.details,
                onTap: () => onTab(_DetailTab.details),
              ),
              const SizedBox(width: 28),
              _TabLabel(
                label: reviews.total == 0
                    ? 'Ulasan'
                    : 'Ulasan (${reviews.total})',
                selected: tab == _DetailTab.reviews,
                onTap: () => onTab(_DetailTab.reviews),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        if (tab == _DetailTab.details)
          _DetailsContent(product: product, rating: rating)
        else
          _ReviewsContent(
            wide: wide,
            product: product,
            rating: rating,
            reviews: reviews,
            failed: failed,
            sort: sort,
            onSort: onSort,
          ),
      ],
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.only(top: 6, bottom: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: selected ? AppColors.ink : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppColors.ink : AppColors.muted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailsContent extends StatelessWidget {
  const _DetailsContent({required this.product, required this.rating});

  final Product product;
  final double rating;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 640),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.7,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 24),
          _InfoRow(label: 'Kategori', value: product.category),
          _InfoRow(
            label: 'Ukuran tersedia',
            value: 'EU ${product.sizes.join(', ')}',
          ),
          _InfoRow(
            label: 'Rating',
            value: '${rating.toStringAsFixed(1)} dari 5',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.muted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ULASAN
// ============================================================

class _ReviewsContent extends StatelessWidget {
  const _ReviewsContent({
    required this.wide,
    required this.product,
    required this.rating,
    required this.reviews,
    required this.failed,
    required this.sort,
    required this.onSort,
  });

  final bool wide;
  final Product product;
  final double rating;
  final _ReviewData reviews;
  final bool failed;
  final _ReviewSort sort;
  final ValueChanged<_ReviewSort> onSort;

  @override
  Widget build(BuildContext context) {
    final uid = AuthController.currentUid;
    final mine = reviews.mineFor(uid);

    final form = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: _ReviewForm(product: product, mine: mine),
    );

    final side = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (reviews.total > 0) ...[
          _RatingSummary(rating: rating, reviews: reviews),
          const SizedBox(height: 28),
        ],
        form,
      ],
    );

    final Widget list;
    if (failed) {
      list = const Text(
        'Ulasan belum bisa dimuat. Periksa koneksi internet atau aturan '
        'Firestore untuk koleksi "reviews".',
        style: TextStyle(color: AppColors.danger, height: 1.5),
      );
    } else if (reviews.total == 0) {
      list = const Text(
        'Belum ada ulasan. Jadilah yang pertama memberi rating.',
        style: TextStyle(color: AppColors.muted),
      );
    } else {
      list = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SortDropdown(value: sort, onChanged: onSort),
          const SizedBox(height: 8),
          for (final review in reviews.sorted(sort))
            _ReviewTile(review: review, isMine: review.userId == uid),
        ],
      );
    }

    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 11, child: list),
          const SizedBox(width: 56),
          Expanded(flex: 9, child: side),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        side,
        const SizedBox(height: 28),
        list,
      ],
    );
  }
}

/// Form rating yang bisa ditekan: pilih bintang, tulis komentar, kirim.
class _ReviewForm extends StatefulWidget {
  const _ReviewForm({required this.product, required this.mine});

  final Product product;
  final _Review? mine;

  @override
  State<_ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<_ReviewForm> {
  static const _labels = [
    'Buruk',
    'Kurang bagus',
    'Cukup',
    'Bagus',
    'Sangat bagus',
  ];

  late int _rating = widget.mine?.rating ?? 0;
  late final TextEditingController _text =
      TextEditingController(text: widget.mine?.text ?? '');

  bool _touched = false;
  bool _saving = false;
  String? _error;

  @override
  void didUpdateWidget(covariant _ReviewForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Isi form dengan ulasan lama begitu datanya tiba dari Firestore,
    // selama pengguna belum mengubah apa pun.
    final mine = widget.mine;
    if (!_touched && mine != null && oldWidget.mine?.rating != mine.rating) {
      _rating = mine.rating;
      _text.text = mine.text;
    }
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      setState(() => _error = 'Tekan bintang dulu untuk memberi rating.');
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final isUpdate = widget.mine != null;

    setState(() {
      _saving = true;
      _error = null;
    });
    final error = await _ReviewRepo.save(
      product: widget.product,
      rating: _rating,
      text: _text.text.trim(),
    );
    if (mounted) {
      setState(() {
        _saving = false;
        _error = error;
      });
    }
    if (error == null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(isUpdate ? 'Ulasan diperbarui.' : 'Terima kasih, ulasan terkirim.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUpdate = widget.mine != null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isUpdate ? 'Rating Anda' : 'Beri rating produk ini',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              RatingBar.builder(
                initialRating: _rating.toDouble(),
                minRating: 1,
                itemCount: 5,
                itemSize: 36,
                glow: false,
                allowHalfRating: false,
                unratedColor: _kStarEmpty,
                itemPadding: const EdgeInsets.only(right: 6),
                itemBuilder: (context, _) =>
                    const Icon(Icons.star_rounded, size: 36, color: _kStar),
                onRatingUpdate: (value) => setState(() {
                  _touched = true;
                  _rating = value.round();
                  _error = null;
                }),
              ),
              const SizedBox(width: 6),
              if (_rating > 0)
                Flexible(
                  child: Text(
                    _labels[_rating - 1],
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _text,
            maxLines: 3,
            maxLength: 300,
            textInputAction: TextInputAction.newline,
            onChanged: (_) => _touched = true,
            decoration: const InputDecoration(
              hintText: 'Ceritakan pengalaman Anda (opsional)',
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 6),
            Text(
              _error!,
              style: const TextStyle(fontSize: 12, color: AppColors.danger),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: _saving ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.ink,
                disabledBackgroundColor: AppColors.ink,
              ),
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(isUpdate ? 'Perbarui ulasan' : 'Kirim ulasan'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortDropdown extends StatelessWidget {
  const _SortDropdown({required this.value, required this.onChanged});

  final _ReviewSort value;
  final ValueChanged<_ReviewSort> onChanged;

  static const _labels = {
    _ReviewSort.newest: 'Terbaru',
    _ReviewSort.highest: 'Rating tertinggi',
    _ReviewSort.lowest: 'Rating terendah',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<_ReviewSort>(
          value: value,
          isDense: true,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(10),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.ink,
          ),
          items: [
            for (final entry in _labels.entries)
              DropdownMenuItem(value: entry.key, child: Text(entry.value)),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review, required this.isMine});

  final _Review review;
  final bool isMine;

  static const _avatarColors = [
    Color(0xFFD9E6E0),
    Color(0xFFF3E3C3),
    Color(0xFFE6DCEB),
    Color(0xFFD7E3F0),
    Color(0xFFF0D9D5),
  ];

  String get _ago {
    final d = DateTime.now().difference(review.createdAt).inDays;
    if (d <= 0) return 'Hari ini';
    if (d == 1) return 'Kemarin';
    if (d < 30) return '$d hari lalu';
    if (d < 365) return '${d ~/ 30} bulan lalu';
    return '${d ~/ 365} tahun lalu';
  }

  @override
  Widget build(BuildContext context) {
    final name = review.name.trim().isEmpty ? 'Pengguna' : review.name.trim();
    final color =
        _avatarColors[name.codeUnitAt(0) % _avatarColors.length];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color,
            child: Text(
              name.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    Text(
                      isMine ? '$name (Anda)' : name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _ago,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _Stars(rating: review.rating.toDouble(), size: 14),
                if (review.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    review.text,
                    style: const TextStyle(fontSize: 13, height: 1.5),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingSummary extends StatelessWidget {
  const _RatingSummary({required this.rating, required this.reviews});

  final double rating;
  final _ReviewData reviews;

  @override
  Widget build(BuildContext context) {
    final counts = reviews.counts;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Stars(rating: rating, size: 30, gap: 4),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.line),
          const SizedBox(height: 16),
          for (var star = 5; star >= 1; star--)
            _DistributionRow(
              star: star,
              count: counts[star - 1],
              total: reviews.total,
            ),
        ],
      ),
    );
  }
}

class _DistributionRow extends StatelessWidget {
  const _DistributionRow({
    required this.star,
    required this.count,
    required this.total,
  });

  final int star;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 14,
            child: Text(
              '$star',
              style: const TextStyle(fontSize: 13, color: AppColors.muted),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : count / total,
                minHeight: 8,
                backgroundColor: _kImageBg,
                valueColor: const AlwaysStoppedAnimation<Color>(_kStar),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 28,
            child: Text(
              '$count',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _Review {
  const _Review({
    required this.userId,
    required this.name,
    required this.rating,
    required this.text,
    required this.createdAt,
  });

  final String userId;
  final String name;
  final int rating;
  final String text;
  final DateTime createdAt;

  static _Review? fromMap(Map<String, dynamic> data) {
    final rating = data['rating'];
    if (rating is! num) return null;
    final created = data['createdAt'];
    return _Review(
      userId: data['userId']?.toString() ?? '',
      name: data['userName']?.toString() ?? 'Pengguna',
      rating: math.min(5, math.max(1, rating.round())),
      text: data['text']?.toString() ?? '',
      // Null sebentar saat dokumen baru menunggu timestamp dari server.
      createdAt: created is Timestamp ? created.toDate() : DateTime.now(),
    );
  }
}

class _ReviewData {
  const _ReviewData(this.items);

  final List<_Review> items;

  int get total => items.length;

  /// Indeks 0 = bintang 1, indeks 4 = bintang 5.
  List<int> get counts {
    final result = List<int>.filled(5, 0);
    for (final review in items) {
      result[review.rating - 1]++;
    }
    return result;
  }

  double? get average {
    if (items.isEmpty) return null;
    final sum = items.fold<int>(0, (a, r) => a + r.rating);
    return sum / items.length;
  }

  _Review? mineFor(String? uid) {
    if (uid == null) return null;
    for (final review in items) {
      if (review.userId == uid) return review;
    }
    return null;
  }

  List<_Review> sorted(_ReviewSort sort) {
    final list = [...items];
    int byNewest(_Review a, _Review b) => b.createdAt.compareTo(a.createdAt);
    switch (sort) {
      case _ReviewSort.newest:
        list.sort(byNewest);
      case _ReviewSort.highest:
        list.sort((a, b) {
          final c = b.rating.compareTo(a.rating);
          return c != 0 ? c : byNewest(a, b);
        });
      case _ReviewSort.lowest:
        list.sort((a, b) {
          final c = a.rating.compareTo(b.rating);
          return c != 0 ? c : byNewest(a, b);
        });
    }
    return list;
  }
}

class _ReviewRepo {
  _ReviewRepo._();

  static CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('reviews');

  /// Produk di app ini belum punya id, jadi kuncinya dari nama produk.
  static String keyOf(Product p) =>
      p.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');

  static Stream<List<_Review>> watch(Product p) {
    return _col.where('productId', isEqualTo: keyOf(p)).snapshots().map(
          (snap) => [
            for (final doc in snap.docs)
              if (_Review.fromMap(doc.data()) case final review?) review,
          ],
        );
  }

  /// Mengembalikan null kalau berhasil, atau pesan error.
  static Future<String?> save({
    required Product product,
    required int rating,
    required String text,
  }) async {
    final user = AuthController.firebaseUser;
    if (user == null) return 'Masuk dulu untuk memberi ulasan.';

    final savedName = AuthController.currentName?.trim() ?? '';
    final name = savedName.isNotEmpty
        ? savedName
        : (user.displayName?.trim().isNotEmpty ?? false)
            ? user.displayName!.trim()
            : (user.email?.split('@').first ?? 'Pengguna');

    final productId = keyOf(product);
    try {
      await _col.doc('${productId}_${user.uid}').set({
        'productId': productId,
        'userId': user.uid,
        'userName': name,
        'rating': rating,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return null;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return 'Ulasan belum bisa disimpan. Aturan Firestore belum '
            'mengizinkan koleksi "reviews".';
      }
      return 'Gagal mengirim ulasan. Coba lagi.';
    } catch (_) {
      return 'Gagal mengirim ulasan. Coba lagi.';
    }
  }
}