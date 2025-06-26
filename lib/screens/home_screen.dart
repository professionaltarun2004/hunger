// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/restaurant_provider.dart';
import '../providers/home_provider.dart';
import '../widgets/top_bar.dart';
import '../utils/responsive_utils.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();
  bool _showFloatingButton = false;
  final PageController _offerPageController = PageController();
  int _currentOfferIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    _scrollController.addListener(() {
      setState(() {
        _showFloatingButton = _scrollController.offset > 200;
      });
    });

    // Auto-scroll offers
    _startOfferAutoScroll();
  }

  void _startOfferAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _offerPageController.hasClients) {
        final offers = ref.read(offersProvider);
        final nextIndex = (_currentOfferIndex + 1) % offers.length;
        _offerPageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _startOfferAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _offerPageController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      ref.refresh(restaurantProvider.future),
      ref.refresh(popularDishesProvider.future),
      ref.refresh(quickBitesProvider.future),
      ref.refresh(featuredRestaurantsProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);
    final maxWidth = ResponsiveUtils.getMaxContentWidth(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const TopBar(),
        backgroundColor: Colors.black,
        elevation: 0,
        toolbarHeight: ResponsiveUtils.height(120),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            color: const Color(0xFFE23744),
            backgroundColor: Colors.grey[900],
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Offers Carousel Section
                  SliverToBoxAdapter(
                    child: _buildOffersCarousel(),
                  ),

                  // What's on your mind? - Food Categories
                  SliverToBoxAdapter(
                    child: _buildSectionHeader('What\'s on your mind?'),
                  ),
                  SliverToBoxAdapter(
                    child: _buildFoodCategoriesGrid(),
                  ),

                  // Popular Near You
                  SliverToBoxAdapter(
                    child: _buildSectionHeader('Popular near you'),
                  ),
                  SliverToBoxAdapter(
                    child: _buildPopularDishes(),
                  ),

                  // Quick Bites
                  SliverToBoxAdapter(
                    child: _buildSectionHeader('Quick Bites', subtitle: 'Delivered in 15-20 mins'),
                  ),
                  SliverToBoxAdapter(
                    child: _buildQuickBites(),
                  ),

                  // Featured Restaurants
                  SliverToBoxAdapter(
                    child: _buildSectionHeader('Featured Restaurants'),
                  ),
                  SliverToBoxAdapter(
                    child: _buildFeaturedRestaurants(),
                  ),

                  // All Restaurants
                  SliverToBoxAdapter(
                    child: _buildSectionHeader('All Restaurants'),
                  ),
                  _buildAllRestaurants(),

                  // Bottom spacing
                  SliverToBoxAdapter(
                    child: SizedBox(height: ResponsiveUtils.height(100)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: AnimatedScale(
        scale: _showFloatingButton ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: FloatingActionButton(
          onPressed: () {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          backgroundColor: const Color(0xFFE23744),
          child: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildOffersCarousel() {
    final offers = ref.watch(offersProvider);
    
    return Container(
      height: ResponsiveUtils.height(160),
      margin: ResponsiveUtils.padding(horizontal: 16, vertical: 8),
      child: PageView.builder(
        controller: _offerPageController,
        onPageChanged: (index) {
          setState(() {
            _currentOfferIndex = index;
          });
        },
        itemCount: offers.length,
        itemBuilder: (context, index) {
          final offer = offers[index];
          return Container(
            margin: ResponsiveUtils.padding(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              gradient: LinearGradient(
                colors: [
                  Color(offer['color']).withValues(alpha: 0.8),
                  Color(offer['color']).withValues(alpha: 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: CachedNetworkImage(
                    imageUrl: offer['imageUrl'],
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[800]!,
                      highlightColor: Colors.grey[600]!,
                      child: Container(color: Colors.grey[800]),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.6),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
                Positioned(
                  left: ResponsiveUtils.width(16),
                  bottom: ResponsiveUtils.height(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer['title'],
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: ResponsiveUtils.fontSize(24),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        offer['subtitle'],
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: ResponsiveUtils.fontSize(14),
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.height(4)),
                      Container(
                        padding: ResponsiveUtils.padding(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          'Code: ${offer['code']}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: ResponsiveUtils.fontSize(12),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, {String? subtitle}) {
    return Padding(
      padding: ResponsiveUtils.padding(
        horizontal: 16,
        top: 24,
        bottom: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: ResponsiveUtils.fontSize(20),
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: ResponsiveUtils.height(4)),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                color: Colors.grey[400],
                fontSize: ResponsiveUtils.fontSize(14),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFoodCategoriesGrid() {
    final categories = ref.watch(foodCategoriesProvider);
    
    return Container(
      height: ResponsiveUtils.height(240),
      padding: ResponsiveUtils.padding(horizontal: 16),
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: ResponsiveUtils.height(8),
          mainAxisSpacing: ResponsiveUtils.width(8),
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () {
              // Navigate to category page or filter
            },
            child: Column(
              children: [
                Expanded(
                  child: Container(
                          decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: CachedNetworkImage(
                        imageUrl: category.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[800]!,
                          highlightColor: Colors.grey[600]!,
                          child: Container(color: Colors.grey[800]),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveUtils.height(8)),
                Text(
                  category.name,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: ResponsiveUtils.fontSize(12),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPopularDishes() {
    final popularDishes = ref.watch(popularDishesProvider);
    
    return popularDishes.when(
      data: (dishes) => Container(
        height: ResponsiveUtils.height(200),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: ResponsiveUtils.padding(horizontal: 16),
          itemCount: dishes.length,
          itemBuilder: (context, index) {
            final dish = dishes[index];
            return _buildDishCard(dish);
          },
        ),
      ),
      loading: () => _buildHorizontalShimmer(),
      error: (e, _) => _buildErrorWidget('Failed to load popular dishes'),
    );
  }

  Widget _buildQuickBites() {
    final quickBites = ref.watch(quickBitesProvider);
    
    return quickBites.when(
      data: (bites) => Container(
        height: ResponsiveUtils.height(200),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: ResponsiveUtils.padding(horizontal: 16),
          itemCount: bites.length,
          itemBuilder: (context, index) {
            final bite = bites[index];
            return _buildDishCard(bite, isQuickBite: true);
          },
        ),
      ),
      loading: () => _buildHorizontalShimmer(),
      error: (e, _) => _buildErrorWidget('Failed to load quick bites'),
    );
  }

  Widget _buildDishCard(dynamic dish, {bool isQuickBite = false}) {
    return Container(
      width: ResponsiveUtils.width(160),
      margin: ResponsiveUtils.padding(right: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: dish.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[800]!,
                      highlightColor: Colors.grey[600]!,
                      child: Container(color: Colors.grey[800]),
                    ),
                  ),
                ),
                if (dish.isVegetarian)
                  Positioned(
                    top: ResponsiveUtils.height(8),
                    left: ResponsiveUtils.width(8),
                    child: Container(
                      padding: ResponsiveUtils.padding(all: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Icon(
                        Icons.circle,
                        color: Colors.white,
                        size: ResponsiveUtils.width(8),
                      ),
                    ),
                  ),
                if (isQuickBite)
                  Positioned(
                    top: ResponsiveUtils.height(8),
                    right: ResponsiveUtils.width(8),
                    child: Container(
                      padding: ResponsiveUtils.padding(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '15 min',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: ResponsiveUtils.fontSize(10),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: ResponsiveUtils.padding(all: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dish.name,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: ResponsiveUtils.fontSize(12),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: ResponsiveUtils.height(2)),
                  Text(
                    dish.restaurantName,
                    style: GoogleFonts.poppins(
                      color: Colors.grey[400],
                      fontSize: ResponsiveUtils.fontSize(10),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${dish.price.toInt()}',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFE23744),
                          fontSize: ResponsiveUtils.fontSize(14),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: ResponsiveUtils.width(12),
                          ),
                          SizedBox(width: ResponsiveUtils.width(2)),
                          Text(
                            dish.rating.toString(),
                            style: GoogleFonts.poppins(
                              color: Colors.grey[300],
                              fontSize: ResponsiveUtils.fontSize(10),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedRestaurants() {
    final featuredRestaurants = ref.watch(featuredRestaurantsProvider);
    
    return featuredRestaurants.when(
      data: (restaurants) => Container(
        height: ResponsiveUtils.height(180),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: ResponsiveUtils.padding(horizontal: 16),
          itemCount: restaurants.length,
          itemBuilder: (context, index) {
            final restaurant = restaurants[index];
            return _buildRestaurantCard(restaurant);
          },
        ),
      ),
      loading: () => _buildHorizontalShimmer(),
      error: (e, _) => _buildErrorWidget('Failed to load featured restaurants'),
    );
  }

  Widget _buildRestaurantCard(dynamic restaurant) {
    return GestureDetector(
      onTap: () => context.push('/restaurant/${restaurant.id}'),
      child: Container(
        width: ResponsiveUtils.width(140),
        margin: ResponsiveUtils.padding(right: 12),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.r),
                      topRight: Radius.circular(12.r),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: restaurant.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[800]!,
                        highlightColor: Colors.grey[600]!,
                        child: Container(color: Colors.grey[800]),
                      ),
                    ),
                  ),
                  if (restaurant.offer.isNotEmpty)
                    Positioned(
                      top: ResponsiveUtils.height(8),
                      left: ResponsiveUtils.width(8),
                      child: Container(
                        padding: ResponsiveUtils.padding(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          restaurant.offer,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: ResponsiveUtils.fontSize(9),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: ResponsiveUtils.padding(all: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: ResponsiveUtils.fontSize(12),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: ResponsiveUtils.width(12),
                            ),
                            SizedBox(width: ResponsiveUtils.width(2)),
                            Text(
                              restaurant.rating.toString(),
                              style: GoogleFonts.poppins(
                                color: Colors.grey[300],
                                fontSize: ResponsiveUtils.fontSize(10),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${restaurant.etaMinutes} min',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[400],
                            fontSize: ResponsiveUtils.fontSize(10),
                          ),
                        ),
                      ],
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

  Widget _buildAllRestaurants() {
    final restaurants = ref.watch(restaurantProvider);

    return restaurants.when(
      data: (restaurants) {
        if (restaurants.isEmpty) {
          return SliverToBoxAdapter(child: _buildEmptyState());
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final restaurant = restaurants[index];
              return Container(
                margin: ResponsiveUtils.padding(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: ResponsiveUtils.padding(all: 12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: CachedNetworkImage(
                      imageUrl: restaurant.imageUrl,
                      width: ResponsiveUtils.width(60),
                      height: ResponsiveUtils.height(60),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[800]!,
                        highlightColor: Colors.grey[600]!,
                        child: Container(color: Colors.grey[800]),
                      ),
                    ),
                  ),
                  title: Text(
                    restaurant.name,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: ResponsiveUtils.fontSize(14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: ResponsiveUtils.height(4)),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: ResponsiveUtils.width(14),
                          ),
                          SizedBox(width: ResponsiveUtils.width(4)),
                          Text(
                            '${restaurant.rating} • ${restaurant.etaMinutes} mins',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[400],
                              fontSize: ResponsiveUtils.fontSize(12),
                            ),
                          ),
                        ],
                      ),
                      if (restaurant.offer.isNotEmpty) ...[
                        SizedBox(height: ResponsiveUtils.height(4)),
                        Container(
                          padding: ResponsiveUtils.padding(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            restaurant.offer,
                            style: GoogleFonts.poppins(
                              color: Colors.green,
                              fontSize: ResponsiveUtils.fontSize(10),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  onTap: () => context.push('/restaurant/${restaurant.id}'),
                ),
              );
            },
            childCount: restaurants.length,
          ),
        );
      },
      loading: () => SliverToBoxAdapter(child: _buildLoadingState()),
      error: (e, _) => SliverToBoxAdapter(child: _buildErrorState(e.toString())),
    );
  }

  Widget _buildHorizontalShimmer() {
    return Container(
      height: ResponsiveUtils.height(200),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: ResponsiveUtils.padding(horizontal: 16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: ResponsiveUtils.width(160),
            margin: ResponsiveUtils.padding(right: 12),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[800]!,
              highlightColor: Colors.grey[600]!,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      height: ResponsiveUtils.height(100),
      child: Center(
        child: Text(
          message,
          style: GoogleFonts.poppins(
            color: Colors.grey[400],
            fontSize: ResponsiveUtils.fontSize(14),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_outlined,
            size: ResponsiveUtils.width(80),
            color: Colors.grey[400],
          ),
          SizedBox(height: ResponsiveUtils.height(16)),
          Text(
            'No Restaurants Found',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: ResponsiveUtils.fontSize(20),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: ResponsiveUtils.height(8)),
          Text(
            'Try adjusting your filters or location',
            style: GoogleFonts.poppins(
              color: Colors.grey[400],
              fontSize: ResponsiveUtils.fontSize(14),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: ResponsiveUtils.padding(all: 16),
      child: Column(
        children: List.generate(
          5,
          (index) => Container(
            margin: ResponsiveUtils.padding(bottom: 12),
            height: ResponsiveUtils.height(120),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE23744),
                strokeWidth: 2,
              ),
            ),
          ),
        ),
      ),
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
              'Something went wrong',
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
              onPressed: _onRefresh,
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
