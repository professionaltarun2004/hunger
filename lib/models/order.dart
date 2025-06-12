import 'package:intl/intl.dart';

class Order {
  final int id;
  final double totalPrice;
  final DateTime orderTime;
  final String userId;
  final int itemCount;

  Order({
    required this.id,
    required this.totalPrice,
    required this.orderTime,
    required this.userId,
    required this.itemCount,
  });

  // Computed property for formatted date in IST
  String get formattedDate {
    final istTime = orderTime
        .add(const Duration(hours: 5, minutes: 30)); // Convert UTC to IST
    return DateFormat('dd MMM yyyy, hh:mm a').format(istTime);
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      totalPrice: (json['total_price'] as num).toDouble(),
      orderTime: DateTime.parse(json['order_time'] as String),
      userId: json['user_id'] as String,
      itemCount: json['item_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'total_price': totalPrice,
      'order_time': orderTime.toIso8601String(),
      'user_id': userId,
      'item_count': itemCount,
    };
  }
}
