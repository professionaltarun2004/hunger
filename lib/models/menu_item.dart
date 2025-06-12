class MenuItem {
  final int id;
  final String name;
  final String imageUrl;
  final double price;
  final int calories;
  final int restaurantId;

  MenuItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.calories,
    required this.restaurantId,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'],
      price: (json['price'] as num).toDouble(),
      calories: json['calories'],
      restaurantId: json['restaurant_id'],
    );
  }
}