import 'package:supabase_flutter/supabase_flutter.dart';

class MemberService {
  final _supabase = Supabase.instance.client;

  /// 🔥 Get ALL registered members
  Future<List<Map<String, dynamic>>> getAllMembers() async {
    final data = await _supabase
        .from('profiles')
        .select('user_id, display_name')
        .eq('role', 'member')
        .order('display_name');

    return List<Map<String, dynamic>>.from(data);
  }
}
