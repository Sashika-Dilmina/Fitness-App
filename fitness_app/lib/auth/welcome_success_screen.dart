import 'package:fitness_app/screens/home/home_dashboard_screen.dart';
import 'package:flutter/material.dart';

class WelcomeSuccessScreen extends StatelessWidget {
  const WelcomeSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Center(
          child: Container(
            width: size.width * 0.9, // 👈 wider card
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 32,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🖼️ Image (fits nicely)
                SizedBox(
                  height: size.height * 0.25,
                  child: Image.asset(
                    'assets/images/welcome.png',
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 24),

                // 📝 Title
                const Text(
                  "Welcome, Sashika",
                  style: TextStyle(
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
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

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
