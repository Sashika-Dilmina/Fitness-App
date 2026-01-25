import 'package:supabase_flutter/supabase_flutter.dart';

class MemberWorkoutService {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getAssignedWorkouts() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      print("❌ No logged-in user");
      return [];
    }

    try {
      final response = await _supabase
          .from('workout_assignments')
          .select('''
            id,
            workouts:workout_id (
              id,
              name,
              minutes,
              description
            )
          ''')
          .eq('member_id', user.id)
          .order('created_at', ascending: false);

      print("✅ ASSIGNED RESPONSE: $response");

      // 🔑 IMPORTANT: always return a LIST
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("❌ ERROR fetching assigned workouts: $e");
      return [];
    }
  }
}
