import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/home_screen.dart';
import '../screens/reorder_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/restaurant_detail_screen.dart';
import '../screens/donations_screen.dart';
import '../screens/dining_screen.dart';
import '../screens/app_navigation_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/subscription_screen.dart';
import '../screens/preferences_screen.dart';
import '../screens/calorie_analysis_screen.dart';
import '../screens/home_chef_exchange_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    errorBuilder: (context, state) => const Scaffold(
      body: Center(
        child: Text(
          'Page not found',
          style: TextStyle(color: Colors.white),
        ),
      ),
    ),
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          int selectedIndex = 0; // Default to home
          if (state.fullPath == '/reorder') {
            selectedIndex = 1;
          } else if (state.fullPath == '/dining') {
            selectedIndex = 2;
          } else if (state.fullPath == '/profile') {
            selectedIndex = 3;
          }
          return AppNavigationScreen(
            selectedIndex: selectedIndex,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => HomeScreen(),
          ),
          GoRoute(
            path: '/reorder',
            builder: (context, state) => const ReorderScreen(),
          ),
          GoRoute(
            path: '/dining',
            builder: (context, state) => const DiningScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      // Routes outside the bottom navigation bar (e.g., detail screens and new feature screens)
      GoRoute(
        path: '/donations',
        builder: (context, state) => DonationsScreen(),
      ),
      GoRoute(
        path: '/restaurant/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return const Scaffold(
              body: Center(
                child: Text(
                  'Invalid restaurant ID',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          }
          return RestaurantDetailScreen(restaurantId: id);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: '/preferences',
        builder: (context, state) => const PreferencesScreen(),
      ),
      GoRoute(
        path: '/calorie_analysis',
        builder: (context, state) => const CalorieAnalysisScreen(),
      ),
      GoRoute(
        path: '/home_chef_exchange',
        builder: (context, state) => const HomeChefExchangeScreen(),
      ),
    ],
    redirect: (context, state) async {
      // Only redirect if the path is one of the main navigation paths
      final bool isMainRoute = ['/', '/reorder', '/dining', '/profile'].contains(state.fullPath);

      if (state.fullPath == '/profile') {
        return null;
      }

      try {
        final supabase = Supabase.instance.client;
        final user = supabase.auth.currentUser;
        
        if (user == null && isMainRoute) {
          // Only redirect to profile if not logged in and trying to access a main route
          return '/profile';
        }
        return null;
      } catch (e) {
        debugPrint('Error in GoRouter redirect: $e');
        return '/profile';
      }
    },
  );
});

// Temporary debug screen to test rendering
class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'Debug Screen: App is running!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}