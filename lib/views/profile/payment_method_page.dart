import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/home_button.dart';

class PaymentMethodPage
    extends StatefulWidget {
  const PaymentMethodPage({
    super.key,
  });

  @override
  State<PaymentMethodPage>
      createState() =>
          _PaymentMethodPageState();
}

class _PaymentMethodPageState
    extends State<PaymentMethodPage> {
  String _selected =
      'Transfer Bank';

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
          'Metode Pembayaran',
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
                RadioListTile<String>(
                  value:
                      'Transfer Bank',
                  groupValue:
                      _selected,
                  onChanged:
                      (value) {
                    setState(() {
                      _selected =
                          value!;
                    });
                  },
                  title:
                      const Text(
                    'Transfer Bank',
                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  subtitle:
                      const Text(
                    'BCA / BRI / Mandiri',
                  ),
                ),
                const Divider(
                  height: 1,
                ),
                RadioListTile<String>(
                  value:
                      'E-Wallet',
                  groupValue:
                      _selected,
                  onChanged:
                      (value) {
                    setState(() {
                      _selected =
                          value!;
                    });
                  },
                  title:
                      const Text(
                    'E-Wallet',
                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  subtitle:
                      const Text(
                    'OVO / DANA / GoPay',
                  ),
                ),
                const Divider(
                  height: 1,
                ),
                RadioListTile<String>(
                  value:
                      'COD',
                  groupValue:
                      _selected,
                  onChanged:
                      (value) {
                    setState(() {
                      _selected =
                          value!;
                    });
                  },
                  title:
                      const Text(
                    'Cash on Delivery',
                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  subtitle:
                      const Text(
                    'Bayar saat barang diterima',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width:
                double.infinity,
            height: 52,
            child:
                ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(
                  context,
                )
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      'Metode "$_selected" dipilih.',
                    ),
                  ),
                );
              },
              child:
                  const Text(
                'Simpan Metode',
              ),
            ),
          ),
        ],
      ),
    );
  }
}