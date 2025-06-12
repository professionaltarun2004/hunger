import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/home_chef_listing.dart';

final homeChefListingsProvider = StreamProvider<List<HomeChefListing>>((ref) {
  final supabase = Supabase.instance.client;
  
  return supabase
      .from('home_chef_listings')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false) // Order by newest first
      .map((data) => data.map((json) => HomeChefListing.fromJson(json)).toList());
});

class HomeChefNotifier extends StateNotifier<AsyncValue<void>> {
  HomeChefNotifier() : super(const AsyncValue.data(null));

  final _supabase = Supabase.instance.client;
  final _uuid = const Uuid();

  Future<void> addHomeChefListing({
    required String dishName,
    required String description,
    required String imageUrl,
    required double price,
    required String availability,
    required String location,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final newListing = HomeChefListing(
        id: _uuid.v4(),
        chefId: user.id,
        dishName: dishName,
        description: description,
        imageUrl: imageUrl,
        price: price,
        availability: availability,
        location: location,
      );

      await _supabase.from('home_chef_listings').insert(newListing.toJson());

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final homeChefNotifierProvider = StateNotifierProvider<HomeChefNotifier, AsyncValue<void>>((ref) {
  return HomeChefNotifier();
}); 