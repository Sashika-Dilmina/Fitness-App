import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final _supabase = Supabase.instance.client;

  Future<String> getUserRole() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('No logged in user');

    final data = await _supabase
        .from('profiles')
        .select('role')
        .eq('user_id', user.id)
        .single();

    return data['role'] as String;
  }
}
