import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_routes.dart';
import '../../core/app_theme.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  void _openPage(BuildContext context, String routeName) {
    Navigator.of(context).pushNamed(routeName);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final textScale =
        MediaQuery.textScalerOf(context).scale(1.0).clamp(1.0, 1.65);
    final columns = width >= 1050
        ? 3
        : width >= 650
            ? 2
            : 1;
    final padding = width < 600 ? 16.0 : 30.0;
    final promoHeight = math.max(110.0, 96.0 * textScale);
    final baseServiceExtent = width < 600 ? 196.0 : 216.0;
    final serviceCardExtent = baseServiceExtent * textScale.clamp(1.0, 1.5);

    // Hubungkan nilai ini dengan jumlah data dari database.
    // Nilai awal 0 agar tidak menampilkan angka palsu.
    const jumlahPesanan = 0;
    const jumlahAlamat = 0;
    const jumlahMetodePembayaran = 0;
    const jumlahKeranjang = 0;
    const jumlahWishlist = 0;

    final services = [
      _ServiceData(
        icon: Icons.receipt_long_outlined,
        title: 'Pesanan Saya',
        subtitle: 'Lihat riwayat & status pesanan.',
        badge: jumlahPesanan,
        badgeColor: const Color(0xFF32966C),
        action: 'Lacak Paket',
        onTap: () => _openPage(context, AppRoutes.orders),
      ),
      _ServiceData(
        icon: Icons.location_on_outlined,
        title: 'Alamat Pengiriman',
        subtitle: 'Kelola alamat penerima pesanan.',
        badge: jumlahAlamat,
        badgeColor: const Color(0xFFE69A32),
        action: 'Atur Alamat',
        onTap: () => _openPage(context, AppRoutes.address),
      ),
      _ServiceData(
        icon: Icons.credit_card_outlined,
        title: 'Metode Pembayaran',
        subtitle: 'Atur pilihan metode pembayaran.',
        badge: jumlahMetodePembayaran,
        badgeColor: const Color(0xFF3885B8),
        action: 'Kelola Metode',
        onTap: () => _openPage(context, AppRoutes.payment),
      ),
      _ServiceData(
        icon: Icons.shopping_bag_outlined,
        title: 'Keranjang',
        subtitle: 'Periksa produk sebelum checkout.',
        badge: jumlahKeranjang,
        badgeColor: const Color(0xFFC34448),
        action: 'Buka Keranjang',
        onTap: () => _openPage(context, AppRoutes.cart),
      ),
      _ServiceData(
        icon: Icons.favorite_border_rounded,
        title: 'Wishlist',
        subtitle: 'Lihat sepatu yang kamu simpan.',
        badge: jumlahWishlist,
        badgeColor: const Color(0xFFE995A5),
        action: 'Buka Wishlist',
        onTap: () => _openPage(context, AppRoutes.wishlist),
      ),
      _ServiceData(
        icon: Icons.forum_outlined,
        title: 'SOLEA Chat Hub',
        subtitle: 'Chat Bot AI, Admin Support, dan Komunitas.',
        badge: 0,
        badgeColor: const Color(0xFF466F60),
        action: 'Buka Chat',
        onTap: () => _openPage(context, AppRoutes.chat),
      ),
      _ServiceData(
        icon: Icons.help_outline_rounded,
        title: 'Bantuan & FAQ',
        subtitle: 'Temukan jawaban atas pertanyaanmu.',
        badge: 0,
        badgeColor: const Color(0xFF929292),
        action: 'Tanya SOLEA',
        onTap: () => _openPage(context, AppRoutes.faq),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.sand,
      appBar: AppBar(
        backgroundColor: AppColors.sand,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppColors.ink,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Layanan SOLEA',
          style: GoogleFonts.poppins(
            fontSize: 19,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Icon(
              Icons.notifications_none_rounded,
              color: AppColors.ink,
              size: 25,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(padding, 20, padding, 45),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Semua kebutuhanmu, dalam satu tempat.',
                  style: GoogleFonts.poppins(
                    color: AppColors.ink,
                    fontSize: width < 600 ? 23 : 30,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: 7),

                Text(
                  'Pilih layanan yang ingin kamu akses.',
                  style: GoogleFonts.poppins(
                    color: AppColors.muted,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  height: promoHeight,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _PromoBanner(
                        width: width < 600
                            ? math.max(260, width - 48)
                            : 760,
                        icon: Icons.directions_run_rounded,
                        title: '✨ SOLEA Privilege',
                        description:
                            'Nikmati gratis ongkir & promo khusus member!',
                        background: const Color(0xFF315F50),
                      ),
                      const SizedBox(width: 16),
                      _PromoBanner(
                        width: width < 600
                            ? math.max(250, width - 64)
                            : 390,
                        icon: Icons.confirmation_number_outlined,
                        title: 'Klaim Voucher Diskon',
                        description: 'Temukan penawaran menarik dari SOLEA.',
                        background: const Color(0xFF315F50),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 150.ms),

                const SizedBox(height: 40),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: services.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    mainAxisExtent: serviceCardExtent,
                  ),
                  itemBuilder: (context, index) {
                    return _ServiceCard(data: services[index], index: index);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceData {
  final IconData icon;
  final String title;
  final String subtitle;
  final int badge;
  final Color badgeColor;
  final String action;
  final VoidCallback onTap;

  const _ServiceData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.action,
    required this.onTap,
  });
}

class _ServiceCard extends StatelessWidget {
  final _ServiceData data;
  final int index;

  const _ServiceCard({required this.data, required this.index});

  @override
  Widget build(BuildContext context) {
    return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            onTap: data.onTap,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(19),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFBDB8AD), width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.09),
                    blurRadius: 13,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: data.badgeColor,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        '${data.badge}',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 38),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCE8E1),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Icon(
                                data.icon,
                                color: const Color(0xFF466F60),
                                size: 29,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      color: AppColors.ink,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    data.subtitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      color: AppColors.muted,
                                      fontSize: 11,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(left: 75),
                          child: Row(
                            children: [
                              Text(
                                data.action,
                                style: GoogleFonts.poppins(
                                  color: AppColors.ink,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 7),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 16,
                                color: AppColors.forest,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 80 * index),
          duration: 400.ms,
        )
        .slideY(begin: 0.08, duration: 400.ms);
  }
}

class _PromoBanner extends StatelessWidget {
  final double width;
  final IconData icon;
  final String title;
  final String description;
  final Color background;

  const _PromoBanner({
    required this.width,
    required this.icon,
    required this.title,
    required this.description,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFE5EEE8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(icon, color: const Color(0xFFD6E4DB), size: 43),
        ],
      ),
    );
  }
}