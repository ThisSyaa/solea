import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/home_button.dart';

class NotificationPage
    extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage>
      createState() =>
          _NotificationPageState();
}

class _NotificationPageState
    extends State<NotificationPage> {
  bool _orderNotification = true;
  bool _promoNotification = true;
  bool _wishlistNotification = false;

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
          'Notifikasi',
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
          Container(
            decoration:
                BoxDecoration(
              color:
                  Colors.white,
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value:
                      _orderNotification,
                  onChanged:
                      (value) {
                    setState(() {
                      _orderNotification =
                          value;
                    });
                  },
                  title:
                      const Text(
                    'Status pesanan',
                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  subtitle:
                      const Text(
                    'Dapatkan update mengenai pesanan.',
                  ),
                ),
                const Divider(
                  height: 1,
                ),
                SwitchListTile(
                  value:
                      _promoNotification,
                  onChanged:
                      (value) {
                    setState(() {
                      _promoNotification =
                          value;
                    });
                  },
                  title:
                      const Text(
                    'Promo & diskon',
                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  subtitle:
                      const Text(
                    'Info promo dan penawaran terbaru.',
                  ),
                ),
                const Divider(
                  height: 1,
                ),
                SwitchListTile(
                  value:
                      _wishlistNotification,
                  onChanged:
                      (value) {
                    setState(() {
                      _wishlistNotification =
                          value;
                    });
                  },
                  title:
                      const Text(
                    'Wishlist',
                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  subtitle:
                      const Text(
                    'Update terkait produk wishlist.',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}