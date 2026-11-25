import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../controllers/product_controller.dart';
import '../models/admin_models.dart';
import '../models/product.dart';

class AdminService {
  AdminService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Admin = punya dokumen di koleksi `admins` dengan ID = UID.
  static Future<bool> isAdmin() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    try {
      final doc = await _db.collection('admins').doc(uid).get();
      return doc.exists;
    } catch (_) {
      return false;
    }
  }

  // ---------- PESANAN ----------

  /// Semua pesanan dari semua user (users/{uid}/orders).
  /// Diurutkan di sisi klien supaya tidak butuh index tambahan.
  static Stream<List<AdminOrder>> ordersStream() {
    return _db.collectionGroup('orders').snapshots().map((snap) {
      final list = snap.docs.map(AdminOrder.fromDoc).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  static Future<void> updateOrderStatus(AdminOrder order, String status) {
    return order.ref.update({'status': status});
  }

  // ---------- PRODUK ----------

  static Stream<List<AdminProduct>> productsStream() {
    return _db.collection('products').snapshots().map((snap) {
      final list = snap.docs.map(AdminProduct.fromDoc).toList();
      list.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
      return list;
    });
  }

  static Future<void> saveProduct(AdminProduct p) async {
    final col = _db.collection('products');
    if (p.id.isEmpty) {
      await col.add({
        ...p.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await col.doc(p.id).set(p.toMap(), SetOptions(merge: true));
    }
    _refreshStore();
  }

  static Future<void> deleteProduct(String id) async {
    await _db.collection('products').doc(id).delete();
    _refreshStore();
  }

  /// Isi awal koleksi `products` dari DummyJSON (sekali jalan).
  static Future<int> importFromDummyJson() async {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://dummyjson.com',
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
      ),
    );

    final responses = await Future.wait([
      dio.get('/products/category/mens-shoes'),
      dio.get('/products/category/womens-shoes'),
    ]);

    final raws = responses
        .expand((r) => (r.data['products'] as List))
        .cast<Map<String, dynamic>>()
        .toList();

    final batch = _db.batch();
    for (final raw in raws) {
      final p = Product.fromDummyJson(raw);
      final stock = (raw['stock'] as num?)?.toInt() ?? 20;
      batch.set(_db.collection('products').doc(_slug(p.name)), {
        'name': p.name,
        'category': p.category,
        'price': p.price,
        'stock': stock,
        'imageUrl': p.imageUrl,
        'images': p.images,
        'description': p.description,
        'sizes': p.sizes,
        'rating': p.rating,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    _refreshStore();
    return raws.length;
  }

  /// Menyalin katalog yang sedang tampil di toko ke koleksi `products`,
  /// supaya panel admin dan toko memakai data yang sama. Urutan toko dijaga
  /// lewat field `sortIndex`.
  static Future<int> importStoreCatalog(List<Product> products) async {
    const chunk = 400; // batas Firestore: 500 operasi per batch
    for (var start = 0; start < products.length; start += chunk) {
      final end =
          start + chunk < products.length ? start + chunk : products.length;
      final batch = _db.batch();
      for (var i = start; i < end; i++) {
        final p = products[i];
        batch.set(_db.collection('products').doc(_slug(p.name)), {
          'name': p.name,
          'category': p.category,
          'price': p.price,
          'stock': 20,
          'imageUrl': p.imageUrl,
          'images': p.images,
          'description': p.description,
          'sizes': p.sizes,
          'rating': p.rating,
          'sortIndex': i,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    }
    _refreshStore();
    return products.length;
  }

  /// Muat ulang katalog toko agar perubahan dari admin langsung terlihat
  /// (tanpa harus menutup aplikasi).
  static void _refreshStore() {
    unawaited(ProductController.load());
  }

  static String _slug(String s) {
    final slug = s
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return slug.isEmpty
        ? 'produk-${DateTime.now().microsecondsSinceEpoch}'
        : slug;
  }
}