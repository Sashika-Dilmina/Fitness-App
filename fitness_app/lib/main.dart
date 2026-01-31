import 'package:fitness_app/app_start_gate.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

 await Supabase.initialize(
    url: 'https://jptmxatqufwopvjqczgq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpwdG14YXRxdWZ3b3B2anFjemdxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc5ODM3NTksImV4cCI6MjA4MzU1OTc1OX0.Mljt29sscMTJqn-_gs7ZP0aw5EGKk2k11Ya4KwJEIc8',
  );

  await NotificationService.init();
  await NotificationService.requestPermission();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AppStartGate(),

    );
  }
}
