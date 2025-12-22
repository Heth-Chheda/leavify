import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leavify/core/utils/constants/api_endpoints.dart';
import 'package:leavify/core/utils/constants/status_color/status_colors.dart';
import 'package:leavify/features/Authentication/domain/models/leave.dart';
import 'package:leavify/features/Authentication/domain/models/user.dart';
import 'package:leavify/features/Authentication/domain/response/get_user_summary_response.dart';
import 'package:leavify/features/Home/viewmodel/home_view_model.dart';
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
      context.read<HomeViewModel>().loadUserSummaryFromApi(
        userId: widget.userId,
      );
      context.read<ProfileViewModel>().loadUserLeaves(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homeVM = context.watch<HomeViewModel>();

    final user = homeVM.otherUser;
    final summary = homeVM.otherUserData;
    final isLoading = homeVM.isLoading;

    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
      );
    }

    if (user == null || summary == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('User not found')),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () => homeVM.loadUserSummaryFromApi(userId: widget.userId),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(theme, user),

              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PERSONAL INFO
                    const SectionHeader(title: 'Personal Information'),
                    const SizedBox(height: 16),
                    InfoCard(
                      icon: Icons.email_outlined,
                      title: 'Email Address',
                      value: user.email,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InfoCard(
                            icon: Icons.phone_outlined,
                            title: 'Mobile Number',
                            value: user.mobile,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InfoCard(
                            icon: Icons.calendar_today_outlined,
                            title: 'Joining Date',
                            value: _formatDate(user.joiningDate),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // WORK INFO (RESTORED)
                    if (user.reportingTo.isNotEmpty ||
                        user.projectList.isNotEmpty) ...[
                      const SectionHeader(title: 'Work Information'),
                      const SizedBox(height: 16),

                      if (user.reportingTo.isNotEmpty) ...[
                        InfoCard(
                          icon: Icons.supervisor_account_outlined,
                          title: 'Reporting To',
                          value: user.reportingTo.join(', '),
                        ),
                        const SizedBox(height: 12),
                      ],

                      if (user.projectList.isNotEmpty) ...[
                        InfoCard(
                          icon: Icons.work_outline,
                          title: 'Projects',
                          value: user.projectList.join(', '),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ],

                    // LEAVE HISTORY
                    const SectionHeader(title: 'Leave History'),
                    const SizedBox(height: 16),
                    _buildLeaveSection(theme, user, summary),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, User user) {
    return SizedBox(
      height: 130,
      child: Row(
        children: [
          const SizedBox(width: 20),
          ProfileAvatar(
            initials: '${user.firstName[0]}${user.lastName[0]}',
            size: 100,
            baseUrl: ApiEndpoints.baseUrl,
            imagePath: user.profileImageUrl?.isNotEmpty == true
                ? user.profileImageUrl
                : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.firstName} ${user.lastName}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(user.designation ?? 'Unknown'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(date));
    } catch (_) {
      return date;
    }
  }

  // ================= LEAVE SECTION =================

  Widget _buildLeaveSection(
    ThemeData theme,
    User user,
    GetUserSummaryResponse summary,
  ) {
    final leaves = summary.myUpcomingLeaves ?? [];

    // SUMMARY CHIPS (RESTORED)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildSummaryChip('Approved', user.approved, theme),
            _buildSummaryChip('Rejected', user.rejected, theme),
            _buildSummaryChip('Pending', user.pending, theme),
          ],
        ),

        const SizedBox(height: 24),

        if (leaves.isEmpty)
          const Center(child: Text('No leave history found'))
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: leaves.map((leave) {
              return SizedBox(
                width: (MediaQuery.of(context).size.width - 64) / 2,
                child: _buildLeaveCard(leave, theme),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildSummaryChip(String label, num count, ThemeData theme) {
    final display = count % 1 == 0
        ? count.toInt().toString()
        : count.toString();

    return Container(
      width: (MediaQuery.of(context).size.width - 64) / 3,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.18), width: 0.5),
      ),
      child: Column(
        children: [
          Text(
            display,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ================= LEAVE CARD (HALF + COMP OFF) =================

  Widget _buildLeaveCard(LeaveDetailsWithoutLeaveId leave, ThemeData theme) {
    final statusColor = StatusColors.fromStatus(leave.status);

    final bool isCompOff = leave.requestType.toLowerCase() == 'extra';
    final bool isHalfDay = leave.isHalfDay == true;

    Color? leftBorder;
    if (isCompOff) {
      leftBorder = Colors.purple;
    } else if (isHalfDay) {
      leftBorder = Colors.amber.shade700;
    }

    final start = DateTime.tryParse(leave.startDate);
    final end = DateTime.tryParse(leave.endDate);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: leftBorder != null
            ? Border(left: BorderSide(color: leftBorder, width: 4))
            : null,
      ),
      child: Container(
        height: 180,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.colorScheme.onSurface.withOpacity(0.1),
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
          children: [
            Text(
              start != null && end != null
                  ? DateFormat('dd MMM').format(start) +
                        (start != end
                            ? ' - ${DateFormat('dd MMM').format(end)}'
                            : '')
                  : '',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(leave.reason, maxLines: 3, overflow: TextOverflow.ellipsis),
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                leave.status.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
