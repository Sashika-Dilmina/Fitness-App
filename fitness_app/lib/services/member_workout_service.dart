import 'package:supabase_flutter/supabase_flutter.dart';

class MemberWorkoutService {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getAssignedWorkouts() async {
    final user = _supabase.auth.currentUser;

    if (user == null) return [];

    final response = await _supabase
        .from('workout_assignments')
        .select('''
          id,
          assigned_at,
          workouts (
            id,
            name,
            description,
            minutes
          )
        ''')
        .eq('member_id', user.id)
        .order('assigned_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}
