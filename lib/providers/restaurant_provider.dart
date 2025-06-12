import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/restaurant.dart';

final restaurantProvider = StreamProvider<List<Restaurant>>((ref) async* {
  final supabase = Supabase.instance.client;

  // Fetch initial restaurants
  final initialResponse = await supabase.from('restaurants').select();
  yield initialResponse.map((json) => Restaurant.fromJson(json)).toList();

  // Stream updates from the restaurants table
  yield* supabase
      .from('restaurants')
      .stream(primaryKey: ['id'])
      .map((data) => data.map((json) => Restaurant.fromJson(json)).toList());
});