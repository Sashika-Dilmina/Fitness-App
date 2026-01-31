import 'package:flutter/material.dart';
import '../../services/member_workout_service.dart';

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
    print("🔥 WorkoutView initState called");
    _reload();
  }

  void _reload() {
    _assignedWorkoutsFuture = _service.getAssignedWorkouts();
  }

  @override
  Widget build(BuildContext context) {
    print("🔥 WorkoutView build called");

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _assignedWorkoutsFuture,
      builder: (context, snapshot) {
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

            final assignmentId = item['id'];
            final status = item['status'] ?? 'pending';
            final completedAt = item['completed_at'];

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TOP ROW
                  Row(
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
                              "${workout['minutes']} min",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// STATUS BADGE
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: status == 'completed'
                              ? Colors.green.withOpacity(0.15)
                              : Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: status == 'completed'
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// DESCRIPTION
                  if (workout['description'] != null)
                    Text(
                      workout['description'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black54),
                    ),

                  /// COMPLETED DATE
                  if (completedAt != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      "Completed on ${DateTime.parse(completedAt).toLocal()}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ],

                  /// COMPLETE BUTTON
                  if (status == 'pending') ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () async {
                          await _service.markWorkoutCompleted(assignmentId);
                          setState(() {
                            _reload();
                          });
                        },
                        child: const Text("Mark Completed"),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}
