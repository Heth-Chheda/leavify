import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leavify/core/utils/constants/api_endpoints.dart';
import 'package:leavify/core/utils/formatters/date_formatter.dart';
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
  User? user;
  bool isLoadingUser = true;
  LeaveData? leaveData;
  bool isLoadingLeaves = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // MARK: LOAD USER DATA
  Future<void> _loadUserData() async {
    try {
      // get the user summary from the homeViewModel
      final homeViewModel = context.read<HomeViewModel>();

      setState(() {
        user = homeViewModel.homeData?.currentUser;
        isLoadingUser = false;
      });

      if (user != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<ProfileViewModel>().loadUserLeaves(user!.id);
        });
      }
      setState(() {
        isLoadingUser = false;
        isLoadingLeaves = false;
      });
    } catch (e) {
      setState(() {
        isLoadingUser = false;
        isLoadingLeaves = false;
      });
    }
  }

  // MARK: MAIN BUILD SECTION
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<ProfileViewModel>();

    if (isLoadingUser) {
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
          appBar: AppBar(title: const Text('My Profile'), centerTitle: true),
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
        appBar: AppBar(
          title: Text("My Profile", textAlign: TextAlign.center),
          centerTitle: true,
          leading: const BackButton(),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        body: RefreshIndicator(
          onRefresh: () async {
            // reload the user data and leaves
            viewModel.loadUserLeaves(user?.id ?? '');
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
                          decoration: BoxDecoration(shape: BoxShape.circle),
                          child: ProfileAvatar(
                            initials:
                                '${user!.firstName[0]}${user!.lastName[0]}',
                            size: 100,
                            baseUrl: ApiEndpoints.baseUrl, // Your base URL
                            imagePath:
                                (user?.profileImageUrl?.isNotEmpty ?? false)
                                ? user!.profileImageUrl
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
                                '${user!.firstName} ${user!.lastName}'.trim(),
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                                softWrap: true,
                                overflow: TextOverflow.visible,
                              ),
                              Text(
                                user!.designation ?? 'Unknown',
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
                          value: user!.email,
                          iconColor: Colors.blue[600],
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: InfoCard(
                                icon: Icons.phone_outlined,
                                title: 'Mobile Number',
                                value: user!.mobile,
                                iconColor: Colors.green[600],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InfoCard(
                                icon: Icons.calendar_today_outlined,
                                title: 'Joining Date',
                                value: _formatJoiningDate(user!.joiningDate),
                                iconColor: Colors.purple[600],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Work Information Section
                        if (user!.reportingTo.isNotEmpty ||
                            user!.projectList.isNotEmpty) ...[
                          const SectionHeader(title: 'Work Information'),
                          const SizedBox(height: 16),

                          if (user!.reportingTo.isNotEmpty) ...[
                            InfoCard(
                              icon: Icons.supervisor_account_outlined,
                              title: 'Reporting To',
                              value: user!.reportingTo.join(', '),
                              iconColor: Colors.orange[600],
                            ),
                            const SizedBox(height: 12),
                          ],

                          if (user!.projectList.isNotEmpty) ...[
                            InfoCard(
                              icon: Icons.work_outline,
                              title: 'Projects',
                              value: user!.projectList.join(', '),
                              iconColor: Colors.teal[600],
                            ),
                            const SizedBox(height: 30),
                          ],
                        ],

                        // Leave Information Section
                        const SectionHeader(title: 'My Leaves'),
                        const SizedBox(height: 16),

                        _buildLeaveSection(viewModel, theme),
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

  // MARK: LEAVE SECTION WITH HORIZONTAL SCROLL
  Widget _buildLeaveSection(ProfileViewModel viewModel, ThemeData theme) {
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
              onPressed: () => viewModel.loadUserLeaves(user!.id),
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
    final String statusLower = leave.status.toLowerCase();
    final bool isApproved = statusLower == 'approved';
    final bool isRejected =
        statusLower == 'rejected' || statusLower == 'denied';
    final bool isPending = statusLower == 'pending';

    // Check if from and to dates are the same
    final bool isSingleDay =
        DateFormat('dd MMM yyyy').format(leave.fromDate) ==
        DateFormat('dd MMM yyyy').format(leave.toDate);

    // Determine status color and text
    Color statusColor;
    String statusText;

    if (isApproved) {
      statusColor = const Color(0xFF10B981);
      statusText = 'APPROVED';
    } else if (isRejected) {
      statusColor = const Color(0xFFEF4444);
      statusText = 'REJECTED';
    } else if (isPending) {
      statusColor = const Color(0xFFF59E0B);
      statusText = 'PENDING';
    } else {
      statusColor = theme.colorScheme.onSurface.withOpacity(0.5);
      statusText = leave.status.toUpperCase();
    }

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
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Date display with icon
          Row(
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
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
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
                        ],
                      ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Leave reason with subtle background - single line
          Row(
            children: [
              Expanded(
                child: Text(
                  leave.reason,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.65),
                    fontSize: 13,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Status badge - always shown
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  statusText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveSummaryBox({
    required String label,
    required int count,
    required ThemeData theme,
  }) {
    return Container(
      width: (MediaQuery.of(context).size.width - 20 * 2 - 12) / 2,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.30),
            blurRadius: 1,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count.toString(),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // MARK: NAVIGATE TO LEAVE DETAIL
  Future<void> _navigateToLeaveDetail(String leaveId) async {
    if (user == null) return;

    final result = await AppNavigator.navigateTo(
      RouteNames.leaveDetail,
      arguments: {'leaveId': leaveId, 'userId': user!.id},
    );

    if (result == true && mounted) {
      final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
      viewModel.loadUserLeaves(user!.id);
    }
  }
}
