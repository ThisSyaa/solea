class Product {
  String _name;
  String _category;
  String _price;
  String _imageUrl;
  double _rating;

  Product({
    required String name,
    required String category,
    required String price,
    required String imageUrl,
    required double rating,
  })  : _name = name,
        _category = category,
        _price = price,
        _imageUrl = imageUrl,
        _rating = rating;

  // Getter
  String get name => _name;
  String get category => _category;
  String get price => _price;
  String get imageUrl => _imageUrl;
  double get rating => _rating;

  // Setter
  set name(String value) => _name = value;
  set category(String value) => _category = value;
  set price(String value) => _price = value;
  set imageUrl(String value) => _imageUrl = value;
  set rating(double value) => _rating = value;
}