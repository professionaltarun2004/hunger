// lib/widgets/filter_chips.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterChips extends StatelessWidget {
  const FilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    final filters = ['Filters', 'New to You', 'Friends\' Recos', 'Under ₹100'];
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                if (filters[index] == 'Filters') const Icon(Icons.filter_list, color: Colors.white, size: 16),
                if (filters[index] == 'Friends\' Recos') const Icon(Icons.thumb_up, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  filters[index],
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}