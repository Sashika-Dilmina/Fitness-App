import 'package:flutter/material.dart';
import '../services/workout_service.dart';
import '../services/assignment_service.dart';
import '../services/member_service.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:fitness_app/theme/app_theme.dart';

class AssignWorkoutScreen extends StatefulWidget {
  const AssignWorkoutScreen({super.key});

  @override
  State<AssignWorkoutScreen> createState() => _AssignWorkoutScreenState();
}

class _AssignWorkoutScreenState extends State<AssignWorkoutScreen> {
  String? _selectedMemberId;
  String? _selectedWorkoutId;

  final _memberService = MemberService();
  final _workoutService = WorkoutService();
  final _assignmentService = AssignmentService();

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Assign Workout"),
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Management",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              "Select a member and choosing a training plan to assign to them.",
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 32),

            /* ================= MEMBERS ================= */
            _sectionLabel("Select Member", Icons.person_outline_rounded),
            const SizedBox(height: 12),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _memberService.getAllMembers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                }
                if (snapshot.hasError) return Text("Error: ${snapshot.error}");

                final members = snapshot.data ?? [];
                if (members.isEmpty) return const Text("No registered members found");

                final validIds = members.map((m) => m['user_id']).toSet();
                if (!validIds.contains(_selectedMemberId)) _selectedMemberId = null;

                return DropdownButtonFormField<String>(
                  value: _selectedMemberId,
                  items: members.map((m) {
                    return DropdownMenuItem<String>(
                      value: m['user_id'],
                      child: Text(m['display_name']),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedMemberId = v),
                  decoration: const InputDecoration(hintText: "Choose a member"),
                );
              },
            ),

            const SizedBox(height: 24),

            /* ================= WORKOUTS ================= */
            _sectionLabel("Select Workout Plan", Icons.fitness_center_rounded),
            const SizedBox(height: 12),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _workoutService.getMyWorkouts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                }
                if (snapshot.hasError) return Text("Error: ${snapshot.error}");

                final workouts = snapshot.data ?? [];
                if (workouts.isEmpty) return const Text("No workouts created yet");

                final validIds = workouts.map((w) => w['id']).toSet();
                if (!validIds.contains(_selectedWorkoutId)) _selectedWorkoutId = null;

                return DropdownButtonFormField<String>(
                  value: _selectedWorkoutId,
                  items: workouts.map((w) {
                    return DropdownMenuItem<String>(
                      value: w['id'],
                      child: Text(w['name']),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedWorkoutId = v),
                  decoration: const InputDecoration(hintText: "Choose a workout"),
                );
              },
            ),

            const SizedBox(height: 40),

            /* ================= ASSIGN BUTTON ================= */
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _assignWorkout,
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Confirm Assignment"),
              ),
            ),
          ],
        ).animate().fadeIn().slideY(begin: 0.1),
      ),
    );
  }

  Widget _sectionLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
        ),
      ],
    );
  }

  Future<void> _assignWorkout() async {
    if (_selectedMemberId == null || _selectedWorkoutId == null) {
      _showMsg("Please complete all selections", isError: true);
      return;
    }

    setState(() => _loading = true);

    try {
      await _assignmentService.assignWorkout(
        memberId: _selectedMemberId!,
        workoutId: _selectedWorkoutId!,
      );

      setState(() {
        _selectedMemberId = null;
        _selectedWorkoutId = null;
      });

      _showMsg("Workout assigned successfully ✨");
    } catch (e) {
      _showMsg(e.toString(), isError: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showMsg(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppTheme.error : AppTheme.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }
}
