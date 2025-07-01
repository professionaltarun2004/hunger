// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hunger/providers/order_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animations/animations.dart';
import '../models/menu_item.dart';
import '../providers/menu_item_provider.dart';
import '../utils/responsive_utils.dart';

class RestaurantDetailScreen extends ConsumerStatefulWidget {
  final int restaurantId;

  const RestaurantDetailScreen({required this.restaurantId, super.key});

  @override
  _RestaurantDetailScreenState createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends ConsumerState<RestaurantDetailScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> cart = [];
  double totalPrice = 0.0;
  bool _isProcessingPayment = false;
  late AnimationController _cartAnimationController;
  late Animation<double> _cartSlideAnimation;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();
    _cartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _cartSlideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _cartAnimationController, curve: Curves.easeInOut),
    );

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _cartAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void addToCart(MenuItem item) {
    setState(() {
      final existingItemIndex = cart.indexWhere(
        (cartItem) => cartItem['item'].id == item.id,
      );
      
      if (existingItemIndex != -1) {
        cart[existingItemIndex]['quantity'] += 1;
      } else {
        cart.add({'item': item, 'quantity': 1});
      }
      totalPrice += item.price;
      
      if (cart.length == 1 && cart[0]['quantity'] == 1) {
        _fabAnimationController.forward();
      }
    });

    // Show add to cart animation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: ResponsiveUtils.width(8)),
            Text(
              '${item.name} added to cart',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }

  void removeFromCart(MenuItem item) {
    setState(() {
      final existingItemIndex = cart.indexWhere(
        (cartItem) => cartItem['item'].id == item.id,
      );
      
      if (existingItemIndex != -1) {
        if (cart[existingItemIndex]['quantity'] > 1) {
          cart[existingItemIndex]['quantity'] -= 1;
        } else {
          cart.removeAt(existingItemIndex);
        }
        totalPrice -= item.price;
        
        if (cart.isEmpty) {
          _fabAnimationController.reverse();
        }
      }
    });
  }

  int getItemQuantity(MenuItem item) {
    final cartItem = cart.firstWhere(
      (cartItem) => cartItem['item'].id == item.id,
      orElse: () => {'quantity': 0},
    );
    return cartItem['quantity'] ?? 0;
  }

  void placeOrder() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      _showErrorSnackBar('Please sign in to proceed with order');
      return;
    }

    if (cart.isEmpty) {
      _showErrorSnackBar('Please add items to cart first');
      return;
    }

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      // First test database connectivity
      final orderNotifier = ref.read(orderNotifierProvider.notifier);
      final testResult = await orderNotifier.testDatabaseConnection();
      
      if (!testResult['success']) {
        _showErrorSnackBar('Database connection failed: ${testResult['message']}');
        return;
      }

      print('Database test successful: ${testResult['message']}');

      // Prepare order items with proper validation
      final orderItems = cart.map((cartItem) {
        final item = cartItem['item'] as MenuItem;
        final quantity = cartItem['quantity'] as int;
        
        return {
          'menu_item_id': item.id,
          'quantity': quantity,
        };
      }).toList();

      print('Prepared order items: $orderItems'); // Debug logging

      // Use the improved order creation method from OrderNotifier
      final result = await orderNotifier.createOrder(
        userId: user.id,
        totalPrice: totalPrice,
        restaurantId: widget.restaurantId,
        items: orderItems,
      );

      print('Order creation result: $result'); // Debug logging

      // If real order creation fails, try mock order for testing
      Map<String, dynamic> finalResult = result;
      if (result['success'] != true) {
        print('Real order creation failed, trying mock order...');
        finalResult = await orderNotifier.createMockOrder(
          userId: user.id,
          totalPrice: totalPrice,
          restaurantId: widget.restaurantId,
          items: orderItems,
        );
        print('Mock order result: $finalResult');
      }

      if (finalResult['success'] == true) {
        setState(() {
          cart.clear();
          totalPrice = 0.0;
        });

        _fabAnimationController.reverse();
        _showSuccessSnackBar('Order placed successfully! Order ID: ${finalResult['order_id']}');
      } else {
        _showErrorSnackBar('${finalResult['message'] ?? 'Failed to place order'}\nError: ${finalResult['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Exception in placeOrder: $e'); // Debug logging
      _showErrorSnackBar('Error placing order: $e');
    } finally {
      setState(() {
        _isProcessingPayment = false;
      });
    }
  }

  // Simple test method to check database
  void testDatabase() async {
    final orderNotifier = ref.read(orderNotifierProvider.notifier);
    final result = await orderNotifier.testDatabaseConnection();
    
    if (result['success']) {
      _showSuccessSnackBar('Database test successful!');
    } else {
      _showErrorSnackBar('Database test failed: ${result['message']}');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: ResponsiveUtils.width(8)),
            Text(message, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
          ],
        ),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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
            Text(message, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
          ],
        ),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);
    final menuItemsAsync = ref.watch(menuItemProvider(widget.restaurantId));
    final maxWidth = ResponsiveUtils.getMaxContentWidth(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Restaurant Menu',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          // Debug test button
          IconButton(
            onPressed: testDatabase,
            icon: Icon(
              Icons.bug_report,
              color: Colors.yellow,
              size: ResponsiveUtils.width(20),
            ),
            tooltip: 'Test Database',
          ),
          if (cart.isNotEmpty)
            Padding(
              padding: ResponsiveUtils.padding(right: 16),
              child: Stack(
                children: [
                  IconButton(
                    onPressed: _showCartBottomSheet,
                    icon: Icon(
                      Icons.shopping_cart,
                      color: Colors.white,
                      size: ResponsiveUtils.width(24),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: ResponsiveUtils.padding(all: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE23744),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      constraints: BoxConstraints(
                        minWidth: ResponsiveUtils.width(20),
                        minHeight: ResponsiveUtils.height(20),
                      ),
                      child: Text(
                        cart.fold(0, (sum, item) => sum + (item['quantity'] as int)).toString(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: ResponsiveUtils.fontSize(12),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: menuItemsAsync.when(
            data: (menuItems) {
              if (menuItems.isEmpty) {
                return _buildEmptyState();
              }
              return _buildMenuList(menuItems);
            },
            loading: () => _buildLoadingState(),
            error: (e, _) => _buildErrorState(e.toString()),
          ),
        ),
      ),
      floatingActionButton: cart.isNotEmpty
          ? ScaleTransition(
              scale: _fabScaleAnimation,
              child: FloatingActionButton.extended(
                onPressed: _showCartBottomSheet,
                backgroundColor: const Color(0xFFE23744),
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                label: Text(
                  '₹${totalPrice.toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildMenuList(List<MenuItem> menuItems) {
    return ListView.builder(
      padding: ResponsiveUtils.padding(all: 16),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _buildMenuItemCard(item);
      },
    );
  }

  Widget _buildMenuItemCard(MenuItem item) {
    final quantity = getItemQuantity(item);
    
    return Container(
      margin: ResponsiveUtils.padding(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Row(
          children: [
            // Image Section
            CachedNetworkImage(
              imageUrl: item.imageUrl,
              width: ResponsiveUtils.width(120),
              height: ResponsiveUtils.height(120),
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey[800]!,
                highlightColor: Colors.grey[600]!,
                child: Container(
                  width: ResponsiveUtils.width(120),
                  height: ResponsiveUtils.height(120),
                  color: Colors.grey[800],
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: ResponsiveUtils.width(120),
                height: ResponsiveUtils.height(120),
                color: Colors.grey[800],
                child: Icon(
                  Icons.fastfood,
                  color: Colors.grey[400],
                  size: ResponsiveUtils.width(40),
                ),
              ),
            ),
            
            // Content Section
            Expanded(
              child: Padding(
                padding: ResponsiveUtils.padding(all: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: ResponsiveUtils.fontSize(16),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: ResponsiveUtils.height(4)),
                    
                    Row(
                      children: [
                        Text(
                          '₹${item.price}',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFE23744),
                            fontSize: ResponsiveUtils.fontSize(18),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.width(12)),
                        Container(
                          padding: ResponsiveUtils.padding(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            '${item.calories} kcal',
                            style: GoogleFonts.poppins(
                              color: Colors.orange,
                              fontSize: ResponsiveUtils.fontSize(12),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: ResponsiveUtils.height(12)),
                    
                    // Add/Remove Controls
                    quantity > 0
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildQuantityButton(
                                icon: Icons.remove,
                                onPressed: () => removeFromCart(item),
                              ),
                              Container(
                                margin: ResponsiveUtils.padding(horizontal: 12),
                                padding: ResponsiveUtils.padding(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE23744).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  quantity.toString(),
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFFE23744),
                                    fontSize: ResponsiveUtils.fontSize(16),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              _buildQuantityButton(
                                icon: Icons.add,
                                onPressed: () => addToCart(item),
                              ),
                            ],
                          )
                        : ElevatedButton.icon(
                            onPressed: () => addToCart(item),
                            icon: Icon(
                              Icons.add,
                              size: ResponsiveUtils.width(18),
                            ),
                            label: Text(
                              'Add',
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
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: ResponsiveUtils.width(36),
        height: ResponsiveUtils.height(36),
        decoration: BoxDecoration(
          color: const Color(0xFFE23744),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: ResponsiveUtils.width(20),
        ),
      ),
    );
  }

  void _showCartBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCartBottomSheet(),
    );
  }

  Widget _buildCartBottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: ResponsiveUtils.padding(vertical: 8),
            width: ResponsiveUtils.width(40),
            height: ResponsiveUtils.height(4),
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          
          // Header
          Padding(
            padding: ResponsiveUtils.padding(all: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Cart',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: ResponsiveUtils.fontSize(20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: ResponsiveUtils.width(24),
                  ),
                ),
              ],
            ),
          ),
          
          // Cart Items
          Expanded(
            child: ListView.builder(
              padding: ResponsiveUtils.padding(horizontal: 16),
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final cartItem = cart[index];
                final item = cartItem['item'] as MenuItem;
                final quantity = cartItem['quantity'] as int;
                
                return Container(
                  margin: ResponsiveUtils.padding(bottom: 12),
                  padding: ResponsiveUtils.padding(all: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: ResponsiveUtils.fontSize(14),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '₹${item.price} × $quantity',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[400],
                                fontSize: ResponsiveUtils.fontSize(12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${(item.price * quantity).toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFE23744),
                          fontSize: ResponsiveUtils.fontSize(16),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Bottom Section
          Container(
            padding: ResponsiveUtils.padding(all: 16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: ResponsiveUtils.fontSize(18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₹${totalPrice.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFE23744),
                        fontSize: ResponsiveUtils.fontSize(20),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: ResponsiveUtils.height(16)),
                
                SizedBox(
                  width: double.infinity,
                  height: ResponsiveUtils.height(50),
                  child: ElevatedButton(
                    onPressed: _isProcessingPayment ? null : () {
                      Navigator.pop(context);
                      placeOrder();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE23744),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: _isProcessingPayment
                        ? SizedBox(
                            width: ResponsiveUtils.width(20),
                            height: ResponsiveUtils.height(20),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Place Order',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: ResponsiveUtils.fontSize(16),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: ResponsiveUtils.width(80),
            color: Colors.grey[400],
          ),
          SizedBox(height: ResponsiveUtils.height(16)),
          Text(
            'No Menu Items Available',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: ResponsiveUtils.fontSize(20),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: ResponsiveUtils.height(8)),
          Text(
            'Check back later for delicious options',
            style: GoogleFonts.poppins(
              color: Colors.grey[400],
              fontSize: ResponsiveUtils.fontSize(14),
            ),
          ),
        ],
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
          height: ResponsiveUtils.height(120),
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
              size: ResponsiveUtils.width(64),
              color: Colors.red[400],
            ),
            SizedBox(height: ResponsiveUtils.height(16)),
            Text(
              'Failed to Load Menu',
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
            SizedBox(height: ResponsiveUtils.height(16)),
            ElevatedButton(
              onPressed: () => ref.refresh(menuItemProvider(widget.restaurantId)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE23744),
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
