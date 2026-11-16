import 'package:cloud_firestore/cloud_firestore.dart';

int _int(dynamic v, [int fallback = 0]) =>
    v is num ? v.toInt() : (int.tryParse('$v') ?? fallback);

class AdminProduct {
  final String id;
  final String name;
  final String category;
  final int price;
  final int stock;
  final String imageUrl;
  final String description;
  final List<int> sizes;
  final double rating;

  const AdminProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.description,
    required this.sizes,
    this.rating = 0,
  });

  factory AdminProduct.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? <String, dynamic>{};
    final rawSizes = d['sizes'];
    return AdminProduct(
      id: doc.id,
      name: d['name']?.toString() ?? '',
      category: d['category']?.toString() ?? '',
      price: _int(d['price']),
      stock: _int(d['stock']),
      imageUrl: d['imageUrl']?.toString() ?? '',
      description: d['description']?.toString() ?? '',
      sizes: rawSizes is List
          ? rawSizes.whereType<num>().map((e) => e.toInt()).toList()
          : <int>[],
      rating: d['rating'] is num ? (d['rating'] as num).toDouble() : 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'category': category,
        'price': price,
        'stock': stock,
        'imageUrl': imageUrl,
        'description': description,
        'sizes': sizes,
        'rating': rating,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}

class AdminOrderItem {
  final String name;
  final String category;
  final String imageUrl;
  final int size;
  final int quantity;
  final int price;

  const AdminOrderItem({
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.size,
    required this.quantity,
    required this.price,
  });

  int get subtotal => price * quantity;

  factory AdminOrderItem.fromMap(Map<String, dynamic> m) {
    final p = m['product'] is Map
        ? Map<String, dynamic>.from(m['product'] as Map)
        : <String, dynamic>{};
    return AdminOrderItem(
      name: p['name']?.toString() ?? '-',
      category: p['category']?.toString() ?? '',
      imageUrl: p['imageUrl']?.toString() ?? '',
      size: _int(m['size']),
      quantity: _int(m['quantity'], 1),
      price: _int(p['price']),
    );
  }
}

class AdminOrder {
  final DocumentReference<Map<String, dynamic>> ref;
  final String id;
  final String customerName;
  final String phone;
  final String address;
  final String paymentMethod;
  final String status;
  final int total;
  final int shippingCost;
  final DateTime createdAt;
  final List<AdminOrderItem> items;

  const AdminOrder({
    required this.ref,
    required this.id,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.paymentMethod,
    required this.status,
    required this.total,
    required this.shippingCost,
    required this.createdAt,
    required this.items,
  });

  /// UID pemilik pesanan (dari path users/{uid}/orders/{id}).
  String get uid => ref.parent.parent?.id ?? '';

  factory AdminOrder.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    final rawDate = d['createdAt'];
    final items = <AdminOrderItem>[];
    final rawItems = d['items'];
    if (rawItems is List) {
      for (final r in rawItems) {
        if (r is Map) {
          items.add(AdminOrderItem.fromMap(Map<String, dynamic>.from(r)));
        }
      }
    }
    return AdminOrder(
      ref: doc.reference,
      id: d['id']?.toString() ?? doc.id,
      customerName: d['customerName']?.toString() ?? '-',
      phone: d['phone']?.toString() ?? '-',
      address: d['address']?.toString() ?? '-',
      paymentMethod: d['paymentMethod']?.toString() ?? '-',
      status: d['status']?.toString() ?? 'Diproses',
      total: _int(d['total']),
      shippingCost: _int(d['shippingCost']),
      createdAt: rawDate is Timestamp ? rawDate.toDate() : DateTime.now(),
      items: items,
    );
  }
}