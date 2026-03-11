import 'package:fitness_app/trainer/member_details_screen.dart';
import 'package:flutter/material.dart';
import '../services/trainer_service.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:fitness_app/theme/app_theme.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Search Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: "Search members...",
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary),
                hintStyle: const TextStyle(color: AppTheme.textSecondary),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
          ).animate().fadeIn().slideY(begin: -0.1),

          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: TrainerService().getMyMembers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.error),
                        const SizedBox(height: 16),
                        Text("Error loading members: ${snapshot.error}"),
                      ],
                    ),
                  );
                }

                final allMembers = snapshot.data ?? [];
                
                // Filter logic
                final members = allMembers.where((m) {
                  final name = (m['profiles']['display_name'] ?? "").toString().toLowerCase();
                  return name.contains(_searchQuery.toLowerCase());
                }).toList();

                if (members.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline_rounded, size: 64, color: AppTheme.primary.withOpacity(0.2)),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty ? "No members assigned yet" : "No members match your search",
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    final profile = member['profiles'];
                    final name = profile['display_name'] ?? 'Unknown';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MemberDetailsScreen(
                                memberId: member['member_id'],
                                memberName: name,
                              ),
                            ),
                          );
                        },
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Hero(
                          tag: 'avatar_${member['member_id']}',
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: AppTheme.primaryLight,
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text("Premium Member • Active Plan"),
                        trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
                      ),
                    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
