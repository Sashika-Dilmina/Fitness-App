import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;
  final _picker = ImagePicker();

  bool _loading = true;

  String _displayName = '';
  String _email = '';
  String _role = '';
  String? _avatarUrl;
  DateTime? _createdAt;

  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  /* ================= LOAD PROFILE ================= */

  Future<void> _loadProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final profile = await supabase
          .from('profiles')
          .select('display_name, role, created_at, avatar_url')
          .eq('user_id', user.id)
          .single();

      setState(() {
        _displayName = profile['display_name'] ?? '';
        _role = profile['role'] ?? 'member';
        _createdAt = DateTime.parse(profile['created_at']);
        _avatarUrl = profile['avatar_url'];
        _email = user.email ?? '';
        _nameController.text = _displayName;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  /* ================= UPDATE NAME ================= */

  Future<void> _updateName() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('profiles').update({
      'display_name': _nameController.text.trim(),
    }).eq('user_id', user.id);

    setState(() {
      _displayName = _nameController.text.trim();
    });

    _show("Profile updated");
  }

  /* ================= AVATAR UPLOAD ================= */

  Future<void> _pickAndUploadAvatar() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked == null) return;

    final file = File(picked.path);
    final ext = picked.path.split('.').last;
    final filePath = '${user.id}/avatar.$ext';

    // Upload
    await supabase.storage.from('avatars').upload(
          filePath,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    final publicUrl =
        supabase.storage.from('avatars').getPublicUrl(filePath);

    // Save URL
    await supabase.from('profiles').update({
      'avatar_url': publicUrl,
    }).eq('user_id', user.id);

    setState(() {
      _avatarUrl = publicUrl;
    });

    _show("Profile picture updated");
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// Avatar
            GestureDetector(
              onTap: _pickAndUploadAvatar,
              child: CircleAvatar(
                radius: 46,
                backgroundColor: Colors.blue.withOpacity(0.15),
                backgroundImage:
                    _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                child: _avatarUrl == null
                    ? const Icon(
                        Icons.camera_alt,
                        size: 30,
                        color: Colors.blue,
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 14),

            Text(
              _displayName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              _email,
              style: const TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 24),

            /// Edit name
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Display Name",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _updateName,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9EC9FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text("Update Profile"),
              ),
            ),

            const SizedBox(height: 30),

            /// Info tiles
            _infoTile("Role", _role.toUpperCase()),
            _infoTile(
              "Joined",
              _createdAt == null
                  ? "-"
                  : "${_createdAt!.day}/${_createdAt!.month}/${_createdAt!.year}",
            ),

            const Spacer(),

            /// Logout
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.red),
                ),
                              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Logout"),
                    content: const Text("Are you sure you want to logout?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Logout"),
                      ),
                    ],
                  ),
                );

                if (ok == true) {
                  await AuthService().logout();
                  if (!mounted) return;
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },

              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
