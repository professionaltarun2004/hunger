import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/menu_item.dart';
import '../providers/menu_item_provider.dart';

class RestaurantDetailScreen extends ConsumerStatefulWidget {
  final int restaurantId;

  const RestaurantDetailScreen({required this.restaurantId, super.key});

  @override
  _RestaurantDetailScreenState createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends ConsumerState<RestaurantDetailScreen> {
  List<Map<String, dynamic>> cart = [];
  double totalPrice = 0.0;
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
  }

  void addToCart(MenuItem item) {
    setState(() {
      final existingItem = cart.firstWhere(
        (cartItem) => cartItem['item'].id == item.id,
        orElse: () => {'item': item, 'quantity': 0},
      );
      if (existingItem['quantity'] == 0) {
        cart.add({'item': item, 'quantity': 1});
      } else {
        existingItem['quantity'] += 1;
      }
      totalPrice += item.price;
    });
  }

  void placeOrder() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to proceed with order')),
      );
      return;
    }

    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add items to cart first')),
      );
      return;
    }

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      // Direct order creation (simulating successful payment)
      // Create order
      final orderResponse = await supabase.from('orders').insert({
        'user_id': user.id,
        'restaurant_id': widget.restaurantId,
        'total_price': totalPrice,
        'order_time': DateTime.now().toIso8601String(),
      }).select().single();

      final orderId = orderResponse['id'];

      // Create order items
      final orderItems = cart.map((item) => {
        'order_id': orderId,
        'menu_item_id': item['item'].id,
        'quantity': item['quantity'],
      }).toList();

      await supabase.from('order_items').insert(orderItems);

      setState(() {
        cart.clear();
        totalPrice = 0.0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order: $e')),
      );
    } finally {
      setState(() {
        _isProcessingPayment = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuItemsAsync = ref.watch(menuItemProvider(widget.restaurantId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurant Details',
            style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          menuItemsAsync.when(
            data: (menuItems) {
              if (menuItems.isEmpty) {
                return Center(
                  child: Text(
                    'No menu items available.',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                );
              }
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: menuItems.length,
                      itemBuilder: (context, index) {
                        final item = menuItems[index];
                        return Card(
                          color: Colors.grey[900],
                          child: ListTile(
                            leading: CachedNetworkImage(
                              imageUrl: item.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error, color: Colors.red),
                            ),
                            title: Text(
                              item.name,
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '₹${item.price}',
                                  style: GoogleFonts.poppins(color: Colors.grey),
                                ),
                                Text(
                                  '${item.calories} kcal',
                                  style: GoogleFonts.poppins(color: Colors.grey),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.add, color: Colors.white),
                              onPressed: () => addToCart(item),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (cart.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'Cart Total: ₹$totalPrice',
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _isProcessingPayment ? null : placeOrder,
                            child: _isProcessingPayment
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text('Place Order'),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE23744)),
              ),
            ),
            error: (e, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading menu: $e',
                    style: GoogleFonts.poppins(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(menuItemProvider(widget.restaurantId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
