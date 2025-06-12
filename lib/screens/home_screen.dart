import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/restaurant_provider.dart';
import '../widgets/top_bar.dart';
import '../widgets/offer_banner.dart';
import '../widgets/category_chips.dart';
import '../widgets/filter_chips.dart';
import '../widgets/restaurant_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // int _selectedIndex = 0; // No longer needed as handled by AppNavigationScreen

  // void _onItemTapped(int index) { // No longer needed as handled by AppNavigationScreen
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  //   switch (index) {
  //     case 0:
  //       context.go('/');
  //       break;
  //     case 1:
  //       context.go('/reorder');
  //       break;
  //     case 2:
  //       context.go('/dining');
  //       break;
  //     case 3:
  //       context.go('/profile');
  //       break;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final restaurants = ref.watch(restaurantProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: TopBar(),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            OfferBanner(),
            CategoryChips(),
            FilterChips(),
            restaurants.when(
              data: (restaurants) => ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: restaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = restaurants[index];
                  return RestaurantCard(
                    id: restaurant.id,
                    name: restaurant.name,
                    imageUrl: restaurant.imageUrl,
                    rating: restaurant.rating,
                    offer: restaurant.offer,
                    etaMinutes: restaurant.etaMinutes,
                    isHomeChef: restaurant.isHomeChef,
                  );
                },
              ),
              loading: () => Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                  child:
                      Text('Error: $e', style: TextStyle(color: Colors.white))),
            ),
          ],
        ),
      ),
      // BottomNavigationBar removed, as it's now handled by AppNavigationScreen
    );
  }
}
