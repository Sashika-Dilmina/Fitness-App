import 'package:flutter/material.dart';
import '../services/workout_service.dart';

class CreateWorkoutScreen extends StatefulWidget {
  const CreateWorkoutScreen({super.key});

  @override
  State<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends State<CreateWorkoutScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  bool _loading = false;
  final _service = WorkoutService();

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

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
              "Create Workout",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Add a new workout for your members",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            _inputField(
              controller: _nameController,
              label: "Workout Name",
            ),
            const SizedBox(height: 16),

            _inputField(
              controller: _descController,
              label: "Description",
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _createWorkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9EC9FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Save Workout",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 30),

            const Divider(),

            const SizedBox(height: 16),

            const Text(
              "My Workouts",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _service.getMyWorkouts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(snapshot.error.toString()),
                    );
                  }

                  final workouts = snapshot.data ?? [];

                  if (workouts.isEmpty) {
                    return const Center(
                      child: Text(
                        "No workouts created yet",
                        style: TextStyle(color: Colors.black54),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: workouts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final workout = workouts[index];

                      return _WorkoutCard(
                        name: workout['name'],
                        description: workout['description'],
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

  Future<void> _createWorkout() async {
    final name = _nameController.text.trim();
    final desc = _descController.text.trim();

    if (name.isEmpty) {
      _showMessage("Workout name is required");
      return;
    }

    setState(() => _loading = true);

    try {
      await _service.createWorkout(
        name: name,
        description: desc,
      );

      _nameController.clear();
      _descController.clear();

      setState(() => _loading = false);
      _showMessage("Workout created successfully");

      setState(() {}); // refresh list
    } catch (e) {
      setState(() => _loading = false);
      _showMessage(e.toString());
    }
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}

/* ================= WORKOUT CARD ================= */

class _WorkoutCard extends StatelessWidget {
  final String name;
  final String? description;

  const _WorkoutCard({
    required this.name,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
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
        ],
      ),
    );
  }
}
