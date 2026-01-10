import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkoutView extends StatefulWidget {
  const WorkoutView({super.key});

  @override
  State<WorkoutView> createState() => WorkoutViewState();
}

class WorkoutViewState extends State<WorkoutView> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _workouts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchWorkouts();
  }

  /* ================= FETCH ================= */

  Future<void> _fetchWorkouts() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('workouts')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    if (!mounted) return;

    setState(() {
      _workouts = List<Map<String, dynamic>>.from(data);
      _loading = false;
    });
  }

  /* ================= ADD ================= */

  Future<void> addWorkout(String name, int minutes) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('workouts').insert({
      'user_id': user.id,
      'name': name,
      'minutes': minutes,
    });

    _fetchWorkouts();
  }

  /* ================= UPDATE ================= */

  Future<void> updateWorkout(String id, String name, int minutes) async {
    await supabase
        .from('workouts')
        .update({'name': name, 'minutes': minutes})
        .eq('id', id);

    _fetchWorkouts();
  }

  /* ================= DELETE ================= */

  Future<void> deleteWorkout(String id) async {
    await supabase.from('workouts').delete().eq('id', id);
    _fetchWorkouts();
  }

  /* ================= EDIT SHEET ================= */

  void _showEditSheet(Map<String, dynamic> workout) {
    final nameCtrl = TextEditingController(text: workout['name']);
    final minCtrl =
        TextEditingController(text: workout['minutes'].toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Edit Workout",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Workout name",
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: minCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Duration (minutes)",
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final min = int.tryParse(minCtrl.text);

                    if (name.isEmpty || min == null) return;

                    updateWorkout(workout['id'], name, min);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9EC9FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text("Update"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_workouts.isEmpty) {
      return const _EmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      itemCount: _workouts.length,
      itemBuilder: (context, index) {
        final w = _workouts[index];

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
                  color: const Color(0xFF9EC9FF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: Color(0xFF9EC9FF),
                ),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      w['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${w['minutes']} min",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _showEditSheet(w),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),
                onPressed: () => deleteWorkout(w['id']),
              ),
            ],
          ),
        );
      },
    );
  }
}

/* ================= EMPTY STATE ================= */

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.fitness_center, size: 60, color: Colors.black26),
          SizedBox(height: 16),
          Text(
            "No workouts yet",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "Tap + to add your first workout",
            style: TextStyle(color: Colors.black45),
          ),
        ],
      ),
    );
  }
}
