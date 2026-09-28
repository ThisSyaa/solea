import 'package:flutter/material.dart';
import '../../controllers/wishlist_controller.dart';
import '../../core/app_helpers.dart';
import '../../core/app_theme.dart';
import '../home/product_detail_page.dart';
import '../../core/home_button.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand,
      appBar: AppBar(
        backgroundColor: AppColors.sand,
        elevation: 0,
        title: const Text(
          'Wishlist',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: HomeButton(),
          ),
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
              final columns = constraints.maxWidth >= 1000 ? 4 : constraints.maxWidth >= 650 ? 3 : 2;
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: .72,
                ),
                itemCount: products.length,
                itemBuilder: (_, index) {
                  final product = products[index];
                  return Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Container(
                                  color: const Color(0xFFEDEAE2),
                                  child: Image.network(product.imageUrl, fit: BoxFit.cover),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton.filled(
                                    style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(.9)),
                                    onPressed: () => WishlistController.instance.toggle(product),
                                    icon: const Icon(Icons.favorite_rounded, size: 19, color: AppColors.danger),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                                const SizedBox(height: 5),
                                Text(formatRupiah(product.price), style: const TextStyle(fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

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
              width: 76,
              height: 76,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
              child: const Icon(Icons.favorite_border_rounded, size: 34),
            ),
            const SizedBox(height: 16),
            const Text('Wishlist masih kosong', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 7),
            const Text('Simpan sepatu yang kamu suka untuk dibeli nanti.', textAlign: TextAlign.center),
            const SizedBox(height: 22),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Kembali belanja')),
          ],
        ),
      ),
    );
  }
}
