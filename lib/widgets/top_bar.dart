// lib/widgets/top_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:google_fonts/google_fonts.dart';

class TopBar extends ConsumerWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.white, size: 20),
              SizedBox(width: 4),
              DropdownButton<String>(
                value: 'Home',
                dropdownColor: Colors.grey[800],
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                items: [
                  DropdownMenuItem(value: 'Home', child: Text('Home')),
                  DropdownMenuItem(value: 'Work', child: Text('Work')),
                ],
                onChanged: (_) {},
              ),
              Spacer(),
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(
                    'https://subfggmfnkhrmissnwfo.supabase.co/storage/v1/object/public/images//default_avatar.png'),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Flat 416 Ushodayas Signature Deepthisrinag...',
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'VEG',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search "dosa"',
              hintStyle: GoogleFonts.poppins(color: Colors.grey),
              prefixIcon: Icon(Icons.search, color: Colors.white),
              suffixIcon: Icon(Icons.mic, color: Colors.white),
              filled: true,
              fillColor: Colors.grey[900],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            style: GoogleFonts.poppins(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
