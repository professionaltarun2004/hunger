import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../utils/responsive_utils.dart';

class HomeChef {
  final int id;
  final String name;
  final String imageUrl;
  final double rating;
  final int totalOrders;
  final String specialty;
  final String location;
  final bool isVerified;
  final List<String> cuisines;
  final String description;
  final List<HomeFoodItem> menuItems;

  HomeChef({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.totalOrders,
    required this.specialty,
    required this.location,
    required this.isVerified,
    required this.cuisines,
    required this.description,
    required this.menuItems,
  });
}

class HomeFoodItem {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final bool isVegetarian;
  final bool isAvailable;
  final int preparationTime;

  HomeFoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.isVegetarian,
    required this.isAvailable,
    required this.preparationTime,
  });
}

final homeChefsProvider = Provider<List<HomeChef>>((ref) {
  return [
    HomeChef(
      id: 1,
      name: 'Priya\'s Kitchen',
      imageUrl: 'https://images.pexels.com/photos/3184291/pexels-photo-3184291.jpeg?auto=compress&cs=tinysrgb&w=400',
      rating: 4.8,
      totalOrders: 150,
      specialty: 'Traditional Indian',
      location: 'Koramangala, Bangalore',
      isVerified: true,
      cuisines: ['North Indian', 'South Indian', 'Bengali'],
      description: 'Authentic homemade Indian food with love and traditional recipes passed down through generations.',
      menuItems: [
        HomeFoodItem(
          id: 1,
          name: 'Mom\'s Special Biryani',
          description: 'Aromatic basmati rice with tender chicken, cooked in traditional dum style',
          price: 280.0,
          imageUrl: 'https://images.pexels.com/photos/11220209/pexels-photo-11220209.jpeg?auto=compress&cs=tinysrgb&w=400',
          isVegetarian: false,
          isAvailable: true,
          preparationTime: 45,
        ),
        HomeFoodItem(
          id: 2,
          name: 'Homestyle Dal Tadka',
          description: 'Yellow lentils tempered with cumin, garlic, and aromatic spices',
          price: 120.0,
          imageUrl: 'https://images.pexels.com/photos/5560763/pexels-photo-5560763.jpeg?auto=compress&cs=tinysrgb&w=400',
          isVegetarian: true,
          isAvailable: true,
          preparationTime: 30,
        ),
      ],
    ),
    HomeChef(
      id: 2,
      name: 'Amma\'s Tiffin Center',
      imageUrl: 'https://images.pexels.com/photos/3184338/pexels-photo-3184338.jpeg?auto=compress&cs=tinysrgb&w=400',
      rating: 4.6,
      totalOrders: 89,
      specialty: 'South Indian Breakfast',
      location: 'Indiranagar, Bangalore',
      isVerified: true,
      cuisines: ['South Indian', 'Tamil', 'Kerala'],
      description: 'Fresh South Indian breakfast and traditional meals made with authentic spices and techniques.',
      menuItems: [
        HomeFoodItem(
          id: 3,
          name: 'Fresh Idli Sambar',
          description: 'Soft steamed rice cakes with traditional sambar and coconut chutney',
          price: 80.0,
          imageUrl: 'https://images.pexels.com/photos/5560763/pexels-photo-5560763.jpeg?auto=compress&cs=tinysrgb&w=400',
          isVegetarian: true,
          isAvailable: true,
          preparationTime: 20,
        ),
        HomeFoodItem(
          id: 4,
          name: 'Crispy Masala Dosa',
          description: 'Golden crispy dosa with spiced potato filling and fresh chutneys',
          price: 100.0,
          imageUrl: 'https://images.pexels.com/photos/5560763/pexels-photo-5560763.jpeg?auto=compress&cs=tinysrgb&w=400',
          isVegetarian: true,
          isAvailable: true,
          preparationTime: 25,
        ),
      ],
    ),
    HomeChef(
      id: 3,
      name: 'Nani\'s Secret Recipes',
      imageUrl: 'https://images.pexels.com/photos/3184360/pexels-photo-3184360.jpeg?auto=compress&cs=tinysrgb&w=400',
      rating: 4.9,
      totalOrders: 203,
      specialty: 'Maharashtrian Cuisine',
      location: 'Whitefield, Bangalore',
      isVerified: true,
      cuisines: ['Maharashtrian', 'Gujarati', 'Rajasthani'],
      description: 'Traditional Maharashtrian delicacies prepared with authentic ingredients and grandmother\'s recipes.',
      menuItems: [
        HomeFoodItem(
          id: 5,
          name: 'Puran Poli',
          description: 'Sweet flatbread stuffed with jaggery and lentil filling',
          price: 60.0,
          imageUrl: 'https://images.pexels.com/photos/291528/pexels-photo-291528.jpeg?auto=compress&cs=tinysrgb&w=400',
          isVegetarian: true,
          isAvailable: true,
          preparationTime: 35,
        ),
      ],
    ),
  ];
});

class HomeFoodDeliveryScreen extends ConsumerStatefulWidget {
  const HomeFoodDeliveryScreen({super.key});

  @override
  _HomeFoodDeliveryScreenState createState() => _HomeFoodDeliveryScreenState();
}

class _HomeFoodDeliveryScreenState extends ConsumerState<HomeFoodDeliveryScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'North Indian', 'South Indian', 'Bengali', 'Maharashtrian'];

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);
    final homeChefs = ref.watch(homeChefsProvider);
    final filteredChefs = _selectedFilter == 'All' 
        ? homeChefs 
        : homeChefs.where((chef) => chef.cuisines.contains(_selectedFilter)).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Home Food Delivery',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: ResponsiveUtils.fontSize(20),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildFilterChips(),
          Expanded(
            child: ListView.builder(
              padding: ResponsiveUtils.padding(all: 16),
              itemCount: filteredChefs.length,
              itemBuilder: (context, index) {
                return _buildHomeChefCard(filteredChefs[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: ResponsiveUtils.padding(all: 20),
      margin: ResponsiveUtils.padding(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withValues(alpha: 0.8),
            Colors.teal.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.home,
                size: ResponsiveUtils.width(30),
                color: Colors.white,
              ),
              SizedBox(width: ResponsiveUtils.width(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Homemade with Love',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: ResponsiveUtils.fontSize(20),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Fresh, authentic meals from local home chefs',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: ResponsiveUtils.fontSize(14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.height(16)),
          Row(
            children: [
              _buildFeatureChip('🏠', 'Home Made'),
              SizedBox(width: ResponsiveUtils.width(8)),
              _buildFeatureChip('✅', 'Verified'),
              SizedBox(width: ResponsiveUtils.width(8)),
              _buildFeatureChip('🚚', 'Fresh Delivery'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String emoji, String text) {
    return Container(
      padding: ResponsiveUtils.padding(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: ResponsiveUtils.fontSize(12))),
          SizedBox(width: ResponsiveUtils.width(4)),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: ResponsiveUtils.fontSize(12),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: ResponsiveUtils.height(50),
      padding: ResponsiveUtils.padding(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });
            },
            child: Container(
              margin: ResponsiveUtils.padding(right: 8),
              padding: ResponsiveUtils.padding(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.green : Colors.grey[800],
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                filter,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: ResponsiveUtils.fontSize(14),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHomeChefCard(HomeChef chef) {
    return Container(
      margin: ResponsiveUtils.padding(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16.r),
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
          // Chef Header
          Padding(
            padding: ResponsiveUtils.padding(all: 16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: CachedNetworkImage(
                    imageUrl: chef.imageUrl,
                    width: ResponsiveUtils.width(60),
                    height: ResponsiveUtils.height(60),
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[800],
                      child: Icon(Icons.person, color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(width: ResponsiveUtils.width(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            chef.name,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: ResponsiveUtils.fontSize(16),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (chef.isVerified) ...[
                            SizedBox(width: ResponsiveUtils.width(4)),
                            Icon(
                              Icons.verified,
                              color: Colors.green,
                              size: ResponsiveUtils.width(16),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        chef.specialty,
                        style: GoogleFonts.poppins(
                          color: Colors.green,
                          fontSize: ResponsiveUtils.fontSize(14),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        chef.location,
                        style: GoogleFonts.poppins(
                          color: Colors.grey[400],
                          fontSize: ResponsiveUtils.fontSize(12),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: ResponsiveUtils.width(16),
                        ),
                        Text(
                          chef.rating.toString(),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: ResponsiveUtils.fontSize(14),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${chef.totalOrders} orders',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[400],
                        fontSize: ResponsiveUtils.fontSize(12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Description
          Padding(
            padding: ResponsiveUtils.padding(horizontal: 16),
            child: Text(
              chef.description,
              style: GoogleFonts.poppins(
                color: Colors.grey[300],
                fontSize: ResponsiveUtils.fontSize(14),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          SizedBox(height: ResponsiveUtils.height(12)),

          // Cuisines
          Padding(
            padding: ResponsiveUtils.padding(horizontal: 16),
            child: Wrap(
              spacing: 8,
              children: chef.cuisines.map((cuisine) => Container(
                padding: ResponsiveUtils.padding(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  cuisine,
                  style: GoogleFonts.poppins(
                    color: Colors.green,
                    fontSize: ResponsiveUtils.fontSize(12),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )).toList(),
            ),
          ),

          SizedBox(height: ResponsiveUtils.height(16)),

          // Menu Items
          SizedBox(
            height: ResponsiveUtils.height(120),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: ResponsiveUtils.padding(horizontal: 16),
              itemCount: chef.menuItems.length,
              itemBuilder: (context, index) {
                return _buildMenuItemCard(chef.menuItems[index]);
              },
            ),
          ),

          SizedBox(height: ResponsiveUtils.height(16)),

          // Action Buttons
          Padding(
            padding: ResponsiveUtils.padding(horizontal: 16, bottom: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showChefDetails(chef);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.green),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'View Menu',
                      style: GoogleFonts.poppins(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: ResponsiveUtils.width(12)),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Order from ${chef.name} - Coming Soon!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Order Now',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemCard(HomeFoodItem item) {
    return Container(
      width: ResponsiveUtils.width(140),
      margin: ResponsiveUtils.padding(right: 12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            child: CachedNetworkImage(
              imageUrl: item.imageUrl,
              width: double.infinity,
              height: ResponsiveUtils.height(60),
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[800],
                child: Icon(Icons.restaurant, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: ResponsiveUtils.padding(all: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (item.isVegetarian)
                      Container(
                        width: ResponsiveUtils.width(12),
                        height: ResponsiveUtils.height(12),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    SizedBox(width: ResponsiveUtils.width(4)),
                    Expanded(
                      child: Text(
                        item.name,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: ResponsiveUtils.fontSize(12),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveUtils.height(4)),
                Text(
                  '₹${item.price.toInt()}',
                  style: GoogleFonts.poppins(
                    color: Colors.green,
                    fontSize: ResponsiveUtils.fontSize(14),
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

  void _showChefDetails(HomeChef chef) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: ResponsiveUtils.padding(all: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  chef.name,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: ResponsiveUtils.fontSize(20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUtils.height(16)),
            Text(
              'Full Menu',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: ResponsiveUtils.fontSize(18),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: ResponsiveUtils.height(12)),
            ...chef.menuItems.map((item) => Container(
              margin: ResponsiveUtils.padding(bottom: 12),
              padding: ResponsiveUtils.padding(all: 12),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: CachedNetworkImage(
                      imageUrl: item.imageUrl,
                      width: ResponsiveUtils.width(50),
                      height: ResponsiveUtils.height(50),
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: ResponsiveUtils.width(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: ResponsiveUtils.fontSize(14),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          item.description,
                          style: GoogleFonts.poppins(
                            color: Colors.grey[400],
                            fontSize: ResponsiveUtils.fontSize(12),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '₹${item.price.toInt()} • ${item.preparationTime} mins',
                          style: GoogleFonts.poppins(
                            color: Colors.green,
                            fontSize: ResponsiveUtils.fontSize(12),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
} 