import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import '../providers/home_provider.dart';
import '../utils/responsive_utils.dart';

class MoodAnalysis {
  final String mood;
  final String emoji;
  final String description;
  final List<String> foodSuggestions;
  final Color color;

  MoodAnalysis({
    required this.mood,
    required this.emoji,
    required this.description,
    required this.foodSuggestions,
    required this.color,
  });
}

final moodAnalysisProvider = StateProvider<MoodAnalysis?>((ref) => null);

class MoodAnalyzerScreen extends ConsumerStatefulWidget {
  const MoodAnalyzerScreen({super.key});

  @override
  _MoodAnalyzerScreenState createState() => _MoodAnalyzerScreenState();
}

class _MoodAnalyzerScreenState extends ConsumerState<MoodAnalyzerScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _analyzeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _isAnalyzing = false;
  List<String> _selectedEmotions = [];

  final Map<String, MoodAnalysis> _moodDatabase = {
    'happy': MoodAnalysis(
      mood: 'Happy',
      emoji: '😊',
      description: 'You\'re feeling great! Perfect time for comfort foods and treats.',
      foodSuggestions: ['Pizza', 'Burger', 'Ice Cream', 'Desserts'],
      color: Colors.orange,
    ),
    'stressed': MoodAnalysis(
      mood: 'Stressed',
      emoji: '😰',
      description: 'Take a break with some comfort food that soothes your soul.',
      foodSuggestions: ['Soup', 'Tea', 'Chocolate', 'Pasta'],
      color: Colors.red,
    ),
    'sad': MoodAnalysis(
      mood: 'Sad',
      emoji: '😢',
      description: 'Comfort foods can help lift your spirits.',
      foodSuggestions: ['Ice Cream', 'Chocolate', 'Cookies', 'Hot Chocolate'],
      color: Colors.blue,
    ),
    'energetic': MoodAnalysis(
      mood: 'Energetic',
      emoji: '⚡',
      description: 'You\'re full of energy! Try something fresh and vibrant.',
      foodSuggestions: ['Salad', 'Smoothie', 'Fruits', 'Protein Bowl'],
      color: Colors.green,
    ),
    'romantic': MoodAnalysis(
      mood: 'Romantic',
      emoji: '💕',
      description: 'Perfect mood for a special meal with someone special.',
      foodSuggestions: ['Wine', 'Chocolate', 'Fine Dining', 'Desserts'],
      color: Colors.pink,
    ),
  };

  final List<String> _emotions = [
    'Happy', 'Sad', 'Stressed', 'Energetic', 'Tired', 'Romantic', 
    'Adventurous', 'Nostalgic', 'Excited', 'Calm'
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
          'Mood Food Analyzer',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: ResponsiveUtils.fontSize(20),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: ResponsiveUtils.padding(all: 20),
        child: Column(
          children: [
            _buildHeader(),
            SizedBox(height: ResponsiveUtils.height(30)),
            _buildMoodInput(),
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
            'How are you feeling?',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: ResponsiveUtils.fontSize(22),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMoodInput() {
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
              onPressed: _selectedEmotions.isNotEmpty ? _analyzeMood : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE23744),
                padding: ResponsiveUtils.padding(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: _isAnalyzing
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
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

  Widget _buildMoodResults(MoodAnalysis analysis) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: ResponsiveUtils.padding(all: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
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
          ],
        ),
      ),
    );
  }

  Widget _buildFoodRecommendations(MoodAnalysis analysis) {
    final dishes = ref.watch(popularDishesProvider).value ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: ResponsiveUtils.height(24)),
        Text(
          'Perfect Food Matches',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: ResponsiveUtils.fontSize(20),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: ResponsiveUtils.height(16)),
        
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
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.restaurant,
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

        ...dishes.take(3).map((dish) => Container(
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
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[800],
                    child: Icon(Icons.restaurant, color: Colors.grey),
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
                    Text(
                      dish.restaurantName,
                      style: GoogleFonts.poppins(
                        color: Colors.grey[400],
                        fontSize: ResponsiveUtils.fontSize(14),
                      ),
                    ),
                    Text(
                      '₹${dish.price.toInt()}',
                      style: GoogleFonts.poppins(
                        color: analysis.color,
                        fontSize: ResponsiveUtils.fontSize(16),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )),

        SizedBox(height: ResponsiveUtils.height(24)),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.push('/'),
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

  void _analyzeMood() {
    setState(() {
      _isAnalyzing = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      String primaryMood = 'happy';
      
      if (_selectedEmotions.any((e) => ['happy', 'excited', 'energetic'].contains(e.toLowerCase()))) {
        primaryMood = 'happy';
      } else if (_selectedEmotions.any((e) => ['sad', 'nostalgic'].contains(e.toLowerCase()))) {
        primaryMood = 'sad';
      } else if (_selectedEmotions.any((e) => ['stressed', 'anxious'].contains(e.toLowerCase()))) {
        primaryMood = 'stressed';
      } else if (_selectedEmotions.any((e) => ['tired', 'calm'].contains(e.toLowerCase()))) {
        primaryMood = 'energetic';
      } else if (_selectedEmotions.any((e) => e.toLowerCase() == 'romantic')) {
        primaryMood = 'romantic';
      }

      final analysis = _moodDatabase[primaryMood] ?? _moodDatabase['happy']!;
      ref.read(moodAnalysisProvider.notifier).state = analysis;
      
      setState(() {
        _isAnalyzing = false;
      });
      
      _analyzeController.forward();
    });
  }
} 