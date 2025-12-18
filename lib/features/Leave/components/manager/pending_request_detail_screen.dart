import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:leavify/core/utils/components/button/my_app_button.dart';
import 'package:leavify/core/utils/components/statustracking/status_tracking.dart';
import 'package:leavify/core/utils/constants/api_endpoints.dart';
import 'package:leavify/core/utils/constants/enums/enums.dart';
import 'package:leavify/core/utils/formatters/date/date_formatter.dart';
import 'package:leavify/core/utils/helpers/documents/ui/viewer/document_viewer.dart';
import 'package:leavify/core/utils/theme/app_colors.dart';
import 'package:leavify/features/Authentication/domain/response/get_all_response.dart';
import 'package:leavify/features/Home/viewmodel/home_view_model.dart';
import 'package:leavify/features/Leave/components/manager/conflict/conflict_dialog.dart';
import 'package:leavify/features/Leave/models/response/get_leave_by_id_response.dart';
import 'package:leavify/features/Leave/viewModel/leave_view_model.dart';
import 'package:leavify/router/app_navigator.dart';
import 'package:leavify/router/route_names.dart';
import 'package:provider/provider.dart';

class PendingRequestDetailScreen extends StatefulWidget {
  final String leaveId;
  final GetAllResponse? user;

  const PendingRequestDetailScreen({
    super.key,
    required this.leaveId,
    this.user,
  });

  @override
  State<PendingRequestDetailScreen> createState() =>
      _PendingRequestDetailScreenState();
}

class _PendingRequestDetailScreenState
    extends State<PendingRequestDetailScreen> {
  final TextEditingController _commentsController = TextEditingController();
  final FocusNode _commentsFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLeaveDetails();
    });
  }

  Future<void> _initializeLeaveDetails() async {
    final viewModel = Provider.of<LeaveViewModel>(context, listen: false);
    // Clear any cached data first
    viewModel.clearSelectedLeave();
    // Then fetch fresh data
    await viewModel.getLeaveById(leaveId: widget.leaveId);

    final leaveDetails = viewModel.selectedLeaveById;
    if (leaveDetails != null &&
        leaveDetails.teamConflictingLeaves.isNotEmpty &&
        leaveDetails.leaveDetails.type.toLowerCase() != 'extra') {
      _showConflictDialog(leaveDetails.teamConflictingLeaves);
    }
  }

  void _showConflictDialog(List<TeamConflictingLeave> conflicts) {
    showDialog(
      context: context,
      builder: (context) => ConflictDialog(
        conflicts: conflicts,
        illustrationAsset: 'lib/assets/conflict.png',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: GestureDetector(
        onTap: () => {FocusScope.of(context).unfocus()},
        behavior: HitTestBehavior.translucent,
        child: Consumer<LeaveViewModel>(
          builder: (context, leaveViewModel, child) {
            if (leaveViewModel.isLoading &&
                leaveViewModel.selectedLeaveById == null) {
              return Center(
                child: SpinKitSquareCircle(
                  color: AppColors.highlightBlue,
                  size: 100,
                ),
              );
            }

            // if (leaveViewModel.errorMessage != null) {
            //   return _buildErrorState(leaveViewModel.errorMessage!);
            // }

            if (leaveViewModel.selectedLeaveById == null) {
              return Center(
                child: Text(
                  'No leave details found',
                  style: TextStyle(color: colorScheme.onBackground),
                ),
              );
            }

            return _buildLeaveDetailsContent(leaveViewModel.selectedLeaveById!);
          },
        ),
      ),
    );
  }

  Widget _buildLeaveDetailsContent(GetLeaveByIdResponse leaveData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _EmployeeHeaderCard(
            leaveData: leaveData,
            designation: widget.user?.designation,
            profileImagePath: widget.user?.profileImage,
            user: widget.user,
          ),
          const SizedBox(height: 20),
          _LeaveRequestDetailsCard(leaveData: leaveData),
          const SizedBox(height: 16),

          if (leaveData.leaveDetails.type.toLowerCase() != 'extra') ...[
            _TeamConflictingLeavesList(
              teamLeaves: leaveData.teamConflictingLeaves,
            ),
            const SizedBox(height: 20),
          ],

          if (leaveData.leaveDetails.reason.isNotEmpty)
            _ReasonCard(reason: leaveData.leaveDetails.reason),

          if (leaveData.leaveDetails.reason.isNotEmpty)
            const SizedBox(height: 16),

          // ---------------------------------------------------------
          if (leaveData.leaveDetails.documents.isNotEmpty)
            DocumentsCard(documents: leaveData.leaveDetails.documents),

          if (leaveData.leaveDetails.documents.isNotEmpty)
            const SizedBox(height: 16),

          if (leaveData.leaveDetails.reqStatusTracking.isNotEmpty) ...[
            StatusTrackingCard(
              statusTracking: leaveData.leaveDetails.reqStatusTracking.map((
                tracking,
              ) {
                return StatusTrackingItem(
                  status: tracking.status,
                  processedBy: tracking.processedBy,
                  processedAt: tracking.processedAt,
                  comment: tracking.comment,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          if (leaveData.recentApprovedLeaves.isNotEmpty) ...[
            _RecentApprovedLeavesCard(leaves: leaveData.recentApprovedLeaves),
            const SizedBox(height: 16),
          ],

          if (leaveData.leaveDetails.reqStatusTracking.isNotEmpty)
            const SizedBox(height: 16),

          if (leaveData.leaveDetails.isEscalated &&
              leaveData.leaveDetails.escalationDet != null)
            const SizedBox(height: 16),

          _CommentsCard(
            commentsController: _commentsController,
            focusNode: _commentsFocusNode,
          ),
          const SizedBox(height: 24),
          _buildActionButtons(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Consumer<LeaveViewModel>(
      builder: (context, leaveViewModel, child) {
        final homeViewModel = context.read<HomeViewModel>();
        final userRole = homeViewModel.userRole.toLowerCase();

        final actionTaken =
            widget.user?.actionTaken?.trim().toLowerCase() ?? "pending";

        // HR → still only Resolve button
        if (userRole == "hr") {
          return SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: MyAppButton(
                    label: 'Resolve',
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    onPressed: leaveViewModel.isLoading
                        ? null
                        : _handleProcessEscalated,
                    isLoading: leaveViewModel.isProcessEscalatedLeaveLoading,
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    type: MyButtonType.elevated,
                  ),
                ),
              ],
            ),
          );
        }

        // ================================
        // NEW LOGIC (BASED ON actionTaken)
        // ================================

        // If APPROVED → show only REJECT
        if (actionTaken == "approved") {
          return SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: MyAppButton(
                    label: 'Reject',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: leaveViewModel.isLoading ? null : _handleReject,
                    isLoading: leaveViewModel.isRejectLoading,
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    type: MyButtonType.elevated,
                  ),
                ),
              ],
            ),
          );
        }

        // If REJECTED → show only APPROVE
        if (actionTaken == "rejected") {
          return SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: MyAppButton(
                    label: 'Approve',
                    icon: const Icon(Icons.check_rounded),
                    onPressed: leaveViewModel.isLoading ? null : _handleApprove,
                    isLoading: leaveViewModel.isApproveLoading,
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    type: MyButtonType.elevated,
                  ),
                ),
              ],
            ),
          );
        }

        // If PENDING → show both Approve + Reject
        return SafeArea(
          child: Row(
            children: [
              Expanded(
                child: MyAppButton(
                  label: 'Reject',
                  icon: const Icon(Icons.close_rounded),
                  onPressed: leaveViewModel.isLoading ? null : _handleReject,
                  isLoading: leaveViewModel.isRejectLoading,
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  type: MyButtonType.elevated,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: MyAppButton(
                  label: 'Approve',
                  icon: const Icon(Icons.check_rounded),
                  onPressed: leaveViewModel.isLoading ? null : _handleApprove,
                  isLoading: leaveViewModel.isApproveLoading,
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  type: MyButtonType.elevated,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleApprove() async {
    final leaveViewModel = context.read<LeaveViewModel>();
    if (_commentsController.text.trim().isEmpty) {
      _commentsFocusNode.requestFocus();
      leaveViewModel.showError(context, 'Please provide reason!');
      return;
    }

    final success = await leaveViewModel.processLeaveRequest(
      leaveId: widget.leaveId,
      status: 'APPROVED',
      context: context,
      comment: _commentsController.text,
    );

    if (success && mounted) {
      AppNavigator.goBack(true);
      leaveViewModel.showSuccess(context, 'Request approved!');
    } else if (mounted) {
      leaveViewModel.showError(
        context,
        leaveViewModel.processLeaveError ?? 'Failed to approve request',
      );
    }
  }

  Future<void> _handleProcessEscalated() async {
    final leaveViewModel = context.read<LeaveViewModel>();
    if (_commentsController.text.trim().isEmpty) {
      leaveViewModel.showError(context, 'Please provide reason!');
      return;
    }

    final success = await leaveViewModel.processEscalatedLeaveRequest(
      leaveId: widget.leaveId,
      comment: _commentsController.text,
    );

    if (success && mounted) {
      // Navigator.pop(context);
      AppNavigator.goBack(true);
      leaveViewModel.showInfo(context, 'Request resolved!');
    } else if (mounted) {
      leaveViewModel.showError(
        context,
        leaveViewModel.processLeaveError ?? 'Failed to resolve request',
      );
    }
  }

  Future<void> _handleReject() async {
    final leaveViewModel = context.read<LeaveViewModel>();
    if (_commentsController.text.trim().isEmpty) {
      _commentsFocusNode.requestFocus();
      leaveViewModel.showError(context, 'Please provide reason!');
      return;
    }

    final success = await leaveViewModel.processLeaveRequest(
      leaveId: widget.leaveId,
      status: 'REJECTED',
      context: context,
      comment: _commentsController.text,
    );

    if (success && mounted) {
      // Navigator.pop(context);
      AppNavigator.goBack(true);
      leaveViewModel.showSuccess(context, 'Request rejected!');
    } else if (mounted) {
      leaveViewModel.showError(
        context,
        leaveViewModel.processLeaveError ?? 'Failed to reject request',
      );
    }
  }

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }
}

// MARK: - Employee Header Card
class _EmployeeHeaderCard extends StatelessWidget {
  final GetLeaveByIdResponse leaveData;
  final String? designation;
  final String? profileImagePath;
  final GetAllResponse? user;

  const _EmployeeHeaderCard({
    required this.leaveData,
    this.designation,
    this.profileImagePath,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        // navigate to the other user detail page.
        debugPrint('Employee Header Card tapped');
        AppNavigator.navigateTo(
          RouteNames.otherUserProfile,
          arguments: user?.userId,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withOpacity(0.15),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child:
                        profileImagePath != null && profileImagePath!.isNotEmpty
                        ? Image.network(
                            '${ApiEndpoints.baseUrl}/$profileImagePath',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // fallback to initials if image fails to load
                              return Center(
                                child: Text(
                                  _getInitials(leaveData.employeeName),
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                  ),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Text(
                              _getInitials(leaveData.employeeName),
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leaveData.employeeName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      designation ?? 'N/A',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color.fromARGB(255, 54, 54, 54),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildBalanceInfo(),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }

  Widget _buildBalanceInfo() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Balance Leaves: ${leaveData.balanceLeaves}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
        ),

        const SizedBox(width: 16),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Working Days: ${leaveData.workingDaysCount}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade700,
            ),
          ),
        ),
      ],
    );
  }
}

// MARK: - Leave Request Details Card
class _LeaveRequestDetailsCard extends StatelessWidget {
  final GetLeaveByIdResponse leaveData;

  const _LeaveRequestDetailsCard({required this.leaveData});

  @override
  Widget build(BuildContext context) {
    // 1. Get Flags
    final bool isHalfDay = leaveData.leaveDetails.isHalfDay;
    final bool isCompOff = leaveData.leaveDetails.isCompOff;

    // 2. Determine if we need to show a badge (Half Day OR Comp Off)
    final bool showBadge = isHalfDay || isCompOff;

    // 3. Determine Badge Style
    String badgeLabel = '';
    Color badgeBgColor = Colors.transparent;
    Color badgeIconColor = Colors.transparent;
    Color badgeValueColor = Colors.transparent;

    if (isCompOff) {
      // Style for Comp Off (Purple Theme)
      badgeLabel = 'Comp Off';
      badgeBgColor = Colors.purple.withOpacity(0.15);
      badgeIconColor = Colors.purple[800]!;
      badgeValueColor = Colors.purple[900]!;
    } else if (isHalfDay) {
      // Style for Half Day (Orange Theme)
      badgeLabel = 'Half Day';
      badgeBgColor = Colors.orange.withOpacity(0.15);
      badgeIconColor = Colors.orange[800]!;
      badgeValueColor = Colors.orange[900]!;
    }

    return _InfoCard(
      title: 'Leave Request Details',
      children: [
        if (leaveData.leaveDetails.type.toLowerCase() == 'extra') ...[
          _InfoRow(
            icon: Icons.more_time_rounded,
            label: 'Comp Off',
            value: leaveData.leaveDetails.type,
          ),
        ],
        // Row 1: Type & Duration
        Row(
          children: [
            Expanded(
              child: _InfoRow(
                icon: Icons.category_outlined,
                label: 'Leave Type',
                value: leaveData.leaveDetails.subType,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _InfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'Duration',
                value: _calculateDuration(),
              ),
            ),
          ],
        ),

        // Row 2: From & To Date
        Row(
          children: [
            Expanded(
              child: _InfoRow(
                icon: Icons.date_range_outlined,
                label: 'From Date',
                value: _formatDate(leaveData.leaveDetails.fromDate),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _InfoRow(
                icon: Icons.date_range_outlined,
                label: 'To Date',
                value: _formatDate(leaveData.leaveDetails.toDate),
              ),
            ),
          ],
        ),

        _InfoRow(
          icon: isCompOff ? Icons.star_rounded : Icons.timelapse_rounded,
          label: 'Mode',
          value: badgeLabel,
          // Apply dynamic styles
          backgroundColor: badgeBgColor,
          iconColor: badgeIconColor,
          valueColor: badgeValueColor,
        ),

        // Row 3: Applied On (Conditionally Split for Comp Off OR Half Day)
        if (showBadge)
          Row(
            children: [
              // 1. Applied On
              Expanded(
                child: _InfoRow(
                  icon: Icons.access_time_outlined,
                  label: 'Applied On',
                  value: _formatDateTime(leaveData.leaveDetails.createdAt),
                ),
              ),
            ],
          )
        else
          // Standard full-width row if NO special mode
          _InfoRow(
            icon: Icons.access_time_outlined,
            label: 'Applied On',
            value: _formatDateTime(leaveData.leaveDetails.createdAt),
          ),
      ],
    );
  }

  String _calculateDuration() {
    final days = leaveData.duration;
    return '$days day${days == 1 ? '' : 's'}';
  }

  String _formatDate(DateTime date) {
    return DateFormatter.formatShort(date.toIso8601String());
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }
}

// MARK: - Reason Card
class _ReasonCard extends StatelessWidget {
  final String reason;

  const _ReasonCard({required this.reason});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _InfoCard(
      title: 'Reason for Leave',
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.onSurface.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            reason,
            style: TextStyle(
              fontSize: 15,
              color: colorScheme.onSurface,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

// MARK: - Comments Card
class _CommentsCard extends StatelessWidget {
  final TextEditingController commentsController;
  final FocusNode focusNode;

  const _CommentsCard({
    required this.commentsController,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _InfoCard(
      title: 'Comments',
      children: [
        // Wrap in SingleChildScrollView to scroll when keyboard appears
        SingleChildScrollView(
          reverse: true, // ensures bottom content is visible
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: commentsController,
                  focusNode: focusNode,
                  maxLines: 4,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => FocusScope.of(context).unfocus(),
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText:
                        'Add any comments or feedback for the employee...',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme.onSurface.withOpacity(0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: colorScheme.onSurface.withOpacity(0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colorScheme.primary),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Note: Comments are required when rejecting a request',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// MARK: - Reusable Info Card
class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.15),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

// MARK: - Info Row
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  // New properties for custom styling
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.backgroundColor,
    this.iconColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // Use custom background or default grey
          color: backgroundColor ?? Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              // Use custom icon color or default
              color: iconColor ?? colorScheme.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      // Use custom value color or default
                      color: valueColor ?? colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamConflictingLeavesList extends StatelessWidget {
  final List<TeamConflictingLeave> teamLeaves;

  const _TeamConflictingLeavesList({required this.teamLeaves});

  @override
  Widget build(BuildContext context) {
    if (teamLeaves.isEmpty) {
      return const SizedBox.shrink(); // don't show anything if empty
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Team Conflicting Leaves",
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: teamLeaves.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 24, color: Colors.transparent),
              itemBuilder: (context, index) {
                final leave = teamLeaves[index];
                final imageUrl =
                    "${ApiEndpoints.baseUrl}/${leave.profileImagePath}";

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.network(
                        imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.account_circle, size: 50),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${leave.fName} ${leave.lName}",
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${DateFormat('dd MMM yyyy').format(leave.fromDate)} → ${DateFormat('dd MMM yyyy').format(leave.toDate)}",
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            leave.reason.isNotEmpty
                                ? leave.reason
                                : "No reason provided",
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// MARK: - Recent Approved Leaves Card
class _RecentApprovedLeavesCard extends StatelessWidget {
  final List<RecentApprovedLeave> leaves;

  const _RecentApprovedLeavesCard({required this.leaves});

  @override
  Widget build(BuildContext context) {
    if (leaves.isEmpty) return const SizedBox.shrink();

    return _InfoCard(
      title: 'Recent Approved History',
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: leaves.length,
          itemBuilder: (context, index) {
            return _TimelineLeaveItem(
              leave: leaves[index],
              isLast: index == leaves.length - 1,
            );
          },
        ),
      ],
    );
  }
}

// MARK: - Timeline Item Widget
class _TimelineLeaveItem extends StatelessWidget {
  final RecentApprovedLeave leave;
  final bool isLast;

  const _TimelineLeaveItem({required this.leave, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Timeline Visuals (Dot + Line)
          Column(
            children: [
              // The Dot
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: Center(
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              // The Line (only show if not the last item)
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.withOpacity(0.2),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),

          // 2. Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Date and Type
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDateRange(leave.fromDate, leave.toDate),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          leave.type, // e.g., "Casual", "Sick"
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Reason Text
                  Text(
                    leave.reason.isNotEmpty
                        ? leave.reason
                        : "No reason provided",
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateRange(DateTime from, DateTime to) {
    final fromStr = DateFormat('dd MMM').format(from);
    // If same day, just show one date
    if (from.year == to.year && from.month == to.month && from.day == to.day) {
      return fromStr;
    }
    final toStr = DateFormat('dd MMM').format(to);
    return "$fromStr - $toStr";
  }
}
