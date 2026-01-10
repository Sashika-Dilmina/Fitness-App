import 'package:flutter/material.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F8),

      // 🔝 App Bar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Fitness App",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),

      // 🏠 Body
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome 👋",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "Let’s track your daily activities",
              style: TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 30),

            // 🧱 Feature Cards
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: const [
                  _DashboardCard(
                    title: "Workout",
                    icon: Icons.fitness_center,
                    color: Color(0xFF9EC9FF),
                  ),
                  _DashboardCard(
                    title: "Meals",
                    icon: Icons.restaurant,
                    color: Color(0xFFFFC7A6),
                  ),
                  _DashboardCard(
                    title: "Sleep",
                    icon: Icons.bedtime,
                    color: Color(0xFFB5EAD7),
                  ),
                  _DashboardCard(
                    title: "Profile",
                    icon: Icons.person,
                    color: Color(0xFFD6B4F8),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // 🔻 Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        selectedItemColor: const Color(0xFF9EC9FF),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: "Workout",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: "Meals",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bedtime),
            label: "Sleep",
          ),
        ],
      ),
    );
  }
}

// 🧱 Dashboard Card Widget
class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.white),
          const SizedBox(height: 12),
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
    );
  }
}
