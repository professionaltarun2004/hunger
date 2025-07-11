class User {
  final String id;
  final String name;
  final String email;
  final String? address;
  final bool isVegOnly;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.address,
    required this.isVegOnly,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      address: json['address'] as String?,
      isVegOnly: json['is_veg_only'] as bool? ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'name': name,
      'email': email,
      'address': address,
      'is_veg_only': isVegOnly,
    };
    
    // Only include created_at if it exists
    if (createdAt != null) {
      data['created_at'] = createdAt!.toIso8601String();
    }
    
    return data;
  }
} 