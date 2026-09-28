import 'package:flutter/material.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/wishlist_controller.dart';
import '../../core/app_helpers.dart';
import '../../core/app_theme.dart';
import '../../models/product.dart';
import '../shopping/cart_page.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int? _selectedSize;
  int _quantity = 1;

  void _addToCart() {
    if (_selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih ukuran sepatu dulu.')),
      );
      return;
    }
    CartController.instance.add(widget.product, _selectedSize!, _quantity);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produk ditambahkan ke keranjang.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      backgroundColor: AppColors.sand,
      appBar: AppBar(
        backgroundColor: AppColors.sand,
        elevation: 0,
        title: const SoleaLogo(iconSize: 30),
        actions: [
          AnimatedBuilder(
            animation: WishlistController.instance,
            builder: (_, __) => IconButton(
              onPressed: () => WishlistController.instance.toggle(product),
              icon: Icon(
                WishlistController.instance.contains(product)
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: WishlistController.instance.contains(product) ? AppColors.danger : AppColors.ink,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage())),
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 800;
          final image = Hero(
            tag: product.name,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Container(
                color: const Color(0xFFEDEAE2),
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_outlined, size: 70),
                ),
              ),
            ),
          );

          final info = _ProductInfo(
            product: product,
            selectedSize: _selectedSize,
            quantity: _quantity,
            onSizeChanged: (size) => setState(() => _selectedSize = size),
            onQuantityChanged: (quantity) => setState(() => _quantity = quantity),
            onAddToCart: _addToCart,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: AspectRatio(aspectRatio: 1, child: image)),
                          const SizedBox(width: 42),
                          Expanded(child: info),
                        ],
                      )
                    : Column(
                        children: [
                          AspectRatio(aspectRatio: 1, child: image),
                          const SizedBox(height: 24),
                          info,
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProductInfo extends StatelessWidget {
  final Product product;
  final int? selectedSize;
  final int quantity;
  final ValueChanged<int> onSizeChanged;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onAddToCart;

  const _ProductInfo({
    required this.product,
    required this.selectedSize,
    required this.quantity,
    required this.onSizeChanged,
    required this.onQuantityChanged,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(product.category.toUpperCase(), style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        Text(product.name, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -.8)),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.star_rounded, size: 18),
            const SizedBox(width: 5),
            Text(product.rating.toStringAsFixed(1)),
          ],
        ),
        const SizedBox(height: 16),
        Text(formatRupiah(product.price), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 18),
        Text(product.description, style: const TextStyle(color: AppColors.muted, height: 1.6)),
        const SizedBox(height: 24),
        const Text('Pilih ukuran', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: product.sizes.map((size) {
            final selected = size == selectedSize;
            return ChoiceChip(
              label: Text('$size'),
              selected: selected,
              onSelected: (_) => onSizeChanged(size),
              selectedColor: AppColors.ink,
              labelStyle: TextStyle(color: selected ? Colors.white : AppColors.ink, fontWeight: FontWeight.w700),
            );
          }).toList(),
        ),
        const SizedBox(height: 22),
        const Text('Jumlah', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 9),
        Row(
          children: [
            _RoundButton(
              icon: Icons.remove_rounded,
              onTap: quantity <= 1 ? null : () => onQuantityChanged(quantity - 1),
            ),
            SizedBox(width: 46, child: Center(child: Text('$quantity', style: const TextStyle(fontWeight: FontWeight.w800)))),
            _RoundButton(icon: Icons.add_rounded, onTap: () => onQuantityChanged(quantity + 1)),
          ],
        ),
        const SizedBox(height: 26),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onAddToCart,
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text('Tambah ke Keranjang'),
          ),
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _RoundButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(icon, size: 17, color: onTap == null ? AppColors.line : AppColors.ink),
        ),
      ),
    );
  }
}
