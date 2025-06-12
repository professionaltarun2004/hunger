class HomeChefListing {
  final String id;
  final String chefId;
  final String dishName;
  final String description;
  final String imageUrl;
  final double price;
  final String availability;
  final String location;
  final double rating;
  final int numberOfRatings;

  HomeChefListing({
    required this.id,
    required this.chefId,
    required this.dishName,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.availability,
    required this.location,
    this.rating = 0.0,
    this.numberOfRatings = 0,
  });

  factory HomeChefListing.fromJson(Map<String, dynamic> json) {
    return HomeChefListing(
      id: json['id'] as String,
      chefId: json['chef_id'] as String,
      dishName: json['dish_name'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String,
      price: (json['price'] as num).toDouble(),
      availability: json['availability'] as String,
      location: json['location'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      numberOfRatings: json['number_of_ratings'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chef_id': chefId,
      'dish_name': dishName,
      'description': description,
      'image_url': imageUrl,
      'price': price,
      'availability': availability,
      'location': location,
      'rating': rating,
      'number_of_ratings': numberOfRatings,
    };
  }
} 