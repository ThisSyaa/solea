
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'auth_controller.dart';
import 'product_controller.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartController extends ChangeNotifier {
  CartController._();

  static final CartController instance = CartController._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<CartItem> _items = [];

  String? _loadedUid;
  String? _lastError;

  bool _isLoading = false;
  bool _hasLoaded = false;
  int _generation = 0;

  Future<void> _pendingWrite = Future<void>.value();

  List<CartItem> get items => List<CartItem>.unmodifiable(_items);

  int get totalItems =>
      _items.fold<int>(0, (runningTotal, item) {
        return runningTotal + item.quantity;
      });

  int get subtotal =>
      _items.fold<int>(0, (runningTotal, item) {
        return runningTotal + item.subtotal;
      });

  bool get isLoading => _isLoading;

  String? get lastError => _lastError;

  bool contains(Product product, int size) {
    return _items.any(
      (item) =>
          item.product.name == product.name &&
          item.size == size,
    );
  }

  // =========================================================
  // LOAD CART DARI FIRESTORE
  // =========================================================

  Future<void> loadFromFirebase({
    bool forceRefresh = false,
  }) async {
    final user = AuthController.firebaseUser;

    if (user == null || !user.emailVerified) {
      resetForSignedOut();

      if (user != null && !user.emailVerified) {
        _lastError = 'Verifikasi email terlebih dahulu.';
        notifyListeners();
      }

      return;
    }

    if (_isLoading) return;

    if (!forceRefresh &&
        _hasLoaded &&
        _loadedUid == user.uid) {
      return;
    }

    if (_loadedUid != user.uid) {
      _generation++;
      _items.clear();
      _hasLoaded = false;
    }

    _loadedUid = user.uid;
    final loadGeneration = _generation;

    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final snapshot = await _db
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc('state')
          .get();

      if (_generation != loadGeneration ||
          AuthController.currentUid != user.uid) {
        return;
      }

      final restoredItems = <CartItem>[];
      final data = snapshot.data();
      final rawItems = data?['items'];

      if (rawItems is List) {
        for (final rawItem in rawItems) {
          if (rawItem is! Map) continue;

          final itemData =
              Map<String, dynamic>.from(rawItem);

          final productName = itemData['productName'];

          if (productName is! String) continue;

          Product? matchedProduct;

          for (final product in ProductController.products) {
            if (product.name == productName) {
              matchedProduct = product;
              break;
            }
          }

          // Produk yang sudah tidak tersedia di katalog
          // tidak dimasukkan kembali ke keranjang.
          if (matchedProduct == null) continue;

          final size = _toInt(itemData['size']);
          final quantity = _toInt(itemData['quantity']);

          if (!matchedProduct.sizes.contains(size) ||
              quantity < 1) {
            continue;
          }

          final existingIndex = restoredItems.indexWhere(
            (item) =>
                item.product.name == matchedProduct!.name &&
                item.size == size,
          );

          if (existingIndex == -1) {
            restoredItems.add(
              CartItem(
                product: matchedProduct,
                size: size,
                quantity: quantity,
              ),
            );
          } else {
            restoredItems[existingIndex].quantity += quantity;
          }
        }
      }

      if (_generation != loadGeneration ||
          AuthController.currentUid != user.uid) {
        return;
      }

      _items
        ..clear()
        ..addAll(restoredItems);

      _hasLoaded = true;
      _lastError = null;
    } on FirebaseException catch (e) {
      if (_generation != loadGeneration) return;

      _hasLoaded = false;

      if (e.code == 'permission-denied') {
        _lastError =
            'Akses keranjang ditolak Firestore Rules.';
      } else {
        _lastError =
            'Gagal memuat keranjang (${e.code}).';
      }
    } catch (_) {
      if (_generation != loadGeneration) return;

      _hasLoaded = false;
      _lastError = 'Terjadi kesalahan saat memuat keranjang.';
    } finally {
      if (_generation == loadGeneration) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // =========================================================
  // ADD ITEM
  // =========================================================

  void add(Product product, int size, [int quantity = 1]) {
    if (quantity < 1 || !product.sizes.contains(size)) return;

    final index = _items.indexWhere(
      (item) =>
          item.product.name == product.name &&
          item.size == size,
    );

    if (index == -1) {
      _items.add(
        CartItem(
          product: product,
          size: size,
          quantity: quantity,
        ),
      );
    } else {
      _items[index].quantity += quantity;
    }

    _changed();
  }

  // =========================================================
  // INCREMENT
  // =========================================================

  void increment(CartItem item) {
    if (!_items.contains(item)) return;

    item.quantity++;
    _changed();
  }

  // =========================================================
  // DECREMENT
  // =========================================================

  void decrement(CartItem item) {
    if (!_items.contains(item)) return;

    if (item.quantity <= 1) {
      _items.remove(item);
    } else {
      item.quantity--;
    }

    _changed();
  }

  // =========================================================
  // REMOVE ITEM
  // =========================================================

  void remove(CartItem item) {
    final removed = _items.remove(item);

    if (removed) {
      _changed();
    }
  }

  // =========================================================
  // SNAPSHOT
  // =========================================================

  List<CartItem> snapshot() {
    return _items
        .map(
          (item) => CartItem(
            product: item.product,
            size: item.size,
            quantity: item.quantity,
          ),
        )
        .toList();
  }

  // =========================================================
  // CLEAR CART
  // =========================================================

  void clear() {
    if (_items.isEmpty) return;

    _items.clear();
    _changed();
  }

  // =========================================================
  // LOCAL STATE CHANGE + AUTO SAVE
  // =========================================================

  void _changed() {
    notifyListeners();
    _scheduleSave();
  }

  void _scheduleSave() {
    final user = AuthController.firebaseUser;
    final uid = _loadedUid;

    // Jangan menimpa cart Firestore kalau data akun belum
    // berhasil dimuat atau belum ada sesi terverifikasi.
    if (user == null ||
        !user.emailVerified ||
        uid == null ||
        uid != user.uid ||
        !_hasLoaded) {
      return;
    }

    final generation = _generation;

    final payload = _items
        .map(
          (item) => <String, dynamic>{
            'productName': item.product.name,
            'size': item.size,
            'quantity': item.quantity,
          },
        )
        .toList();

    // Penulisan dilakukan berurutan agar snapshot lama tidak
    // menimpa snapshot yang lebih baru.
    _pendingWrite = _pendingWrite.then((_) async {
      if (_generation != generation ||
          _loadedUid != uid ||
          AuthController.currentUid != uid) {
        return;
      }

      try {
        await _db
            .collection('users')
            .doc(uid)
            .collection('cart')
            .doc('state')
            .set({
          'uid': uid,
          'items': payload,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } on FirebaseException catch (e) {
        if (_generation == generation &&
            _loadedUid == uid) {
          _lastError = 'Gagal menyimpan keranjang (${e.code}).';
          notifyListeners();
        }
      } catch (_) {
        if (_generation == generation &&
            _loadedUid == uid) {
          _lastError = 'Gagal menyimpan keranjang.';
          notifyListeners();
        }
      }
    });
  }

  // =========================================================
  // RESET STATE SAAT LOGOUT / GANTI AKUN
  // =========================================================

  void resetForSignedOut() {
    _generation++;

    _items.clear();
    _loadedUid = null;
    _lastError = null;
    _isLoading = false;
    _hasLoaded = false;

    notifyListeners();
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
