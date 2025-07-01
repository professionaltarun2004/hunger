import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../utils/responsive_utils.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);
    final authState = ref.watch(authProvider);
    final orders = ref.watch(orderProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: authState.currentUser != null
          ? _buildProfileContent(authState.currentUser!, orders)
          : authState.errorMessage != null
              ? _buildErrorState(authState.errorMessage!)
              : _buildSignInContent(),
    );
  }

  Widget _buildProfileContent(User user, AsyncValue<List<dynamic>> orders) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Profile Header
            SliverToBoxAdapter(
              child: _buildProfileHeader(user),
            ),

            // Quick Stats
            SliverToBoxAdapter(
              child: _buildQuickStats(orders),
            ),

            // Menu Options
            SliverToBoxAdapter(
              child: _buildMenuOptions(),
            ),

            // Recent Orders
            SliverToBoxAdapter(
              child: _buildRecentOrders(orders),
            ),

            // Account Settings
            SliverToBoxAdapter(
              child: _buildAccountSettings(),
            ),

            // Bottom spacing
            SliverToBoxAdapter(
              child: SizedBox(height: ResponsiveUtils.height(100)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    return Container(
      padding: ResponsiveUtils.padding(all: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE23744).withValues(alpha: 0.8),
            const Color(0xFFE23744).withValues(alpha: 0.6),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Profile',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: ResponsiveUtils.fontSize(24),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => context.push('/settings'),
                  icon: Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: ResponsiveUtils.width(24),
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUtils.height(24)),
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: ResponsiveUtils.width(40),
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      backgroundImage: user.userMetadata?['avatar_url'] != null
                          ? CachedNetworkImageProvider(user.userMetadata!['avatar_url'])
                          : null,
                      child: user.userMetadata?['avatar_url'] == null
                          ? Icon(
                              Icons.person,
                              size: ResponsiveUtils.width(40),
                              color: Colors.white,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: ResponsiveUtils.padding(all: 4),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: ResponsiveUtils.width(16),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: ResponsiveUtils.width(16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.userMetadata?['full_name'] ?? user.email?.split('@').first ?? 'User',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: ResponsiveUtils.fontSize(20),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.height(4)),
                      Text(
                        user.email ?? '',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: ResponsiveUtils.fontSize(14),
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.height(8)),
                      Container(
                        padding: ResponsiveUtils.padding(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          'Gold Member',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: ResponsiveUtils.fontSize(12),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(AsyncValue<List<dynamic>> orders) {
    return Container(
      margin: ResponsiveUtils.padding(all: 16),
      padding: ResponsiveUtils.padding(all: 20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: orders.when(
        data: (orderList) {
          final totalOrders = orderList.length;
          final totalSpent = orderList.fold<double>(
            0.0,
            (sum, order) => sum + (order.totalPrice ?? 0.0),
          );
          
          return Row(
            children: [
              _buildStatItem(
                icon: Icons.shopping_bag,
                title: 'Total Orders',
                value: totalOrders.toString(),
                color: const Color(0xFFE23744),
              ),
              SizedBox(width: ResponsiveUtils.width(20)),
              _buildStatItem(
                icon: Icons.currency_rupee,
                title: 'Total Spent',
                value: '₹${totalSpent.toInt()}',
                color: Colors.green,
              ),
              SizedBox(width: ResponsiveUtils.width(20)),
              _buildStatItem(
                icon: Icons.star,
                title: 'Points',
                value: '${(totalSpent / 10).toInt()}',
                color: Colors.amber,
              ),
            ],
          );
        },
        loading: () => _buildStatsShimmer(),
        error: (_, __) => _buildStatsError(),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: ResponsiveUtils.padding(all: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: color,
              size: ResponsiveUtils.width(24),
            ),
          ),
          SizedBox(height: ResponsiveUtils.height(8)),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: ResponsiveUtils.fontSize(18),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.grey[400],
              fontSize: ResponsiveUtils.fontSize(12),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOptions() {
    final menuItems = [
      {
        'icon': Icons.analytics,
        'title': 'Calorie Tracking',
        'subtitle': 'Track your daily calorie intake',
        'route': '/calorie_analysis',
        'enabled': true,
      },
      {
        'icon': Icons.location_on,
        'title': 'Manage Addresses',
        'subtitle': 'Add or edit delivery addresses',
        'route': '/addresses',
        'enabled': false,
      },
      {
        'icon': Icons.payment,
        'title': 'Payment Methods',
        'subtitle': 'Cards, UPI, and wallets',
        'route': '/payments',
        'enabled': false,
      },
      {
        'icon': Icons.favorite,
        'title': 'Favorites',
        'subtitle': 'Your liked restaurants and dishes',
        'route': '/favorites',
        'enabled': false,
      },
      {
        'icon': Icons.card_giftcard,
        'title': 'Offers & Coupons',
        'subtitle': 'Available deals and discounts',
        'route': '/offers',
        'enabled': false,
      },
      {
        'icon': Icons.help_outline,
        'title': 'Help & Support',
        'subtitle': 'FAQs and customer support',
        'route': '/help',
        'enabled': false,
      },
    ];

    return Container(
      margin: ResponsiveUtils.padding(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: ResponsiveUtils.fontSize(18),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: ResponsiveUtils.height(16)),
          ...menuItems.map((item) => _buildMenuItem(
                icon: item['icon'] as IconData,
                title: item['title'] as String,
                subtitle: item['subtitle'] as String,
                onTap: () {
                  if (item['enabled'] as bool) {
                    context.push(item['route'] as String);
                  } else {
                    _showComingSoon(context);
                  }
                },
              )),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: ResponsiveUtils.padding(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: ResponsiveUtils.padding(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          padding: ResponsiveUtils.padding(all: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE23744).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFE23744),
            size: ResponsiveUtils.width(20),
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: ResponsiveUtils.fontSize(16),
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            color: Colors.grey[400],
            fontSize: ResponsiveUtils.fontSize(14),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey[400],
          size: ResponsiveUtils.width(16),
        ),
      ),
    );
  }

  Widget _buildRecentOrders(AsyncValue<List<dynamic>> orders) {
    return Container(
      margin: ResponsiveUtils.padding(all: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Orders',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: ResponsiveUtils.fontSize(18),
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/reorder'),
                child: Text(
                  'View All',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFE23744),
                    fontSize: ResponsiveUtils.fontSize(14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.height(16)),
          orders.when(
            data: (orderList) {
              if (orderList.isEmpty) {
                return _buildNoOrdersState();
              }
              return Column(
                children: orderList
                    .take(3)
                    .map((order) => _buildOrderItem(order))
                    .toList(),
              );
            },
            loading: () => _buildOrdersShimmer(),
            error: (_, __) => _buildOrdersError(),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(dynamic order) {
    return Container(
      margin: ResponsiveUtils.padding(bottom: 12),
      padding: ResponsiveUtils.padding(all: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            padding: ResponsiveUtils.padding(all: 8),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.check_circle,
              color: Colors.green,
              size: ResponsiveUtils.width(20),
            ),
          ),
          SizedBox(width: ResponsiveUtils.width(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${order.id}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: ResponsiveUtils.fontSize(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.height(4)),
                Text(
                  '${order.itemCount} items • ₹${order.totalPrice.toInt()}',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[400],
                    fontSize: ResponsiveUtils.fontSize(14),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // Reorder functionality
              ref.read(orderNotifierProvider.notifier).reorder(order.id);
            },
            child: Text(
              'Reorder',
              style: GoogleFonts.poppins(
                color: const Color(0xFFE23744),
                fontSize: ResponsiveUtils.fontSize(14),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettings() {
    return Container(
      margin: ResponsiveUtils.padding(all: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: ResponsiveUtils.fontSize(18),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: ResponsiveUtils.height(16)),
          _buildMenuItem(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'How we handle your data',
            onTap: () => _showComingSoon(context),
          ),
          _buildMenuItem(
            icon: Icons.description,
            title: 'Terms of Service',
            subtitle: 'App usage terms and conditions',
            onTap: () => _showComingSoon(context),
          ),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'App version and information',
            onTap: () => _showAbout(context),
          ),
          SizedBox(height: ResponsiveUtils.height(16)),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.red.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: ListTile(
              onTap: () => _showSignOutDialog(context),
              contentPadding: ResponsiveUtils.padding(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Icon(
                Icons.logout,
                color: Colors.red,
                size: ResponsiveUtils.width(20),
              ),
              title: Text(
                'Sign Out',
                style: GoogleFonts.poppins(
                  color: Colors.red,
                  fontSize: ResponsiveUtils.fontSize(16),
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Sign out of your account',
                style: GoogleFonts.poppins(
                  color: Colors.red.withValues(alpha: 0.7),
                  fontSize: ResponsiveUtils.fontSize(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInContent() {
    return Center(
      child: Padding(
        padding: ResponsiveUtils.padding(all: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: ResponsiveUtils.width(80),
              color: Colors.grey[400],
            ),
            SizedBox(height: ResponsiveUtils.height(24)),
            Text(
              'Welcome to Hunger',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: ResponsiveUtils.fontSize(24),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: ResponsiveUtils.height(8)),
            Text(
              'Sign in to access your profile, orders, and personalized recommendations',
              style: GoogleFonts.poppins(
                color: Colors.grey[400],
                fontSize: ResponsiveUtils.fontSize(16),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.height(32)),
            ElevatedButton(
              onPressed: () {
                ref.read(authProvider.notifier).signInWithGoogle();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE23744),
                padding: ResponsiveUtils.padding(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.login,
                    color: Colors.white,
                    size: ResponsiveUtils.width(20),
                  ),
                  SizedBox(width: ResponsiveUtils.width(8)),
                  Text(
                    'Sign In with Google',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: ResponsiveUtils.fontSize(16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        color: const Color(0xFFE23744),
        strokeWidth: 2.w,
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: ResponsiveUtils.padding(all: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: ResponsiveUtils.width(64),
              color: Colors.red[400],
            ),
            SizedBox(height: ResponsiveUtils.height(16)),
            Text(
              'Something went wrong',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: ResponsiveUtils.fontSize(18),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: ResponsiveUtils.height(8)),
            Text(
              error,
              style: GoogleFonts.poppins(
                color: Colors.grey[400],
                fontSize: ResponsiveUtils.fontSize(14),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsShimmer() {
    return Row(
      children: List.generate(
        3,
        (index) => Expanded(
          child: Shimmer.fromColors(
            baseColor: Colors.grey[800]!,
            highlightColor: Colors.grey[600]!,
            child: Container(
              height: ResponsiveUtils.height(80),
              margin: ResponsiveUtils.padding(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsError() {
    return Container(
      height: ResponsiveUtils.height(80),
      child: Center(
        child: Text(
          'Failed to load stats',
          style: GoogleFonts.poppins(
            color: Colors.grey[400],
            fontSize: ResponsiveUtils.fontSize(14),
          ),
        ),
      ),
    );
  }

  Widget _buildNoOrdersState() {
    return Container(
      padding: ResponsiveUtils.padding(all: 32),
      child: Column(
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: ResponsiveUtils.width(60),
            color: Colors.grey[400],
          ),
          SizedBox(height: ResponsiveUtils.height(16)),
          Text(
            'No orders yet',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: ResponsiveUtils.fontSize(18),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: ResponsiveUtils.height(8)),
          Text(
            'Start exploring restaurants and place your first order',
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

  Widget _buildOrdersShimmer() {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          margin: ResponsiveUtils.padding(bottom: 12),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[800]!,
            highlightColor: Colors.grey[600]!,
            child: Container(
              height: ResponsiveUtils.height(70),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersError() {
    return Container(
      padding: ResponsiveUtils.padding(all: 16),
      child: Text(
        'Failed to load orders',
        style: GoogleFonts.poppins(
          color: Colors.grey[400],
          fontSize: ResponsiveUtils.fontSize(14),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Coming Soon',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This feature is coming soon!',
          style: GoogleFonts.poppins(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(
                color: const Color(0xFFE23744),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'About Hunger',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Hunger v1.0.0\n\nA modern food delivery app built with Flutter.\n\nDeveloped with ❤️ for food lovers.',
          style: GoogleFonts.poppins(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(
                color: const Color(0xFFE23744),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Sign Out',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: GoogleFonts.poppins(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Colors.grey[400],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authProvider.notifier).signOut();
            },
            child: Text(
              'Sign Out',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
