import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      backgroundColor: const Color(0xFFF7F8FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),

              /// 🌙 Moon Icon
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isSleeping
                        ? [Colors.deepPurple, Colors.indigo]
                        : [Colors.indigo, Colors.blue],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withOpacity(0.4),
                      blurRadius: 25,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.nightlight_round,
                  size: 70,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 32),

              /// Status text
              Text(
                isSleeping
                    ? 'Sleeping since ${formatTime(sleepStart!)}'
                    : 'Ready to sleep?',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                isSleeping
                    ? 'Have a peaceful rest 😴'
                    : 'Track your sleep for better recovery',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),

              /// 📊 Sleep Duration Preview Card
              if (!isSleeping && lastSleepMinutes != null) ...[
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5A6BF5), Color(0xFF7B8CFF)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Last Sleep',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formatDuration(lastSleepMinutes!),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.nightlight_round,
                              size: 16, color: Colors.white70),
                          const SizedBox(width: 6),
                          Text(
                            '${formatTime(lastSleepStart!)} → ${formatTime(lastSleepEnd!)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              /// CTA Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isSleeping ? endSleep : startSleep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isSleeping ? Colors.redAccent : Colors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                  ),
                  child: Text(
                    isSleeping ? 'I Woke Up' : 'I\'m Going to Sleep',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
