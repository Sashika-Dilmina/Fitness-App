import 'package:flutter/material.dart';
import '../services/assignment_service.dart';

class MemberDetailsScreen extends StatelessWidget {
  final String memberId;
  final String memberName;

  const MemberDetailsScreen({
    super.key,
    required this.memberId,
    required this.memberName,
  });

  @override
  Widget build(BuildContext context) {
    final service = AssignmentService();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

     
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            const Text(
              "Assigned Workouts",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: service.getAssignmentsForMember(
                  memberId: memberId,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(snapshot.error.toString()),
                    );
                  }

                  final assignments = snapshot.data ?? [];

                  if (assignments.isEmpty) {
                    return const Center(
                      child: Text(
                        "No workouts assigned yet",
                        style: TextStyle(color: Colors.black54),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: assignments.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = assignments[index];
                      final workout = item['workouts'];

                      return _WorkoutCard(
                        name: workout['name'],
                        description: workout['description'],
                        assignedAt: item['assigned_at'],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ================= WORKOUT CARD ================= */

class _WorkoutCard extends StatelessWidget {
  final String name;
  final String? description;
  final String assignedAt;

  const _WorkoutCard({
    required this.name,
    this.description,
    required this.assignedAt,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(assignedAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          if (description != null && description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              description!,
              style: const TextStyle(color: Colors.black54),
            ),
          ],

          const SizedBox(height: 10),

          Text(
            "Assigned on ${date.day}/${date.month}/${date.year}",
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}
