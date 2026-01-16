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
  String _selectedCategory = "All";

  final List<String> categories = [
    "All",
    "Breakfast",
    "Lunch",
    "Dinner",
    "Snack",
  ];

  @override
  void initState() {
    super.initState();
    _fetchMeals();
  }

  /* ================= FETCH ================= */

  Future<void> _fetchMeals() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    var query = supabase.from('meals').select().eq('user_id', user.id);

    if (_selectedCategory != "All") {
      query = query.eq('category', _selectedCategory);
    }

    final data = await query.order('created_at', ascending: false);

    if (!mounted) return;

    setState(() {
      _meals = List<Map<String, dynamic>>.from(data);
      _loading = false;
    });
  }

  /* ================= ADD ================= */

  Future<void> _addMeal(
    String name,
    int calories,
    String category,
  ) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('meals').insert({
      'user_id': user.id,
      'name': name,
      'calories': calories,
      'category': category,
    });

    _fetchMeals();
  }

  /* ================= UPDATE ================= */

  Future<void> _updateMeal(
    String id,
    String name,
    int calories,
    String category,
  ) async {
    await supabase.from('meals').update({
      'name': name,
      'calories': calories,
      'category': category,
    }).eq('id', id);

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

      body: Column(
        children: [
          _categoryFilter(),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _meals.isEmpty
                    ? const _EmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        itemCount: _meals.length,
                        itemBuilder: (context, index) {
                          final meal = _meals[index];
                          return _MealCard(
                            meal: meal,
                            onEdit: () => _showEditSheet(meal),
                            onDelete: () => _deleteMeal(meal['id']),
                          );
                        },
                      ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF9EC9FF),
        onPressed: _showAddSheet,
        child: const Icon(Icons.add),
      ),
    );
  }

  /* ================= CATEGORY FILTER ================= */

  Widget _categoryFilter() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: categories.map((cat) {
          final active = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ChoiceChip(
              label: Text(cat),
              selected: active,
              selectedColor: const Color(0xFF9EC9FF),
              onSelected: (_) {
                setState(() {
                  _selectedCategory = cat;
                  _loading = true;
                });
                _fetchMeals();
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  /* ================= ADD / EDIT SHEETS ================= */

  void _showAddSheet() {
    _showMealSheet(title: "Add Meal");
  }

  void _showEditSheet(Map<String, dynamic> meal) {
    _showMealSheet(
      title: "Edit Meal",
      meal: meal,
    );
  }

  void _showMealSheet({
    required String title,
    Map<String, dynamic>? meal,
  }) {
    final nameCtrl = TextEditingController(text: meal?['name']);
    final calCtrl =
        TextEditingController(text: meal?['calories']?.toString());
    String selectedCategory = meal?['category'] ?? "Breakfast";

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
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  TextField(
                    controller: nameCtrl,
                    decoration:
                        const InputDecoration(labelText: "Meal name"),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: calCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: "Calories"),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: categories
                        .where((e) => e != "All")
                        .map(
                          (cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setSheetState(() => selectedCategory = val!);
                    },
                    decoration:
                        const InputDecoration(labelText: "Category"),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        final name = nameCtrl.text.trim();
                        final cal = int.tryParse(calCtrl.text);

                        if (name.isEmpty || cal == null) return;

                        if (meal == null) {
                          _addMeal(name, cal, selectedCategory);
                        } else {
                          _updateMeal(
                            meal['id'],
                            name,
                            cal,
                            selectedCategory,
                          );
                        }

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
              );
            },
          ),
        );
      },
    );
  }
}

/* ================= MEAL CARD ================= */

class _MealCard extends StatelessWidget {
  final Map<String, dynamic> meal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MealCard({
    required this.meal,
    required this.onEdit,
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
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFFFC7A6).withOpacity(0.3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.restaurant),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meal['name'],
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  "${meal['calories']} kcal • ${meal['category']}",
                  style:
                      const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: Colors.redAccent),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

/* ================= EMPTY ================= */

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("No meals yet"),
    );
  }
}
