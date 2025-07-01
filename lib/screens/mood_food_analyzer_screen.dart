import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';
import '../providers/home_provider.dart';
import '../providers/restaurant_provider.dart';
import '../utils/responsive_utils.dart';

// Mood data provider
final moodAnalysisProvider = StateProvider<MoodAnalysis?>((ref) => null);

class MoodAnalysis {
  final String mood;
  final String emoji;
  final String description;
  final List<String> foodSuggestions;
  final Color color;
  final double confidence;

  MoodAnalysis({
    required this.mood,
    required this.emoji,
    required this.description,
    required this.foodSuggestions,
    required this.color,
    required this.confidence,
  });
}

class MoodFoodAnalyzerScreen extends ConsumerStatefulWidget {
  const MoodFoodAnalyzerScreen({super.key});

  @override
  _MoodFoodAnalyzerScreenState createState() => _MoodFoodAnalyzerScreenState();
}

class _MoodFoodAnalyzerScreenState extends ConsumerState<MoodFoodAnalyzerScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _analyzeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _isAnalyzing = false;
  String _selectedMoodInput = 'manual';
  List<String> _selectedEmotions = [];

  // Predefined moods and their food associations
  final Map<String, MoodAnalysis> _moodDatabase = {
    'happy': MoodAnalysis(
      mood: 'Happy',
      emoji: '😊',
      description: 'You\'re feeling great! Perfect time for comfort foods and treats.',
      foodSuggestions: ['Pizza', 'Burger', 'Ice Cream', 'Desserts', 'Celebration Cake'],
      color: Colors.orange,
      confidence: 0.9,
    ),
    'stressed': MoodAnalysis(
      mood: 'Stressed',
      emoji: '😰',
      description: 'Take a break with some comfort food that soothes your soul.',
      foodSuggestions: ['Soup', 'Tea', 'Chocolate', 'Pasta', 'Warm Milk'],
      color: Colors.red,
      confidence: 0.85,
    ),
    'sad': MoodAnalysis(
      mood: 'Sad',
      emoji: '😢',
      description: 'Comfort foods can help lift your spirits.',
      foodSuggestions: ['Ice Cream', 'Chocolate', 'Mac & Cheese', 'Cookies', 'Hot Chocolate'],
      color: Colors.blue,
      confidence: 0.8,
    ),
    'energetic': MoodAnalysis(
      mood: 'Energetic',
      emoji: '⚡',
      description: 'You\'re full of energy! Try something fresh and vibrant.',
      foodSuggestions: ['Salad', 'Smoothie', 'Fresh Fruits', 'Protein Bowl', 'Energy Bars'],
      color: Colors.green,
      confidence: 0.95,
    ),
    'romantic': MoodAnalysis(
      mood: 'Romantic',
      emoji: '💕',
      description: 'Perfect mood for a special meal with someone special.',
      foodSuggestions: ['Wine', 'Chocolate Fondue', 'Fine Dining', 'Candlelit Dinner', 'Champagne'],
      color: Colors.pink,
      confidence: 0.88,
    ),
    'adventurous': MoodAnalysis(
      mood: 'Adventurous',
      emoji: '🌟',
      description: 'Ready to try something new and exciting!',
      foodSuggestions: ['Exotic Cuisine', 'Fusion Food', 'Spicy Dishes', 'Street Food', 'International'],
      color: Colors.purple,
      confidence: 0.92,
    ),
    'tired': MoodAnalysis(
      mood: 'Tired',
      emoji: '😴',
      description: 'You need something easy and comforting.',
      foodSuggestions: ['Instant Noodles', 'Ready Meals', 'Coffee', 'Energy Drinks', 'Quick Bites'],
      color: Colors.grey,
      confidence: 0.87,
    ),
    'nostalgic': MoodAnalysis(
      mood: 'Nostalgic',
      emoji: '🥺',
      description: 'Craving foods that remind you of good times.',
      foodSuggestions: ['Home Style Cooking', 'Traditional Food', 'Mom\'s Recipes', 'Childhood Favorites', 'Local Cuisine'],
      color: Colors.brown,
      confidence: 0.83,
    ),
  };

  final List<String> _emotions = [
    'Happy', 'Sad', 'Stressed', 'Energetic', 'Tired', 'Romantic', 
    'Adventurous', 'Nostalgic', 'Excited', 'Calm', 'Anxious', 'Bored'
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _analyzeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _analyzeController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _analyzeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);
    final currentAnalysis = ref.watch(moodAnalysisProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'AI Mood Food Analyzer',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: ResponsiveUtils.fontSize(20),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () => _showHelpDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: ResponsiveUtils.padding(all: 20),
        child: Column(
          children: [
            _buildHeader(),
            SizedBox(height: ResponsiveUtils.height(30)),
            _buildMoodInputSelector(),
            SizedBox(height: ResponsiveUtils.height(30)),
            if (_selectedMoodInput == 'manual') _buildManualMoodInput(),
            if (_selectedMoodInput == 'ai') _buildAIMoodAnalyzer(),
            if (_selectedMoodInput == 'voice') _buildVoiceMoodAnalyzer(),
            SizedBox(height: ResponsiveUtils.height(30)),
            if (currentAnalysis != null) _buildMoodResults(currentAnalysis),
            if (currentAnalysis != null) _buildFoodRecommendations(currentAnalysis),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: ResponsiveUtils.padding(all: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE23744).withValues(alpha: 0.8),
            Colors.purple.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          Icon(
            Icons.psychology,
            size: ResponsiveUtils.width(60),
            color: Colors.white,
          ),
          SizedBox(height: ResponsiveUtils.height(16)),
          Text(
            'Discover Your Perfect Food Match',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: ResponsiveUtils.fontSize(22),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.height(8)),
          Text(
            'Let AI analyze your mood and recommend the perfect food to match your feelings',
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: ResponsiveUtils.fontSize(14),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMoodInputSelector() {
    return Container(
      padding: ResponsiveUtils.padding(all: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How would you like to analyze your mood?',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: ResponsiveUtils.fontSize(16),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: ResponsiveUtils.height(16)),
          Row(
            children: [
              _buildInputOption('manual', '🤔', 'Manual', 'Tell us how you feel'),
              SizedBox(width: ResponsiveUtils.width(12)),
              _buildInputOption('ai', '🤖', 'AI Camera', 'Facial expression analysis'),
              SizedBox(width: ResponsiveUtils.width(12)),
              _buildInputOption('voice', '🎤', 'Voice', 'Voice tone analysis'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputOption(String type, String emoji, String title, String subtitle) {
    final isSelected = _selectedMoodInput == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedMoodInput = type;
          });
        },
        child: Container(
          padding: ResponsiveUtils.padding(all: 16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE23744).withValues(alpha: 0.2) : Colors.grey[800],
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? const Color(0xFFE23744) : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                emoji,
                style: TextStyle(fontSize: ResponsiveUtils.fontSize(24)),
              ),
              SizedBox(height: ResponsiveUtils.height(8)),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: ResponsiveUtils.fontSize(14),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: ResponsiveUtils.height(4)),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  color: Colors.grey[400],
                  fontSize: ResponsiveUtils.fontSize(10),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManualMoodInput() {
    return Container(
      padding: ResponsiveUtils.padding(all: 20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How are you feeling right now?',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: ResponsiveUtils.fontSize(18),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: ResponsiveUtils.height(16)),
          Text(
            'Select all emotions that describe your current mood:',
            style: GoogleFonts.poppins(
              color: Colors.grey[400],
              fontSize: ResponsiveUtils.fontSize(14),
            ),
          ),
          SizedBox(height: ResponsiveUtils.height(16)),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _emotions.map((emotion) {
              final isSelected = _selectedEmotions.contains(emotion);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedEmotions.remove(emotion);
                    } else {
                      _selectedEmotions.add(emotion);
                    }
                  });
                },
                child: Container(
                  padding: ResponsiveUtils.padding(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFE23744) : Colors.grey[800],
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    emotion,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: ResponsiveUtils.fontSize(14),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: ResponsiveUtils.height(24)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedEmotions.isNotEmpty ? _analyzeManualMood : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE23744),
                padding: ResponsiveUtils.padding(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Analyze My Mood',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: ResponsiveUtils.fontSize(16),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIMoodAnalyzer() {
    return Container(
      padding: ResponsiveUtils.padding(all: 20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: ResponsiveUtils.width(150),
                  height: ResponsiveUtils.height(150),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE23744).withValues(alpha: 0.5),
                      width: 3,
                    ),
                    color: Colors.grey[800],
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: ResponsiveUtils.width(60),
                    color: const Color(0xFFE23744),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: ResponsiveUtils.height(24)),
          Text(
            'AI Camera Analysis',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: ResponsiveUtils.fontSize(18),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: ResponsiveUtils.height(8)),
          Text(
            'Position your face in the camera circle and let AI analyze your facial expressions',
            style: GoogleFonts.poppins(
              color: Colors.grey[400],
              fontSize: ResponsiveUtils.fontSize(14),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.height(24)),
          ElevatedButton.icon(
            onPressed: _isAnalyzing ? null : _startAIAnalysis,
            icon: _isAnalyzing
                ? SizedBox(
                    width: ResponsiveUtils.width(20),
                    height: ResponsiveUtils.height(20),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(Icons.camera_alt, color: Colors.white),
            label: Text(
              _isAnalyzing ? 'Analyzing...' : 'Start Camera Analysis',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: ResponsiveUtils.fontSize(16),
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE23744),
              padding: ResponsiveUtils.padding(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceMoodAnalyzer() {
    return Container(
      padding: ResponsiveUtils.padding(all: 20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: ResponsiveUtils.width(150),
                  height: ResponsiveUtils.height(150),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.5),
                      width: 3,
                    ),
                    color: Colors.grey[800],
                  ),
                  child: Icon(
                    Icons.mic,
                    size: ResponsiveUtils.width(60),
                    color: Colors.green,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: ResponsiveUtils.height(24)),
          Text(
            'Voice Tone Analysis',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: ResponsiveUtils.fontSize(18),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: ResponsiveUtils.height(8)),
          Text(
            'Speak about how you\'re feeling and let AI analyze your voice tone to determine your mood',
            style: GoogleFonts.poppins(
              color: Colors.grey[400],
              fontSize: ResponsiveUtils.fontSize(14),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.height(24)),
          ElevatedButton.icon(
            onPressed: _isAnalyzing ? null : _startVoiceAnalysis,
            icon: _isAnalyzing
                ? SizedBox(
                    width: ResponsiveUtils.width(20),
                    height: ResponsiveUtils.height(20),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(Icons.mic, color: Colors.white),
            label: Text(
              _isAnalyzing ? 'Listening...' : 'Start Voice Analysis',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: ResponsiveUtils.fontSize(16),
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: ResponsiveUtils.padding(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodResults(MoodAnalysis analysis) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: ResponsiveUtils.padding(all: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              analysis.color.withValues(alpha: 0.8),
              analysis.color.withValues(alpha: 0.4),
            ],
          ),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          children: [
            Text(
              analysis.emoji,
              style: TextStyle(fontSize: ResponsiveUtils.fontSize(60)),
            ),
            SizedBox(height: ResponsiveUtils.height(16)),
            Text(
              'You\'re feeling ${analysis.mood}!',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: ResponsiveUtils.fontSize(24),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: ResponsiveUtils.height(8)),
            Text(
              analysis.description,
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: ResponsiveUtils.fontSize(16),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.height(16)),
            Container(
              padding: ResponsiveUtils.padding(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                '${(analysis.confidence * 100).toInt()}% Confidence',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: ResponsiveUtils.fontSize(14),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodRecommendations(MoodAnalysis analysis) {
    final dishes = ref.watch(popularDishesProvider).value ?? [];
    final restaurants = ref.watch(restaurantProvider).value ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: ResponsiveUtils.height(24)),
        Text(
          'Perfect Food Matches for Your Mood',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: ResponsiveUtils.fontSize(20),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: ResponsiveUtils.height(16)),
        
        // Food categories based on mood
        SizedBox(
          height: ResponsiveUtils.height(120),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: analysis.foodSuggestions.length,
            itemBuilder: (context, index) {
              final suggestion = analysis.foodSuggestions[index];
              return Container(
                margin: ResponsiveUtils.padding(right: 12),
                width: ResponsiveUtils.width(100),
                decoration: BoxDecoration(
                  color: analysis.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: analysis.color.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getFoodIcon(suggestion),
                      color: analysis.color,
                      size: ResponsiveUtils.width(30),
                    ),
                    SizedBox(height: ResponsiveUtils.height(8)),
                    Text(
                      suggestion,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: ResponsiveUtils.fontSize(12),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        SizedBox(height: ResponsiveUtils.height(24)),
        Text(
          'Recommended Dishes',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: ResponsiveUtils.fontSize(18),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: ResponsiveUtils.height(16)),

        // Filtered dishes based on mood
        ...dishes.take(3).map((dish) => GestureDetector(
          onTap: () {
            // Navigate to restaurant detail page to order this dish
            final restaurant = restaurants.firstWhere(
              (r) => r.name == dish.restaurantName,
              orElse: () => restaurants.first,
            );
            if (restaurant != null) {
              context.push('/restaurant/${restaurant.id}');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Restaurant not found for ${dish.name}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Container(
            margin: ResponsiveUtils.padding(bottom: 12),
            padding: ResponsiveUtils.padding(all: 12),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: analysis.color.withValues(alpha: 0.3),
                width: 1,
              ),
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
                      Row(
                        children: [
                          Text(
                            '₹${dish.price.toInt()}',
                            style: GoogleFonts.poppins(
                              color: analysis.color,
                              fontSize: ResponsiveUtils.fontSize(16),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: ResponsiveUtils.padding(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: analysis.color.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              'Perfect Match',
                              style: GoogleFonts.poppins(
                                color: analysis.color,
                                fontSize: ResponsiveUtils.fontSize(10),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: analysis.color,
                  size: ResponsiveUtils.width(16),
                ),
              ],
            ),
          ),
        )),

        SizedBox(height: ResponsiveUtils.height(24)),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              context.push('/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: analysis.color,
              padding: ResponsiveUtils.padding(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'Order Now',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: ResponsiveUtils.fontSize(16),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getFoodIcon(String foodType) {
    switch (foodType.toLowerCase()) {
      case 'pizza':
        return Icons.local_pizza;
      case 'burger':
        return Icons.lunch_dining;
      case 'ice cream':
        return Icons.icecream;
      case 'coffee':
        return Icons.local_cafe;
      case 'soup':
        return Icons.soup_kitchen;
      case 'salad':
        return Icons.eco;
      case 'desserts':
        return Icons.cake;
      default:
        return Icons.restaurant;
    }
  }

  void _analyzeManualMood() {
    setState(() {
      _isAnalyzing = true;
    });

    // Simulate analysis delay
    Future.delayed(const Duration(seconds: 2), () {
      // Simple mood analysis based on selected emotions
      String primaryMood = _selectedEmotions.first.toLowerCase();
      
      // Map emotions to mood categories
      if (['happy', 'excited', 'energetic'].any((mood) => _selectedEmotions.map((e) => e.toLowerCase()).contains(mood))) {
        primaryMood = 'happy';
      } else if (['sad', 'nostalgic'].any((mood) => _selectedEmotions.map((e) => e.toLowerCase()).contains(mood))) {
        primaryMood = 'sad';
      } else if (['stressed', 'anxious'].any((mood) => _selectedEmotions.map((e) => e.toLowerCase()).contains(mood))) {
        primaryMood = 'stressed';
      } else if (['tired', 'bored'].any((mood) => _selectedEmotions.map((e) => e.toLowerCase()).contains(mood))) {
        primaryMood = 'tired';
      } else if (_selectedEmotions.map((e) => e.toLowerCase()).contains('romantic')) {
        primaryMood = 'romantic';
      } else if (_selectedEmotions.map((e) => e.toLowerCase()).contains('adventurous')) {
        primaryMood = 'adventurous';
      } else {
        primaryMood = 'energetic';
      }

      final analysis = _moodDatabase[primaryMood] ?? _moodDatabase['happy']!;
      ref.read(moodAnalysisProvider.notifier).state = analysis;
      
      setState(() {
        _isAnalyzing = false;
      });
      
      _analyzeController.forward();
    });
  }

  void _startAIAnalysis() {
    setState(() {
      _isAnalyzing = true;
    });

    // Simulate AI camera analysis
    Future.delayed(const Duration(seconds: 4), () {
      // Random mood for demo (in real app, this would be actual AI analysis)
      final random = Random();
      final moods = _moodDatabase.keys.toList();
      final randomMood = moods[random.nextInt(moods.length)];
      final analysis = _moodDatabase[randomMood]!;
      
      ref.read(moodAnalysisProvider.notifier).state = analysis;
      
      setState(() {
        _isAnalyzing = false;
      });
      
      _analyzeController.forward();
    });
  }

  void _startVoiceAnalysis() {
    setState(() {
      _isAnalyzing = true;
    });

    // Simulate voice analysis
    Future.delayed(const Duration(seconds: 3), () {
      // Random mood for demo (in real app, this would be actual voice analysis)
      final random = Random();
      final moods = _moodDatabase.keys.toList();
      final randomMood = moods[random.nextInt(moods.length)];
      final analysis = _moodDatabase[randomMood]!;
      
      ref.read(moodAnalysisProvider.notifier).state = analysis;
      
      setState(() {
        _isAnalyzing = false;
      });
      
      _analyzeController.forward();
    });
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'How It Works',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem('🤔', 'Manual', 'Select emotions that describe your current mood'),
            _buildHelpItem('🤖', 'AI Camera', 'Let AI analyze your facial expressions'),
            _buildHelpItem('🎤', 'Voice', 'Speak and let AI analyze your voice tone'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Got it!',
              style: GoogleFonts.poppins(
                color: const Color(0xFFE23744),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String emoji, String title, String description) {
    return Padding(
      padding: ResponsiveUtils.padding(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: TextStyle(fontSize: ResponsiveUtils.fontSize(20))),
          SizedBox(width: ResponsiveUtils.width(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: ResponsiveUtils.fontSize(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
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