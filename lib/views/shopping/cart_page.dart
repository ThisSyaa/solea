import 'package:flutter/material.dart';
import '../../controllers/cart_controller.dart';
import '../../core/app_helpers.dart';
import '../../core/app_theme.dart';
import '../../models/cart_item.dart';
import 'checkout_page.dart';
import '../../core/home_button.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand,
      appBar: AppBar(
        backgroundColor: AppColors.sand,
        elevation: 0,
        title: const Text(
          'Keranjang',
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
        animation: CartController.instance,
        builder: (context, _) {
          final cart = CartController.instance;
          if (cart.items.isEmpty) return const _CartEmpty();

          return LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 850;
              final list = ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                itemCount: cart.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, index) => _CartItemTile(item: cart.items[index]),
              );

              final summary = _CartSummary(
                subtotal: cart.subtotal,
                onCheckout: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CheckoutPage()),
                ),
              );

              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: list),
                    SizedBox(width: 360, child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(0, 10, 20, 24), child: summary)),
                  ],
                );
              }

              return Column(
                children: [
                  Expanded(child: list),
                  summary,
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = CartController.instance;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 92,
              height: 92,
              child: Image.network(item.product.imageUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 4),
                Text('Ukuran ${item.size} • ${formatRupiah(item.product.price)}', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _QtyButton(icon: Icons.remove_rounded, onTap: () => cart.decrement(item)),
                    SizedBox(width: 40, child: Center(child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w800)))),
                    _QtyButton(icon: Icons.add_rounded, onTap: () => cart.increment(item)),
                    const Spacer(),
                    Text(formatRupiah(item.subtotal), style: const TextStyle(fontWeight: FontWeight.w900)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Hapus',
            onPressed: () => cart.remove(item),
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.sand,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: SizedBox(width: 30, height: 30, child: Icon(icon, size: 16)),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final int subtotal;
  final VoidCallback onCheckout;
  const _CartSummary({required this.subtotal, required this.onCheckout});

  @override
  Widget build(BuildContext context) {
    const shipping = 15000;
    final total = subtotal + shipping;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ringkasan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 18),
          _SummaryRow(label: 'Subtotal', value: formatRupiah(subtotal)),
          const SizedBox(height: 10),
          const _SummaryRow(label: 'Ongkir', value: 'Rp 15.000'),
          const Divider(height: 28),
          _SummaryRow(label: 'Total', value: formatRupiah(total), bold: true),
          const SizedBox(height: 18),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: onCheckout, child: const Text('Checkout'))),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _SummaryRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontWeight: bold ? FontWeight.w900 : FontWeight.w500, fontSize: bold ? 17 : 14);
    return Row(children: [Text(label, style: style), const Spacer(), Text(value, style: style)]);
  }
}

class _CartEmpty extends StatelessWidget {
  const _CartEmpty();

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
              child: const Icon(Icons.shopping_bag_outlined, size: 34),
            ),
            const SizedBox(height: 16),
            const Text('Keranjang kosong', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 7),
            const Text('Pilih sepatu dulu, lalu masukkan ke keranjang.'),
            const SizedBox(height: 22),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Kembali belanja')),
          ],
        ),
      ),
    );
  }
}
