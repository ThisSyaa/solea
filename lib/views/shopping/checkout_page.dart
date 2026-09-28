import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/order_controller.dart';
import '../../core/app_helpers.dart';
import '../../core/app_theme.dart';
import '../order/order_page.dart';
import '../../core/home_button.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController(text: AuthController.currentName ?? 'Syaaxi');
  final _phone = TextEditingController();
  final _address = TextEditingController();
  String _payment = 'Transfer Bank';

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  void _placeOrder() {
    if (!_formKey.currentState!.validate()) return;
    final cart = CartController.instance;
    if (cart.items.isEmpty) return;

    OrderController.instance.createOrder(
      items: cart.snapshot(),
      shippingCost: 15000,
      customerName: _name.text.trim(),
      phone: _phone.text.trim(),
      address: _address.text.trim(),
      paymentMethod: _payment,
    );
    cart.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OrderPage(showSuccess: true)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartController.instance;
    final total = cart.subtotal + 15000;

    return Scaffold(
      backgroundColor: AppColors.sand,
      appBar: AppBar(
        backgroundColor: AppColors.sand,
        elevation: 0,
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
      body: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 850;
            final form = _AddressForm(
              name: _name,
              phone: _phone,
              address: _address,
              payment: _payment,
              onPaymentChanged: (value) => setState(() => _payment = value),
            );
            final summary = _CheckoutSummary(total: total, onOrder: _placeOrder);

            if (wide) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1050),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: form),
                        const SizedBox(width: 28),
                        SizedBox(width: 350, child: summary),
                      ],
                    ),
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
              child: Column(children: [form, const SizedBox(height: 18), summary]),
            );
          },
        ),
      ),
    );
  }
}

class _AddressForm extends StatelessWidget {
  final TextEditingController name;
  final TextEditingController phone;
  final TextEditingController address;
  final String payment;
  final ValueChanged<String> onPaymentChanged;

  const _AddressForm({
    required this.name,
    required this.phone,
    required this.address,
    required this.payment,
    required this.onPaymentChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Data Pengiriman', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FieldLabel('Nama penerima'),
              TextFormField(
                controller: name,
                decoration: const InputDecoration(hintText: 'Nama lengkap', prefixIcon: Icon(Icons.person_outline_rounded)),
                validator: (v) => v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 15),
              const FieldLabel('Nomor HP'),
              TextFormField(
                controller: phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(hintText: '08xxxxxxxxxx', prefixIcon: Icon(Icons.phone_outlined)),
                validator: (v) => v == null || v.trim().length < 9 ? 'Nomor HP belum valid' : null,
              ),
              const SizedBox(height: 15),
              const FieldLabel('Alamat lengkap'),
              TextFormField(
                controller: address,
                maxLines: 4,
                decoration: const InputDecoration(hintText: 'Jalan, kecamatan, kota, kode pos', alignLabelWithHint: true),
                validator: (v) => v == null || v.trim().length < 10 ? 'Alamat terlalu singkat' : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Text('Metode Pembayaran', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              RadioListTile<String>(
                value: 'Transfer Bank',
                groupValue: payment,
                onChanged: (v) => onPaymentChanged(v!),
                title: const Text('Transfer Bank', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('BCA / BRI / Mandiri'),
              ),
              const Divider(height: 1),
              RadioListTile<String>(
                value: 'E-Wallet',
                groupValue: payment,
                onChanged: (v) => onPaymentChanged(v!),
                title: const Text('E-Wallet', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('OVO / DANA / GoPay'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CheckoutSummary extends StatelessWidget {
  final int total;
  final VoidCallback onOrder;

  const _CheckoutSummary({required this.total, required this.onOrder});

  @override
  Widget build(BuildContext context) {
    final subtotal = CartController.instance.subtotal;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ringkasan pesanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 18),
          _Line(label: 'Produk', value: formatRupiah(subtotal)),
          const SizedBox(height: 10),
          const _Line(label: 'Ongkir', value: 'Rp 15.000'),
          const Divider(height: 28),
          _Line(label: 'Total', value: formatRupiah(total), bold: true),
          const SizedBox(height: 18),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: onOrder, child: const Text('Buat Pesanan'))),
          const SizedBox(height: 8),
          const Text('Pesanan demo disimpan selama aplikasi berjalan.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _Line({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontWeight: bold ? FontWeight.w900 : FontWeight.w500, fontSize: bold ? 17 : 14);
    return Row(children: [Text(label, style: style), const Spacer(), Text(value, style: style)]);
  }
}
