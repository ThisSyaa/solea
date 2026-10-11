
import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/order_controller.dart';
import '../../core/app_helpers.dart';
import '../../core/app_theme.dart';
import '../../core/home_button.dart';
import '../order/order_page.dart';

const int _shippingCost = 15000;

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  final _phone = TextEditingController();
  final _address = TextEditingController();

  String _payment = 'Transfer Bank';

  bool _isPlacingOrder = false;
  bool _isLoadingAddress = true;
  bool _userEditedForm = false;

  String? _addressLoadWarning;

  @override
  void initState() {
    super.initState();

    _name = TextEditingController(
      text: AuthController.currentName ?? '',
    );

    _loadSavedAddress();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  // =========================================================
  // MEMUAT ALAMAT UTAMA
  // =========================================================

  Future<void> _loadSavedAddress() async {
    try {
      final data = await AuthController.loadFirebaseAddress();

      if (!mounted) return;

      if (data != null && !_userEditedForm) {
        _name.text = data['name'] ?? _name.text;
        _phone.text = data['phone'] ?? '';
        _address.text = data['address'] ?? '';
      }

      setState(() {
        _isLoadingAddress = false;
        _addressLoadWarning = null;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoadingAddress = false;
        _addressLoadWarning =
            'Alamat tersimpan tidak dapat dimuat. '
            'Silakan isi data pengiriman secara manual.';
      });
    }
  }

  void _markFormEdited(String _) {
    _userEditedForm = true;
  }

  // =========================================================
  // MEMBUAT PESANAN
  // =========================================================

  Future<void> _placeOrder() async {
    if (_isPlacingOrder) return;

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final cart = CartController.instance;

    if (cart.items.isEmpty) {
      _showMessage('Keranjang kamu masih kosong.');
      return;
    }

    final items = cart.snapshot();

    setState(() {
      _isPlacingOrder = true;
    });

    final error = await OrderController.instance.createOrder(
      items: items,
      shippingCost: _shippingCost,
      customerName: _name.text.trim(),
      phone: _phone.text.trim(),
      address: _address.text.trim(),
      paymentMethod: _payment,
    );

    if (!mounted) return;

    setState(() {
      _isPlacingOrder = false;
    });

    if (error != null) {
      _showMessage(error);
      return;
    }

    // Kosongkan keranjang hanya setelah Firestore mengonfirmasi
    // bahwa dokumen pesanan berhasil disimpan.
    cart.clear();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const OrderPage(showSuccess: true),
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // =========================================================
  // UI CHECKOUT
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final cart = CartController.instance;

    return Scaffold(
      backgroundColor: AppColors.sand,
      appBar: AppBar(
        backgroundColor: AppColors.sand,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Checkout',
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
        animation: cart,
        builder: (context, _) {
          if (cart.items.isEmpty) {
            return _EmptyCheckout(
              onBack: () => Navigator.of(context).maybePop(),
            );
          }

          final subtotal = cart.subtotal;
          final total = subtotal + _shippingCost;

          final form = _AddressForm(
            name: _name,
            phone: _phone,
            address: _address,
            payment: _payment,
            isLoadingAddress: _isLoadingAddress,
            addressLoadWarning: _addressLoadWarning,
            onEdited: _markFormEdited,
            onPaymentChanged: (value) {
              setState(() {
                _payment = value;
              });
            },
          );

          final summary = _CheckoutSummary(
            subtotal: subtotal,
            shippingCost: _shippingCost,
            total: total,
            itemCount: cart.totalItems,
            isSaving: _isPlacingOrder,
            onOrder: _placeOrder,
          );

          return Form(
            key: _formKey,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 850;

                if (wide) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      24,
                      10,
                      24,
                      30,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 1050,
                        ),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Expanded(child: form),
                            const SizedBox(width: 28),
                            SizedBox(
                              width: 350,
                              child: summary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    8,
                    20,
                    30,
                  ),
                  child: Column(
                    children: [
                      form,
                      const SizedBox(height: 18),
                      summary,
                    ],
                  ),
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
// FORM PENGIRIMAN DAN PEMBAYARAN
// ============================================================

class _AddressForm extends StatelessWidget {
  final TextEditingController name;
  final TextEditingController phone;
  final TextEditingController address;

  final String payment;
  final bool isLoadingAddress;
  final String? addressLoadWarning;

  final ValueChanged<String> onEdited;
  final ValueChanged<String> onPaymentChanged;

  const _AddressForm({
    required this.name,
    required this.phone,
    required this.address,
    required this.payment,
    required this.isLoadingAddress,
    required this.addressLoadWarning,
    required this.onEdited,
    required this.onPaymentChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Pengiriman',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
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
              if (isLoadingAddress) ...[
                const LinearProgressIndicator(),
                const SizedBox(height: 12),
              ],

              if (addressLoadWarning != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F0E4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    addressLoadWarning!,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              const FieldLabel('Nama penerima'),
              TextFormField(
                controller: name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                onChanged: onEdited,
                decoration: const InputDecoration(
                  hintText: 'Nama lengkap',
                  prefixIcon: Icon(
                    Icons.person_outline_rounded,
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Nama wajib diisi.';
                  }

                  if (value.trim().length < 3) {
                    return 'Nama minimal 3 karakter.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              const FieldLabel('Nomor HP'),
              TextFormField(
                controller: phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                onChanged: onEdited,
                decoration: const InputDecoration(
                  hintText: '08xxxxxxxxxx',
                  prefixIcon: Icon(
                    Icons.phone_outlined,
                  ),
                ),
                validator: (value) {
                  final digits = (value ?? '')
                      .replaceAll(RegExp(r'\D'), '');

                  if (digits.length < 8) {
                    return 'Nomor HP belum valid.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              const FieldLabel('Alamat lengkap'),
              TextFormField(
                controller: address,
                minLines: 3,
                maxLines: 5,
                textCapitalization:
                    TextCapitalization.sentences,
                onChanged: onEdited,
                decoration: const InputDecoration(
                  hintText:
                      'Jalan, kecamatan, kota, provinsi, kode pos',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().length < 10) {
                    return 'Alamat minimal 10 karakter.';
                  }

                  return null;
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        Text(
          'Metode Pembayaran',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 14),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.line,
            ),
          ),
          child: Column(
            children: [
              RadioListTile<String>(
                value: 'Transfer Bank',
                groupValue: payment,
                onChanged: (value) {
                  if (value != null) {
                    onPaymentChanged(value);
                  }
                },
                activeColor: AppColors.forest,
                title: const Text(
                  'Transfer Bank',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: const Text('BCA / BRI / Mandiri'),
              ),
              const Divider(
                height: 1,
                color: AppColors.line,
              ),
              RadioListTile<String>(
                value: 'E-Wallet',
                groupValue: payment,
                onChanged: (value) {
                  if (value != null) {
                    onPaymentChanged(value);
                  }
                },
                activeColor: AppColors.forest,
                title: const Text(
                  'E-Wallet',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: const Text('OVO / DANA / GoPay'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// RINGKASAN PESANAN
// ============================================================

class _CheckoutSummary extends StatelessWidget {
  final int subtotal;
  final int shippingCost;
  final int total;
  final int itemCount;
  final bool isSaving;
  final VoidCallback onOrder;

  const _CheckoutSummary({
    required this.subtotal,
    required this.shippingCost,
    required this.total,
    required this.itemCount,
    required this.isSaving,
    required this.onOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const Text(
            'Ringkasan pesanan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '$itemCount item dalam keranjang',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 18),

          _Line(
            label: 'Subtotal',
            value: formatRupiah(subtotal),
          ),
          const SizedBox(height: 10),
          _Line(
            label: 'Ongkir',
            value: formatRupiah(shippingCost),
          ),

          const Divider(height: 28),

          _Line(
            label: 'Total',
            value: formatRupiah(total),
            bold: true,
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSaving ? null : onOrder,
              child: isSaving
                  ? const SizedBox(
                      width: 21,
                      height: 21,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Buat Pesanan'),
            ),
          ),

          const SizedBox(height: 12),

          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 15,
                color: AppColors.muted,
              ),
              SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Pembayaran masih berupa simulasi. '
                  'Belum ada transaksi uang sungguhan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.5,
                    color: AppColors.muted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _Line({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight:
          bold ? FontWeight.w900 : FontWeight.w500,
      fontSize: bold ? 17 : 14,
      color: AppColors.ink,
    );

    return Row(
      children: [
        Text(label, style: style),
        const Spacer(),
        Text(value, style: style),
      ],
    );
  }
}

// ============================================================
// KERANJANG KOSONG
// ============================================================

class _EmptyCheckout extends StatelessWidget {
  final VoidCallback onBack;

  const _EmptyCheckout({
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 35,
                color: AppColors.forest,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Keranjang masih kosong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tambahkan sepatu ke keranjang sebelum checkout.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.muted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: 220,
              child: ElevatedButton(
                onPressed: onBack,
                child: const Text('Kembali'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
