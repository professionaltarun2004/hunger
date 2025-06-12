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

      final items = await _supabase
          .from('order_items')
          .select()
          .eq('order_id', orderId) as List<dynamic>;

      if (items.isEmpty) {
        throw Exception('No items found for this order. Please add items to reorder.');
      }

      final originalOrder = await _supabase
          .from('orders')
          .select()
          .eq('id', orderId)
          .single() as Map<String, dynamic>;

      final totalPrice = originalOrder['total_price'] as num;

      final newOrder = {
        'user_id': user.id,
        'total_price': totalPrice,
        'order_time': DateTime.now().toIso8601String(), // 03:10 PM IST, June 11, 2025
      };

      final newOrderData = await _supabase
          .from('orders')
          .insert(newOrder)
          .select()
          .single() as Map<String, dynamic>;

      final newOrderId = newOrderData['id'] as int;

      final newOrderItems = items.map((item) => {
            'order_id': newOrderId,
            'menu_item_id': item['menu_item_id'],
            'quantity': item['quantity'],
          }).toList();

      await _supabase.from('order_items').insert(newOrderItems);

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final orderNotifierProvider = StateNotifierProvider<OrderNotifier, AsyncValue<void>>((ref) {
  return OrderNotifier();
});