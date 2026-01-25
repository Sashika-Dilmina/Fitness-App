import 'package:supabase_flutter/supabase_flutter.dart';

class WorkoutService {
  final _supabase = Supabase.instance.client;

  /// Create new workout (trainer only)
  Future<void> createWorkout({
    required String name,
    required String description,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("Not authenticated");

    await _supabase.from('workouts').insert({
      'name': name,
      'description': description,
      'created_by': user.id,
    });
  }

  /// Get workouts created by logged-in trainer
  Future<List<Map<String, dynamic>>> getMyWorkouts() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("Not authenticated");

    final data = await _supabase
        .from('workouts')
        .select()
        .eq('created_by', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }
}
