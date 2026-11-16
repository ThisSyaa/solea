import 'package:dio/dio.dart';

import '../models/product.dart';

class ProductService {
  ProductService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'https://dummyjson.com',
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
            headers: {'Accept': 'application/json'},
          ),
        );

  final Dio _dio;

  /// Mengambil sepatu pria dan wanita dari DummyJSON, lalu digabung.
  Future<List<Product>> fetchProducts() async {
    try {
      final responses = await Future.wait([
        _dio.get('/products/category/mens-shoes'),
        _dio.get('/products/category/womens-shoes'),
      ]);

      return responses
          .expand((res) => (res.data['products'] as List))
          .map((e) => Product.fromDummyJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Gagal memuat produk: ${e.message}');
    }
  }
}