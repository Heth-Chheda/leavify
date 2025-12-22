import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leavify/core/utils/constants/api_endpoints.dart';
import 'package:leavify/core/utils/constants/status_color/status_colors.dart';
import 'package:leavify/core/utils/formatters/date/date_formatter.dart';
import 'package:leavify/features/Authentication/domain/models/user.dart';
import 'package:leavify/features/Home/viewmodel/home_view_model.dart';
import 'package:leavify/features/Leave/models/general/my_leaves.dart';
import 'package:leavify/features/Profile/components/info_card.dart';
import 'package:leavify/features/Profile/components/profile_avatar.dart';
import 'package:leavify/features/Profile/components/section_header.dart';
import 'package:leavify/features/profile/viewmodel/profile_view_model.dart';
import 'package:leavify/router/app_navigator.dart';
import 'package:leavify/router/route_names.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // We fetch the user's leaves when the screen is first initialized.
    // We use `addPostFrameCallback` to ensure the context is available and
    // to avoid trying to access providers before the build is complete.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // We use context.read here to get the HomeViewModel just once, without
      // subscribing to its changes inside initState.
      final user = context.read<HomeViewModel>().homeData?.currentUser;
      if (user != null) {
        // We call the method to load the leaves for the current user.
        context.read<ProfileViewModel>().loadUserLeaves(user.id);
      }
    });
  }

  // MARK: MAIN BUILD SECTION
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homeViewModel = context.watch<HomeViewModel>();
    final profileViewModel = context.watch<ProfileViewModel>();

    final user = homeViewModel.homeData?.currentUser;

    if (homeViewModel.isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
      );
    }

    if (user == null) {
      return SafeArea(
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                const SizedBox(height: 16),
                Text(
                  'Unable to load user data',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please try logging in again',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: RefreshIndicator(
          onRefresh: () async {
            profileViewModel.loadUserLeaves(user.id);
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header Section with Gradient Background
                SizedBox(
                  height: 130,
                  width: double.infinity,
                  child: SafeArea(
                    child: Row(
                      children: [
                        const SizedBox(width: 20),
                        // Profile Avatar
                        Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: ProfileAvatar(
                            initials: '${user.firstName[0]}${user.lastName[0]}',
                            size: 100,
                            baseUrl: ApiEndpoints.baseUrl, // Your base URL
                            imagePath:
                                (user.profileImageUrl?.isNotEmpty ?? false)
                                ? user.profileImageUrl
                                : null, // Pass null if empty or null, // Path from backend, e.g. "profilepics/abc.png"
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
                        // Personal Information Section
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

                        // Work Information Section
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

                        if (user.role.toLowerCase() != 'employee') ...[
                          _buildMyTeamMemberContainerListSection(
                            userId: user.id,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Leave Information Section
                        const SectionHeader(title: 'My Leaves'),
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

  Widget _buildMyTeamMemberContainerListSection({required String userId}) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        AppNavigator.navigateTo(
          RouteNames.userMemberListScreen,
          arguments: {'userId': userId},
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 2,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.groups_outlined,
                color: Colors.black,
                size: 28,
              ),
            ),

            const SizedBox(width: 16),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Team Members',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'View and manage people reporting to you',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.black.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Arrow
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // MARK: LEAVE SECTION WITH HORIZONTAL SCROLL
  Widget _buildLeaveSection(
    ProfileViewModel viewModel,
    ThemeData theme,
    User user,
  ) {
    // Show loader
    if (viewModel.isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
      );
    }

    // Show error
    if (viewModel.loadUserLeavesError != null) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
            const SizedBox(height: 12),
            Text(
              'Failed to load leave data',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.red[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => viewModel.loadUserLeaves(user.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Show leave details if available
    if (viewModel.leaveData != null) {
      final leaveData = viewModel.leaveData!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildLeaveSummaryBox(
                label: 'Approved',
                count: leaveData.approvedLeaves,
                theme: theme,
              ),
              _buildLeaveSummaryBox(
                label: 'Rejected',
                count: leaveData.rejectedLeaves,
                theme: theme,
              ),
              _buildLeaveSummaryBox(
                label: 'Available',
                count: leaveData.balanceLeaves,
                theme: theme,
              ),
              _buildLeaveSummaryBox(
                label: 'Pending',
                count: leaveData.pendingLeaves,
                theme: theme,
              ),
            ],
          ),
          if (leaveData.allLeaves.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Recent Leave Applications',
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
                    width:
                        (MediaQuery.of(context).size.width - 20 * 2 - 12) / 2,
                    child: GestureDetector(
                      onTap: () => _navigateToLeaveDetail(leave.id),
                      child: _buildLeaveItemCard(leave, theme),
                    ),
                  ),
              ],
            ),
          ],
        ],
      );
    }

    // If nothing to show
    return const Center(child: Text("No leave data available"));
  }

  Widget _buildLeaveItemCard(MyLeaves leave, ThemeData theme) {
    final String statusUpper = leave.status.toUpperCase();
    final Color statusColor = StatusColors.fromStatus(leave.status);

    // Logic refactor: check if type is 'extra' for Comp Off
    final bool isCompOff = leave.type.toLowerCase() == 'extra';

    // Determine dynamic border color and width
    Color borderColor = theme.colorScheme.onSurface.withOpacity(0.09);
    double borderWidth = 1.5;

    // Check if from and to dates are the same
    final bool isSingleDay =
        DateFormat('dd MMM yyyy').format(leave.fromDate) ==
        DateFormat('dd MMM yyyy').format(leave.toDate);

    return Container(
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Date display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: isSingleDay
                    ? Text(
                        DateFormat('dd MMM yyyy').format(leave.fromDate),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : Text(
                        DateFormatter.formatDateRange(
                          leave.fromDate.toIso8601String(),
                          leave.toDate.toIso8601String(),
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: 0.2,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Leave reason
          // Leave reason
          Row(
            children: [
              Expanded(
                child: Text(
                  leave.reason,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.65),
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // COMP OFF / HALF DAY TAG
          if (isCompOff || leave.isHalfDay) ...[
            const SizedBox(height: 6),
            RichText(
              text: TextSpan(
                children: [
                  if (isCompOff)
                    const TextSpan(
                      text: 'COMP OFF',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.purple,
                        letterSpacing: 0.4,
                      ),
                    ),
                  if (isCompOff && leave.isHalfDay) const TextSpan(text: ' '),
                  if (leave.isHalfDay)
                    TextSpan(
                      text: '(HALF DAY)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.purple,
                        letterSpacing: 0.2,
                      ),
                    ),
                ],
              ),
            ),
          ],

          const Spacer(),

          // Status badge
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
            ),
            child: Center(
              child: Text(
                statusUpper,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildLeaveTagText(bool isCompOff, bool isHalfDay) {
    if (isCompOff && isHalfDay) {
      return 'COMP OFF (HALF DAY)';
    }
    if (isCompOff) {
      return 'COMP OFF';
    }
    if (isHalfDay) {
      return 'HALF DAY';
    }
    return '';
  }

  Widget _buildLeaveSummaryBox({
    required String label,
    required num count,
    required ThemeData theme,
  }) {
    // FORMATTING LOGIC:
    // If it's a whole number (e.g., 5.0), show "5".
    // If it has decimals (e.g., -0.95), show "-0.95".
    String displayValue = count % 1 == 0
        ? count.toInt().toString()
        : count.toString();

    return Container(
      width: (MediaQuery.of(context).size.width - 20 * 2 - 12 * 3) / 2,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.18), width: 0.5),
      ),
      child: Column(
        children: [
          Text(
            displayValue, // CHANGED: Use the formatted string
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
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToLeaveDetail(String leaveId) async {
    final user = context.read<HomeViewModel>().homeData?.currentUser;
    if (user != null) {
      final result = await AppNavigator.navigateTo(
        RouteNames.leaveDetail,
        arguments: {'leaveId': leaveId, 'userId': user.id},
      );

      // 🔄 Refresh after coming back
      if (result == true && mounted) {
        debugPrint('bro called me.');
        context.read<ProfileViewModel>().loadUserLeaves(user.id);
      } else {
        debugPrint('bro did not called me.');
      }
    }
  }
}
