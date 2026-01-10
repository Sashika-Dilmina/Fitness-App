import 'package:fitness_app/screens/home/home_dashboard_screen.dart';
import 'package:flutter/material.dart';

class WelcomeSuccessScreen extends StatelessWidget {
  final String userName;

  const WelcomeSuccessScreen({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Center(
          child: Container(
            width: size.width * 0.9,
            height: size.height * 0.9, // 👈 full card height
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 32,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              children: [
                // 🖼️ Image
                SizedBox(
                  height: size.height * 0.35,
                  child: Image.asset(
                    'assets/images/welcome.png',
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 24),

                // 📝 Title with Name
                Text(
                  "Welcome, $userName",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),

                // 📄 Subtitle
                const Text(
                  "You are all set now, let’s reach your goals together with us",
                  style: TextStyle(
                    color: Colors.black54,
                    height: 1.4,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(), // 👈 pushes button to bottom

                // 🔵 Go To Home Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomeDashboardScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9EC9FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Go To Home",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
