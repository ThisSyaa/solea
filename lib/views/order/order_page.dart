
import 'package:flutter/material.dart';

import '../../controllers/order_controller.dart';
import '../../core/app_helpers.dart';
import '../../core/app_theme.dart';
import '../../models/order.dart';

class OrderPage extends StatefulWidget {
  final bool showSuccess;

  const OrderPage({
    super.key,
    this.showSuccess = false,
  });

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  @override
  void initState() {
    super.initState();

    // Muat riwayat terbaru dari Firestore.
    OrderController.instance.loadOrders(
      forceRefresh: true,
    );

    if (widget.showSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Pesanan berhasil disimpan.',
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = OrderController.instance;

    return Scaffold(
      backgroundColor: AppColors.sand,
      appBar: AppBar(
        backgroundColor: AppColors.sand,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Pesanan Saya',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Muat ulang pesanan',
            onPressed: controller.isLoading
                ? null
                : () {
                    controller.loadOrders(
                      forceRefresh: true,
                    );
                  },
            icon: const Icon(Icons.refresh_rounded),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: SoleaLogo(iconSize: 28),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final orders = controller.orders;

          if (controller.isLoading && orders.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.forest,
              ),
            );
          }

          if (controller.lastError != null &&
              orders.isEmpty) {
            return _OrderLoadError(
              message: controller.lastError!,
              onRetry: () {
                controller.loadOrders(
                  forceRefresh: true,
                );
              },
            );
          }

          if (orders.isEmpty) {
            return const _NoOrders();
          }

          return RefreshIndicator(
            color: AppColors.forest,
            onRefresh: () {
              return controller.loadOrders(
                forceRefresh: true,
              );
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                20,
                8,
                20,
                30,
              ),
              itemCount: orders.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 12),
              itemBuilder: (_, index) {
                return _OrderCard(
                  order: orders[index],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// ORDER CARD
// ============================================================

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.line,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.id,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      formatDate(order.createdAt),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5EFE9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.status,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.forestDeep,
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: 24),

          ...order.items.take(3).map(
            (item) {
              final imageUrl = item.product.imageUrl;

              return Padding(
                padding: const EdgeInsets.only(
                  bottom: 12,
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: imageUrl.isEmpty
                            ? _imagePlaceholder()
                            : Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (
                                  context,
                                  error,
                                  stackTrace,
                                ) {
                                  return _imagePlaceholder();
                                },
                              ),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Size ${item.size} • ${item.quantity}x',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatRupiah(item.subtotal),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          if (order.items.length > 3)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '+ ${order.items.length - 3} item lainnya',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),

          const Divider(height: 20),

          const Text(
            'Dikirim kepada',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            order.customerName,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            order.phone,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            order.address,
            style: const TextStyle(
              fontSize: 12,
              height: 1.5,
              color: AppColors.ink,
            ),
          ),

          const Divider(height: 24),

          Row(
            children: [
              const Text(
                'Pembayaran',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                order.paymentMethod,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                formatRupiah(order.total),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: AppColors.sand,
      alignment: Alignment.center,
      child: const Icon(
        Icons.directions_run_rounded,
        color: AppColors.muted,
      ),
    );
  }
}

// ============================================================
// LOADING ERROR
// ============================================================

class _OrderLoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _OrderLoadError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              color: AppColors.muted,
              size: 42,
            ),
            const SizedBox(height: 16),
            const Text(
              'Pesanan belum bisa dimuat',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.muted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 220,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba lagi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY ORDERS
// ============================================================

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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 34,
                color: AppColors.forest,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada pesanan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Pesanan yang berhasil dibuat akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.muted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
