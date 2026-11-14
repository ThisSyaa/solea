import '../../core/app_network_image.dart';
import 'package:flutter/material.dart';

import '../../controllers/wishlist_controller.dart';
import '../../core/app_helpers.dart';
import '../../core/app_routes.dart';
import '../../core/app_theme.dart';
import '../../core/product_search.dart';
import '../../models/product.dart';
import 'nav_search_field.dart';

enum _ResultSort { related, priceLowToHigh, priceHighToLow, rating }

/// Halaman hasil pencarian: daftar produk (grid) + pilihan urutan.
class SearchResultsPage extends StatefulWidget {
  final String query;

  const SearchResultsPage({super.key, required this.query});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  _ResultSort _sort = _ResultSort.related;

  List<Product> get _results {
    final list = ProductSearch.search(widget.query);

    switch (_sort) {
      case _ResultSort.related:
        return list;
      case _ResultSort.priceLowToHigh:
        return [...list]..sort((a, b) => a.price.compareTo(b.price));
      case _ResultSort.priceHighToLow:
        return [...list]..sort((a, b) => b.price.compareTo(a.price));
      case _ResultSort.rating:
        return [...list]..sort((a, b) => b.rating.compareTo(a.rating));
    }
  }

  void _searchAgain(String query) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => SearchResultsPage(query: query),
      ),
    );
  }

  void _toggleWishlist(Product product) {
    final controller = WishlistController.instance;
    final wasFavorite = controller.contains(product);

    controller.toggle(product);

    if (!mounted) return;
    setState(() {});

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

  Future<void> _openProduct(Product product) async {
    await Navigator.of(context).pushNamed<void>(AppRoutes.product(product));

    if (mounted) setState(() {});
  }

  String _sortLabel(_ResultSort sort) {
    switch (sort) {
      case _ResultSort.related:
        return 'Terkait';
      case _ResultSort.priceLowToHigh:
        return 'Harga terendah';
      case _ResultSort.priceHighToLow:
        return 'Harga tertinggi';
      case _ResultSort.rating:
        return 'Rating';
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    final wishlist = WishlistController.instance;

    return Scaffold(
      backgroundColor: AppColors.sand,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER: tombol kembali + kolom search
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppColors.line)),
              ),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Kembali',
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 620),
                        child: NavSearchField(
                          initialText: widget.query,
                          autofocus: false,
                          onSubmit: _searchAgain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth > 1200 ? 1180.0 : 1000.0;
                  final basePadding = constraints.maxWidth < 700 ? 16.0 : 24.0;
                  final sidePadding = (constraints.maxWidth - maxWidth) / 2 >
                          basePadding
                      ? (constraints.maxWidth - maxWidth) / 2
                      : basePadding;

                  return CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          sidePadding,
                          22,
                          sidePadding,
                          16,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  text: 'Hasil pencarian untuk ',
                                  children: [
                                    TextSpan(
                                      text: "'${widget.query}'",
                                      style: const TextStyle(
                                        color: AppColors.forest,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: AppColors.ink,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${results.length} produk ditemukan',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.muted,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 10,
                                runSpacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text(
                                    'Urutkan',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                  for (final sort in _ResultSort.values)
                                    ChoiceChip(
                                      selected: _sort == sort,
                                      onSelected: (_) {
                                        setState(() => _sort = sort);
                                      },
                                      label: Text(_sortLabel(sort)),
                                      selectedColor: AppColors.forest,
                                      backgroundColor: Colors.white,
                                      side: BorderSide(
                                        color: _sort == sort
                                            ? AppColors.forest
                                            : AppColors.line,
                                      ),
                                      labelStyle: TextStyle(
                                        color: _sort == sort
                                            ? Colors.white
                                            : AppColors.muted,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          14,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (results.isEmpty)
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: sidePadding,
                            vertical: 40,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.search_off_rounded,
                                  size: 54,
                                  color: AppColors.muted,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Tidak ada hasil untuk '${widget.query}'.",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Coba kata kunci lain, misalnya nama kategori '
                                  'seperti Running atau Casual.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppColors.muted),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            sidePadding,
                            0,
                            sidePadding,
                            36,
                          ),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 230,
                                  childAspectRatio: 0.64,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                ),
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final product = results[index];

                              return _ResultCard(
                                product: product,
                                isFavorite: wishlist.contains(product),
                                onFavoriteTap: () => _toggleWishlist(product),
                                onTap: () => _openProduct(product),
                              );
                            }, childCount: results.length),
                          ),
                        ),
                    ],
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
// KARTU PRODUK HASIL PENCARIAN
// ============================================================

class _ResultCard extends StatelessWidget {
  final Product product;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onTap;

  const _ResultCard({
    required this.product,
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        child: Material(
                          color: Colors.white.withValues(alpha: 0.94),
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: onFavoriteTap,
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
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 11),
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
              const SizedBox(height: 6),
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
            ],
          ),
        ),
      ),
    );
  }
}
