import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leavify/core/utils/constants/api_endpoints.dart';
import 'package:leavify/core/storage/app_storage.dart';
import 'package:leavify/features/Authentication/domain/models/user.dart';
import 'package:leavify/features/Authentication/domain/response/get_user_summary_response.dart';
import 'package:leavify/features/Profile/components/info_card.dart';
import 'package:leavify/features/Profile/components/profile_avatar.dart';
import 'package:leavify/features/Profile/components/section_header.dart';
import 'package:leavify/features/profile/viewmodel/profile_view_model.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;
  bool isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // MARK: LOAD USER DATA
  Future<void> _loadUserData() async {
    try {
      final userSummary = await AppStorage.getObject<GetUserSummaryResponse>(
        'user_details',
        (json) => GetUserSummaryResponse.fromJson(json),
      );

      if (userSummary?.currentUser != null) {
        setState(() {
          user = userSummary!.currentUser;
          isLoadingUser = false;
        });

        if (mounted) {
          final viewModel = Provider.of<ProfileViewModel?>(
            context,
            listen: false,
          );
          viewModel?.loadUserLeaves(user!.id);
        }
      } else {
        setState(() {
          isLoadingUser = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingUser = false;
      });
    }
  }

  // MARK: MAIN BUILD SECTION
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section with Gradient Background
              SizedBox(
                height: 280,
                width: double.infinity,
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Profile Avatar
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ProfileAvatar(
                          initials: '${user!.firstName[0]}${user!.lastName[0]}',
                          size: 100,
                          baseUrl: ApiEndpoints.baseUrl, // Your base URL
                          imagePath:
                              (user?.profileImageUrl?.isNotEmpty ?? false)
                              ? user!.profileImageUrl
                              : null, // Pass null if empty or null, // Path from backend, e.g. "profilepics/abc.png"
                        ),
                      ),

                      const SizedBox(height: 20),

                      // User Name and Role
                      Text(
                        '${user!.firstName} ${user!.lastName}'.trim(),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user!.designation ?? 'Unknown',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content Section
              Container(
                width: double.infinity,
                color: theme.scaffoldBackgroundColor,
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

                      InfoCard(
                        icon: Icons.phone_outlined,
                        title: 'Mobile Number',
                        value: user!.mobile,
                        iconColor: Colors.green[600],
                      ),
                      const SizedBox(height: 12),

                      InfoCard(
                        icon: Icons.calendar_today_outlined,
                        title: 'Joining Date',
                        value: _formatJoiningDate(user!.joiningDate),
                        iconColor: Colors.purple[600],
                      ),

                      const SizedBox(height: 30),

                      // Work Information Section
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

                      // Leave Information Section
                      const SectionHeader(title: 'My Leaves'),
                      const SizedBox(height: 16),

                      _buildLeaveSection(
                        Provider.of<ProfileViewModel>(
                          context,
                        ), // 👈 direct access
                        theme,
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
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
    switch (viewModel.state) {
      case ProfileViewState.loading:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: CircularProgressIndicator(color: theme.colorScheme.primary),
          ),
        );

      case ProfileViewState.error:
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
                onPressed: () => viewModel.retry(user!.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        );

      case ProfileViewState.success:
        final leaveData = viewModel.leaveData!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Horizontal Scrolling Leave Summary Cards
            SizedBox(
              height: 70,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                children: [
                  _buildHorizontalLeaveCard(
                    label: 'Available',
                    count: leaveData.balanceLeaves,
                    color: Colors.green,
                    theme: theme,
                    showRightBorder: true,
                  ),
                  const SizedBox(width: 12),
                  _buildHorizontalLeaveCard(
                    label: 'Pending',
                    count: leaveData.pendingLeaves,
                    color: Colors.orange,
                    theme: theme,
                    showRightBorder: true,
                  ),
                  const SizedBox(width: 12),
                  _buildHorizontalLeaveCard(
                    label: 'Approved',
                    count: leaveData.approvedLeaves,
                    color: Colors.blue,
                    theme: theme,
                    showRightBorder: true,
                  ),
                  const SizedBox(width: 12),
                  _buildHorizontalLeaveCard(
                    label: 'Rejected',
                    count: leaveData.rejectedLeaves,
                    color: Colors.red,
                    theme: theme,
                    showRightBorder: false,
                  ),
                ],
              ),
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

              ...leaveData.allLeaves.map(
                (leave) => GestureDetector(
                  onTap: () => _navigateToLeaveDetail(leave.id),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${DateFormat('dd MMM').format(leave.fromDate)} - ${DateFormat('dd MMM yyyy').format(leave.toDate)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  leave.status,
                                ).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                leave.status,
                                style: TextStyle(
                                  color: _getStatusColor(leave.status),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          leave.reason,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (leave.isHalfDay || leave.isCompOff) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (leave.isHalfDay)
                                _buildLeaveTag('Half Day', Colors.blue, theme),
                              if (leave.isHalfDay && leave.isCompOff)
                                const SizedBox(width: 8),
                              if (leave.isCompOff)
                                _buildLeaveTag(
                                  'Comp Off',
                                  Colors.purple,
                                  theme,
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
    }
  }

  Widget _buildHorizontalLeaveCard({
    required String label,
    required int count,
    required Color color,
    required ThemeData theme,
    required bool showRightBorder,
  }) {
    return Stack(
      children: [
        Container(
          width: 140,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                count.toString(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // Right short border
        if (showRightBorder)
          Positioned(
            right: 0,
            top: 12,
            bottom: 12,
            child: Container(
              width: 1.5,
              color: theme.dividerColor.withOpacity(0.3),
            ),
          ),
      ],
    );
  }

  Widget _buildLeaveTag(String text, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // MARK: NAVIGATE TO LEAVE DETAIL
  Future<void> _navigateToLeaveDetail(String leaveId) async {
    if (user == null) return;

    final result = await Navigator.pushNamed(
      context,
      '/leave-detail',
      arguments: {'leaveId': leaveId, 'userId': user!.id},
    );

    if (result == true && mounted) {
      final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
      viewModel.loadUserLeaves(user!.id);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
