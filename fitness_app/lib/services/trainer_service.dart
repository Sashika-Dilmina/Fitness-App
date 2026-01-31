import 'package:supabase_flutter/supabase_flutter.dart';

class TrainerService {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getMyMembers() async {
    final trainerId = _supabase.auth.currentUser!.id;

    final response = await _supabase
        .from('trainer_members')
        .select(
          'member_id, profiles!trainer_members_member_id_fkey(display_name)',
        )
        .eq('trainer_id', trainerId);

    // ✅ VERY IMPORTANT

    return List<Map<String, dynamic>>.from(response);
  }
}
