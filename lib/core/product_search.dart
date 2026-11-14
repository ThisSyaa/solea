import '../controllers/product_controller.dart';
import '../models/product.dart';

/// Logika pencarian produk (dipakai kolom search dan halaman hasil).
class ProductSearch {
  ProductSearch._();

  static List<String> _tokens(String query) {
    return query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toList();
  }

  /// Hasil pencarian. Setiap kata yang diketik harus ditemukan di nama,
  /// kategori, atau deskripsi produk. Kecocokan di nama diurutkan paling atas.
  static List<Product> search(String query) {
    final tokens = _tokens(query);
    if (tokens.isEmpty) return const [];

    final matches = <(Product, int, int)>[];
    final products = ProductController.products;

    for (var i = 0; i < products.length; i++) {
      final product = products[i];
      final name = product.name.toLowerCase();
      final category = product.category.toLowerCase();
      final description = product.description.toLowerCase();

      var score = 0;
      var matched = true;

      for (final token in tokens) {
        if (name.contains(token)) {
          score += 3;
        } else if (category.contains(token)) {
          score += 2;
        } else if (description.contains(token)) {
          score += 1;
        } else {
          matched = false;
          break;
        }
      }

      if (matched) matches.add((product, score, i));
    }

    matches.sort((a, b) {
      final byScore = b.$2.compareTo(a.$2);
      return byScore != 0 ? byScore : a.$3.compareTo(b.$3);
    });

    return matches.map((m) => m.$1).toList();
  }

  /// Rekomendasi kata pencarian saat pengguna mengetik
  /// (nama kategori dan nama produk yang cocok).
  static List<String> suggestions(String query, {int limit = 8}) {
    final tokens = _tokens(query);
    if (tokens.isEmpty) return const [];

    final typed = query.trim().toLowerCase();
    final seen = <String>{};
    final startsWith = <String>[];
    final contains = <String>[];

    void consider(String candidate) {
      final lower = candidate.toLowerCase();

      if (lower == typed) return;
      if (!tokens.every((token) => lower.contains(token))) return;
      if (!seen.add(lower)) return;

      (lower.startsWith(typed) ? startsWith : contains).add(candidate);
    }

    for (final category in ProductController.categories) {
      if (category != 'Semua') consider(category);
    }

    for (final product in ProductController.products) {
      consider(product.name);
    }

    return [...startsWith, ...contains].take(limit).toList();
  }
}
