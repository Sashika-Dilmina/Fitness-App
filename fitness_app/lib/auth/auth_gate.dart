import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/profile_service.dart';
import 'login_screen.dart';
import '../screens/home/home_dashboard_screen.dart';
import '../trainer/trainer_home_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = supabase.auth.currentSession;

        // 🔴 NOT LOGGED IN
        if (session == null) {
          return const LoginScreen();
        }

        // 🟢 LOGGED IN → CHECK ROLE
        return FutureBuilder<String>(
          future: ProfileService().getUserRole(),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (roleSnapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Text(
                    'Error loading profile\n${roleSnapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final role = roleSnapshot.data;

            if (role == 'trainer') {
              return const TrainerHomeScreen();
            }

            return const HomeDashboardScreen(); // member
          },
        );
      },
    );
  }
}
