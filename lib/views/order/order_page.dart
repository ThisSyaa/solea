import 'package:flutter/material.dart';
import '../../controllers/order_controller.dart';
import '../../core/app_helpers.dart';
import '../../core/app_theme.dart';
import '../../models/order.dart';

class OrderPage extends StatefulWidget {
  final bool showSuccess;
  const OrderPage({super.key, this.showSuccess = false});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  @override
  void initState() {
    super.initState();
    if (widget.showSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan berhasil dibuat.')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand,
      appBar: AppBar(
        backgroundColor: AppColors.sand,
        elevation: 0,
        title: const Text('Pesanan', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: const [Padding(padding: EdgeInsets.only(right: 12), child: SoleaLogo(iconSize: 28))],
      ),
      body: AnimatedBuilder(
        animation: OrderController.instance,
        builder: (context, _) {
          final orders = OrderController.instance.orders;
          if (orders.isEmpty) return const _NoOrders();
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) => _OrderCard(order: orders[index]),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(order.id, style: const TextStyle(fontWeight: FontWeight.w900)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: AppColors.sand, borderRadius: BorderRadius.circular(20)),
                child: Text(order.status, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(formatDate(order.createdAt), style: Theme.of(context).textTheme.bodySmall),
          const Divider(height: 24),
          ...order.items.take(3).map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(width: 52, height: 52, child: Image.network(item.product.imageUrl, fit: BoxFit.cover)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text('${item.product.name}\nSize ${item.size} • ${item.quantity}x', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700))),
                      Text(formatRupiah(item.subtotal), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
                    ],
                  ),
                ),
              ),
          if (order.items.length > 3)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('+ ${order.items.length - 3} item lainnya', style: Theme.of(context).textTheme.bodySmall),
            ),
          const Divider(height: 20),
          Row(children: [const Text('Pembayaran', style: TextStyle(color: AppColors.muted)), const Spacer(), Text(order.paymentMethod, style: const TextStyle(fontWeight: FontWeight.w700))]),
          const SizedBox(height: 8),
          Row(children: [const Text('Total', style: TextStyle(fontWeight: FontWeight.w900)), const Spacer(), Text(formatRupiah(order.total), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900))]),
        ],
      ),
    );
  }
}

class _NoOrders extends StatelessWidget {
  const _NoOrders();
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
              child: const Icon(Icons.receipt_long_outlined, size: 34),
            ),
            const SizedBox(height: 16),
            const Text('Belum ada pesanan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 7),
            const Text('Pesanan yang berhasil dibuat akan muncul di sini.'),
          ],
        ),
      ),
    );
  }
}
