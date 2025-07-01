import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:math';

class MoodNotification {
  final String id;
  final String title;
  final String message;
  final String mood;
  final String foodSuggestion;
  final DateTime timestamp;
  final bool isRead;

  MoodNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.mood,
    required this.foodSuggestion,
    required this.timestamp,
    this.isRead = false,
  });

  MoodNotification copyWith({
    String? id,
    String? title,
    String? message,
    String? mood,
    String? foodSuggestion,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return MoodNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      mood: mood ?? this.mood,
      foodSuggestion: foodSuggestion ?? this.foodSuggestion,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}

class NotificationService extends StateNotifier<List<MoodNotification>> {
  NotificationService() : super([]) {
    _startMoodBasedNotifications();
  }

  Timer? _notificationTimer;
  final Random _random = Random();

  final List<Map<String, dynamic>> _moodNotificationTemplates = [
    {
      'mood': 'happy',
      'title': '🎉 Celebrate with Food!',
      'message': 'You seem happy today! How about treating yourself to something special?',
      'suggestions': ['Pizza', 'Burger', 'Ice Cream', 'Cake', 'Desserts'],
    },
    {
      'mood': 'stressed',
      'title': '😌 Comfort Food Time',
      'message': 'Feeling stressed? Let us help you relax with some comfort food.',
      'suggestions': ['Soup', 'Tea', 'Pasta', 'Hot Chocolate', 'Warm Meals'],
    },
    {
      'mood': 'energetic',
      'title': '⚡ Fuel Your Energy!',
      'message': 'You\'re full of energy! Try something fresh and healthy.',
      'suggestions': ['Salad', 'Smoothie', 'Protein Bowl', 'Fresh Juice', 'Healthy Snacks'],
    },
    {
      'mood': 'tired',
      'title': '😴 Quick & Easy Meals',
      'message': 'Feeling tired? We\'ve got quick delivery options for you.',
      'suggestions': ['Ready Meals', 'Fast Food', 'Coffee', 'Energy Drinks', 'Quick Bites'],
    },
    {
      'mood': 'romantic',
      'title': '💕 Perfect for Date Night',
      'message': 'Planning something special? Check out our romantic dining options.',
      'suggestions': ['Fine Dining', 'Wine', 'Chocolate', 'Candlelit Dinner', 'Desserts'],
    },
    {
      'mood': 'nostalgic',
      'title': '🥺 Comfort from Home',
      'message': 'Missing home? Try some traditional comfort food.',
      'suggestions': ['Home Style', 'Traditional Food', 'Local Cuisine', 'Mom\'s Recipes', 'Comfort Food'],
    },
  ];

  final List<String> _timeBasedMessages = [
    'Good morning! Start your day with a healthy breakfast 🌅',
    'Lunch time! Don\'t skip your meal 🍽️',
    'Evening snack time! Something light? 🍪',
    'Dinner time! What\'s on your mind tonight? 🌙',
    'Late night craving? We\'ve got you covered 🌃',
  ];

  void _startMoodBasedNotifications() {
    // Send notifications every 2-4 hours (simulated)
    _notificationTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      _sendMoodBasedNotification();
    });

    // Send initial notification after 1 minute
    Timer(const Duration(minutes: 1), () {
      _sendMoodBasedNotification();
    });
  }

  void _sendMoodBasedNotification() {
    final template = _moodNotificationTemplates[_random.nextInt(_moodNotificationTemplates.length)];
    final suggestions = template['suggestions'] as List<String>;
    final suggestion = suggestions[_random.nextInt(suggestions.length)];

    final notification = MoodNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: template['title'],
      message: template['message'],
      mood: template['mood'],
      foodSuggestion: suggestion,
      timestamp: DateTime.now(),
    );

    state = [notification, ...state];

    // Keep only last 10 notifications
    if (state.length > 10) {
      state = state.take(10).toList();
    }
  }

  void sendCustomNotification(String mood, String customMessage) {
    final template = _moodNotificationTemplates.firstWhere(
      (t) => t['mood'] == mood,
      orElse: () => _moodNotificationTemplates[0],
    );

    final suggestions = template['suggestions'] as List<String>;
    final suggestion = suggestions[_random.nextInt(suggestions.length)];

    final notification = MoodNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '🎯 Personalized Suggestion',
      message: customMessage,
      mood: mood,
      foodSuggestion: suggestion,
      timestamp: DateTime.now(),
    );

    state = [notification, ...state];
  }

  void markAsRead(String notificationId) {
    state = state.map((notification) {
      if (notification.id == notificationId) {
        return notification.copyWith(isRead: true);
      }
      return notification;
    }).toList();
  }

  void clearNotification(String notificationId) {
    state = state.where((notification) => notification.id != notificationId).toList();
  }

  void clearAllNotifications() {
    state = [];
  }

  int get unreadCount => state.where((notification) => !notification.isRead).length;

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }
}

final notificationServiceProvider = StateNotifierProvider<NotificationService, List<MoodNotification>>((ref) {
  return NotificationService();
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationServiceProvider);
  return notifications.where((notification) => !notification.isRead).length;
}); 