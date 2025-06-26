// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';
import '../providers/order_provider.dart';
import '../utils/responsive_utils.dart';

class ReorderScreen extends ConsumerStatefulWidget {
  const ReorderScreen({super.key});

  @override
  ConsumerState<ReorderScreen> createState() => _ReorderScreenState();
}

class _ReorderScreenState extends ConsumerState<ReorderScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();

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
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await ref.refresh(orderProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);
    final ordersAsync = ref.watch(orderProvider);
    final maxWidth = ResponsiveUtils.getMaxContentWidth(context);

    return WillPopScope(
      onWillPop: () async {
        context.go('/');
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(
            'Your Orders',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: ResponsiveUtils.fontSize(20),
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: ResponsiveUtils.width(24),
            ),
            onPressed: () => context.go('/'),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              color: const Color(0xFFE23744),
              backgroundColor: Colors.grey[900],
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ordersAsync.when(
                  data: (orders) {
                    if (orders.isEmpty) {
                      return _buildEmptyState();
                    }
                    return _buildOrdersList(orders);
                  },
                  loading: () => _buildLoadingState(),
                  error: (e, _) => _buildErrorState(e.toString()),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList(List orders) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header Section
        SliverToBoxAdapter(
          child: Padding(
            padding: ResponsiveUtils.padding(
              horizontal: 16,
              top: 16,
              bottom: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Orders',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: ResponsiveUtils.fontSize(18),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${orders.length} order${orders.length != 1 ? 's' : ''}',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[400],
                    fontSize: ResponsiveUtils.fontSize(14),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Orders List
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final order = orders[index];
              return OpenContainer(
                transitionType: ContainerTransitionType.fadeThrough,
                transitionDuration: const Duration(milliseconds: 400),
                openBuilder: (context, _) => Container(), // Order detail screen
                closedBuilder: (context, openContainer) => _buildOrderCard(order, index),
              );
            },
            childCount: orders.length,
          ),
        ),

        // Bottom spacing
        SliverToBoxAdapter(
          child: SizedBox(height: ResponsiveUtils.height(100)),
        ),
      ],
    );
  }

  Widget _buildOrderCard(dynamic order, int index) {
    return Container(
      margin: ResponsiveUtils.padding(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[900]!,
            Colors.grey[850]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          children: [
            // Header Section
            Container(
              padding: ResponsiveUtils.padding(all: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFE23744).withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFFE23744).withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: ResponsiveUtils.padding(all: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE23744).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.receipt_long,
                      color: const Color(0xFFE23744),
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
                            fontSize: ResponsiveUtils.fontSize(16),
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: ResponsiveUtils.height(2)),
                        Text(
                          order.formattedDate,
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveUtils.fontSize(12),
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge('Delivered'),
                ],
              ),
            ),

            // Content Section
            Padding(
              padding: ResponsiveUtils.padding(all: 16),
              child: Column(
                children: [
                  // Order Details Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildOrderInfo(
                        icon: Icons.restaurant,
                        label: 'Items',
                        value: '${order.itemCount} item${order.itemCount != 1 ? 's' : ''}',
                      ),
                      _buildOrderInfo(
                        icon: Icons.access_time,
                        label: 'Delivered in',
                        value: '25 mins',
                      ),
                      _buildOrderInfo(
                        icon: Icons.currency_rupee,
                        label: 'Total',
                        value: '₹${order.totalPrice}',
                        isPrice: true,
                      ),
                    ],
                  ),

                  SizedBox(height: ResponsiveUtils.height(16)),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // View order details
                          },
                          icon: Icon(
                            Icons.visibility,
                            size: ResponsiveUtils.width(18),
                            color: Colors.white,
                          ),
                          label: Text(
                            'View Details',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[600]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            padding: ResponsiveUtils.padding(vertical: 12),
                          ),
                        ),
                      ),
                      SizedBox(width: ResponsiveUtils.width(12)),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _handleReorder(order),
                          icon: Icon(
                            Icons.replay,
                            size: ResponsiveUtils.width(18),
                          ),
                          label: Text(
                            'Reorder',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE23744),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            padding: ResponsiveUtils.padding(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color statusColor;
    IconData statusIcon;
    
    switch (status.toLowerCase()) {
      case 'delivered':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'preparing':
        statusColor = Colors.orange;
        statusIcon = Icons.restaurant;
        break;
      case 'on the way':
        statusColor = Colors.blue;
        statusIcon = Icons.delivery_dining;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }

    return Container(
      padding: ResponsiveUtils.padding(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: statusColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: ResponsiveUtils.width(14),
          ),
          SizedBox(width: ResponsiveUtils.width(4)),
          Text(
            status,
            style: GoogleFonts.poppins(
              color: statusColor,
              fontSize: ResponsiveUtils.fontSize(12),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfo({
    required IconData icon,
    required String label,
    required String value,
    bool isPrice = false,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.grey[400],
          size: ResponsiveUtils.width(20),
        ),
        SizedBox(height: ResponsiveUtils.height(4)),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize(11),
            color: Colors.grey[500],
          ),
        ),
        SizedBox(height: ResponsiveUtils.height(2)),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize(14),
            fontWeight: FontWeight.w600,
            color: isPrice ? const Color(0xFFE23744) : Colors.white,
          ),
        ),
      ],
    );
  }

  void _handleReorder(dynamic order) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFFE23744),
            ),
            SizedBox(height: ResponsiveUtils.height(16)),
            Text(
              'Reordering...',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: ResponsiveUtils.fontSize(16),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );

    try {
      final orderNotifier = ref.read(orderNotifierProvider.notifier);
      await orderNotifier.reorder(order.id);
      
      Navigator.pop(context); // Close loading dialog
      
      final reorderState = ref.read(orderNotifierProvider);
      if (reorderState.hasError) {
        _showErrorSnackBar('Failed to reorder: ${reorderState.error}');
      } else {
        _showSuccessSnackBar('Order #${order.id} reordered successfully!');
        context.go('/');
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorSnackBar('Failed to reorder: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: ResponsiveUtils.width(8)),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[700],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        behavior: SnackBarBehavior.floating,
        margin: ResponsiveUtils.padding(all: 16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: ResponsiveUtils.width(8)),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[700],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        behavior: SnackBarBehavior.floating,
        margin: ResponsiveUtils.padding(all: 16),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: ResponsiveUtils.padding(all: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: ResponsiveUtils.padding(all: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Icon(
                  Icons.receipt_long,
                  size: ResponsiveUtils.width(80),
                  color: Colors.grey[400],
                ),
              ),
              SizedBox(height: ResponsiveUtils.height(24)),
              Text(
                'No Orders Yet',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: ResponsiveUtils.fontSize(24),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: ResponsiveUtils.height(8)),
              Text(
                'Order some delicious food now!',
                style: GoogleFonts.poppins(
                  color: Colors.grey[400],
                  fontSize: ResponsiveUtils.fontSize(16),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveUtils.height(32)),
              ElevatedButton.icon(
                onPressed: () => context.go('/'),
                icon: Icon(
                  Icons.restaurant,
                  size: ResponsiveUtils.width(20),
                ),
                label: Text(
                  'Explore Restaurants',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE23744),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: ResponsiveUtils.padding(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: ResponsiveUtils.padding(all: 16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: ResponsiveUtils.padding(bottom: 16),
          height: ResponsiveUtils.height(160),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFE23744),
              strokeWidth: 2,
            ),
          ),
        );
      },
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
              size: ResponsiveUtils.width(80),
              color: Colors.red[400],
            ),
            SizedBox(height: ResponsiveUtils.height(16)),
            Text(
              'Something went wrong',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: ResponsiveUtils.fontSize(20),
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
            SizedBox(height: ResponsiveUtils.height(24)),
            ElevatedButton(
              onPressed: _onRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE23744),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
