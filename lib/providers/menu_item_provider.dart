import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/menu_item.dart';

final menuItemProvider = StreamProvider.family<List<MenuItem>, int>((ref, restaurantId) {
  final supabase = Supabase.instance.client;
  return supabase
      .from('menu_items')
      .stream(primaryKey: ['id'])
      .eq('restaurant_id', restaurantId)
      .map((data) => data.map((json) => MenuItem.fromJson(json)).toList());
}); 