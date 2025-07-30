import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leavify/core/storage/app_storage.dart';
import 'package:leavify/features/Authentication/domain/models/user.dart';
import 'package:leavify/features/Authentication/domain/response/get_user_summary_response.dart';
import 'package:leavify/features/User/components/profile/info_card.dart';
import 'package:leavify/features/User/components/profile/leave_type_card.dart';
import 'package:leavify/features/User/components/profile/profile_avatar.dart';
import 'package:leavify/features/User/components/profile/section_header.dart';
import 'package:leavify/features/User/domain/models/my_leaves.dart';
import 'package:leavify/features/User/viewmodel/profile_view_model.dart';
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

        // Load user leaves after getting user data
        if (mounted) {
          context.read<ProfileViewModel>().loadUserLeaves(user!.id);
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

  @override
  Widget build(BuildContext context) {
    if (isLoadingUser) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              const SizedBox(height: 16),
              const Text(
                'Unable to load user data',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Please try logging in again',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background - Full screen without SafeArea
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
              ),
            ),
          ),
          // Bottom Sheet
          Positioned(
            left: 0,
            right: 0,
            top: MediaQuery.of(context).size.height * 0.1,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Consumer<ProfileViewModel>(
                  builder: (context, viewModel, child) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User Name and Basic Info
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  '${user!.firstName} ${user!.lastName}'.trim(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800],
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user!.role,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Employee ID: ${user!.empId}',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Personal Information Section
                          const SectionHeader(
                            title: 'Personal Information',
                            subtitle:
                                'Your basic details and contact information',
                          ),
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
                          const SectionHeader(
                            title: 'Work Information',
                            subtitle: 'Your role and project assignments',
                          ),
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
                          const SectionHeader(
                            title: 'My Leaves',
                            subtitle:
                                'Overview of your leave balance and history',
                          ),
                          const SizedBox(height: 16),

                          _buildLeaveSection(viewModel),

                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Profile Avatar positioned above the bottom sheet
          Positioned(
            left: 0,
            right: 0,
            top: MediaQuery.of(context).size.height * 0.1 - 50,
            child: Center(
              child: ProfileAvatar(initials: user!.firstName, size: 100),
            ),
          ),
        ],
      ),
    );
  }

  String _formatJoiningDate(String joiningDate) {
    try {
      // Try parsing as DateTime first
      if (joiningDate.contains('T') || joiningDate.contains('-')) {
        final date = DateTime.parse(joiningDate);
        return DateFormat('dd MMM yyyy').format(date);
      }
      // If it's already formatted, return as is
      return joiningDate;
    } catch (e) {
      return joiningDate; // Return original if parsing fails
    }
  }

  Widget _buildLeaveSection(ProfileViewModel viewModel) {
    switch (viewModel.state) {
      case ProfileViewState.loading:
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
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
                style: TextStyle(
                  color: Colors.red[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => viewModel.retry(user!.id),
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
            // Leave Summary Cards
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                LeaveTypeCard(
                  label: 'Available',
                  count: leaveData.balanceLeaves,
                  color: Colors.green,
                  icon: Icons.check_circle_outline,
                ),
                LeaveTypeCard(
                  label: 'Pending',
                  count: leaveData.pendingLeaves,
                  color: Colors.orange,
                  icon: Icons.pending_outlined,
                ),
                LeaveTypeCard(
                  label: 'Approved',
                  count: leaveData.approvedLeaves,
                  color: Colors.blue,
                  icon: Icons.thumb_up_outlined,
                ),
                LeaveTypeCard(
                  label: 'Rejected',
                  count: leaveData.rejectedLeaves,
                  color: Colors.red,
                  icon: Icons.cancel_outlined,
                ),
              ],
            ),

            if (leaveData.allLeaves.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Recent Leave Applications',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),

              ...leaveData.allLeaves
                  .take(3)
                  .map(
                    (leave) => GestureDetector(
                      onTap: () => _navigateToLeaveDetail(leave),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${DateFormat('dd MMM').format(leave.fromDate)} - ${DateFormat('dd MMM yyyy').format(leave.toDate)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                      leave.status,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
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
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (leave.isHalfDay || leave.isCompOff) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  if (leave.isHalfDay)
                                    Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Half Day',
                                        style: TextStyle(
                                          color: Colors.blue[700],
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  if (leave.isCompOff)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.purple[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Comp Off',
                                        style: TextStyle(
                                          color: Colors.purple[700],
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
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

  Future<void> _navigateToLeaveDetail(MyLeaves leave) async {
    if (user == null) return;

    final result = await Navigator.pushNamed(
      context,
      '/leave-detail',
      arguments: {'leave': leave, 'userId': user!.id},
    );

    // If leave was updated, refresh the data
    if (result == true && mounted) {
      context.read<ProfileViewModel>().loadUserLeaves(user!.id);
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
