// lib/widgets/top_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../services/notification_service.dart';

class TopBar extends ConsumerWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 20),
              const SizedBox(width: 4),
              DropdownButton<String>(
                value: 'Home',
                dropdownColor: Colors.grey[800],
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                items: const [
                  DropdownMenuItem(value: 'Home', child: Text('Home')),
                  DropdownMenuItem(value: 'Work', child: Text('Work')),
                ],
                onChanged: (_) {},
              ),
              const Spacer(),
              // Notification icon with badge
              Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      context.push('/notifications');
                    },
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  // Notification badge
                  Consumer(
                    builder: (context, ref, child) {
                      final unreadCount = ref.watch(unreadNotificationCountProvider);
                      if (unreadCount > 0) {
                        return Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              unreadCount.toString(),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
              const SizedBox(width: 8),
              const CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(
                    'https://subfggmfnkhrmissnwfo.supabase.co/storage/v1/object/public/images//default_avatar.png'),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Flat 416 Ushodayas Signature Deepthisrinag...',
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'VEG',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              context.push('/search');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    'Search "dosa"',
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                  const Spacer(),
                  const Icon(Icons.mic, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
