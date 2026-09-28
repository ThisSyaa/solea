import '../models/product.dart';

class ProductController {
  static const List<String> categories = [
    'Semua',
    'Running',
    'Lifestyle',
    'Basketball',
    'Casual',
    'Outdoor',
    'Training',
  ];

  static const List<Product> products = [
    Product(
      name: 'Air Runner Pro',
      category: 'Running',
      price: 'Rp 1.299.000',
      rating: 4.9,
      imageUrl:
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=900&q=85',
    ),
    Product(
      name: 'Street Classic',
      category: 'Lifestyle',
      price: 'Rp 899.000',
      rating: 4.8,
      imageUrl:
          'https://images.unsplash.com/photo-1549298916-b41d501d3772?auto=format&fit=crop&w=900&q=85',
    ),
    Product(
      name: 'Court Vision',
      category: 'Basketball',
      price: 'Rp 1.049.000',
      rating: 4.7,
      imageUrl:
          'https://images.unsplash.com/photo-1552346154-21d32810aba3?auto=format&fit=crop&w=900&q=85',
    ),
    Product(
      name: 'Urban White',
      category: 'Casual',
      price: 'Rp 749.000',
      rating: 4.8,
      imageUrl:
          'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?auto=format&fit=crop&w=900&q=85',
    ),
    Product(
      name: 'Trail Max',
      category: 'Outdoor',
      price: 'Rp 1.499.000',
      rating: 4.9,
      imageUrl:
          'https://images.unsplash.com/photo-1518002171953-a080ee817e1f?auto=format&fit=crop&w=900&q=85',
    ),
    Product(
      name: 'Daily Flex',
      category: 'Training',
      price: 'Rp 999.000',
      rating: 4.6,
      imageUrl:
          'https://images.unsplash.com/photo-1520256862855-398228c41684?auto=format&fit=crop&w=900&q=85',
    ),
    Product(
      name: 'Daily Flex 2',
      category: 'Training',
      price: 'Rp 999.000',
      rating: 4.6,
      imageUrl:
          'https://images.unsplash.com/photo-1520256862855-398228c41684?auto=format&fit=crop&w=900&q=85',
    ),
    Product(
      name: 'Daily Flex 3',
      category: 'Training',
      price: 'Rp 999.000',
      rating: 4.6,
      imageUrl:
          'https://images.unsplash.com/photo-1520256862855-398228c41684?auto=format&fit=crop&w=900&q=85',
    ),
  ];
}
