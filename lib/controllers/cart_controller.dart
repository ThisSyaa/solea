import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartController extends ChangeNotifier {
  CartController._();
  static final CartController instance = CartController._();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  int get subtotal => _items.fold(0, (sum, item) => sum + item.subtotal);

  bool contains(Product product, int size) => _items.any(
        (item) => item.product.name == product.name && item.size == size,
      );

  void add(Product product, int size, [int quantity = 1]) {
    final index = _items.indexWhere(
      (item) => item.product.name == product.name && item.size == size,
    );

    if (index == -1) {
      _items.add(CartItem(product: product, size: size, quantity: quantity));
    } else {
      _items[index].quantity += quantity;
    }
    notifyListeners();
  }

  void increment(CartItem item) {
    item.quantity += 1;
    notifyListeners();
  }

  void decrement(CartItem item) {
    if (item.quantity <= 1) {
      _items.remove(item);
    } else {
      item.quantity -= 1;
    }
    notifyListeners();
  }

  void remove(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  List<CartItem> snapshot() => _items
      .map(
        (item) => CartItem(
          product: item.product,
          size: item.size,
          quantity: item.quantity,
        ),
      )
      .toList();

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
