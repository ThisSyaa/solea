import '../models/product.dart';

class ProductController {
  static const categories = [
    'Semua',
    'Running',
    'Lifestyle',
    'Basketball',
    'Casual',
    'Outdoor',
    'Training',
  ];

  static const products = <Product>[
    Product(
      name: 'Air Runner Pro',
      category: 'Running',
      price: 1299000,
      rating: 4.9,
      imageUrl:
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=900&q=85',
      description:
          'Sneakers ringan untuk aktivitas harian dan lari ringan dengan bantalan nyaman.',
    ),
    Product(
      name: 'Street Classic',
      category: 'Lifestyle',
      price: 899000,
      rating: 4.8,
      imageUrl:
          'https://images.unsplash.com/photo-1549298916-b41d501d3772?auto=format&fit=crop&w=900&q=85',
      description:
          'Gaya klasik yang gampang dipadukan dengan outfit casual maupun streetwear.',
    ),
    Product(
      name: 'Court Vision',
      category: 'Basketball',
      price: 1049000,
      rating: 4.7,
      imageUrl:
          'https://images.unsplash.com/photo-1552346154-21d32810aba3?auto=format&fit=crop&w=900&q=85',
      description:
          'Midsole responsif dan upper yang stabil untuk permainan dan aktivitas indoor.',
    ),
    Product(
      name: 'Urban White',
      category: 'Casual',
      price: 749000,
      rating: 4.8,
      imageUrl:
          'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?auto=format&fit=crop&w=900&q=85',
      description:
          'Sneaker putih clean untuk gaya minimalis sehari-hari.',
    ),
    Product(
      name: 'Trail Max',
      category: 'Outdoor',
      price: 1499000,
      rating: 4.9,
      imageUrl:
          'https://images.unsplash.com/photo-1518002171953-a080ee817e1f?auto=format&fit=crop&w=900&q=85',
      description:
          'Outsole bergrip untuk jalan outdoor dan medan yang lebih menantang.',
    ),
    Product(
      name: 'Daily Flex',
      category: 'Training',
      price: 999000,
      rating: 4.6,
      imageUrl:
          'https://images.unsplash.com/photo-1520256862855-398228c41684?auto=format&fit=crop&w=900&q=85',
      description:
          'Sepatu training fleksibel untuk gym, workout, dan aktivitas ringan.',
    ),
    Product(
      name: 'Daily Flex 2',
      category: 'Training',
      price: 1059000,
      rating: 4.7,
      imageUrl:
          'https://images.unsplash.com/photo-1554138390-1f2c0d18b3b1?auto=format&fit=crop&w=900&q=85',
      description:
          'Versi terbaru Daily Flex dengan feel lebih empuk dan stabil.',
    ),
    Product(
      name: 'Daily Flex 3',
      category: 'Training',
      price: 1129000,
      rating: 4.8,
      imageUrl:
          'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?auto=format&fit=crop&w=900&q=85',
      description:
          'Model training modern dengan upper breathable dan fit nyaman.',
    ),
  ];

  static List<Product> byCategory(String category) {
    if (category == 'Semua') return products;
    return products.where((p) => p.category == category).toList();
  }
}
