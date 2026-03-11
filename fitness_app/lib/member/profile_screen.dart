import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:fitness_app/theme/app_theme.dart';
import 'package:intl/intl.dart';

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

    await supabase.storage.from('avatars').upload(
          filePath,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    final publicUrl = supabase.storage.from('avatars').getPublicUrl(filePath);

    await supabase.from('profiles').update({
      'avatar_url': publicUrl,
    }).eq('user_id', user.id);

    setState(() {
      _avatarUrl = publicUrl;
    });

    _show("Profile picture updated");
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Profile Settings"),
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            // Profile Header
            Center(
              child: Stack(
                children: [
                   Hero(
                    tag: 'profile_avatar',
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: AppTheme.primaryLight,
                        backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                        child: _avatarUrl == null
                            ? const Icon(Icons.person_rounded, size: 48, color: AppTheme.primary)
                            : null,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickAndUploadAvatar,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.camera_alt_rounded, size: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

            const SizedBox(height: 24),

            Text(
              _displayName,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              _email,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 32),

            // Profile Stats (Dummy but looking good)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem("Weight", "72kg"),
                Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2)),
                _buildStatItem("Height", "178cm"),
                Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2)),
                _buildStatItem("Age", "24"),
              ],
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

            const SizedBox(height: 40),

            // Edit Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Personal Information",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateName,
                child: const Text("Save Changes"),
              ),
            ),

            const SizedBox(height: 32),

            // App Settings list
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  _buildSettingTile(
                    Icons.security_rounded,
                    "Account Security",
                    "Password, 2FA, Login logs",
                    () {},
                  ),
                  const Divider(indent: 50, endIndent: 20, height: 1),
                  _buildSettingTile(
                    Icons.notifications_active_rounded,
                    "Notifications",
                    "Alerts, reminders, tips",
                    () {},
                  ),
                  const Divider(indent: 50, endIndent: 20, height: 1),
                  _buildSettingTile(
                    Icons.info_outline_rounded,
                    "Member Status",
                    _role.toUpperCase(),
                    null,
                    trailing: const SizedBox(),
                  ),
                   const Divider(indent: 50, endIndent: 20, height: 1),
                  _buildSettingTile(
                    Icons.calendar_today_rounded,
                    "Joined Date",
                    _createdAt == null ? "-" : DateFormat('MMM dd, yyyy').format(_createdAt!),
                    null,
                    trailing: const SizedBox(),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

            const SizedBox(height: 40),

            // Logout Button
            TextButton.icon(
              icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
              label: const Text(
                "Sign Out",
                style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold),
              ),
              onPressed: _handleLogout,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textPrimary),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSettingTile(IconData icon, String title, String subtitle, VoidCallback? onTap, {Widget? trailing}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded, size: 18),
      onTap: onTap,
    );
  }

  void _handleLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Logout"),
        content: const Text("Are you sure you want to exit the app?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error, foregroundColor: Colors.white),
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
  }
}
