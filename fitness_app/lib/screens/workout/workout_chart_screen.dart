import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fitness_app/theme/app_theme.dart';

enum ChartMode { daily, weekly, monthly }

class WorkoutChartScreen extends StatefulWidget {
  const WorkoutChartScreen({super.key});

  @override
  State<WorkoutChartScreen> createState() => _WorkoutChartScreenState();
}

class _WorkoutChartScreenState extends State<WorkoutChartScreen> {
  final supabase = Supabase.instance.client;

  bool _loading = true;
  ChartMode _mode = ChartMode.daily;
  List<Map<String, dynamic>> _workouts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase.from('workouts').select().eq('user_id', user.id);

    if (!mounted) return;

    setState(() {
      _workouts = List<Map<String, dynamic>>.from(data);
      _loading = false;
    });
  }

  Map<int, int> _dailyData() {
    final Map<int, int> map = {};
    final now = DateTime.now();
    for (final w in _workouts) {
      final date = DateTime.parse(w['created_at']);
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        final hour = date.hour;
        map[hour] = (map[hour] ?? 0) + (w['minutes'] as int);
      }
    }
    return map;
  }

  Map<String, int> _weeklyData() {
    final Map<String, int> map = {};
    for (final w in _workouts) {
      final date = DateTime.parse(w['created_at']);
      final day = DateFormat('EEE').format(date);
      map[day] = (map[day] ?? 0) + (w['minutes'] as int);
    }
    return map;
  }

  Map<String, int> _monthlyData() {
    final Map<String, int> map = {};
    for (final w in _workouts) {
      final date = DateTime.parse(w['created_at']);
      final month = DateFormat('MMM').format(date);
      map[month] = (map[month] ?? 0) + (w['minutes'] as int);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    int totalMinutes = _workouts.fold(0, (sum, item) => sum + (item['minutes'] as int));

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Training Analytics"),
        surfaceTintColor: Colors.transparent,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsRow(totalMinutes).animate().fadeIn().slideY(begin: 0.1),
                  const SizedBox(height: 32),
                  Text("Workout Intensity", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  _toggle().animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 32),
                  Container(
                    height: 300,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: _barChart(),
                  ).animate().fadeIn(delay: 400.ms).scale(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsRow(int total) {
    return Row(
      children: [
        _buildStatCard("Total Workouts", _workouts.length.toString(), Icons.fitness_center_rounded, AppTheme.primary),
        const SizedBox(width: 16),
        _buildStatCard("Total Minutes", total.toString(), Icons.timer_rounded, AppTheme.secondary),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _toggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _toggleItem("Daily", _mode == ChartMode.daily, () => setState(() => _mode = ChartMode.daily)),
          _toggleItem("Weekly", _mode == ChartMode.weekly, () => setState(() => _mode = ChartMode.weekly)),
          _toggleItem("Monthly", _mode == ChartMode.monthly, () => setState(() => _mode = ChartMode.monthly)),
        ],
      ),
    );
  }

  Widget _toggleItem(String text, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: active
                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
                : null,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: active ? AppTheme.primary : AppTheme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _barChart() {
    late List<String> labels;
    late List<int> values;

    if (_mode == ChartMode.daily) {
      final data = _dailyData();
      labels = List.generate(24, (i) => "$i");
      values = List.generate(24, (i) => data[i] ?? 0);
    } else if (_mode == ChartMode.weekly) {
      final data = _weeklyData();
      labels = data.keys.toList();
      values = data.values.toList();
    } else {
      final data = _monthlyData();
      labels = data.keys.toList();
      values = data.values.toList();
    }

    if (values.every((v) => v == 0)) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded, size: 48, color: AppTheme.primary.withOpacity(0.2)),
          const SizedBox(height: 12),
          const Text("No activity data for this period", style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _mode == ChartMode.daily ? 4 : 1,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8,
                  child: Text(labels[i], style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(
          values.length,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: values[i].toDouble(),
                width: 12,
                color: AppTheme.primary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b).toDouble() * 1.2,
                  color: AppTheme.primaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
