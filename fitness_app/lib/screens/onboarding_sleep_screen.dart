import 'package:flutter/material.dart';
import '../auth/create_account_screen.dart';


class OnboardingSleepScreen extends StatelessWidget {
  const OnboardingSleepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔵 TOP IMAGE
              SizedBox(
                width: double.infinity,
                height: size.height * 0.52,
                child: Image.asset(
                  'assets/images/on_4.png',
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 24),

              // 📝 Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  "Improve Sleep\nQuality",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 📄 Description
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  "Improve the quality of your sleep with us, good quality "
                  "sleep can bring a good mood in the morning.",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),

          // ➡️ FINAL BUTTON (GO TO LOGIN)
          Positioned(
            bottom: 30,
            right: 30,
            child: GestureDetector(
             onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateAccountScreen(),
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
