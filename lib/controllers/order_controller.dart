import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/order.dart';

class OrderController extends ChangeNotifier {
  OrderController._();
  static final OrderController instance = OrderController._();

  final List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders);

  void createOrder({
    required List<CartItem> items,
    required int shippingCost,
    required String customerName,
    required String phone,
    required String address,
    required String paymentMethod,
  }) {
    final subtotal = items.fold<int>(0, (sum, item) => sum + item.subtotal);
    final now = DateTime.now();
    final id = 'SL-${now.millisecondsSinceEpoch.toString().substring(5)}';

    _orders.insert(
      0,
      Order(
        id: id,
        createdAt: now,
        items: items,
        shippingCost: shippingCost,
        total: subtotal + shippingCost,
        customerName: customerName,
        phone: phone,
        address: address,
        paymentMethod: paymentMethod,
      ),
    );
    notifyListeners();
  }
}
