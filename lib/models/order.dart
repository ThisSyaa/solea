import 'cart_item.dart';

class Order {
  final String id;
  final DateTime createdAt;
  final List<CartItem> items;
  final int shippingCost;
  final int total;
  final String customerName;
  final String phone;
  final String address;
  final String paymentMethod;
  String status;

  Order({
    required this.id,
    required this.createdAt,
    required this.items,
    required this.shippingCost,
    required this.total,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.paymentMethod,
    this.status = 'Diproses',
  });
}
