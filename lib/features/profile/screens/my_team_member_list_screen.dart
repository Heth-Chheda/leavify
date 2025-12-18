import 'package:flutter/material.dart';
import 'package:leavify/core/utils/constants/api_endpoints.dart';
import 'package:leavify/features/Profile/components/profile_avatar.dart';
import 'package:leavify/features/profile/viewmodel/profile_view_model.dart';
import 'package:leavify/router/app_navigator.dart';
import 'package:leavify/router/route_names.dart';
import 'package:provider/provider.dart';

import '../data/models/get_user_reportees.dart';

class MyTeamMembersScreen extends StatefulWidget {
  final String userId;

  const MyTeamMembersScreen({super.key, required this.userId});

  @override
  State<MyTeamMembersScreen> createState() => _MyTeamMembersScreenState();
}

class _MyTeamMembersScreenState extends State<MyTeamMembersScreen> {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      _isInitialized = true;

      // ✅ Defer state change until AFTER build
      Future.microtask(() {
        context.read<ProfileViewModel>().getEmployeeList(widget.userId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileVM = context.watch<ProfileViewModel>();

    debugPrint(
      '[UI] isLoading=${profileVM.isLoading}, '
      'reportees=${profileVM.userReportees.length}',
    );

    if (profileVM.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (profileVM.userReportees.isEmpty) {
      debugPrint('[UI] Reportees list is EMPTY');
      return const Scaffold(body: Center(child: Text('No team members found')));
    }

    debugPrint('[UI] Rendering reportees list');

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: profileVM.userReportees.length,
        itemBuilder: (_, index) {
          final member = profileVM.userReportees[index];

          debugPrint(
            '[UI] Rendering member: '
            '${member.firstName} ${member.lastName}',
          );

          return _TeamMemberCard(member: member);
        },
      ),
    );
  }
}

class _TeamMemberCard extends StatelessWidget {
  final UserReportee member;

  const _TeamMemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        AppNavigator.navigateTo(
          RouteNames.otherUserProfile,
          arguments: member.userId,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: theme.colorScheme.onSurface.withOpacity(0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            ProfileAvatar(
              size: 52,
              baseUrl: ApiEndpoints.baseUrl,
              imagePath: (member.profileImagePath?.isNotEmpty ?? false)
                  ? member.profileImagePath
                  : null,
              initials: '${member.firstName[0]}${member.lastName[0]}',
            ),

            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${member.firstName} ${member.lastName}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    member.designation,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
