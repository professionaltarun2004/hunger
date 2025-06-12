import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/calorie_entry.dart';

final calorieEntriesProvider = StreamProvider<List<CalorieEntry>>((ref) {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) {
    return Stream.value([]);
  }

  return supabase
      .from('calorie_entries')
      .stream(primaryKey: ['id'])
      .eq('user_id', user.id)
      .order('date', ascending: true)
      .map((data) => data.map((json) => CalorieEntry.fromJson(json)).toList());
});

class CalorieNotifier extends StateNotifier<AsyncValue<void>> {
  CalorieNotifier() : super(const AsyncValue.data(null));

  final _supabase = Supabase.instance.client;
  final _uuid = const Uuid();

  Future<void> addCalorieEntry(int calories, DateTime date) async {
    state = const AsyncValue.loading();
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final newEntry = CalorieEntry(
        id: _uuid.v4(),
        userId: user.id,
        date: date,
        calories: calories,
      );

      await _supabase.from('calorie_entries').insert(newEntry.toJson());

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final calorieNotifierProvider = StateNotifierProvider<CalorieNotifier, AsyncValue<void>>((ref) {
  return CalorieNotifier();
}); 