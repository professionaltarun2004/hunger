class MenuItem {
  final int id;
  final String name;
  final String imageUrl;
  final double price;
  final int calories;
  final int restaurantId;
  final String restaurantName;
  final double rating;
  final int categoryId;
  final bool isVegetarian;
  final bool isPopular;
  final String description;

  MenuItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.calories,
    required this.restaurantId,
    this.restaurantName = '',
    this.rating = 0.0,
    this.categoryId = 0,
    this.isVegetarian = false,
    this.isPopular = false,
    this.description = '',
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'] ?? '',
      price: (json['price'] as num).toDouble(),
      calories: json['calories'] ?? 0,
      restaurantId: json['restaurant_id'],
      restaurantName: json['restaurant_name'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      categoryId: json['category_id'] ?? 0,
      isVegetarian: json['is_vegetarian'] ?? false,
      isPopular: json['is_popular'] ?? false,
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'price': price,
      'calories': calories,
      'restaurant_id': restaurantId,
      'restaurant_name': restaurantName,
      'rating': rating,
      'category_id': categoryId,
      'is_vegetarian': isVegetarian,
      'is_popular': isPopular,
      'description': description,
    };
  }
}