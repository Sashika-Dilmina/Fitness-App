import 'package:flutter/material.dart';
import 'package:fitness_app/screens/meals/meal_planner_screen.dart';
import 'package:fitness_app/screens/sleep/sleep_screen.dart';
import '../workout/workout_view.dart';
import '../workout/workout_chart_screen.dart';
import '../../services/auth_service.dart';
import 'package:fitness_app/member/profile_screen.dart';


class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  int _currentIndex = 0;

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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WorkoutChartScreen(),
                  ),
                );
              },
            ),

          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _confirmLogout,
          ),
        ],
      ),

      /* ================= BODY ================= */
      body: _buildBody(),

      /* ❌ NO FAB FOR MEMBERS */

      /* ================= BOTTOM NAV ================= */
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF9EC9FF),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(),
                  ),
                );
              },

        );

      case 1:
        return const WorkoutView(); // ✅ ASSIGNED WORKOUTS ONLY

      case 2:
        return const MealPlannerScreen();

      case 3:
        return const SleepScreen();

      default:
        return const SizedBox();
    }
  }

  /* ================= LOGOUT ================= */

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await AuthService().logout();
            },
            child: const Text("Logout"),
          ),
        ],
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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),

          const Spacer(),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.95,
            children: [
              _DashboardCard(
                title: "Workout",
                icon: Icons.fitness_center,
                color: Colors.blue,
                onTap: onWorkoutTap,
              ),
              _DashboardCard(
                title: "Meals",
                icon: Icons.restaurant,
                color: Colors.orange,
                onTap: onMealsTap,
              ),
              _DashboardCard(
                title: "Sleep",
                icon: Icons.bedtime,
                color: Colors.green,
                onTap: onSleepTap,
              ),
              _DashboardCard(
                title: "Profile",
                icon: Icons.person,
                color: Colors.deepPurple,
                onTap: onProfileTap,
              ),
            ],
          ),

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
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
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
