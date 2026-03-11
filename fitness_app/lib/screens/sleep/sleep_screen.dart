import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fitness_app/theme/app_theme.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  final supabase = Supabase.instance.client;

  // Active sleep
  DateTime? sleepStart;
  String? sleepLogId;
  bool isSleeping = false;

  // 📊 Last sleep preview
  int? lastSleepMinutes;
  DateTime? lastSleepStart;
  DateTime? lastSleepEnd;

  Future<void> startSleep() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final now = DateTime.now();

    final res = await supabase
        .from('sleep_logs')
        .insert({
          'user_id': user.id,
          'sleep_start': now.toIso8601String(),
        })
        .select()
        .single();

    setState(() {
      sleepStart = now;
      sleepLogId = res['id'];
      isSleeping = true;
    });
  }

  Future<void> endSleep() async {
    if (sleepStart == null || sleepLogId == null) return;

    final end = DateTime.now();
    final duration = end.difference(sleepStart!).inMinutes;

    await supabase.from('sleep_logs').update({
      'sleep_end': end.toIso8601String(),
      'duration_minutes': duration,
    }).eq('id', sleepLogId!);

    setState(() {
      lastSleepMinutes = duration;
      lastSleepStart = sleepStart;
      lastSleepEnd = end;

      sleepStart = null;
      sleepLogId = null;
      isSleeping = false;
    });
  }

  String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  String formatDuration(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isSleeping 
              ? [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)]
              : [const Color(0xFF4B6CB7), const Color(0xFF182848)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Text(
                  "Sleep Status",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontSize: 24),
                ).animate().fadeIn().slideY(begin: -0.2),
                
                const Spacer(),

                /// 🌙 Animated Moon Container
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.1),
                            blurRadius: 40,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                     .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 2.seconds),
                    
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Colors.white, Color(0xFFE0E0E0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Icon(
                        isSleeping ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                        size: 80,
                        color: isSleeping ? const Color(0xFF1A1A1A) : Colors.orange,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 800.ms).scale(),

                const SizedBox(height: 60),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        isSleeping ? "Sleeping Mode Active" : "Ready to Drift Away?",
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isSleeping 
                          ? "Zzz... Tracked since ${formatTime(sleepStart!)}"
                          : "Track your rest to wake up refreshed and energized.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

                const SizedBox(height: 32),

                if (!isSleeping && lastSleepMinutes != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.history_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Last Night", style: TextStyle(color: Colors.white70, fontSize: 12)),
                              Text(
                                formatDuration(lastSleepMinutes!),
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                         Text(
                          "${formatTime(lastSleepStart!)} - ${formatTime(lastSleepEnd!)}",
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: isSleeping ? endSleep : startSleep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSleeping ? AppTheme.error : Colors.white,
                      foregroundColor: isSleeping ? Colors.white : const Color(0xFF182848),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    child: Text(
                      isSleeping ? "WAKE UP" : "GO TO SLEEP",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                  ),
                ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
