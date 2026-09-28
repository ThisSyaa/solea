// ============================================================
// PRODUCT DATA
// ============================================================

class Product {
  final String name; 
  final String category;
  final String price;
  final String imageUrl;
  final double rating;

  const Product({
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.rating,
  });
}
