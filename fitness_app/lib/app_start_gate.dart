import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/auth_gate.dart';
import 'screens/welcome_screen.dart';

class AppStartGate extends StatefulWidget {
  const AppStartGate({super.key});

  @override
  State<AppStartGate> createState() => _AppStartGateState();
}

class _AppStartGateState extends State<AppStartGate> {
  bool? _hasSeenWelcome;

  @override
  void initState() {
    super.initState();
    _checkWelcome();
  }

  Future<void> _checkWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('hasSeenWelcome') ?? false;

    setState(() => _hasSeenWelcome = seen);
  }

  @override
  Widget build(BuildContext context) {
    if (_hasSeenWelcome == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasSeenWelcome == false) {
      return const WelcomeScreen();
    }

    return const AuthGate();
  }
}
