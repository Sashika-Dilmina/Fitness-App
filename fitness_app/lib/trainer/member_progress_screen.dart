import 'package:flutter/material.dart';
import '../../services/trainer_progress_service.dart';

class MemberProgressScreen extends StatelessWidget {
  const MemberProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = TrainerProgressService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Member Progress"),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      backgroundColor: const Color(0xFFF6F7FB),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: service.getMemberProgress(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final rows = snapshot.data ?? [];

          if (rows.isEmpty) {
            return const Center(
              child: Text("No members assigned yet"),
            );
          }

          /// 🔁 GROUP BY MEMBER
          final Map<String, List<Map<String, dynamic>>> grouped = {};

          for (final row in rows) {
            final memberId = row['member_id'];
            grouped.putIfAbsent(memberId, () => []);
            grouped[memberId]!.add(row);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: grouped.entries.map((entry) {
              final assignments = entry.value;
              final profile = assignments.first['profiles'];
              final name = profile?['display_name'] ?? 'Member';

              final total = assignments.length;
              final completed = assignments
                  .where((a) => a['status'] == 'completed')
                  .length;

              final percent =
                  total == 0 ? 0 : ((completed / total) * 100).round();

              final completedDates = assignments
                  .where((a) => a['completed_at'] != null)
                  .map((a) => DateTime.parse(a['completed_at']))
                  .toList();

              completedDates.sort((a, b) => b.compareTo(a));

              final lastCompleted =
                  completedDates.isEmpty ? null : completedDates.first;

              return _MemberProgressCard(
                name: name,
                total: total,
                completed: completed,
                percent: percent,
                lastCompleted: lastCompleted,
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
 class _MemberProgressCard extends StatelessWidget {
  final String name;
  final int total;
  final int completed;
  final int percent;
  final DateTime? lastCompleted;

  const _MemberProgressCard({
    required this.name,
    required this.total,
    required this.completed,
    required this.percent,
    this.lastCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          /// PROGRESS BAR
          LinearProgressIndicator(
            value: percent / 100,
            minHeight: 8,
            backgroundColor: Colors.grey.shade300,
            color: Colors.green,
            borderRadius: BorderRadius.circular(10),
          ),

          const SizedBox(height: 8),

          Text("$completed / $total workouts completed ($percent%)"),

          if (lastCompleted != null) ...[
            const SizedBox(height: 6),
            Text(
              "Last completed: ${lastCompleted!.toLocal()}",
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ],
      ),
    );
  }
}
