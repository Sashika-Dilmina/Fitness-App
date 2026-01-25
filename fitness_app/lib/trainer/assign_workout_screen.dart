import 'package:flutter/material.dart';
import '../services/workout_service.dart';
import '../services/assignment_service.dart';
import '../services/member_service.dart';

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
      backgroundColor: const Color(0xFFF6F7FB),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Assign Workout",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Select a member and workout",
              style: TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 24),

            /* ================= MEMBERS ================= */
            const Text("Member"),
            const SizedBox(height: 6),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _memberService.getAllMembers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                }

                final members = snapshot.data ?? [];

                if (members.isEmpty) {
                  return const Text("No registered members found");
                }

                // Ensure selected value exists
                final validIds =
                    members.map((m) => m['user_id']).toSet();
                if (!validIds.contains(_selectedMemberId)) {
                  _selectedMemberId = null;
                }

                return DropdownButtonFormField<String>(
                  value: _selectedMemberId,
                  items: members.map((m) {
                    return DropdownMenuItem<String>(
                      value: m['user_id'],
                      child: Text(m['display_name']),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedMemberId = v),
                  decoration: _inputDecoration("Select Member"),
                );
              },
            ),

            const SizedBox(height: 16),

            /* ================= WORKOUTS ================= */
            const Text("Workout"),
            const SizedBox(height: 6),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _workoutService.getMyWorkouts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                }

                final workouts = snapshot.data ?? [];

                if (workouts.isEmpty) {
                  return const Text("No workouts created yet");
                }

                // Ensure selected value exists
                final validIds =
                    workouts.map((w) => w['id']).toSet();
                if (!validIds.contains(_selectedWorkoutId)) {
                  _selectedWorkoutId = null;
                }

                return DropdownButtonFormField<String>(
                  value: _selectedWorkoutId,
                  items: workouts.map((w) {
                    return DropdownMenuItem<String>(
                      value: w['id'],
                      child: Text(w['name']),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedWorkoutId = v),
                  decoration: _inputDecoration("Select Workout"),
                );
              },
            ),

            const SizedBox(height: 30),

            /* ================= ASSIGN BUTTON ================= */
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _assignWorkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9EC9FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Assign Workout",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ================= LOGIC ================= */

  Future<void> _assignWorkout() async {
    if (_selectedMemberId == null || _selectedWorkoutId == null) {
      _showMessage("Please select member and workout");
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

      _showMessage("Workout assigned successfully");
    } catch (e) {
      _showMessage(e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}
