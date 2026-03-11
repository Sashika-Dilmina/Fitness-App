import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fitness_app/trainer/assign_workout_screen.dart';
import 'package:fitness_app/trainer/create_workout_screen.dart';
import 'package:fitness_app/trainer/member_progress_screen.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'members_screen.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:fitness_app/theme/app_theme.dart';

class TrainerHomeScreen extends StatefulWidget {
  const TrainerHomeScreen({super.key});

  @override
  State<TrainerHomeScreen> createState() => _TrainerHomeScreenState();
}

class _TrainerHomeScreenState extends State<TrainerHomeScreen> {
  int _currentIndex = 0;
  String _displayName = "";

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('display_name')
          .eq('user_id', user.id)
          .single();
      if (mounted) {
        setState(() {
          _displayName = (data['display_name'] ?? "User").split(' ')[0];
        });
      }
    }
  }

  final List<String> _titles = [
    "Coach Dashboard",
    "Member Registry",
    "Workout Studio",
    "Plan Assignment",
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
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
            onPressed: () async {
              await AuthService().logout();
            },
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
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_rounded),
              label: "Members",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_rounded),
              label: "Workouts",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_turned_in_rounded),
              label: "Assign",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return TrainerDashboard(
          key: const ValueKey(0),
          displayName: _displayName,
          onCardTap: (index) => setState(() => _currentIndex = index),
        );
      case 1:
        return const MembersScreen(key: ValueKey(1));
      case 2:
        return const CreateWorkoutScreen(key: ValueKey(2));
      case 3:
        return const AssignWorkoutScreen(key: ValueKey(3));
      default:
        return const SizedBox();
    }
  }
}

class TrainerDashboard extends StatelessWidget {
  final String displayName;
  final Function(int) onCardTap;

  const TrainerDashboard({super.key, required this.displayName, required this.onCardTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome Coach ${displayName.isEmpty ? '' : displayName} 👋",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Manage your team and training plans",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.secondary,
                child: Icon(Icons.admin_panel_settings_rounded, color: Colors.white),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),

          const SizedBox(height: 30),

          // Stats Section
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: "Total Members",
                  value: "24",
                  icon: Icons.people_rounded,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: "Workouts",
                  value: "12",
                  icon: Icons.fitness_center_rounded,
                  color: AppTheme.success,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

          const SizedBox(height: 30),

          Text(
            "Quick Actions",
            style: Theme.of(context).textTheme.titleLarge,
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 16),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              _ActionCard(
                title: "View Members",
                subtitle: "Manage profiles",
                icon: Icons.people_alt_rounded,
                color: AppTheme.primary,
                onTap: () => onCardTap(1),
              ),
              _ActionCard(
                title: "New Workout",
                subtitle: "Create exercises",
                icon: Icons.add_circle_outline_rounded,
                color: AppTheme.success,
                onTap: () => onCardTap(2),
              ),
              _ActionCard(
                title: "Assign Now",
                subtitle: "Bulk assignment",
                icon: Icons.assignment_turned_in_rounded,
                color: AppTheme.accent,
                onTap: () => onCardTap(3),
              ),
              _ActionCard(
                title: "View Progress",
                subtitle: "User analytics",
                icon: Icons.bar_chart_rounded,
                color: AppTheme.warning,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MemberProgressScreen()),
                  );
                },
              ),
            ],
          ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.9, 0.9)),

          const SizedBox(height: 30),

          // Active Summary
          const _RecentActivitySection().animate().fadeIn(delay: 700.ms),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
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

class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Summary",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(24),
            image: DecorationImage(
              image: const NetworkImage('https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=800&q=80'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                AppTheme.primary.withOpacity(0.8),
                BlendMode.srcATop,
              ),
            ),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Training Efficiency",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Your members have completed 85% of assigned workouts this week. Keep it up!",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

