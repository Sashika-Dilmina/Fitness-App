import 'package:fitness_app/trainer/assign_workout_screen.dart';
import 'package:fitness_app/trainer/create_workout_screen.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'members_screen.dart';

class TrainerHomeScreen extends StatefulWidget {
  const TrainerHomeScreen({super.key});

  @override
  State<TrainerHomeScreen> createState() => _TrainerHomeScreenState();
}

class _TrainerHomeScreenState extends State<TrainerHomeScreen> {
  int _currentIndex = 0;

  final List<String> _titles = [
    "Trainer Dashboard",
    "Members",
    "Workouts",
    "Assign Workouts",
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
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.black,
            onPressed: () async {
              await AuthService().logout();
            },
          ),
        ],
      ),

      /* ================= BODY ================= */
      body: _buildBody(),

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
            icon: Icon(Icons.dashboard_rounded),
            label: "Dashboard",
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
    );
  }

  /* ================= BODY SWITCH ================= */

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return TrainerDashboard(
          onCardTap: (index) {
            setState(() => _currentIndex = index);
          },
        );
      case 1:
        return const MembersScreen();
      case 2:
        return const CreateWorkoutScreen();
      case 3:
        return const AssignWorkoutScreen();
      default:
        return const SizedBox();
    }
  }
}

/* ================= DASHBOARD ================= */

class TrainerDashboard extends StatelessWidget {
  final Function(int) onCardTap;

  const TrainerDashboard({super.key, required this.onCardTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Welcome Coach 👋",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            "Manage your members and workouts",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),

          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.95,
              children: [
                TrainerCard(
                  title: "Members",
                  icon: Icons.people_alt_rounded,
                  color: const Color(0xFF4B7BEC),
                  onTap: () => onCardTap(1),
                ),
                TrainerCard(
                  title: "Create Workout",
                  icon: Icons.add_circle_outline,
                  color: const Color(0xFF20BF6B),
                  onTap: () => onCardTap(2),
                ),
                TrainerCard(
                  title: "Assign Workout",
                  icon: Icons.assignment_turned_in_outlined,
                  color: const Color(0xFFEB3B5A),
                  onTap: () => onCardTap(3),
                ),
                TrainerCard(
                  title: "Progress",
                  icon: Icons.bar_chart_rounded,
                  color: const Color(0xFFF7B731),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ================= PLACEHOLDERS ================= */

class CreateWorkoutPlaceholder extends StatelessWidget {
  const CreateWorkoutPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Create Workout Screen\n(Coming Next)",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class AssignWorkoutPlaceholder extends StatelessWidget {
  const AssignWorkoutPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Assign Workout Screen\n(Coming Next)",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/* ================= ANIMATED CARD ================= */

class TrainerCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const TrainerCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<TrainerCard> createState() => _TrainerCardState();
}

class _TrainerCardState extends State<TrainerCard> {
  double _scale = 1.0;

  void _onTapDown(_) {
    setState(() => _scale = 0.95); // shrink
  }

  void _onTapUp(_) {
    setState(() => _scale = 1.0); // back to normal
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 42, color: Colors.white),
              const SizedBox(height: 14),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
