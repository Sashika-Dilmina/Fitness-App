import 'package:flutter/material.dart';
import 'package:fitness_app/screens/meals/meal_planner_screen.dart';
import 'package:fitness_app/screens/sleep/sleep_screen.dart';
import '../workout/workout_view.dart';
import '../workout/workout_chart_screen.dart';
import '../../services/auth_service.dart';
import 'package:fitness_app/member/profile_screen.dart';


import 'package:flutter_animate/flutter_animate.dart';
import 'package:fitness_app/theme/app_theme.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  int _currentIndex = 0;

  final List<String> _titles = [
    "Dashboard",
    "My Workouts",
    "Nutritional Plan",
    "Sleep Analysis",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,

      /* ================= APP BAR ================= */
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Text(
          _titles[_currentIndex],
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
            icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
            onPressed: _confirmLogout,
          ),
          const SizedBox(width: 8),
        ],
      ),

      /* ================= BODY ================= */
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildBody(),
      ),

      /* ================= BOTTOM NAV ================= */
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          elevation: 0,
          backgroundColor: Colors.transparent,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_rounded),
              activeIcon: Icon(Icons.fitness_center_rounded),
              label: "Workouts",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_rounded),
              activeIcon: Icon(Icons.restaurant_rounded),
              label: "Meals",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bedtime_rounded),
              activeIcon: Icon(Icons.bedtime_rounded),
              label: "Sleep",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _HomeContent(
          key: const ValueKey(0),
          onWorkoutTap: () => setState(() => _currentIndex = 1),
          onMealsTap: () => setState(() => _currentIndex = 2),
          onSleepTap: () => setState(() => _currentIndex = 3),
          onProfileTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
        );
      case 1:
        return const WorkoutView(key: ValueKey(1));
      case 2:
        return const MealPlannerScreen(key: ValueKey(2));
      case 3:
        return const SleepScreen(key: ValueKey(3));
      default:
        return const SizedBox();
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Logout"),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Stay"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
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

class _HomeContent extends StatelessWidget {
  final VoidCallback onWorkoutTap;
  final VoidCallback onMealsTap;
  final VoidCallback onSleepTap;
  final VoidCallback onProfileTap;

  const _HomeContent({
    super.key,
    required this.onWorkoutTap,
    required this.onMealsTap,
    required this.onSleepTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    "Hello, User 👋",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Ready for your session today?",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              GestureDetector(
                onTap: onProfileTap,
                child: Hero(
                  tag: 'profile_avatar',
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primary, width: 2),
                    ),
                    child: const CircleAvatar(
                      radius: 28,
                      backgroundColor: AppTheme.primaryLight,
                      child: Icon(Icons.person_rounded, color: AppTheme.primary),
                    ),
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),

          const SizedBox(height: 30),

          // Daily Progress Summary
          const _DailyProgressCard().animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

          const SizedBox(height: 30),

          Text(
             "Explore Categories",
            style: Theme.of(context).textTheme.titleLarge,
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 16),

          // Action Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              _CategoryCard(
                title: "Workouts",
                subtitle: "Assigned by Trainer",
                icon: Icons.fitness_center_rounded,
                color: AppTheme.primary,
                onTap: onWorkoutTap,
              ),
              _CategoryCard(
                title: "Nutrition",
                subtitle: "Daily Meal Plan",
                icon: Icons.restaurant_rounded,
                color: Colors.orange,
                onTap: onMealsTap,
              ),
              _CategoryCard(
                title: "Sleep",
                subtitle: "Rest & Recovery",
                icon: Icons.bedtime_rounded,
                color: Colors.indigo,
                onTap: onSleepTap,
              ),
              _CategoryCard(
                title: "Stats",
                subtitle: "Your Progress",
                icon: Icons.insights_rounded,
                color: AppTheme.success,
                onTap: onProfileTap,
              ),
            ],
          ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.9, 0.9)),

          const SizedBox(height: 30),

          // Recent Workouts Preview (Mock for design)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recently Assigned",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: onWorkoutTap,
                child: const Text("See all"),
              ),
            ],
          ).animate().fadeIn(delay: 700.ms),

          const SizedBox(height: 12),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 2,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: index == 0 ? AppTheme.primaryLight : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.fitness_center_rounded,
                      color: index == 0 ? AppTheme.primary : Colors.green,
                    ),
                  ),
                  title: Text(
                    index == 0 ? "Full Body HIIT" : "Morning Yoga",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text("45 mins • Intermediate"),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: onWorkoutTap,
                ),
              );
            },
          ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1),
        ],
      ),
    );
  }
}

class _DailyProgressCard extends StatelessWidget {
  const _DailyProgressCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Daily Progress",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "You're doing great!",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "75%",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.75,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSimpleStat("Kcal", "1,240"),
              _buildSimpleStat("Steps", "8,500"),
              _buildSimpleStat("Water", "1.5L"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
