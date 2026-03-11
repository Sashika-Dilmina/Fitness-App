import 'package:flutter/material.dart';
import '../../services/member_workout_service.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:fitness_app/theme/app_theme.dart';
import 'package:intl/intl.dart';

class WorkoutView extends StatefulWidget {
  const WorkoutView({super.key});

  @override
  State<WorkoutView> createState() => _WorkoutViewState();
}

class _WorkoutViewState extends State<WorkoutView> {
  final _service = MemberWorkoutService();
  late Future<List<Map<String, dynamic>>> _assignedWorkoutsFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _assignedWorkoutsFuture = _service.getAssignedWorkouts();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _assignedWorkoutsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.error),
                const SizedBox(height: 16),
                Text("Error: ${snapshot.error}"),
              ],
            ),
          );
        }

        final data = snapshot.data ?? [];

        if (data.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fitness_center_rounded, size: 64, color: AppTheme.primary.withOpacity(0.2)),
                const SizedBox(height: 16),
                const Text(
                  "No workouts assigned yet",
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            final workout = item['workouts'];

            if (workout == null) return const SizedBox();

            final assignmentId = item['id'];
            final status = item['status'] ?? 'pending';
            final completedAt = item['completed_at'];
            final isCompleted = status == 'completed';

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isCompleted ? AppTheme.success.withOpacity(0.1) : AppTheme.primaryLight,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.fitness_center_rounded,
                              color: isCompleted ? AppTheme.success : AppTheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  workout['name'],
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.timer_outlined, size: 14, color: AppTheme.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${workout['minutes']} min session",
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isCompleted ? AppTheme.success.withOpacity(0.1) : Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isCompleted ? "COMPLETED" : "PENDING",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isCompleted ? AppTheme.success : Colors.amber[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (workout['description'] != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          workout['description'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                      if (isCompleted && completedAt != null) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 16, color: AppTheme.success),
                            const SizedBox(width: 6),
                            Text(
                              "Done on ${DateFormat('MMM dd, yyyy').format(DateTime.parse(completedAt).toLocal())}",
                              style: const TextStyle(fontSize: 12, color: AppTheme.success, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                      if (!isCompleted) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () async {
                              await _service.markWorkoutCompleted(assignmentId);
                              _reload();
                              setState(() {});
                            },
                            child: const Text("Complete Workout"),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1);
          },
        );
      },
    );
  }
}
