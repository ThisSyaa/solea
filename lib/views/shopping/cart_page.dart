import 'dart:math' as math;

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
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: list),
                        SizedBox(
                          width: 360,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(0, 10, 20, 24),
                            child: summary,
                          ),
                        ),
                      ],
                    ),
                  ),
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
    final isCompact = MediaQuery.sizeOf(context).width < 390;
    final thumbSize = isCompact ? 76.0 : 92.0;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: thumbSize,
              height: thumbSize,
              child: Image.network(
                item.product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: AppColors.sand,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.directions_run_rounded,
                    color: AppColors.muted,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
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
                            item.product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ukuran ${item.size} • ${formatRupiah(item.product.price)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Hapus',
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                      onPressed: () => cart.remove(item),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _QtyButton(
                          icon: Icons.remove_rounded,
                          onTap: () => cart.decrement(item),
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 36),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Center(
                              child: Text(
                                '${item.quantity}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                        _QtyButton(
                          icon: Icons.add_rounded,
                          onTap: () => cart.increment(item),
                        ),
                      ],
                    ),
                    Text(
                      formatRupiah(item.subtotal),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ],
            ),
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
    final isAdd = icon == Icons.add_rounded;
    return Semantics(
      button: true,
      label: isAdd ? 'Tambah jumlah' : 'Kurangi jumlah',
      child: Tooltip(
        message: isAdd ? 'Tambah jumlah' : 'Kurangi jumlah',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 48,
                minHeight: 48,
              ),
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.sand,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: Icon(icon, size: 16),
                  ),
                ),
              ),
            ),
          ),
        ),
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
    final surfaceColor = Theme.of(context).colorScheme.surface;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 18),
          _SummaryRow(label: 'Subtotal', value: formatRupiah(subtotal)),
          const SizedBox(height: 10),
          const _SummaryRow(label: 'Ongkir', value: 'Rp 15.000'),
          const Divider(height: 28),
          _SummaryRow(label: 'Total', value: formatRupiah(total), bold: true),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onCheckout,
              child: const Text('Checkout'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.w900 : FontWeight.w500,
      fontSize: bold ? 17 : 14,
    );
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: style,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// TAMPILAN KERANJANG KOSONG
// Ilustrasi keranjang beranimasi (digambar dengan kode, jadi tidak
// butuh file GIF/Lottie dan tetap tajam di semua ukuran layar).
// ============================================================

class _CartEmpty extends StatefulWidget {
  const _CartEmpty();

  @override
  State<_CartEmpty> createState() => _CartEmptyState();
}

class _CartEmptyState extends State<_CartEmpty>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  @override
  void initState() {
    super.initState();

    // Hormati pengaturan "kurangi animasi" dari sistem.
    final reduceMotion = WidgetsBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations;

    if (!reduceMotion) _loop.repeat();
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 16 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 230,
                  height: 170,
                  child: CustomPaint(painter: _EmptyCartPainter(_loop)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Keranjangmu masih kosong',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sepatu impianmu menunggu di katalog.\n'
                  'Pilih satu, lalu masukkan ke keranjang.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.55,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: 240,
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.forest,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    icon: const Icon(Icons.storefront_outlined, size: 19),
                    label: const Text('Mulai belanja'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Keranjang belanja yang melayang naik-turun pelan, dengan bayangan
/// yang mengecil saat naik, roda yang berputar, dan kilauan bintang.
class _EmptyCartPainter extends CustomPainter {
  final Animation<double> loop;

  _EmptyCartPainter(this.loop) : super(repaint: loop);

  static const _ink = AppColors.ink;
  static const _forest = AppColors.forest;
  static const _amber = Color(0xFFE1A12B);

  @override
  void paint(Canvas canvas, Size size) {
    final t = loop.value;
    final wave = math.sin(t * 2 * math.pi);
    final lift = (wave + 1) / 2; // 0 = turun, 1 = naik
    final cx = size.width / 2;

    _paintBackdrop(canvas, size);
    _paintShadow(canvas, size, lift);

    // Keranjang: melayang + miring sedikit.
    canvas.save();
    canvas.translate(cx, 80 - 12 * lift);
    canvas.rotate(0.035 * math.sin(t * 2 * math.pi + 0.8));
    canvas.translate(-60, -50);
    _paintCart(canvas, t);
    canvas.restore();

    // Kilauan di sekitar keranjang.
    _sparkle(canvas, Offset(cx - 84, 44), 9, _amber, t, 0.00);
    _sparkle(canvas, Offset(cx + 88, 60), 7, _forest, t, 0.33);
    _sparkle(canvas, Offset(cx + 66, 20), 5, _amber, t, 0.62);
    _sparkle(canvas, Offset(cx - 62, 112), 5, _forest, t, 0.80);
  }

  void _paintBackdrop(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, 82);
    canvas.drawCircle(
      center,
      74,
      Paint()..color = _forest.withValues(alpha: 0.07),
    );
    canvas.drawCircle(
      center,
      52,
      Paint()..color = _forest.withValues(alpha: 0.07),
    );
  }

  void _paintShadow(Canvas canvas, Size size, double lift) {
    final width = 104 - 28 * lift;
    final alpha = 0.16 - 0.07 * lift;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height - 14),
        width: width,
        height: 12,
      ),
      Paint()..color = _ink.withValues(alpha: alpha),
    );
  }

  /// Digambar pada kotak lokal 120 x 100.
  void _paintCart(Canvas canvas, double t) {
    final stroke = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Badan keranjang.
    final basket = Path()
      ..moveTo(24, 26)
      ..lineTo(112, 26)
      ..lineTo(100, 66)
      ..lineTo(40, 66)
      ..close();

    canvas.drawPath(basket, Paint()..color = Colors.white);

    // Kisi-kisi di dalam keranjang.
    final slat = Paint()
      ..color = _ink.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    for (var i = 1; i <= 3; i++) {
      final top = 24 + 88 * i / 4;
      final bottom = 40 + 60 * i / 4;
      canvas.drawLine(Offset(top, 31), Offset(bottom, 61), slat);
    }
    canvas.drawLine(const Offset(32, 46), const Offset(106, 46), slat);

    canvas.drawPath(basket, stroke);

    // Gagang.
    canvas.drawPath(
      Path()
        ..moveTo(4, 10)
        ..lineTo(18, 10)
        ..lineTo(24, 26),
      stroke,
    );

    // Penyangga roda.
    final strut = Paint()
      ..color = _ink
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(50, 66), const Offset(50, 80), strut);
    canvas.drawLine(const Offset(92, 66), const Offset(92, 80), strut);

    // Roda berputar.
    _wheel(canvas, const Offset(50, 87), t);
    _wheel(canvas, const Offset(92, 87), t);
  }

  void _wheel(Canvas canvas, Offset c, double t) {
    canvas.drawCircle(c, 8, Paint()..color = _forest);

    final angle = t * 2 * math.pi * 3;
    final spoke = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 2; i++) {
      final a = angle + i * math.pi;
      canvas.drawLine(
        c,
        c + Offset(math.cos(a), math.sin(a)) * 5,
        spoke,
      );
    }
    canvas.drawCircle(c, 2, Paint()..color = Colors.white);
  }

  void _sparkle(
    Canvas canvas,
    Offset c,
    double r,
    Color color,
    double t,
    double phase,
  ) {
    final pulse = math.max(0.0, math.sin((t + phase) * 2 * math.pi));
    final radius = r * (0.35 + 0.65 * pulse);
    if (radius < 0.5) return;

    final path = Path()
      ..moveTo(c.dx, c.dy - radius)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + radius, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + radius)
      ..quadraticBezierTo(c.dx, c.dy, c.dx - radius, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - radius)
      ..close();

    canvas.drawPath(
      path,
      Paint()..color = color.withValues(alpha: 0.35 + 0.65 * pulse),
    );
  }

  @override
  bool shouldRepaint(covariant _EmptyCartPainter oldDelegate) =>
      oldDelegate.loop != loop;
}