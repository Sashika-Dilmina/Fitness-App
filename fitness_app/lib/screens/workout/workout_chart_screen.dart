import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  /* ================= LOAD ================= */

  Future<void> _loadData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('workouts')
        .select()
        .eq('user_id', user.id);

    if (!mounted) return;

    setState(() {
      _workouts = List<Map<String, dynamic>>.from(data);
      _loading = false;
    });
  }

  /* ================= GROUPING ================= */

  // 📅 DAILY (hourly – today)
  Map<int, int> _dailyData() {
    final Map<int, int> map = {};
    final now = DateTime.now();

    for (final w in _workouts) {
      final date = DateTime.parse(w['created_at']);
      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        final hour = date.hour;
        map[hour] = (map[hour] ?? 0) + (w['minutes'] as int);
      }
    }
    return map;
  }

  // 📊 WEEKLY
  Map<String, int> _weeklyData() {
    final Map<String, int> map = {};
    for (final w in _workouts) {
      final date = DateTime.parse(w['created_at']);
      final day = DateFormat('EEE').format(date);
      map[day] = (map[day] ?? 0) + (w['minutes'] as int);
    }
    return map;
  }

  // 📈 MONTHLY
  Map<String, int> _monthlyData() {
    final Map<String, int> map = {};
    for (final w in _workouts) {
      final date = DateTime.parse(w['created_at']);
      final month = DateFormat('MMM').format(date);
      map[month] = (map[month] ?? 0) + (w['minutes'] as int);
    }
    return map;
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Workout Charts",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _toggle(),
                  const SizedBox(height: 24),
                  Expanded(child: _barChart()),
                ],
              ),
            ),
    );
  }

  /* ================= TOGGLE ================= */

  Widget _toggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _toggleItem("Daily", _mode == ChartMode.daily,
              () => setState(() => _mode = ChartMode.daily)),
          _toggleItem("Weekly", _mode == ChartMode.weekly,
              () => setState(() => _mode = ChartMode.weekly)),
          _toggleItem("Monthly", _mode == ChartMode.monthly,
              () => setState(() => _mode = ChartMode.monthly)),
        ],
      ),
    );
  }

  Widget _toggleItem(String text, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF9EC9FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: active ? Colors.white : Colors.black54,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /* ================= BAR CHART ================= */

  Widget _barChart() {
    late List<String> labels;
    late List<int> values;

    if (_mode == ChartMode.daily) {
      final data = _dailyData();
      if (data.isEmpty) {
        return const Center(child: Text("No workouts today"));
      }
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

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),

        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(value.toInt().toString()),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _mode == ChartMode.daily ? 3 : 1,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= labels.length) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8,
                  child: Text(labels[i]),
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
                width: 18,
                color: const Color(0xFF9EC9FF),
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
