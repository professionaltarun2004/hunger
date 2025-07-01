import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../services/notification_service.dart';
import '../utils/responsive_utils.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ResponsiveUtils.init(context);
    final notifications = ref.watch(notificationServiceProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: ResponsiveUtils.fontSize(20),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all, color: Colors.white),
              onPressed: () {
                ref.read(notificationServiceProvider.notifier).clearAllNotifications();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All notifications cleared')),
                );
              },
            ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: ResponsiveUtils.padding(all: 16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationCard(context, ref, notification);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: ResponsiveUtils.width(80),
            color: Colors.grey[400],
          ),
          SizedBox(height: ResponsiveUtils.height(16)),
          Text(
            'No notifications yet',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: ResponsiveUtils.fontSize(18),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: ResponsiveUtils.height(8)),
          Text(
            'We\'ll send you personalized food suggestions based on your mood',
            style: GoogleFonts.poppins(
              color: Colors.grey[400],
              fontSize: ResponsiveUtils.fontSize(14),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, WidgetRef ref, MoodNotification notification) {
    final moodColors = {
      'happy': Colors.orange,
      'stressed': Colors.red,
      'energetic': Colors.green,
      'tired': Colors.grey,
      'romantic': Colors.pink,
      'nostalgic': Colors.brown,
    };

    final moodColor = moodColors[notification.mood] ?? Colors.blue;

    return Container(
      margin: ResponsiveUtils.padding(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.grey[900] : Colors.grey[850],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: notification.isRead 
              ? Colors.transparent 
              : moodColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: ResponsiveUtils.padding(all: 16),
        leading: Container(
          padding: ResponsiveUtils.padding(all: 8),
          decoration: BoxDecoration(
            color: moodColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            _getMoodIcon(notification.mood),
            color: moodColor,
            size: ResponsiveUtils.width(24),
          ),
        ),
        title: Text(
          notification.title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: ResponsiveUtils.fontSize(16),
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: ResponsiveUtils.height(4)),
            Text(
              notification.message,
              style: GoogleFonts.poppins(
                color: Colors.grey[300],
                fontSize: ResponsiveUtils.fontSize(14),
              ),
            ),
            SizedBox(height: ResponsiveUtils.height(8)),
            Container(
              padding: ResponsiveUtils.padding(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: moodColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'Suggested: ${notification.foodSuggestion}',
                style: GoogleFonts.poppins(
                  color: moodColor,
                  fontSize: ResponsiveUtils.fontSize(12),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: ResponsiveUtils.height(8)),
            Text(
              _formatTimestamp(notification.timestamp),
              style: GoogleFonts.poppins(
                color: Colors.grey[500],
                fontSize: ResponsiveUtils.fontSize(12),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          color: Colors.grey[800],
          onSelected: (value) {
            switch (value) {
              case 'mark_read':
                ref.read(notificationServiceProvider.notifier).markAsRead(notification.id);
                break;
              case 'delete':
                ref.read(notificationServiceProvider.notifier).clearNotification(notification.id);
                break;
              case 'order_now':
                context.push('/');
                break;
            }
          },
          itemBuilder: (context) => [
            if (!notification.isRead)
              PopupMenuItem(
                value: 'mark_read',
                child: Row(
                  children: [
                    const Icon(Icons.mark_email_read, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Mark as read',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ],
                ),
              ),
            PopupMenuItem(
              value: 'order_now',
              child: Row(
                children: [
                  Icon(Icons.restaurant, color: moodColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Order now',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Delete',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
          child: Icon(
            Icons.more_vert,
            color: Colors.grey[400],
            size: ResponsiveUtils.width(20),
          ),
        ),
        onTap: () {
          if (!notification.isRead) {
            ref.read(notificationServiceProvider.notifier).markAsRead(notification.id);
          }
          // Navigate to relevant food category or restaurant
          context.push('/');
        },
      ),
    );
  }

  IconData _getMoodIcon(String mood) {
    switch (mood) {
      case 'happy':
        return Icons.sentiment_very_satisfied;
      case 'stressed':
        return Icons.sentiment_dissatisfied;
      case 'energetic':
        return Icons.bolt;
      case 'tired':
        return Icons.bedtime;
      case 'romantic':
        return Icons.favorite;
      case 'nostalgic':
        return Icons.home;
      default:
        return Icons.restaurant;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd').format(timestamp);
    }
  }
} 