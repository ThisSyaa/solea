
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/foundation.dart';

import 'auth_controller.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/product.dart';

class OrderController extends ChangeNotifier {
  OrderController._();

  static final OrderController instance = OrderController._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<Order> _orders = [];

  String? _loadedUid;
  String? _lastError;

  bool _isLoading = false;
  bool _hasLoaded = false;

  List<Order> get orders {
    if (_loadedUid == null ||
        _loadedUid != AuthController.currentUid) {
      return const <Order>[];
    }

    return List<Order>.unmodifiable(_orders);
  }

  bool get isLoading => _isLoading;

  String? get lastError => _lastError;

  // =========================================================
  // MEMUAT PESANAN DARI FIRESTORE
  // =========================================================

  Future<void> loadOrders({
    bool forceRefresh = false,
  }) async {
    final user = AuthController.firebaseUser;

    if (user == null) {
      _orders.clear();
      _loadedUid = null;
      _hasLoaded = false;
      _isLoading = false;
      _lastError = 'Silakan login untuk melihat pesanan.';
      notifyListeners();
      return;
    }

    if (!user.emailVerified) {
      _orders.clear();
      _loadedUid = null;
      _hasLoaded = false;
      _isLoading = false;
      _lastError = 'Verifikasi email terlebih dahulu.';
      notifyListeners();
      return;
    }

    if (_isLoading) return;

    if (!forceRefresh &&
        _hasLoaded &&
        _loadedUid == user.uid) {
      return;
    }

    if (_loadedUid != user.uid) {
      _orders.clear();
    }

    _loadedUid = user.uid;
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final snapshot = await _db
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();

      // Hindari menampilkan data akun lama ketika sesi berubah.
      if (AuthController.currentUid != user.uid) {
        _orders.clear();
        _loadedUid = null;
        _hasLoaded = false;
        return;
      }

      final loadedOrders = snapshot.docs
          .map(_orderFromDocument)
          .toList();

      _orders
        ..clear()
        ..addAll(loadedOrders);

      _hasLoaded = true;
      _lastError = null;
    } on FirebaseException catch (e) {
      _hasLoaded = false;

      if (e.code == 'permission-denied') {
        _lastError =
            'Akses pesanan ditolak. Periksa Firestore Rules.';
      } else if (e.code == 'unavailable') {
        _lastError =
            'Firestore tidak tersedia. Periksa koneksi internet.';
      } else {
        _lastError = 'Gagal memuat pesanan (${e.code}).';
      }
    } catch (_) {
      _hasLoaded = false;
      _lastError = 'Terjadi kesalahan saat memuat pesanan.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================================================
  // MEMBUAT PESANAN
  // =========================================================

  Future<String?> createOrder({
    required List<CartItem> items,
    required int shippingCost,
    required String customerName,
    required String phone,
    required String address,
    required String paymentMethod,
  }) async {
    final user = AuthController.firebaseUser;

    if (user == null) {
      return 'Sesi login tidak ditemukan. Silakan login kembali.';
    }

    if (!user.emailVerified) {
      return 'Verifikasi email terlebih dahulu.';
    }

    if (items.isEmpty) {
      return 'Keranjang kamu masih kosong.';
    }

    if (items.length > 30) {
      return 'Jumlah jenis produk dalam pesanan terlalu banyak.';
    }

    final cleanName = customerName.trim();
    final cleanPhone = phone.trim();
    final cleanAddress = address.trim();

    if (cleanName.length < 3) {
      return 'Nama penerima minimal 3 karakter.';
    }

    final phoneDigits =
        cleanPhone.replaceAll(RegExp(r'\D'), '');

    if (phoneDigits.length < 8) {
      return 'Nomor HP belum valid.';
    }

    if (cleanAddress.length < 10) {
      return 'Alamat lengkap minimal 10 karakter.';
    }

    if (shippingCost < 0) {
      return 'Biaya pengiriman tidak valid.';
    }

    if (!['Transfer Bank', 'E-Wallet']
        .contains(paymentMethod)) {
      return 'Metode pembayaran tidak valid.';
    }

    for (final item in items) {
      if (item.quantity < 1 ||
          item.product.price < 0 ||
          item.size < 1) {
        return 'Data produk dalam keranjang tidak valid.';
      }
    }

    // Buat salinan item agar tidak terpengaruh perubahan cart.
    final orderItems = items
        .map(
          (item) => CartItem(
            product: item.product,
            size: item.size,
            quantity: item.quantity,
          ),
        )
        .toList();

    final subtotal = orderItems.fold<int>(
      0,
      (sum, item) => sum + item.subtotal,
    );

    final total = subtotal + shippingCost;
    final now = DateTime.now();
    final orderId = 'SL-${now.microsecondsSinceEpoch}';

    final orderRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('orders')
        .doc(orderId);

    try {
      await orderRef.set({
        'id': orderId,
        'uid': user.uid,
        'items': orderItems.map((item) {
          final product = item.product;

          return {
            'product': {
              'name': product.name,
              'category': product.category,
              'price': product.price,
              'imageUrl': product.imageUrl,
              'rating': product.rating,
              'description': product.description,
              'sizes': product.sizes,
            },
            'size': item.size,
            'quantity': item.quantity,
            'subtotal': item.subtotal,
          };
        }).toList(),
        'subtotal': subtotal,
        'shippingCost': shippingCost,
        'total': total,
        'customerName': cleanName,
        'phone': cleanPhone,
        'address': cleanAddress,
        'paymentMethod': paymentMethod,
        'status': 'Diproses',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Tambahkan ke cache setelah Firestore berhasil menyimpan.
      if (AuthController.currentUid == user.uid) {
        if (_loadedUid != user.uid) {
          _orders.clear();
          _loadedUid = user.uid;
        }

        _orders.removeWhere(
          (order) => order.id == orderId,
        );

        _orders.insert(
          0,
          Order(
            id: orderId,
            createdAt: now,
            items: orderItems,
            shippingCost: shippingCost,
            total: total,
            customerName: cleanName,
            phone: cleanPhone,
            address: cleanAddress,
            paymentMethod: paymentMethod,
            status: 'Diproses',
          ),
        );

        _hasLoaded = true;
        _lastError = null;

        notifyListeners();
      }

      return null;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return 'Pesanan ditolak Firestore Rules. '
            'Periksa aturan koleksi orders.';
      }

      if (e.code == 'unavailable') {
        return 'Koneksi ke Firestore terputus. Coba lagi.';
      }

      return 'Gagal menyimpan pesanan (${e.code}).';
    } catch (_) {
      return 'Terjadi kesalahan saat menyimpan pesanan.';
    }
  }

  // =========================================================
  // KONVERSI DATA FIRESTORE KE MODEL ORDER
  // =========================================================

  Order _orderFromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    final rawCreatedAt = data['createdAt'];

    final DateTime createdAt;

    if (rawCreatedAt is Timestamp) {
      createdAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is DateTime) {
      createdAt = rawCreatedAt;
    } else {
      createdAt = DateTime.now();
    }

    final rawItems = data['items'];
    final items = <CartItem>[];

    if (rawItems is List) {
      for (final rawItem in rawItems) {
        if (rawItem is! Map) continue;

        final itemData =
            Map<String, dynamic>.from(rawItem);

        final rawProduct = itemData['product'];

        if (rawProduct is! Map) continue;

        final productData =
            Map<String, dynamic>.from(rawProduct);

        final rawSizes = productData['sizes'];

        final sizes = rawSizes is List
            ? rawSizes
                .whereType<num>()
                .map((size) => size.toInt())
                .toList()
            : <int>[39, 40, 41, 42, 43];

        final quantity = _toInt(
          itemData['quantity'],
          fallback: 1,
        );

        if (quantity < 1) continue;

        final product = Product(
          name: productData['name']?.toString() ?? '',
          category:
              productData['category']?.toString() ?? '',
          price: _toInt(productData['price']),
          imageUrl:
              productData['imageUrl']?.toString() ?? '',
          rating: _toDouble(productData['rating']),
          description:
              productData['description']?.toString() ?? '',
          sizes: sizes,
        );

        items.add(
          CartItem(
            product: product,
            size: _toInt(
              itemData['size'],
              fallback: 39,
            ),
            quantity: quantity,
          ),
        );
      }
    }

    return Order(
      id: data['id']?.toString() ?? document.id,
      createdAt: createdAt,
      items: items,
      shippingCost: _toInt(data['shippingCost']),
      total: _toInt(data['total']),
      customerName:
          data['customerName']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      address: data['address']?.toString() ?? '',
      paymentMethod:
          data['paymentMethod']?.toString() ?? '',
      status: data['status']?.toString() ?? 'Diproses',
    );
  }

  int _toInt(
    dynamic value, {
    int fallback = 0,
  }) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ??
        fallback;
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
