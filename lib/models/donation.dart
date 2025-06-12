class Donation {
  final int id;
  final String userId;
  final int restaurantId;
  final String description;
  final DateTime createdAt;

  Donation({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.description,
    required this.createdAt,
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'],
      userId: json['user_id'],
      restaurantId: json['restaurant_id'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
