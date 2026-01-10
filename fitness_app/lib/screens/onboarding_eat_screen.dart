import 'package:flutter/material.dart';
import 'onboarding_sleep_screen.dart';


class OnboardingEatScreen extends StatelessWidget {
  const OnboardingEatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔵 TOP IMAGE
              SizedBox(
                width: double.infinity,
                height: size.height * 0.52,
                child: Image.asset(
                  'assets/images/on_3.png',
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 24),

              // 📝 Title
              const Text(
                "Eat Well",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // 📄 Description
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  "Let’s start a healthy lifestyle with us, we can determine "
                  "your diet every day. Healthy eating is fun.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),

          // ➡️ FINAL NEXT BUTTON
          Positioned(
            bottom: 30,
            right: 30,
            child: GestureDetector(
             onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OnboardingSleepScreen(),
                  ),
                );
              },

              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF9EC9FF),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
