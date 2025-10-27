import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leavify/core/utils/components/button/my_app_button.dart';
import 'package:leavify/core/utils/components/confirmation/confirmation_dialog.dart';
import 'package:leavify/core/utils/formatters/date_formatter.dart';
import 'package:leavify/features/Leave/components/ApplyLeave/custom_calendar_component.dart';
import 'package:leavify/features/Leave/components/manager/pending_request_detail_screen.dart';
import 'package:leavify/features/Leave/models/response/get_leave_by_id_response.dart';
import 'package:leavify/features/Leave/viewModel/leave_view_model.dart';
import 'package:leavify/features/profile/viewmodel/profile_view_model.dart';
import 'package:provider/provider.dart';

final GlobalKey<_LeaveDetailScreenState> leaveDetailKey = GlobalKey();

class LeaveDetailScreen extends StatefulWidget {
  final String leaveId;
  final String userId;

  const LeaveDetailScreen({
    super.key,
    required this.leaveId,
    required this.userId,
  });

  @override
  State<LeaveDetailScreen> createState() => _LeaveDetailScreenState();
}

class _LeaveDetailScreenState extends State<LeaveDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  late String _fromDate;
  late String _toDate;
  late bool _isHalfDay;
  late bool _isCompOff;
  late List<DateTime> _compDates;
  GetLeaveByIdResponse? _leave;
  late String _status;
  bool _showStatusSection = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void onRemindPressed() async {
    final leaveVM = context.read<LeaveViewModel>();

    await leaveVM.sendReminderForLeave(leaveId: widget.leaveId);

    if (!mounted) return;
    if (leaveVM.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(leaveVM.errorMessage!)));
    } else if (leaveVM.reminderResponse?.success == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(leaveVM.reminderResponse?.message ?? 'Reminder sent'),
        ),
      );
    }
  }

  void toggleStatusSection() {
    setState(() {
      _showStatusSection = !_showStatusSection;
    });
  }

  void onEscalatePressed() async {
    final leaveVM = context.read<LeaveViewModel>();

    await leaveVM.escalateLeave(leaveId: widget.leaveId);
    if (!mounted) return;
    if (leaveVM.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(leaveVM.errorMessage!)));
    } else if (leaveVM.escalateLeaveResponse?.success == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            leaveVM.escalateLeaveResponse?.message ?? 'Escalation sent',
          ),
        ),
      );
    }
  }

  void onCancelPressed() async {
    final leaveVM = context.read<LeaveViewModel>();

    await leaveVM.cancelLeave(leaveId: widget.leaveId);
    if (!mounted) return;
    if (leaveVM.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(leaveVM.errorMessage!)));
    } else if (leaveVM.cancelLeaveResponse?.success == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            leaveVM.cancelLeaveResponse?.message ?? 'Escalation sent',
          ),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  void _initializeData() async {
    final leaveVM = Provider.of<LeaveViewModel>(context, listen: false);
    final profileVM = context.read<ProfileViewModel>();

    profileVM.resetEditMode();

    await leaveVM.getLeaveById(leaveId: widget.leaveId);

    final leave = leaveVM.selectedLeaveById;
    if (leave != null) {
      setState(() {
        _leave = leave;
        _reasonController.text = leave.leaveDetails.reason;
        _fromDate = leave.leaveDetails.fromDate;
        _toDate = leave.leaveDetails.toDate;
        _isHalfDay = leave.leaveDetails.isHalfDay;
        _isCompOff = leave.leaveDetails.isCompOff;
        _compDates = leave.leaveDetails.compDates.map(DateTime.parse).toList();
        _status = leave.leaveDetails.status;
      });
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<bool> _showDiscardConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return ConfirmationDialog(
              title: 'Discard Changes?',
              body:
                  'You have unsaved changes in your leave application. If you go back now, all your progress will be lost.',
              illustrationAsset: 'lib/assets/gifs/remove.gif',
              illustrationHeight: 180,
              confirmButtonText: 'Discard',
              onConfirm: () => Navigator.of(context).pop(true),
              buttonBackgroundColor: Colors.red,
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final leaveViewModel = context.read<LeaveViewModel>();

    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        if (_leave == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return WillPopScope(
          onWillPop: () async {
            final viewModel = context.read<ProfileViewModel>();

            if (viewModel.isEditMode) {
              // Call the centralized confirmation dialog
              final shouldExit = await _showDiscardConfirmationDialog();
              return shouldExit; // true = allow pop, false = stay
            }

            return true; // not in edit mode, allow pop
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            body: Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_status.toLowerCase() != 'cancelled' &&
                              _showStatusSection) ...[
                            _buildStatusSection(leaveViewModel, isDark),
                            const SizedBox(height: 24),
                          ],
                          _buildLeaveCard(viewModel, isDark),
                          const SizedBox(height: 20),
                          _buildDetailsCard(viewModel, isDark),
                          const SizedBox(height: 20),
                          if (_leave!.leaveDetails.reqStatusTracking.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).cardColor.withOpacity(isDark ? 0.8 : 1.0),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: StatusTrackingCard(
                                statusTracking:
                                    _leave!.leaveDetails.reqStatusTracking,
                              ),
                            ),
                          if (_leave!.leaveDetails.documents.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).cardColor.withOpacity(isDark ? 0.8 : 1.0),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: DocumentsCard(
                                documents: _leave!.leaveDetails.documents,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomActionBar(viewModel, isDark),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusSection(LeaveViewModel leaveViewModel, bool isDark) {
    final leaveDetails = leaveViewModel.selectedLeaveById?.leaveDetails;

    // Parse or convert your fromDate (if it’s a String) into DateTime
    final DateTime? fromDate = DateTime.tryParse(leaveDetails!.fromDate);

    // Get today’s date without time (to ignore hour/minute differences)
    final DateTime today = DateTime.now();
    final DateTime todayDateOnly = DateTime(today.year, today.month, today.day);

    // Determine status
    final bool isApproved = leaveDetails.status.toLowerCase() == 'approved';
    final bool isPending = leaveDetails.status.toLowerCase() == 'pending';

    // Updated cancel condition:
    // - If NOT approved → can cancel anytime
    // - If approved → can cancel only if leave starts today or later
    final bool canCancelLeave =
        !isApproved ||
        (isApproved && fromDate != null && !fromDate.isBefore(todayDateOnly));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            // 🔸 Remind Button
            if (isPending)
              Expanded(
                child: MyAppButton(
                  label: 'Remind',
                  icon: const Icon(
                    Icons.notifications_active,
                    color: Colors.white,
                    size: 18,
                  ),
                  backgroundColor: Colors.orange,
                  borderRadius: 12,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  onPressed: () => _showConfirmationDialog(
                    title: 'Send Reminder',
                    body:
                        'Are you sure you want to send a reminder for this leave?',
                    confirmButtonText: 'Send',
                    onConfirm: () {
                      onRemindPressed();
                      debugPrint('Reminder sent');
                    },
                    illustrationAsset: 'lib/assets/reminder.png',
                    illustrationHeight: 180,
                  ),
                ),
              ),

            const SizedBox(width: 10),

            // 🔸 Escalate Button
            Expanded(
              child: MyAppButton(
                label: 'Escalate',
                icon: const Icon(
                  Icons.warning_amber,
                  color: Colors.white,
                  size: 18,
                ),
                backgroundColor: Colors.red,
                borderRadius: 12,
                padding: const EdgeInsets.symmetric(vertical: 12),
                onPressed: () => _showConfirmationDialog(
                  title: 'Escalate Leave',
                  body: 'Are you sure you want to escalate this leave request?',
                  confirmButtonText: 'Escalate',
                  onConfirm: () {
                    onEscalatePressed();
                    debugPrint('Leave escalated');
                  },
                  illustrationAsset: 'lib/assets/escalate.png',
                ),
              ),
            ),

            if (canCancelLeave) ...[
              const SizedBox(width: 10),

              // 🔸 Cancel Button
              Expanded(
                child: MyAppButton(
                  label: 'Cancel',
                  icon: const Icon(Icons.cancel, color: Colors.white, size: 18),
                  backgroundColor: Colors.grey,
                  borderRadius: 12,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  onPressed: () => _showConfirmationDialog(
                    title: 'Cancel Leave',
                    body: 'Are you sure you want to cancel this leave?',
                    confirmButtonText: 'Cancel',
                    onConfirm: () {
                      onCancelPressed();
                      debugPrint('Leave cancelled');
                    },
                    illustrationAsset: 'lib/assets/cancel.png',
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  void _showConfirmationDialog({
    required String title,
    required String body,
    required String confirmButtonText,
    required VoidCallback onConfirm,
    String? illustrationAsset,
    double? illustrationHeight,
  }) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        body: body,
        illustrationAsset: illustrationAsset,
        illustrationHeight: illustrationHeight,
        confirmButtonText: confirmButtonText,
        onConfirm: () {
          onConfirm();
          Navigator.pop(context); // Close the dialog after action
        },
      ),
    );
  }

  Widget _buildLeaveCard(ProfileViewModel viewModel, bool isDark) {
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final leaveViewModel = context.read<LeaveViewModel>();
    final duration = leaveViewModel.selectedLeaveById?.duration;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: isDark
            ? Border.all(color: Colors.white.withOpacity(0.1))
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              // From Date
              Expanded(
                child: GestureDetector(
                  onTap: viewModel.isEditMode ? () => _selectFromDate() : null,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: viewModel.isEditMode
                          ? LinearGradient(
                              colors: [
                                Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1),
                                Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      border: viewModel.isEditMode
                          ? Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.3),
                            )
                          : Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.2),
                            ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'From Date',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            if (viewModel.isEditMode) ...[
                              const SizedBox(width: 6),
                              Icon(
                                Icons.edit_outlined,
                                size: 14,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormatter.formatShort(_fromDate),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Container(
                height: 60,
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // To Date
              Expanded(
                child: GestureDetector(
                  onTap: viewModel.isEditMode ? () => _selectToDate() : null,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: viewModel.isEditMode
                          ? LinearGradient(
                              colors: [
                                Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1),
                                Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      border: viewModel.isEditMode
                          ? Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.3),
                            )
                          : Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.2),
                            ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (viewModel.isEditMode) ...[
                              Icon(
                                Icons.edit_outlined,
                                size: 14,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              'To Date',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormatter.formatShort(_toDate),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.15),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  '$duration ${duration == 1 ? 'Day' : 'Days'}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(ProfileViewModel viewModel, bool isDark) {
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: isDark
            ? Border.all(color: Colors.white.withOpacity(0.1))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reason
          Text(
            'Reason',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),

          if (viewModel.isEditMode)
            TextFormField(
              controller: _reasonController,
              maxLines: 3,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Enter reason for leave',
                hintStyle: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.5),
                ),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.3),
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a reason';
                }
                return null;
              },
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.2),
                ),
              ),
              child: Text(
                _leave!.leaveDetails.reason,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.4,
                ),
              ),
            ),

          const SizedBox(height: 20),

          // Created/Updated dates
          _buildDetailRow(
            'Applied On',
            DateFormat(
              'dd MMM yyyy, hh:mm a',
            ).format(_leave!.leaveDetails.createdAt),
            Icons.schedule_outlined,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.03)
            : Colors.grey.withOpacity(0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(ProfileViewModel viewModel, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: SafeArea(
        child: Row(
          children: [
            if (viewModel.isEditMode) ...[
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: OutlinedButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () {
                            setState(() {
                              _initializeData();
                            });
                            viewModel.resetEditMode();
                          },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide.none,
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () => _saveChanges(viewModel),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: viewModel.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ),
            ] else ...[
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () => viewModel.toggleEditMode(),
                    icon: Icon(Icons.edit_outlined, color: Colors.white),
                    label: Text(
                      'Edit Leave',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Custom Calendar Integration Methods
  Future<void> _selectFromDate() async {
    await _showCustomCalendar(
      title: 'Select From Date',
      initialDate: DateTime.parse(_fromDate),
      onDateSelected: (date) {
        setState(() {
          _fromDate = date.toIso8601String();
          if ((DateTime.parse(_toDate)).isBefore(DateTime.parse(_fromDate))) {
            _toDate = _fromDate;
          }
        });
      },
    );
  }

  Future<void> _selectToDate() async {
    await _showCustomCalendar(
      title: 'Select To Date',
      initialDate: DateTime.parse(_toDate),
      firstDate: DateTime.parse(_fromDate),
      onDateSelected: (date) {
        setState(() {
          _toDate = date.toIso8601String();
        });
      },
    );
  }

  Future<void> _showCustomCalendar({
    required String title,
    required DateTime initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    required Function(DateTime) onDateSelected,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Theme.of(context).brightness == Brightness.dark
                  ? Border.all(color: Colors.white.withOpacity(0.1))
                  : null,
            ),
            child: CustomCalendarComponent(
              initialDate: initialDate,
              firstDate:
                  firstDate ??
                  DateTime.now().subtract(const Duration(days: 365)),
              lastDate:
                  lastDate ?? DateTime.now().add(const Duration(days: 365)),
              enableRangeSelection: false,
              onDateSelected: (selectedDate) {
                onDateSelected(selectedDate);
                Navigator.of(context).pop();
              },
              onClose: () => Navigator.of(context).pop(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveChanges(ProfileViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) return;

    // Compare new values with old ones
    final hasChanges =
        _fromDate != _leave!.leaveDetails.fromDate ||
        _toDate != _leave!.leaveDetails.toDate ||
        _reasonController.text.trim() != _leave!.leaveDetails.reason.trim() ||
        _isCompOff != _leave!.leaveDetails.isCompOff ||
        _isHalfDay != _leave!.leaveDetails.isHalfDay ||
        _compDates.toString() != _leave!.leaveDetails.compDates.toString();

    // If no changes, just pop and don’t call update
    if (!hasChanges) {
      Navigator.pop(
        context,
        true,
      ); // you can return `false` to indicate no update
      return;
    }

    // Proceed only if something changed
    final success = await viewModel.updateLeave(
      leaveId: _leave!.leaveId,
      userId: widget.userId,
      fromDate: DateTime.parse(_fromDate),
      toDate: DateTime.parse(_toDate),
      reason: _reasonController.text.trim(),
      isCompOff: _isCompOff,
      isHalfDay: _isHalfDay,
      compDates: _compDates,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Leave updated successfully'),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(viewModel.errorMessage ?? 'Failed to update leave'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
}
