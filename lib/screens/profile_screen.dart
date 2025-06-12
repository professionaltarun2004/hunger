import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    final User? user = authState.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('District', style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // User Info Section
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: _getProfileImage(user),
                  onBackgroundImageError: (exception, stackTrace) {
                    print('Failed to load profile image: $exception');
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  user?.userMetadata?['full_name'] ?? user?.email?.split('@').first ?? 'Guest User',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  user?.email ?? 'Not logged in',
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
                ),
                if (user != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ElevatedButton(
                      onPressed: () => authNotifier.signOut(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Sign Out'),
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Authentication Section (if not logged in)
          if (user == null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Login / Sign Up',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (authState.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      authState.errorMessage!,
                      style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: GoogleFonts.poppins(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: GoogleFonts.poppins(color: Colors.white),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => authNotifier.signInWithEmailAndPassword(
                    _emailController.text,
                    _passwordController.text,
                  ),
                  child: const Text('Sign In with Email'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => authNotifier.signUpWithEmailAndPassword(
                    _emailController.text,
                    _passwordController.text,
                  ),
                  child: const Text('Sign Up with Email'),
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.grey[700]),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => authNotifier.signInWithGoogle(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/icons/google_logo.png', height: 24.0),
                      const SizedBox(width: 8.0),
                      const Text('Sign In with Google'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),

          // User Features Section
          if (user != null) ...[
            _buildSectionHeader(context, 'Your Activity'),
            _buildListTile(context, Icons.history, 'Order History', () => context.go('/reorder')),
            _buildListTile(context, Icons.favorite_border, 'Favorite Restaurants', () => print('Favorite Restaurants tapped')),
            const SizedBox(height: 24),

            _buildSectionHeader(context, 'General'),
            _buildListTile(context, Icons.settings, 'Settings', () => context.push('/settings')),
            _buildListTile(context, Icons.card_giftcard, 'Subscriptions', () => context.push('/subscription')),
            _buildListTile(context, Icons.tune, 'Preferences', () => context.push('/preferences')),
            _buildListTile(context, Icons.analytics, 'Calorie Analysis', () => context.push('/calorie_analysis')),
            _buildListTile(context, Icons.people, 'Home-Chef Exchanges', () => context.push('/home_chef_exchange')),
            _buildListTile(context, Icons.food_bank, 'Surplus Food Donation', () => context.push('/donations')),
            const SizedBox(height: 24),

            _buildSectionHeader(context, 'Support'),
            _buildListTile(context, Icons.help_outline, 'Help & Support', () => print('Help & Support tapped')),
            _buildListTile(context, Icons.info_outline, 'About Us', () => print('About Us tapped')),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  // Helper method to build section headers
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Helper method to build consistent list tiles
  Widget _buildListTile(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.white54),
        title: Text(title, style: GoogleFonts.poppins(color: Colors.white)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
        onTap: onTap,
      ),
    );
  }

  ImageProvider _getProfileImage(User? user) {
    final avatarUrl = user?.userMetadata?['picture']?.toString() ??
        user?.userMetadata?['avatar_url']?.toString();
    if (avatarUrl != null &&
        avatarUrl.isNotEmpty &&
        !avatarUrl.contains(
            'https://subfggmfnkhrmissnwfo.supabase.co/storage/v1/object/public/images//default_avatar.png')) {
      return NetworkImage(avatarUrl);
    }
    return const AssetImage('assets/images/default_avatar.png');
  }
}
