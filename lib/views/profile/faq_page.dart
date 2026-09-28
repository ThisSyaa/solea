import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/home_button.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.sand,
      appBar: AppBar(
        backgroundColor:
            AppColors.sand,
        elevation: 0,
        title: const Text(
          'Bantuan & FAQ',
          style: TextStyle(
            fontWeight:
                FontWeight.w800,
          ),
        ),
        actions: const [
          HomeButton(),
          SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding:
            const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          30,
        ),
        children: [
          _FaqItem(
            question:
                'Bagaimana cara membeli sepatu?',
            answer:
                'Pilih produk dari Home, buka detail produk, pilih ukuran, lalu tambahkan ke keranjang dan lanjutkan checkout.',
          ),
          _FaqItem(
            question:
                'Apakah produk bisa dimasukkan ke wishlist?',
            answer:
                'Bisa. Tekan ikon hati pada produk untuk menyimpannya ke wishlist.',
          ),
          _FaqItem(
            question:
                'Bagaimana cara melihat pesanan?',
            answer:
                'Buka menu Profil lalu pilih Pesanan Saya untuk melihat riwayat pesanan.',
          ),
          _FaqItem(
            question:
                'Apakah pembayaran sudah terhubung ke bank?',
            answer:
                'Belum. Saat ini pembayaran masih berupa simulasi untuk kebutuhan aplikasi.',
          ),
          _FaqItem(
            question:
                'Apakah data akan tetap tersimpan setelah aplikasi ditutup?',
            answer:
                'Saat ini data masih disimpan selama sesi aplikasi berjalan. Persistence akan ditambahkan kemudian.',
          ),
        ],
      ),
    );
  }
}

class _FaqItem
    extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      child:
          ExpansionTile(
        tilePadding:
            const EdgeInsets.symmetric(
          horizontal: 18,
        ),
        childrenPadding:
            const EdgeInsets.fromLTRB(
          18,
          0,
          18,
          18,
        ),
        title:
            Text(
          question,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.w700,
          ),
        ),
        children: [
          Align(
            alignment:
                Alignment.centerLeft,
            child:
                Text(
              answer,
              style:
                  const TextStyle(
                color:
                    AppColors.muted,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}