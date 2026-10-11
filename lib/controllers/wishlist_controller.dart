
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'auth_controller.dart';
import 'product_controller.dart';
import '../models/product.dart';

class WishlistController extends ChangeNotifier {
  WishlistController._();

  static final WishlistController instance =
      WishlistController._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Set<String> _names = <String>{};

  String? _loadedUid;
  String? _lastError;

  bool _isLoading = false;
  bool _hasLoaded = false;
  int _generation = 0;

  Future<void> _pendingWrite = Future<void>.value();

  bool contains(Product product) {
    return _names.contains(product.name);
  }

  int get count => _names.length;

  bool get isLoading => _isLoading;

  String? get lastError => _lastError;

  List<Product> get products => ProductController.products
      .where((product) => _names.contains(product.name))
      .toList(growable: false);

  // =========================================================
  // LOAD WISHLIST DARI FIRESTORE
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
      _names.clear();
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
          .collection('wishlist')
          .doc('state')
          .get();

      if (_generation != loadGeneration ||
          AuthController.currentUid != user.uid) {
        return;
      }

      final rawNames = snapshot.data()?['productNames'];
      final knownNames = ProductController.products
          .map((product) => product.name)
          .toSet();

      final restoredNames = <String>{};

      if (rawNames is List) {
        for (final rawName in rawNames) {
          if (rawName is String &&
              knownNames.contains(rawName)) {
            restoredNames.add(rawName);
          }
        }
      }

      if (_generation != loadGeneration ||
          AuthController.currentUid != user.uid) {
        return;
      }

      _names
        ..clear()
        ..addAll(restoredNames);

      _hasLoaded = true;
      _lastError = null;
    } on FirebaseException catch (e) {
      if (_generation != loadGeneration) return;

      _hasLoaded = false;

      if (e.code == 'permission-denied') {
        _lastError =
            'Akses wishlist ditolak Firestore Rules.';
      } else {
        _lastError = 'Gagal memuat wishlist (${e.code}).';
      }
    } catch (_) {
      if (_generation != loadGeneration) return;

      _hasLoaded = false;
      _lastError = 'Terjadi kesalahan saat memuat wishlist.';
    } finally {
      if (_generation == loadGeneration) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // =========================================================
  // TOGGLE PRODUCT
  // =========================================================

  void toggle(Product product) {
    if (_names.contains(product.name)) {
      _names.remove(product.name);
    } else {
      _names.add(product.name);
    }

    _changed();
  }

  // =========================================================
  // STATE CHANGE + AUTO SAVE
  // =========================================================

  void _changed() {
    notifyListeners();
    _scheduleSave();
  }

  void _scheduleSave() {
    final user = AuthController.firebaseUser;
    final uid = _loadedUid;

    if (user == null ||
        !user.emailVerified ||
        uid == null ||
        uid != user.uid ||
        !_hasLoaded) {
      return;
    }

    final generation = _generation;
    final names = _names.toList()..sort();

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
            .collection('wishlist')
            .doc('state')
            .set({
          'uid': uid,
          'productNames': names,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } on FirebaseException catch (e) {
        if (_generation == generation &&
            _loadedUid == uid) {
          _lastError = 'Gagal menyimpan wishlist (${e.code}).';
          notifyListeners();
        }
      } catch (_) {
        if (_generation == generation &&
            _loadedUid == uid) {
          _lastError = 'Gagal menyimpan wishlist.';
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

    _names.clear();
    _loadedUid = null;
    _lastError = null;
    _isLoading = false;
    _hasLoaded = false;

    notifyListeners();
  }
}
