import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Food categories are now defined inline
import '../models/menu_item.dart';
import '../models/restaurant.dart';

// Simple food category class
class FoodCategory {
  final int id;
  final String name;
  final String imageUrl;
  final String description;
  final bool isPopular;

  const FoodCategory({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    this.isPopular = false,
  });
}

// Mock data for categories (in production, this would come from Supabase)
final foodCategoriesProvider = Provider<List<FoodCategory>>((ref) {
  return [
    FoodCategory(
      id: 1,
      name: 'Pizza',
      imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400',
      description: 'Delicious pizzas from top restaurants',
      isPopular: true,
    ),
    FoodCategory(
      id: 2,
      name: 'Burger',
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
      description: 'Juicy burgers and sandwiches',
      isPopular: true,
    ),
    FoodCategory(
      id: 3,
      name: 'Biryani',
      imageUrl: 'https://images.unsplash.com/photo-1563379091339-03246963d51a?w=400',
      description: 'Aromatic biryani and rice dishes',
      isPopular: true,
    ),
    FoodCategory(
      id: 4,
      name: 'Chinese',
      imageUrl: 'https://images.unsplash.com/photo-1552611052-33e04de081de?w=400',
      description: 'Authentic Chinese cuisine',
    ),
    FoodCategory(
      id: 5,
      name: 'Desserts',
      imageUrl: 'https://images.unsplash.com/photo-1551024506-0bccd828d307?w=400',
      description: 'Sweet treats and desserts',
    ),
    FoodCategory(
      id: 6,
      name: 'South Indian',
      imageUrl: 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=400',
      description: 'Traditional South Indian dishes',
    ),
    FoodCategory(
      id: 7,
      name: 'North Indian',
      imageUrl: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=400',
      description: 'Rich North Indian curries',
    ),
    FoodCategory(
      id: 8,
      name: 'Beverages',
      imageUrl: 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=400',
      description: 'Refreshing drinks and beverages',
    ),
  ];
});

// Popular dishes provider with mock data
final popularDishesProvider = FutureProvider<List<MenuItem>>((ref) async {
  // In production, this would fetch from Supabase with a query like:
  // SELECT m.*, r.name as restaurant_name, r.rating 
  // FROM menu_items m 
  // JOIN restaurants r ON m.restaurant_id = r.id 
  // WHERE m.is_popular = true 
  // ORDER BY m.rating DESC LIMIT 10

  return [
    MenuItem(
      id: 1,
      name: 'Margherita Pizza',
      imageUrl: 'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=400',
      price: 299.0,
      calories: 800,
      restaurantId: 1,
      restaurantName: 'Pizza Palace',
      rating: 4.5,
      categoryId: 1,
      isVegetarian: true,
      isPopular: true,
      description: 'Classic margherita with fresh basil and mozzarella',
    ),
    MenuItem(
      id: 2,
      name: 'Chicken Biryani',
      imageUrl: 'https://images.unsplash.com/photo-1563379091339-03246963d51a?w=400',
      price: 350.0,
      calories: 650,
      restaurantId: 2,
      restaurantName: 'Biryani House',
      rating: 4.7,
      categoryId: 3,
      isPopular: true,
      description: 'Aromatic basmati rice with tender chicken pieces',
    ),
    MenuItem(
      id: 3,
      name: 'Chicken Burger',
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
      price: 249.0,
      calories: 550,
      restaurantId: 3,
      restaurantName: 'Burger Junction',
      rating: 4.3,
      categoryId: 2,
      isPopular: true,
      description: 'Grilled chicken patty with fresh vegetables',
    ),
    MenuItem(
      id: 4,
      name: 'Masala Dosa',
      imageUrl: 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=400',
      price: 120.0,
      calories: 400,
      restaurantId: 4,
      restaurantName: 'South Spice',
      rating: 4.4,
      categoryId: 6,
      isVegetarian: true,
      isPopular: true,
      description: 'Crispy dosa with spiced potato filling',
    ),
    MenuItem(
      id: 5,
      name: 'Chocolate Brownie',
      imageUrl: 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=400',
      price: 150.0,
      calories: 320,
      restaurantId: 5,
      restaurantName: 'Sweet Dreams',
      rating: 4.6,
      categoryId: 5,
      isVegetarian: true,
      isPopular: true,
      description: 'Rich chocolate brownie with vanilla ice cream',
    ),
  ];
});

// Featured restaurants provider
final featuredRestaurantsProvider = StreamProvider<List<Restaurant>>((ref) async* {
  final supabase = Supabase.instance.client;

  try {
    // Fetch featured restaurants (those with high ratings or special offers)
    final response = await supabase
        .from('restaurants')
        .select()
        .gte('rating', 4.0)
        .limit(8);
    
    yield response.map((json) => Restaurant.fromJson(json)).toList();
  } catch (e) {
    print('Error fetching featured restaurants: $e');
    yield [];
  }
});

// Quick bites provider (fast delivery items)
final quickBitesProvider = FutureProvider<List<MenuItem>>((ref) async {
  // Mock data for quick bites - items that can be delivered quickly
  return [
    MenuItem(
      id: 6,
      name: 'Veg Sandwich',
      imageUrl: 'https://images.unsplash.com/photo-1539252554453-80ab65ce3586?w=400',
      price: 80.0,
      calories: 250,
      restaurantId: 6,
      restaurantName: 'Quick Bites',
      rating: 4.2,
      categoryId: 2,
      isVegetarian: true,
      description: 'Fresh vegetable sandwich with mint chutney',
    ),
    MenuItem(
      id: 7,
      name: 'Samosa (2 pcs)',
      imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=400',
      price: 40.0,
      calories: 180,
      restaurantId: 7,
      restaurantName: 'Snack Corner',
      rating: 4.0,
      categoryId: 6,
      isVegetarian: true,
      description: 'Crispy samosas with tangy tamarind chutney',
    ),
    MenuItem(
      id: 8,
      name: 'Fresh Lime Soda',
      imageUrl: 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=400',
      price: 60.0,
      calories: 50,
      restaurantId: 8,
      restaurantName: 'Juice Bar',
      rating: 4.1,
      categoryId: 8,
      isVegetarian: true,
      description: 'Refreshing lime soda with mint',
    ),
  ];
});

// Search suggestions provider
final searchSuggestionsProvider = Provider<List<String>>((ref) {
  return [
    'Pizza',
    'Burger',
    'Biryani',
    'Chinese',
    'South Indian',
    'North Indian',
    'Desserts',
    'Beverages',
    'Healthy',
    'Fast Food',
  ];
});

// Offers and promotions provider
final offersProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return [
    {
      'title': '50% OFF',
      'subtitle': 'On orders above ₹299',
      'code': 'SAVE50',
      'color': 0xFFE23744,
      'imageUrl': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400',
    },
    {
      'title': 'Free Delivery',
      'subtitle': 'On your first order',
      'code': 'FREEDEL',
      'color': 0xFF4CAF50,
      'imageUrl': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
    },
    {
      'title': '₹100 OFF',
      'subtitle': 'On orders above ₹500',
      'code': 'HUNDRED',
      'color': 0xFF2196F3,
      'imageUrl': 'https://images.unsplash.com/photo-1563379091339-03246963d51a?w=400',
    },
  ];
}); 