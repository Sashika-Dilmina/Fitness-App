import 'package:fitness_app/screens/sleep/sleep_screen.dart';
import 'package:flutter/material.dart';
import 'package:fitness_app/screens/meals/meal_planner_screen.dart';
import '../workout/workout_view.dart';
import '../workout/workout_chart_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  int _currentIndex = 0;
  final workoutKey = GlobalKey<WorkoutViewState>();

  final List<String> _titles = [
    "Home",
    "Workouts",
    "Meals",
    "Sleep",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      /* ================= APP BAR ================= */
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          if (_currentIndex == 1)
            IconButton(
              icon: const Icon(Icons.bar_chart_rounded),
              color: Colors.black,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WorkoutChartScreen(),
                  ),
                );
              },
            ),
        ],
      ),

      /* ================= BODY ================= */
      body: _buildBody(),

      /* ================= FAB ================= */
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF9EC9FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              onPressed: () {
                _showAddWorkoutSheet(context);
              },
              child: const Icon(Icons.add, size: 28),
            )
          : null,

      /* ================= BOTTOM NAV ================= */
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF9EC9FF),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_rounded), label: "Workout"),
          BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_rounded), label: "Meals"),
          BottomNavigationBarItem(
              icon: Icon(Icons.bedtime_rounded), label: "Sleep"),
        ],
      ),
    );
  }

  /* ================= BODY SWITCH ================= */

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _HomeContent(
          onWorkoutTap: () => setState(() => _currentIndex = 1),
          onMealsTap: () => setState(() => _currentIndex = 2),
          onSleepTap: () => setState(() => _currentIndex = 3),
          onProfileTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Profile coming soon")),
            );
          },
        );
      case 1:
        return WorkoutView(key: workoutKey);
      case 2:
        return const MealPlannerScreen();
      case 3:
        return const SleepScreen();;
      default:
        return const SizedBox();
    }
  }

  /* ================= ADD WORKOUT SHEET ================= */

  void _showAddWorkoutSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final minCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            24,
            20,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 5,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Add Workout",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              TextField(
                controller: nameCtrl,
                decoration: _inputDecoration("Workout name"),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: minCtrl,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("Duration (minutes)"),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final min = int.tryParse(minCtrl.text);
                    if (name.isEmpty || min == null) return;
                    workoutKey.currentState?.addWorkout(name, min);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9EC9FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Save Workout",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF6F7FB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}


/* ================= HOME CONTENT ================= */

class _HomeContent extends StatelessWidget {
  final VoidCallback onWorkoutTap;
  final VoidCallback onMealsTap;
  final VoidCallback onSleepTap;
  final VoidCallback onProfileTap;

  const _HomeContent({
    required this.onWorkoutTap,
    required this.onMealsTap,
    required this.onSleepTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Welcome 👋",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            "Let’s track your daily activities",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54 ),
          ),

          /// 🔥 Push cards to vertical center
          const Spacer(),

          SizedBox(
            height: MediaQuery.of(context).size.height * 0.48,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.95,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                final cards = [
                  _DashboardCard(
                    title: "Workout",
                    icon: Icons.fitness_center,
                    color: const Color(0xFF9EC9FF),
                    onTap: onWorkoutTap,
                  ),
                  _DashboardCard(
                    title: "Meals",
                    icon: Icons.restaurant,
                    color: const Color(0xFFFFC7A6),
                    onTap: onMealsTap,
                  ),
                  _DashboardCard(
                    title: "Sleep",
                    icon: Icons.bedtime,
                    color: const Color(0xFFB5EAD7),
                    onTap: onSleepTap,
                  ),
                  _DashboardCard(
                    title: "Profile",
                    icon: Icons.person,
                    color: const Color(0xFFD6B4F8),
                    onTap: onProfileTap,
                  ),
                ];
                return cards[index];
              },
            ),
          ),

          /// 🔥 Balance bottom spacing
          const Spacer(),
        ],
      ),
    );
  }
}


/* ================= DASHBOARD CARD ================= */

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 42, color: Colors.white),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
