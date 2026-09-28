import 'package:flutter/foundation.dart';
import '../models/product.dart';
import 'product_controller.dart';

class WishlistController extends ChangeNotifier {
  WishlistController._();
  static final WishlistController instance = WishlistController._();

  final Set<String> _names = <String>{};

  bool contains(Product product) => _names.contains(product.name);

  int get count => _names.length;

  List<Product> get products => ProductController.products
      .where((product) => _names.contains(product.name))
      .toList();

  void toggle(Product product) {
    if (_names.contains(product.name)) {
      _names.remove(product.name);
    } else {
      _names.add(product.name);
    }
    notifyListeners();
  }
}
