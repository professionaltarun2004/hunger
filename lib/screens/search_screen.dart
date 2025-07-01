import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import '../providers/restaurant_provider.dart';
import '../providers/home_provider.dart';
import '../utils/responsive_utils.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _isSearching = _searchQuery.isNotEmpty;
    });
    _performSearch();
  }

  void _performSearch() {
    if (_searchQuery.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    final restaurants = ref.read(restaurantProvider).value ?? [];
    final popularDishes = ref.read(popularDishesProvider).value ?? [];
    final quickBites = ref.read(quickBitesProvider).value ?? [];
    final categories = ref.read(foodCategoriesProvider);

    List<dynamic> results = [];

    // Search in restaurants
    if (_selectedFilter == 'All' || _selectedFilter == 'Restaurants') {
      final restaurantResults = restaurants
          .where((restaurant) =>
              restaurant.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              restaurant.offer.toLowerCase().contains(_searchQuery.toLowerCase()))
          .map((restaurant) => {'type': 'restaurant', 'data': restaurant})
          .toList();
      results.addAll(restaurantResults);
    }

    // Search in popular dishes
    if (_selectedFilter == 'All' || _selectedFilter == 'Dishes') {
      final dishResults = [...popularDishes, ...quickBites]
          .where((dish) =>
              dish.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              dish.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              dish.restaurantName.toLowerCase().contains(_searchQuery.toLowerCase()))
          .map((dish) => {'type': 'dish', 'data': dish})
          .toList();
      results.addAll(dishResults);
    }

    // Search in categories
    if (_selectedFilter == 'All' || _selectedFilter == 'Categories') {
      final categoryResults = categories
          .where((category) =>
              category.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              category.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .map((category) => {'type': 'category', 'data': category})
          .toList();
      results.addAll(categoryResults);
    }

    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);
    final suggestions = ref.watch(searchSuggestionsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: ResponsiveUtils.fontSize(16),
          ),
          decoration: InputDecoration(
            hintText: 'Search for restaurants, dishes...',
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey[400],
              fontSize: ResponsiveUtils.fontSize(16),
            ),
            border: InputBorder.none,
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                : const Icon(Icons.search, color: Colors.grey),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            height: ResponsiveUtils.height(60),
            padding: ResponsiveUtils.padding(horizontal: 16, vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['All', 'Restaurants', 'Dishes', 'Categories']
                  .map((filter) => GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFilter = filter;
                          });
                          _performSearch();
                        },
                        child: Container(
                          margin: ResponsiveUtils.padding(right: 8),
                          padding: ResponsiveUtils.padding(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedFilter == filter
                                ? const Color(0xFFE23744)
                                : Colors.grey[800],
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            filter,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: ResponsiveUtils.fontSize(14),
                              fontWeight: _selectedFilter == filter
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),

          Expanded(
            child: _isSearching ? _buildSearchResults() : _buildSuggestions(suggestions),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(List<String> suggestions) {
    return ListView(
      padding: ResponsiveUtils.padding(all: 16),
      children: [
        Text(
          'Popular Searches',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: ResponsiveUtils.fontSize(18),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: ResponsiveUtils.height(16)),
        ...suggestions.map((suggestion) => ListTile(
              leading: const Icon(Icons.search, color: Colors.grey),
              title: Text(
                suggestion,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: ResponsiveUtils.fontSize(16),
                ),
              ),
              onTap: () {
                _searchController.text = suggestion;
              },
            )),
        SizedBox(height: ResponsiveUtils.height(24)),
        Text(
          'Recent Searches',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: ResponsiveUtils.fontSize(18),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: ResponsiveUtils.height(16)),
        ListTile(
          leading: const Icon(Icons.history, color: Colors.grey),
          title: Text(
            'Pizza',
            style: GoogleFonts.poppins(
              color: Colors.grey[400],
              fontSize: ResponsiveUtils.fontSize(16),
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: () {
              // Remove from recent searches
            },
          ),
          onTap: () {
            _searchController.text = 'Pizza';
          },
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: ResponsiveUtils.width(80),
              color: Colors.grey[400],
            ),
            SizedBox(height: ResponsiveUtils.height(16)),
            Text(
              'No results found for "$_searchQuery"',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: ResponsiveUtils.fontSize(18),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: ResponsiveUtils.height(8)),
            Text(
              'Try searching for something else',
              style: GoogleFonts.poppins(
                color: Colors.grey[400],
                fontSize: ResponsiveUtils.fontSize(14),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: ResponsiveUtils.padding(all: 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        final type = result['type'];
        final data = result['data'];

        switch (type) {
          case 'restaurant':
            return _buildRestaurantResult(data);
          case 'dish':
            return _buildDishResult(data);
          case 'category':
            return _buildCategoryResult(data);
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildRestaurantResult(dynamic restaurant) {
    return GestureDetector(
      onTap: () => context.push('/restaurant/${restaurant.id}'),
      child: Container(
        margin: ResponsiveUtils.padding(bottom: 12),
        padding: ResponsiveUtils.padding(all: 12),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            ClipRRect(
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
            SizedBox(width: ResponsiveUtils.width(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: ResponsiveUtils.fontSize(16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.height(4)),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: ResponsiveUtils.width(16),
                      ),
                      SizedBox(width: ResponsiveUtils.width(4)),
                      Text(
                        '${restaurant.rating} • ${restaurant.etaMinutes} mins',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[400],
                          fontSize: ResponsiveUtils.fontSize(14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDishResult(dynamic dish) {
    return Container(
      margin: ResponsiveUtils.padding(bottom: 12),
      padding: ResponsiveUtils.padding(all: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: CachedNetworkImage(
              imageUrl: dish.imageUrl,
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
          SizedBox(width: ResponsiveUtils.width(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dish.name,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: ResponsiveUtils.fontSize(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.height(4)),
                Text(
                  dish.restaurantName,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[400],
                    fontSize: ResponsiveUtils.fontSize(14),
                  ),
                ),
                SizedBox(height: ResponsiveUtils.height(4)),
                Text(
                  '₹${dish.price.toInt()}',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFE23744),
                    fontSize: ResponsiveUtils.fontSize(16),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryResult(dynamic category) {
    return Container(
      margin: ResponsiveUtils.padding(bottom: 12),
      padding: ResponsiveUtils.padding(all: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: CachedNetworkImage(
              imageUrl: category.imageUrl,
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
          SizedBox(width: ResponsiveUtils.width(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: ResponsiveUtils.fontSize(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.height(4)),
                Text(
                  category.description,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[400],
                    fontSize: ResponsiveUtils.fontSize(14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 