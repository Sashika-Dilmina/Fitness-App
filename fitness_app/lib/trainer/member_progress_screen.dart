import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/trainer_progress_service.dart';

class MemberProgressScreen extends StatelessWidget {
  const MemberProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = TrainerProgressService();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Client Performance"),
        surfaceTintColor: Colors.transparent,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: service.getMemberProgress(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final rows = snapshot.data ?? [];
          if (rows.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline_rounded,
                      size: 64, color: AppTheme.primary.withOpacity(0.1)),
                  const SizedBox(height: 16),
                  const Text(
                    "No clients assigned yet",
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            );
          }

          final Map<String, List<Map<String, dynamic>>> grouped = {};
          for (final row in rows) {
            final memberId = row['member_id'];
            grouped.putIfAbsent(memberId, () => []);
            grouped[memberId]!.add(row);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final entry = grouped.entries.elementAt(index);
              final assignments = entry.value;
              final profile = assignments.first['profiles'];
              final name = profile?['display_name'] ?? 'Client';

              final total = assignments.length;
              final completed =
                  assignments.where((a) => a['status'] == 'completed').length;

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
              )
                  .animate()
                  .fadeIn(delay: (index * 100).ms)
                  .slideY(begin: 0.1);
            },
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
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                  child: Text(name[0],
                      style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary)),
                      Text("Completion Rate: $percent%",
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                _buildBadge(percent),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Workouts Progress",
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary)),
                Text("$completed / $total",
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percent / 100,
                minHeight: 10,
                backgroundColor: AppTheme.primaryLight,
                valueColor: AlwaysStoppedAnimation<Color>(
                    percent > 70 ? AppTheme.success : AppTheme.primary),
              ),
            ),
            if (lastCompleted != null) ...[
              const SizedBox(height: 20),
              Divider(color: Colors.grey.withOpacity(0.1)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.history_rounded,
                      size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    "Last completed: ${DateFormat('MMM dd, hh:mm a').format(lastCompleted!.toLocal())}",
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(int percent) {
    String label = percent > 80
        ? "Pro"
        : percent > 50
            ? "Active"
            : "Beginner";
    Color color = percent > 80
        ? AppTheme.success
        : percent > 50
            ? AppTheme.secondary
            : AppTheme.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}