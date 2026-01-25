import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'members_screen.dart';


class TrainerHomeScreen extends StatelessWidget {
  const TrainerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      /* ================= APP BAR ================= */
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          "Trainer Dashboard",
          style: TextStyle(
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
              // AuthGate will handle redirect
            },
          ),
        ],
      ),

      /* ================= BODY ================= */
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome Trainer 👋",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Manage your members & workouts",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.95,
                ),
                children: [
                  _TrainerCard(
                    title: "Members",
                    icon: Icons.people_alt_rounded,
                    color: const Color(0xFF4B7BEC),
                   onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MembersScreen(),
                        ),
                      );
                    },

                  ),
                  _TrainerCard(
                    title: "Create Workout",
                    icon: Icons.add_circle_outline,
                    color: const Color(0xFF20BF6B),
                    onTap: () {
                      _comingSoon(context, "Create Workout");
                    },
                  ),
                  _TrainerCard(
                    title: "Assign Workout",
                    icon: Icons.assignment_turned_in_outlined,
                    color: const Color(0xFFEB3B5A),
                    onTap: () {
                      _comingSoon(context, "Assign Workout");
                    },
                  ),
                  _TrainerCard(
                    title: "Progress",
                    icon: Icons.bar_chart_rounded,
                    color: const Color(0xFFF7B731),
                    onTap: () {
                      _comingSoon(context, "Progress");
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$feature coming soon 🚀"),
      ),
    );
  }
}

/* ================= TRAINER CARD ================= */

class _TrainerCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TrainerCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
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
              textAlign: TextAlign.center,
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
