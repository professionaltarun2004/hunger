import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/donation.dart';

class DonationsScreen extends ConsumerStatefulWidget {
  @override
  _DonationsScreenState createState() => _DonationsScreenState();
}

class _DonationsScreenState extends ConsumerState<DonationsScreen> {
  final _descriptionController = TextEditingController();
  List<Donation> donations = [];

  @override
  void initState() {
    super.initState();
    fetchDonations();
  }

  Future<void> fetchDonations() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please sign in to view donations')),
      );
      return;
    }

    final response = await supabase
        .from('donations')
        .select()
        .eq('user_id', user.id); // Removed .execute()

    if (response.isNotEmpty) {
      setState(() {
        donations = response.map((json) => Donation.fromJson(json)).toList();
      });
    }
  }

  Future<void> createDonation() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please sign in to create a donation')),
      );
      return;
    }

    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a description')),
      );
      return;
    }

    try {
      await supabase.from('donations').insert({
        'user_id': user.id,
        'restaurant_id': 1, // Example restaurant ID
        'description': _descriptionController.text,
      }); // Removed .execute()

      _descriptionController.clear();
      fetchDonations();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Donation created successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating donation: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.go('/profile'); // Navigate to ProfileScreen instead of exiting
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Donations',
              style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              context.go(
                  '/profile'); // Navigate to ProfileScreen on back button press
            },
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        hintText: 'Enter donation description',
                        hintStyle: GoogleFonts.poppins(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: createDonation,
                    child: Text('Add'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: donations.length,
                itemBuilder: (context, index) {
                  final donation = donations[index];
                  return Card(
                    color: Colors.grey[900],
                    child: ListTile(
                      title: Text(
                        donation.description,
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                      subtitle: Text(
                        'Restaurant ID: ${donation.restaurantId}',
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
