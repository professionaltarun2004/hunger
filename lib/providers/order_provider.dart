import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';

final orderProvider = StreamProvider<List<Order>>((ref) async* {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) {
    yield [];
    return;
  }

  print('User ID: ${user.id}'); // Debug logging

  try {
    yield* supabase
        .from('orders_with_item_count')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .order('order_time', ascending: false) // Sort by newest first
        .limit(50) // Limit to prevent fetching too many orders
        .map((data) => data.map((json) => Order.fromJson(json)).toList());
  } catch (e) {
    print('Error in orderProvider: $e');
    yield [];
  }
});

class OrderNotifier extends StateNotifier<AsyncValue<void>> {
  OrderNotifier() : super(const AsyncValue.data(null));

  final _supabase = Supabase.instance.client;

  Future<void> reorder(int orderId) async {
    state = const AsyncValue.loading();
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Fetch original order items with proper error handling
      final itemsResponse = await _supabase
          .from('order_items')
          .select('menu_item_id, quantity')
          .eq('order_id', orderId);

      if (itemsResponse.isEmpty) {
        throw Exception('No items found for this order. Please add items to reorder.');
      }

      // Fetch original order details
      final originalOrderResponse = await _supabase
          .from('orders')
          .select('total_price, restaurant_id')
          .eq('id', orderId)
          .single();

      final totalPrice = (originalOrderResponse['total_price'] as num).toDouble();
      final restaurantId = originalOrderResponse['restaurant_id'] as int?;

      // Validate required fields
      if (totalPrice <= 0) {
        throw Exception('Invalid order total price');
      }

      // Create new order with all required fields
      final newOrderData = {
        'user_id': user.id,
        'total_price': totalPrice,
        'order_time': DateTime.now().toIso8601String(),
        'status': 'pending', // Add default status
      };

      // Add restaurant_id if it exists in the original order
      if (restaurantId != null) {
        newOrderData['restaurant_id'] = restaurantId;
      }

      print('Creating new order with data: $newOrderData'); // Debug logging

      final newOrderResponse = await _supabase
          .from('orders')
          .insert(newOrderData)
          .select('id')
          .single();

      final newOrderId = newOrderResponse['id'] as int;

      // Validate and prepare order items
      final newOrderItems = <Map<String, dynamic>>[];
      for (final item in itemsResponse) {
        final menuItemId = item['menu_item_id'];
        final quantity = item['quantity'];

        // Validate required fields
        if (menuItemId == null || quantity == null || quantity <= 0) {
          print('Skipping invalid item: $item');
          continue;
        }

        newOrderItems.add({
          'order_id': newOrderId,
          'menu_item_id': menuItemId,
          'quantity': quantity,
        });
      }

      if (newOrderItems.isEmpty) {
        throw Exception('No valid items to reorder');
      }

      print('Creating order items: $newOrderItems'); // Debug logging

      await _supabase.from('order_items').insert(newOrderItems);

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      print('Error in reorder: $e');
      print('Stack trace: $stackTrace');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<Map<String, dynamic>> createOrder({
    required String userId,
    required double totalPrice,
    int? restaurantId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      // Validate input parameters
      if (userId.isEmpty) {
        throw Exception('User ID is required');
      }
      if (totalPrice <= 0) {
        throw Exception('Total price must be greater than 0');
      }
      if (items.isEmpty) {
        throw Exception('Order must contain at least one item');
      }

      // Validate each item
      for (final item in items) {
        if (item['menu_item_id'] == null || 
            item['quantity'] == null || 
            item['quantity'] <= 0) {
          throw Exception('Invalid item data: $item');
        }
      }

      // Create order with all required fields
      final orderData = {
        'user_id': userId,
        'total_price': totalPrice,
        'order_time': DateTime.now().toIso8601String(),
        'status': 'pending',
      };

      // Add restaurant_id if provided
      if (restaurantId != null) {
        orderData['restaurant_id'] = restaurantId;
      }

      print('Creating order with data: $orderData'); // Debug logging

      // Insert order and get the ID
      final orderResponse = await _supabase
          .from('orders')
          .insert(orderData)
          .select('id')
          .single();

      final orderId = orderResponse['id'] as int;

      // Prepare order items with proper validation
      final orderItems = items.map((item) => {
        'order_id': orderId,
        'menu_item_id': item['menu_item_id'],
        'quantity': item['quantity'],
      }).toList();

      print('Creating order items: $orderItems'); // Debug logging

      // Insert order items
      await _supabase.from('order_items').insert(orderItems);

      return {
        'success': true,
        'order_id': orderId,
        'message': 'Order created successfully',
      };
    } catch (e) {
      print('Error creating order: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to create order',
      };
    }
  }
}

final orderNotifierProvider = StateNotifierProvider<OrderNotifier, AsyncValue<void>>((ref) {
  return OrderNotifier();
});