import 'package:flutter/material.dart';
import '../services/trainer_service.dart';

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      /* ================= APP BAR ================= */
      appBar: AppBar(
        title: const Text(
          "My Members",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),

      /* ================= BODY ================= */
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: TrainerService().getMyMembers(),
        builder: (context, snapshot) {
          // ⏳ Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❌ Error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading members\n${snapshot.error}",
                textAlign: TextAlign.center,
              ),
            );
          }

          final members = snapshot.data ?? [];

          // 🟡 Empty state
          if (members.isEmpty) {
            return const Center(
              child: Text(
                "No members assigned yet",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          // ✅ Members list
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: members.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final member = members[index];
              final profile = member['profiles'];

              return _MemberCard(
                name: profile['display_name'] ?? 'Unknown',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Member details coming soon"),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

/* ================= MEMBER CARD ================= */

class _MemberCard extends StatelessWidget {
  final String name;
  final VoidCallback onTap;

  const _MemberCard({
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFF9EC9FF),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
