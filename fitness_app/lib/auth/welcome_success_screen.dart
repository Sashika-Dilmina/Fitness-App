import 'package:fitness_app/auth/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WelcomeSuccessScreen extends StatefulWidget {
  const WelcomeSuccessScreen({super.key});

  @override
  State<WelcomeSuccessScreen> createState() => _WelcomeSuccessScreenState();
}

class _WelcomeSuccessScreenState extends State<WelcomeSuccessScreen> {
  final supabase = Supabase.instance.client;

  String _displayName = "User";
  String _role = "member";
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await supabase
          .from('profiles')
          .select('display_name, role')
          .eq('user_id', user.id)
          .single();

      if (!mounted) return;

      setState(() {
        _displayName = data['display_name'] ?? "User";
        _role = data['role'] ?? 'member';
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTrainer = _role == 'trainer';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              /// Illustration
              SizedBox(
                height: size.height * 0.4, // slightly smaller image
                child: Image.asset(
                  'assets/images/welcome.png',
                  fit: BoxFit.contain,
                ),
              ),

              /// Push text slightly downward
              const Spacer(flex: 1),

              /// Title
              _loading
                  ? const CircularProgressIndicator()
                  : Text(
                      isTrainer
                          ? "Welcome, Coach $_displayName 👋"
                          : "Welcome, $_displayName 🎉",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),

              const SizedBox(height: 12),

              /// Subtitle
              Text(
                isTrainer
                    ? "You’re all set to guide, train, and track\nyour members’ progress."
                    : "You are all set now, let’s reach your\ngoals together with us",
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              /// Push button to bottom
              const Spacer(flex: 2),

              /// Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const AuthGate()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9DBBFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isTrainer ? "Go To Trainer Dashboard" : "Go To Home",
                    style: const TextStyle(
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
