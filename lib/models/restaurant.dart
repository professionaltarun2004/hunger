class Restaurant {
  final int id;
  final String name;
  final String imageUrl;
  final double rating;
  final String offer;
  final int etaMinutes;
  final bool isHomeChef;

  Restaurant({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.offer,
    required this.etaMinutes,
    required this.isHomeChef,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'],
      rating: (json['rating'] as num).toDouble(),
      offer: json['offer'] ?? '',
      etaMinutes: json['eta_minutes'],
      isHomeChef: json['is_home_chef'] ?? false,
    );
  }
}