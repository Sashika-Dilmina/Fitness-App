import 'package:flutter/material.dart';
import '../services/member_workout_service.dart';

class AssignedWorkoutsScreen extends StatelessWidget {
  const AssignedWorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = MemberWorkoutService();

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: service.getAssignedWorkouts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              snapshot.error.toString(),
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
          padding: const EdgeInsets.all(16),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            final workout = item['workouts'];

            if (workout == null) return const SizedBox();

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                leading: const Icon(Icons.fitness_center),
                title: Text(
                  workout['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(workout['description'] ?? ''),
                trailing: Text(
                  "${workout['minutes']} min",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
