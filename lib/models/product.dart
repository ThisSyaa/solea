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
  final List<String> images; // gambar tambahan untuk halaman detail

  const Product({
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.rating,
    this.description =
        'Sepatu nyaman dengan desain modern untuk menemani aktivitas sehari-hari.',
    this.sizes = const [39, 40, 41, 42, 43],
    this.images = const [],
  });

  /// Mengubah JSON dari DummyJSON (https://dummyjson.com) menjadi Product.
  factory Product.fromDummyJson(Map<String, dynamic> json) {
    final title = (json['title'] ?? 'Sepatu') as String;
    final thumbnail = (json['thumbnail'] ?? '') as String;
    final imageList = ((json['images'] as List?) ?? const [])
        .map((e) => e.toString())
        .toList();

    return Product(
      name: title,
      category: _guessCategory(title),
      // Harga di DummyJSON dalam USD, dikonversi kasar ke Rupiah.
      price: (((json['price'] as num?) ?? 0) * _usdToIdr).round(),
      imageUrl: thumbnail.isNotEmpty
          ? thumbnail
          : (imageList.isNotEmpty ? imageList.first : ''),
      rating: ((json['rating'] as num?) ?? 0).toDouble(),
      description: (json['description'] ??
          'Sepatu nyaman dengan desain modern untuk menemani aktivitas sehari-hari.') as String,
      images: imageList,
    );
  }

  static const int _usdToIdr = 16000;

  /// DummyJSON tidak punya kategori seperti di Solea,
  /// jadi ditebak dari kata kunci pada nama produk.
  static String _guessCategory(String title) {
    final t = title.toLowerCase();
    if (t.contains('run') || t.contains('sport')) return 'Running';
    if (t.contains('basket') || t.contains('jordan')) return 'Basketball';
    if (t.contains('trail') || t.contains('boot') || t.contains('cleat')) {
      return 'Outdoor';
    }
    if (t.contains('train') || t.contains('gym')) return 'Training';
    if (t.contains('slipper') || t.contains('sandal') || t.contains('white')) {
      return 'Casual';
    }
    return 'Lifestyle';
  }
}