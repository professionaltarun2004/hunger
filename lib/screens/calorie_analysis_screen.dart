import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/calorie_provider.dart';
import 'package:intl/intl.dart';
import '../models/calorie_entry.dart';

class CalorieAnalysisScreen extends ConsumerStatefulWidget {
  const CalorieAnalysisScreen({super.key});

  @override
  ConsumerState<CalorieAnalysisScreen> createState() => _CalorieAnalysisScreenState();
}

class _CalorieAnalysisScreenState extends ConsumerState<CalorieAnalysisScreen> {
  final TextEditingController _calorieController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _calorieController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: const Color(0xFFE23744), // Header background color
              onPrimary: Colors.white, // Header text color
              surface: Colors.grey[900]!, // Calendar background color
              onSurface: Colors.white, // Day text color
            ),
            dialogBackgroundColor: Colors.black,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.white), // OK/Cancel buttons
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _addCalorieEntry() async {
    final calories = int.tryParse(_calorieController.text);
    if (calories == null || calories <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid calorie amount')),
      );
      return;
    }

    final calorieNotifier = ref.read(calorieNotifierProvider.notifier);
    await calorieNotifier.addCalorieEntry(calories, _selectedDate);

    final addState = ref.read(calorieNotifierProvider);
    if (addState.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add entry: ${addState.error}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Calorie entry added!')),
      );
      _calorieController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final calorieEntriesAsync = ref.watch(calorieEntriesProvider);
    final calorieNotifierState = ref.watch(calorieNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Calorie Analysis', style: GoogleFonts.poppins(color: Colors.white)),
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
              'Add Daily Calorie Entry',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _calorieController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter calories for ${DateFormat('MMM dd').format(_selectedDate)}',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    DateFormat('MMM dd').format(_selectedDate),
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: calorieNotifierState.isLoading ? null : _addCalorieEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE23744),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: calorieNotifierState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                        )
                      : const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 32),

            Text(
              'Your Calorie Intake Over Time',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            calorieEntriesAsync.when(
              data: (entries) {
                if (entries.isEmpty) {
                  return Container(
                    height: 250,
                    alignment: Alignment.center,
                    child: Text(
                      'No calorie data yet. Add some entries!',
                      style: GoogleFonts.poppins(color: Colors.grey[400]),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                // Prepare data for the chart
                final Map<DateTime, int> dailyCalories = {};
                for (var entry in entries) {
                  final date = DateTime(entry.date.year, entry.date.month, entry.date.day);
                  dailyCalories[date] = (dailyCalories[date] ?? 0) + entry.calories;
                }

                // Sort dates and create spots
                final sortedDates = dailyCalories.keys.toList()..sort();
                final spots = sortedDates.asMap().entries.map((entry) {
                  final index = entry.key.toDouble();
                  final date = entry.value;
                  return FlSpot(index, dailyCalories[date]!.toDouble());
                }).toList();

                // Calculate min/max for chart axes
                final minX = spots.isNotEmpty ? spots.first.x : 0.0;
                final maxX = spots.isNotEmpty ? spots.last.x : 6.0; // Max 7 days for now
                final minY = spots.isNotEmpty ? spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 100 : 0.0;
                final maxY = spots.isNotEmpty ? spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 100 : 2500.0;

                // Generate bottom titles (dates)
                SideTitles getBottomTitles() {
                  return SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() < sortedDates.length) {
                        final date = sortedDates[value.toInt()];
                        return Text(DateFormat('dd/MM').format(date), style: GoogleFonts.poppins(color: Colors.grey, fontSize: 10));
                      }
                      return const Text('');
                    },
                  );
                }

                return Container(
                  height: 250,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: LineChart(
                    LineChartData(
                      minX: minX,
                      maxX: maxX,
                      minY: minY < 0 ? 0 : minY,
                      maxY: maxY,
                      gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: (maxY - minY) / 5, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey[800]!, strokeWidth: 0.8)),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(sideTitles: getBottomTitles()),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 500,
                            getTitlesWidget: (value, meta) {
                              return Text('${value.toInt()} kcal', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 10));
                            },
                            reservedSize: 40,
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey[700]!),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: const Color(0xFFE23744), // Primary app color
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: true, getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(color: Colors.white, radius: 4)),
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color(0xFFE23744).withOpacity(0.3),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(enabled: false),
                    ),
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE23744)),
                ),
              ),
              error: (e, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error loading calorie data: $e',
                      style: GoogleFonts.poppins(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(calorieEntriesProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Daily Intake Summary',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            calorieEntriesAsync.when(
              data: (entries) {
                if (entries.isEmpty) {
                  return Text(
                    'No summary available.',
                    style: GoogleFonts.poppins(color: Colors.grey[400]),
                  );
                }
                final Map<DateTime, int> dailyCalories = {};
                for (var entry in entries) {
                  final date = DateTime(entry.date.year, entry.date.month, entry.date.day);
                  dailyCalories[date] = (dailyCalories[date] ?? 0) + entry.calories;
                }

                final today = DateTime.now();
                final todayCalories = dailyCalories[DateTime(today.year, today.month, today.day)] ?? 0;

                final totalCalories = entries.fold(0, (sum, entry) => sum + entry.calories);
                final averageCalories = entries.isNotEmpty ? (totalCalories / dailyCalories.keys.length).round() : 0;

                return Column(
                  children: [
                    _buildSummaryRow(context, 'Today', '${todayCalories} kcal', todayCalories > 2000 ? Colors.redAccent : Colors.greenAccent), // Example goal
                    _buildSummaryRow(context, 'Average Daily', '${averageCalories} kcal', Colors.blueAccent),
                    _buildSummaryRow(context, 'Total Entries', '${entries.length}', Colors.grey[300]!),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE23744)))),
              error: (e, stack) => Text('Error loading summary: $e', style: GoogleFonts.poppins(color: Colors.redAccent)),
            ),
            const SizedBox(height: 24),
            Text(
              'Goals & Recommendations',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildRecommendationTile(context, 'Maintain a balanced diet and regular exercise for optimal health.'),
            _buildRecommendationTile(context, 'Stay hydrated throughout the day by drinking plenty of water.'),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.poppins(color: Colors.grey[300], fontSize: 16)),
          Text(value, style: GoogleFonts.poppins(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRecommendationTile(BuildContext context, String text) {
    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          text,
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
        ),
      ),
    );
  }
} 