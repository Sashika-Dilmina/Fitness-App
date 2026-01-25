import 'package:supabase_flutter/supabase_flutter.dart';

class AssignmentService {
  final _supabase = Supabase.instance.client;

  /// Assign workout to member
Future<void> assignWorkout({
  required String memberId,
  required String workoutId,
}) async {
  final trainerId = _supabase.auth.currentUser!.id;

  // 1️⃣ Insert workout assignment (this can repeat)
  await _supabase.from('workout_assignments').insert({
    'trainer_id': trainerId,
    'member_id': memberId,
    'workout_id': workoutId,
  });

  // 2️⃣ Create trainer-member relation ONLY IF NOT EXISTS
  await _supabase.from('trainer_members').upsert(
    {
      'trainer_id': trainerId,
      'member_id': memberId,
    },
    onConflict: 'trainer_id,member_id', // 🔑 THIS FIXES IT
  );
}

  /// 🔥 GET ASSIGNED WORKOUTS FOR A MEMBER (TRAINER VIEW)
  Future<List<Map<String, dynamic>>> getAssignmentsForMember({
    required String memberId,
  }) async {
    final trainerId = _supabase.auth.currentUser!.id;

    final data = await _supabase
        .from('workout_assignments')
        .select(
          'assigned_at, workouts(name, description)',
        )
        .eq('trainer_id', trainerId)
        .eq('member_id', memberId)
        .order('assigned_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }
}
