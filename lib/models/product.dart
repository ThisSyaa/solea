// ============================================================
// PRODUCT DATA
// ============================================================

class Product {
  final String name;
  final String category;
  final int price;
  final String imageUrl;
  final double rating;
  final String description;
  final List<int> sizes;

  const Product({
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.rating,
    this.description =
        'Sepatu nyaman dengan desain modern untuk menemani aktivitas sehari-hari.',
    this.sizes = const [39, 40, 41, 42, 43],
  });
}
