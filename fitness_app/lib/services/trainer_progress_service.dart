import 'package:supabase_flutter/supabase_flutter.dart';

class TrainerProgressService {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getMemberProgress() async {
    final trainerId = _supabase.auth.currentUser!.id;

    final response = await _supabase
        .from('workout_assignments')
        .select('''
          member_id,
          status,
          completed_at,
          profiles!workout_assignments_member_id_fkey (
            display_name
          )
        ''')
        .eq('trainer_id', trainerId);

    return List<Map<String, dynamic>>.from(response);
  }
}
