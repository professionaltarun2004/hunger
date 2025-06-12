class CalorieEntry {
  final String id;
  final String userId;
  final DateTime date;
  final int calories;

  CalorieEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.calories,
  });

  factory CalorieEntry.fromJson(Map<String, dynamic> json) {
    return CalorieEntry(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      calories: json['calories'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String(),
      'calories': calories,
    };
  }
} 