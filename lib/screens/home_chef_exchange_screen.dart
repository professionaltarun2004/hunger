import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/home_chef_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeChefExchangeScreen extends ConsumerStatefulWidget {
  const HomeChefExchangeScreen({super.key});

  @override
  ConsumerState<HomeChefExchangeScreen> createState() => _HomeChefExchangeScreenState();
}

class _HomeChefExchangeScreenState extends ConsumerState<HomeChefExchangeScreen> {
  final TextEditingController _dishNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _availabilityController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void dispose() {
    _dishNameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _priceController.dispose();
    _availabilityController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _addHomeChefListing() async {
    final dishName = _dishNameController.text.trim();
    final description = _descriptionController.text.trim();
    final imageUrl = _imageUrlController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    final availability = _availabilityController.text.trim();
    final location = _locationController.text.trim();

    if (dishName.isEmpty ||
        description.isEmpty ||
        imageUrl.isEmpty ||
        price == null || price <= 0 ||
        availability.isEmpty ||
        location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields with valid data')),
      );
      return;
    }

    final homeChefNotifier = ref.read(homeChefNotifierProvider.notifier);
    await homeChefNotifier.addHomeChefListing(
      dishName: dishName,
      description: description,
      imageUrl: imageUrl,
      price: price,
      availability: availability,
      location: location,
    );

    final addState = ref.read(homeChefNotifierProvider);
    if (addState.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add listing: ${addState.error}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Home Chef Listing added successfully!')),
      );
      // Clear controllers after successful addition
      _dishNameController.clear();
      _descriptionController.clear();
      _imageUrlController.clear();
      _priceController.clear();
      _availabilityController.clear();
      _locationController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeChefListingsAsync = ref.watch(homeChefListingsProvider);
    final addListingState = ref.watch(homeChefNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Home-Chef Exchanges', style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Your Home-Chef Listing',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(_dishNameController, 'Dish Name'),
            const SizedBox(height: 12),
            _buildTextField(_descriptionController, 'Description', maxLines: 3),
            const SizedBox(height: 12),
            _buildTextField(_imageUrlController, 'Image URL', keyboardType: TextInputType.url),
            const SizedBox(height: 12),
            _buildTextField(_priceController, 'Price', keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _buildTextField(_availabilityController, 'Availability (e.g., Daily, Weekends)'),
            const SizedBox(height: 12),
            _buildTextField(_locationController, 'Your Location (e.g., Area Name)'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: addListingState.isLoading ? null : _addHomeChefListing,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE23744),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: addListingState.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                  : Text(
                      'Add Listing',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 40),

            Text(
              'Available Home-Chef Dishes',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            homeChefListingsAsync.when(
              data: (listings) {
                if (listings.isEmpty) {
                  return Center(
                    child: Text(
                      'No home chef listings available yet.',
                      style: GoogleFonts.poppins(color: Colors.grey[400]),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: listings.length,
                  itemBuilder: (context, index) {
                    final listing = listings[index];
                    return Card(
                      color: Colors.grey[900],
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              listing.dishName,
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              listing.description,
                              style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            CachedNetworkImage(
                              imageUrl: listing.imageUrl,
                              width: double.infinity,
                              height: 150,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => Icon(Icons.broken_image, color: Colors.grey[600], size: 50),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '₹${listing.price.toStringAsFixed(2)}',
                                  style: GoogleFonts.poppins(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 18),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${listing.rating.toStringAsFixed(1)} (${listing.numberOfRatings})',
                                      style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Availability: ${listing.availability}',
                              style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 13),
                            ),
                            Text(
                              'Location: ${listing.location}',
                              style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 13),
                            ),
                            // Add contact chef button or other interactions here
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE23744)))),
              error: (e, stack) => Center(
                child: Text(
                  'Error loading listings: $e',
                  style: GoogleFonts.poppins(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE23744), width: 1.5),
        ),
      ),
      style: GoogleFonts.poppins(color: Colors.white),
    );
  }
} 