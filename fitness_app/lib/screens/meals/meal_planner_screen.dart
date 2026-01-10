import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _meals = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchMeals();
  }

  /* ================= FETCH ================= */

  Future<void> _fetchMeals() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('meals')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    if (!mounted) return;

    setState(() {
      _meals = List<Map<String, dynamic>>.from(data);
      _loading = false;
    });
  }

  /* ================= ADD ================= */

  Future<void> _addMeal(String name, int calories) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('meals').insert({
      'user_id': user.id,
      'name': name,
      'calories': calories,
    });

    _fetchMeals();
  }

  /* ================= DELETE ================= */

  Future<void> _deleteMeal(String id) async {
    await supabase.from('meals').delete().eq('id', id);
    _fetchMeals();
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F8),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _meals.isEmpty
              ? _EmptyMealState(onAdd: _showAddMealSheet)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: _meals.length,
                  itemBuilder: (context, index) {
                    final meal = _meals[index];
                    return _MealCard(
                      meal: meal,
                      onDelete: () => _deleteMeal(meal['id']),
                    );
                  },
                ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF9EC9FF),
        onPressed: _showAddMealSheet,
        child: const Icon(Icons.add),
      ),
    );
  }

  /* ================= ADD SHEET ================= */

  void _showAddMealSheet() {
    final nameCtrl = TextEditingController();
    final calCtrl = TextEditingController();

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
                "Add Meal",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Meal name"),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: calCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Calories"),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final calories = int.tryParse(calCtrl.text);

                    if (name.isEmpty || calories == null) return;

                    _addMeal(name, calories);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9EC9FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text("Save"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/* ================= EMPTY STATE ================= */

class _EmptyMealState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyMealState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.restaurant, size: 60, color: Colors.black26),
          SizedBox(height: 16),
          Text(
            "No meals yet",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "Tap + to add your first meal",
            style: TextStyle(color: Colors.black45),
          ),
        ],
      ),
    );
  }
}

/* ================= MEAL CARD ================= */

class _MealCard extends StatelessWidget {
  final Map<String, dynamic> meal;
  final VoidCallback onDelete;

  const _MealCard({
    required this.meal,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
              color: const Color(0xFFFFC7A6).withOpacity(0.25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.restaurant, color: Color(0xFFFF9F68)),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${meal['calories']} kcal",
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
