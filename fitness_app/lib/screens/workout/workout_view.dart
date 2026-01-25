import 'package:flutter/material.dart';
import '../../services/member_workout_service.dart';

class WorkoutView extends StatefulWidget {
  const WorkoutView({super.key});

  @override
  State<WorkoutView> createState() => _WorkoutViewState();
}

class _WorkoutViewState extends State<WorkoutView> {
  final _service = MemberWorkoutService();

  // ✅ Store future once
  late Future<List<Map<String, dynamic>>> _assignedWorkoutsFuture;

  @override
  void initState() {
    super.initState();
    print("🔥 WorkoutView initState called");

    _assignedWorkoutsFuture = _service.getAssignedWorkouts();
  }

  @override
  Widget build(BuildContext context) {
    print("🔥 WorkoutView build called");

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _assignedWorkoutsFuture,
      builder: (context, snapshot) {
        // 🔎 Debug snapshot state
        print("🧪 Snapshot state: ${snapshot.connectionState}");
        print("🧪 Snapshot data: ${snapshot.data}");

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error: ${snapshot.error}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final data = snapshot.data ?? [];

        if (data.isEmpty) {
          return const Center(
            child: Text(
              "No workouts assigned yet",
              style: TextStyle(color: Colors.black54),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            final workout = item['workouts'];

            if (workout == null) {
              print("⚠️ Workout is NULL at index $index");
              return const SizedBox();
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.fitness_center),
                  ),
                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          workout['description'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "${workout['minutes']} min",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
