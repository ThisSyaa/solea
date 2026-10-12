
import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../order/order_page.dart';
import '../profile/address_page.dart';
import '../profile/faq_page.dart';
import '../profile/payment_method_page.dart';
import '../shopping/cart_page.dart';
import '../shopping/wishlist_page.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  void _openPage(
    BuildContext context,
    Widget page,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => page,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final columns = width >= 1000
        ? 3
        : width >= 620
            ? 2
            : 1;

    return Scaffold(
      backgroundColor: AppColors.sand,
      appBar: AppBar(
        backgroundColor: AppColors.sand,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Layanan SOLEA',
          style: TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final padding =
              constraints.maxWidth < 600 ? 18.0 : 28.0;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              padding,
              18,
              padding,
              32,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1050,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Semua kebutuhanmu, dalam satu tempat.',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.7,
                      ),
                    ),
                    const SizedBox(height: 9),
                    const Text(
                      'Pilih layanan yang ingin kamu akses.',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 26),

                    GridView.count(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      crossAxisCount: columns,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: columns == 1
                          ? 3.4
                          : 1.65,
                      children: [
                        _ServiceCard(
                          icon: Icons.receipt_long_outlined,
                          title: 'Pesanan Saya',
                          subtitle:
                              'Lihat riwayat dan status pesanan.',
                          onTap: () => _openPage(
                            context,
                            const OrderPage(),
                          ),
                        ),
                        _ServiceCard(
                          icon: Icons.location_on_outlined,
                          title: 'Alamat Pengiriman',
                          subtitle:
                              'Kelola alamat penerima pesanan.',
                          onTap: () => _openPage(
                            context,
                            const AddressPage(),
                          ),
                        ),
                        _ServiceCard(
                          icon: Icons.payment_outlined,
                          title: 'Metode Pembayaran',
                          subtitle:
                              'Atur pilihan metode pembayaran.',
                          onTap: () => _openPage(
                            context,
                            const PaymentMethodPage(),
                          ),
                        ),
                        _ServiceCard(
                          icon: Icons.shopping_bag_outlined,
                          title: 'Keranjang',
                          subtitle:
                              'Periksa produk sebelum checkout.',
                          onTap: () => _openPage(
                            context,
                            const CartPage(),
                          ),
                        ),
                        _ServiceCard(
                          icon: Icons.favorite_border_rounded,
                          title: 'Wishlist',
                          subtitle:
                              'Lihat sepatu yang kamu simpan.',
                          onTap: () => _openPage(
                            context,
                            const WishlistPage(),
                          ),
                        ),
                        _ServiceCard(
                          icon: Icons.help_outline_rounded,
                          title: 'Bantuan & FAQ',
                          subtitle:
                              'Temukan jawaban atas pertanyaan umum.',
                          onTap: () => _openPage(
                            context,
                            const FaqPage(),
                          ),
                        ),
                      ],
                    ),
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

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0EC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: AppColors.forest,
                  size: 23,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.muted,
                size: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
