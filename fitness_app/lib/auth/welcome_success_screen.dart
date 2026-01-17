import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fitness_app/screens/home/home_dashboard_screen.dart';

class WelcomeSuccessScreen extends StatefulWidget {
  const WelcomeSuccessScreen({super.key, required userName});

  @override
  State<WelcomeSuccessScreen> createState() => _WelcomeSuccessScreenState();
}

class _WelcomeSuccessScreenState extends State<WelcomeSuccessScreen> {
  final supabase = Supabase.instance.client;

  String _displayName = "User";
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchDisplayName();
  }

  Future<void> _fetchDisplayName() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await supabase
          .from('profiles')
          .select('display_name')
          .eq('user_id', user.id)
          .single();

      if (!mounted) return;

      setState(() {
        _displayName = data['display_name'] ?? "User";
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              /// Illustration
              SizedBox(
                height: size.height * 0.45,
                child: Image.asset(
                  'assets/images/welcome.png',
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 32),

              /// Title
              _loading
                  ? const CircularProgressIndicator()
                  : Text(
                      "Welcome, $_displayName",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),

              const SizedBox(height: 12),

              /// Subtitle
              const Text(
                "You are all set now, let’s reach your\ngoals together with us",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              /// Button
              SizedBox(
                width: double.infinity,
                height: 54,
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
                    backgroundColor: const Color(0xFF9DBBFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Go To Home",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
