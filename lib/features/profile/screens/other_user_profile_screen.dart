import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leavify/core/utils/constants/api_endpoints.dart';
import 'package:leavify/core/utils/constants/status_color/status_colors.dart';
import 'package:leavify/features/Authentication/domain/models/user.dart';
import 'package:leavify/features/Home/viewmodel/home_view_model.dart';
import 'package:leavify/features/Leave/models/general/my_leaves.dart';
import 'package:leavify/features/Profile/components/info_card.dart';
import 'package:leavify/features/Profile/components/profile_avatar.dart';
import 'package:leavify/features/Profile/components/section_header.dart';
import 'package:leavify/features/profile/viewmodel/profile_view_model.dart';
import 'package:provider/provider.dart';

class OtherUserProfileScreen extends StatefulWidget {
  final String userId;

  const OtherUserProfileScreen({super.key, required this.userId});

  @override
  State<OtherUserProfileScreen> createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 1. Fetch User Summary for THIS specific userId
      context.read<HomeViewModel>().loadUserSummaryFromApi(
        userId: widget.userId,
      );

      // 2. Fetch Leaves for THIS specific userId
      context.read<ProfileViewModel>().loadUserLeaves(widget.userId);
    });
  }

  @override
  void dispose() {
    // Optional: Clear the data when leaving screen so next time it doesn't show stale data briefly
    // context.read<HomeViewModel>().clearOtherUserData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Watch HomeViewModel for the user details
    final homeViewModel = context.watch<HomeViewModel>();
    // Watch ProfileViewModel for the leave list
    final profileViewModel = context.watch<ProfileViewModel>();

    // USE THE NEW GETTERS FOR OTHER USER
    final user = homeViewModel.otherUser;
    final isLoading = homeViewModel.isLoading;

    if (isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
      );
    }

    if (user == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const BackButton(color: Colors.black),
        ),
        body: Center(
          child: Text('User not found', style: theme.textTheme.titleMedium),
        ),
      );
    }

    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        // Add an AppBar for back navigation since this is a pushed screen
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Profile Details",
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              homeViewModel.loadUserSummaryFromApi(userId: widget.userId),
              profileViewModel.loadUserLeaves(widget.userId),
            ]);
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header Section
                SizedBox(
                  height: 130,
                  width: double.infinity,
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      Container(
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: ProfileAvatar(
                          initials: '${user.firstName[0]}${user.lastName[0]}',
                          size: 100,
                          baseUrl: ApiEndpoints.baseUrl,
                          imagePath: (user.profileImageUrl?.isNotEmpty ?? false)
                              ? user.profileImageUrl
                              : null,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${user.firstName} ${user.lastName}'.trim(),
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                            Text(
                              user.designation ?? 'Unknown',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content Section
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Personal Information
                        const SectionHeader(title: 'Personal Information'),
                        const SizedBox(height: 16),
                        InfoCard(
                          icon: Icons.email_outlined,
                          title: 'Email Address',
                          value: user.email,
                          iconColor: Colors.blue[600],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: InfoCard(
                                icon: Icons.phone_outlined,
                                title: 'Mobile Number',
                                value: user.mobile,
                                iconColor: Colors.green[600],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InfoCard(
                                icon: Icons.calendar_today_outlined,
                                title: 'Joining Date',
                                value: _formatJoiningDate(user.joiningDate),
                                iconColor: Colors.purple[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Work Information
                        if (user.reportingTo.isNotEmpty ||
                            user.projectList.isNotEmpty) ...[
                          const SectionHeader(title: 'Work Information'),
                          const SizedBox(height: 16),
                          if (user.reportingTo.isNotEmpty) ...[
                            InfoCard(
                              icon: Icons.supervisor_account_outlined,
                              title: 'Reporting To',
                              value: user.reportingTo.join(', '),
                              iconColor: Colors.orange[600],
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (user.projectList.isNotEmpty) ...[
                            InfoCard(
                              icon: Icons.work_outline,
                              title: 'Projects',
                              value: user.projectList.join(', '),
                              iconColor: Colors.teal[600],
                            ),
                            const SizedBox(height: 30),
                          ],
                        ],

                        // Leave Information
                        const SectionHeader(title: 'Leave History'),
                        const SizedBox(height: 16),
                        _buildLeaveSection(profileViewModel, theme, user),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatJoiningDate(String joiningDate) {
    try {
      if (joiningDate.contains('T') || joiningDate.contains('-')) {
        final date = DateTime.parse(joiningDate);
        return DateFormat('dd MMM yyyy').format(date);
      }
      return joiningDate;
    } catch (e) {
      return joiningDate;
    }
  }

  Widget _buildLeaveSection(
    ProfileViewModel viewModel,
    ThemeData theme,
    User user,
  ) {
    if (viewModel.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      );
    }

    // Note: Reusing the leave list from ProfileViewModel.
    // Since we called loadUserLeaves(widget.userId) in initState,
    // viewModel.leaveData should contain THIS user's leaves.

    if (viewModel.leaveData != null &&
        viewModel.leaveData!.allLeaves.isNotEmpty) {
      final leaveData = viewModel.leaveData!;

      // We might want to hide the "Approved/Rejected/Pending" boxes for other users
      // and only show the list, or show everything. This implementation shows the list.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              // We reuse the boxes but mapped to this user's stats
              _buildLeaveSummaryBox(
                label: 'Approved',
                count: user.approved,
                theme: theme,
              ),
              _buildLeaveSummaryBox(
                label: 'Rejected',
                count: user.rejected,
                theme: theme,
              ),
              _buildLeaveSummaryBox(
                label: 'Pending',
                count: user.pending,
                theme: theme,
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            'Recent Applications',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (var leave
                  in List.from(leaveData.allLeaves)..sort((a, b) {
                    int fromCompare = b.fromDate.compareTo(a.fromDate);
                    return fromCompare != 0
                        ? fromCompare
                        : b.toDate.compareTo(a.toDate);
                  }))
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 20 * 2 - 12) / 2,
                  child: _buildLeaveItemCard(leave, theme),
                ),
            ],
          ),
        ],
      );
    }

    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(child: Text("No leave history found")),
    );
  }

  Widget _buildLeaveSummaryBox({
    required String label,
    required num count,
    required ThemeData theme,
  }) {
    String displayValue = count % 1 == 0
        ? count.toInt().toString()
        : count.toString();
    return Container(
      width:
          (MediaQuery.of(context).size.width - 20 * 2 - 12 * 2) /
          3, // Adjusted width for 3 items
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.18), width: 0.5),
      ),
      child: Column(
        children: [
          Text(
            displayValue,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveItemCard(MyLeaves leave, ThemeData theme) {
    // ... Copy the exact implementation from ProfileScreen ...
    // (Pasting simplified version here for brevity, use your original ProfileScreen card code)
    final String statusUpper = leave.status.toUpperCase();
    final Color statusColor = StatusColors.fromStatus(leave.status);
    final bool isSingleDay =
        DateFormat('dd MMM yyyy').format(leave.fromDate) ==
        DateFormat('dd MMM yyyy').format(leave.toDate);

    return Container(
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.09),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isSingleDay
                ? DateFormat('dd MMM').format(leave.fromDate)
                : "${DateFormat('dd MMM').format(leave.fromDate)} - ${DateFormat('dd MMM').format(leave.toDate)}",
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            leave.reason,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusUpper,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
