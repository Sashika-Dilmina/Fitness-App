import 'package:supabase_flutter/supabase_flutter.dart';

class TrainerService {
  final _supabase = Supabase.instance.client;

  /// Get members assigned to logged-in trainer
  Future<List<Map<String, dynamic>>> getMyMembers() async {
    final trainerId = _supabase.auth.currentUser!.id;

    final data = await _supabase
        .from('trainer_members')
        .select('member_id, profiles!trainer_members_member_id_fkey(display_name)')
        .eq('trainer_id', trainerId);

    return List<Map<String, dynamic>>.from(data);
  }
}
