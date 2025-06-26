import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/responsive_utils.dart';

class RestaurantCard extends StatefulWidget {
  final int id;
  final String name;
  final String imageUrl;
  final double rating;
  final String? offer;
  final int etaMinutes;
  final bool isHomeChef;
  final bool isGridView;

  const RestaurantCard({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    this.offer,
    required this.etaMinutes,
    required this.isHomeChef,
    this.isGridView = false,
    super.key,
  });

  @override
  State<RestaurantCard> createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<RestaurantCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isGridView ? _buildGridCard() : _buildListCard();
  }

  Widget _buildListCard() {
    return GestureDetector(
      onTap: () => context.push('/restaurant/${widget.id}'),
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: ResponsiveUtils.padding(
                horizontal: 16,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Row(
                  children: [
                    _buildImageSection(),
                    Expanded(child: _buildContentSection()),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridCard() {
    return GestureDetector(
      onTap: () => context.push('/restaurant/${widget.id}'),
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageSection(isGrid: true),
                    _buildContentSection(isGrid: true),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageSection({bool isGrid = false}) {
    final imageWidget = Stack(
      children: [
        CachedNetworkImage(
          imageUrl: widget.imageUrl,
          width: isGrid ? double.infinity : ResponsiveUtils.width(120),
          height: isGrid ? ResponsiveUtils.height(160) : ResponsiveUtils.height(120),
          fit: BoxFit.cover,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey[800]!,
            highlightColor: Colors.grey[600]!,
            child: Container(
              width: isGrid ? double.infinity : ResponsiveUtils.width(120),
              height: isGrid ? ResponsiveUtils.height(160) : ResponsiveUtils.height(120),
              color: Colors.grey[800],
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: isGrid ? double.infinity : ResponsiveUtils.width(120),
            height: isGrid ? ResponsiveUtils.height(160) : ResponsiveUtils.height(120),
            color: Colors.grey[800],
            child: Icon(
              Icons.restaurant,
              color: Colors.grey[400],
              size: ResponsiveUtils.width(40),
            ),
          ),
        ),
        
        // Rating Badge
        Positioned(
          top: ResponsiveUtils.height(8),
          left: ResponsiveUtils.width(8),
          child: Container(
            padding: ResponsiveUtils.padding(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: ResponsiveUtils.width(14),
                ),
                SizedBox(width: ResponsiveUtils.width(2)),
                Text(
                  widget.rating.toString(),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: ResponsiveUtils.fontSize(12),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ETA Badge
        Positioned(
          top: ResponsiveUtils.height(8),
          right: ResponsiveUtils.width(8),
          child: Container(
            padding: ResponsiveUtils.padding(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE23744).withOpacity(0.9),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              '${widget.etaMinutes} min',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: ResponsiveUtils.fontSize(11),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );

    return isGrid 
        ? imageWidget 
        : ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              bottomLeft: Radius.circular(16.r),
            ),
            child: imageWidget,
          );
  }

  Widget _buildContentSection({bool isGrid = false}) {
    return Padding(
      padding: ResponsiveUtils.padding(all: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Restaurant Name
          Text(
            widget.name,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: ResponsiveUtils.fontSize(16),
              fontWeight: FontWeight.w600,
            ),
            maxLines: isGrid ? 2 : 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          SizedBox(height: ResponsiveUtils.height(4)),
          
          // Tags Row
          Wrap(
            spacing: ResponsiveUtils.width(6),
            runSpacing: ResponsiveUtils.height(4),
            children: [
              if (widget.isHomeChef) _buildTag('Home Chef', Colors.blue),
              if (widget.offer != null) _buildTag(widget.offer!, Colors.green),
            ],
          ),
          
          if (!isGrid) SizedBox(height: ResponsiveUtils.height(8)),
          
          // Bottom Row (Rating, ETA for list view)
          if (!isGrid)
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: ResponsiveUtils.width(16),
                ),
                SizedBox(width: ResponsiveUtils.width(4)),
                Text(
                  widget.rating.toString(),
                  style: GoogleFonts.poppins(
                    color: Colors.grey[300],
                    fontSize: ResponsiveUtils.fontSize(14),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: ResponsiveUtils.width(12)),
                Icon(
                  Icons.access_time,
                  color: Colors.grey[400],
                  size: ResponsiveUtils.width(16),
                ),
                SizedBox(width: ResponsiveUtils.width(4)),
                Text(
                  '${widget.etaMinutes} mins',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[400],
                    fontSize: ResponsiveUtils.fontSize(14),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: ResponsiveUtils.padding(
        horizontal: 8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: color,
          fontSize: ResponsiveUtils.fontSize(10),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
