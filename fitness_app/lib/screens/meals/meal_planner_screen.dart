import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fitness_app/theme/app_theme.dart';

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

  Future<void> _addMeal(String name, int calories, String category) async {
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

  Future<void> _updateMeal(String id, String name, int calories, String category) async {
    await supabase.from('meals').update({
      'name': name,
      'calories': calories,
      'category': category,
    }).eq('id', id);

    _fetchMeals();
  }

  Future<void> _deleteMeal(String id) async {
    await supabase.from('meals').delete().eq('id', id);
    _fetchMeals();
  }

  @override
  Widget build(BuildContext context) {
    int totalCalories = _meals.fold(0, (sum, item) => sum + (item['calories'] as int));

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(totalCalories).animate().fadeIn().slideY(begin: 0.1),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Daily Meals", style: Theme.of(context).textTheme.titleLarge),
                      _buildAddButton(),
                    ],
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 16),
                  _categoryFilter().animate().fadeIn(delay: 300.ms),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: _loading
                ? const SliverToBoxAdapter(child: Center(child: Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: CircularProgressIndicator(),
                )))
                : _meals.isEmpty
                    ? const SliverToBoxAdapter(child: _EmptyState())
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final meal = _meals[index];
                            return _MealCard(
                              meal: meal,
                              onEdit: () => _showEditSheet(meal),
                              onDelete: () => _deleteMeal(meal['id']),
                            ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1);
                          },
                          childCount: _meals.length,
                        ),
                      ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int total) {
    const int target = 2500;
    double progress = (total / target).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [AppTheme.secondary, AppTheme.secondary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Calorie Goal",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      total.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6, left: 4),
                      child: Text(
                        "/ 2500 kcal",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _showAddSheet,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
             Icon(Icons.add_rounded, color: Colors.white, size: 20),
             SizedBox(width: 4),
             Text("Add Meal", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _categoryFilter() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final active = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = cat;
                  _loading = true;
                });
                _fetchMeals();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? AppTheme.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: active ? AppTheme.primary : Colors.grey.withOpacity(0.2)),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    color: active ? Colors.white : AppTheme.textSecondary,
                    fontWeight: active ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddSheet() {
    _showMealSheet(title: "Log New Meal");
  }

  void _showEditSheet(Map<String, dynamic> meal) {
    _showMealSheet(title: "Update Meal", meal: meal);
  }

  void _showMealSheet({required String title, Map<String, dynamic>? meal}) {
    final nameCtrl = TextEditingController(text: meal?['name']);
    final calCtrl = TextEditingController(text: meal?['calories']?.toString());
    String selectedCategory = meal?['category'] ?? "Breakfast";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22)),
                  const SizedBox(height: 24),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: "What did you eat?", prefixIcon: Icon(Icons.restaurant_rounded)),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: calCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Calories (kcal)", prefixIcon: Icon(Icons.bolt_rounded)),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: categories.where((e) => e != "All").map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                    onChanged: (val) => setSheetState(() => selectedCategory = val!),
                    decoration: const InputDecoration(labelText: "Time of day", prefixIcon: Icon(Icons.access_time_rounded)),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final name = nameCtrl.text.trim();
                        final cal = int.tryParse(calCtrl.text);
                        if (name.isEmpty || cal == null) return;
                        if (meal == null) {
                          _addMeal(name, cal, selectedCategory);
                        } else {
                          _updateMeal(meal['id'], name, cal, selectedCategory);
                        }
                        Navigator.pop(context);
                      },
                      child: const Text("Keep Track"),
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

class _MealCard extends StatelessWidget {
  final Map<String, dynamic> meal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MealCard({required this.meal, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.restaurant_menu_rounded, color: Colors.orange, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meal['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildTag(meal['category'], Colors.blue),
                      const SizedBox(width: 8),
                      Text("${meal['calories']} kcal", style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert_rounded, color: AppTheme.textSecondary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_rounded, size: 18), SizedBox(width: 8), Text("Edit")])),
                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline_rounded, color: AppTheme.error, size: 18), SizedBox(width: 8), Text("Delete", style: TextStyle(color: AppTheme.error))])),
              ],
              onSelected: (val) {
                if (val == 'edit') onEdit();
                if (val == 'delete') onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 100),
          Icon(Icons.restaurant_rounded, size: 64, color: AppTheme.primary.withOpacity(0.1)),
          const SizedBox(height: 16),
          const Text("No meals logged yet", style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
        ],
      ),
    );
  }
}
