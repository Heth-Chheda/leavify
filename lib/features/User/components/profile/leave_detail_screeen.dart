import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leavify/features/User/components/ApplyLeave/custom_calendar_component.dart';
import 'package:leavify/features/User/components/manager/pending_request_detail_screen.dart';
import 'package:leavify/features/User/domain/response/get_leave_by_id_response.dart';
import 'package:leavify/features/User/viewmodel/leave_view_model.dart';
import 'package:leavify/features/User/viewmodel/profile_view_model.dart';
import 'package:provider/provider.dart';

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

  late DateTime _fromDate;
  late DateTime _toDate;
  late bool _isHalfDay;
  late bool _isCompOff;
  late List<DateTime> _compDates;
  GetLeaveByIdResponse? _leave;

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
      });
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        if (_leave == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
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
                        // Status Badge with gradient
                        _buildStatusSection(isDark),
                        const SizedBox(height: 24),

                        // Leave Duration Card with glassmorphism effect
                        _buildLeaveCard(viewModel, isDark),
                        const SizedBox(height: 20),

                        // Leave Details Form with themed styling
                        _buildDetailsCard(viewModel, isDark),
                        const SizedBox(height: 20),

                        if (_leave != null &&
                            _leave!.leaveDetails.reqStatusTracking.isNotEmpty)
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

                        if (_leave != null &&
                            _leave!.leaveDetails.documents.isNotEmpty)
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

                // Bottom Action Bar with gradient buttons
                _buildBottomActionBar(viewModel, isDark),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusSection(bool isDark) {
    final statusColor = _getStatusColor(_leave!.leaveDetails.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Remind and Escalate Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionButton(
              'Remind',
              Icons.notifications_active,
              Colors.orange,
              onRemindPressed,
            ),
            const SizedBox(width: 16),
            _buildActionButton(
              'Escalate',
              Icons.warning_amber,
              Colors.red,
              onEscalatePressed,
            ),
            const SizedBox(width: 16),
            _buildActionButton(
              'Cancel',
              Icons.cancel,
              Colors.grey,
              onCancelPressed,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.15),
        foregroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: color.withOpacity(0.4)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildLeaveCard(ProfileViewModel viewModel, bool isDark) {
    final durationInDays = _toDate.difference(_fromDate).inDays + 1;
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
                          DateFormat('dd MMM yyyy').format(_fromDate),
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
                          DateFormat('dd MMM yyyy').format(_toDate),
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
                  '$durationInDays ${durationInDays == 1 ? 'Day' : 'Days'}',
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: isDark
            ? Border(top: BorderSide(color: Colors.white.withOpacity(0.1)))
            : null,
      ),
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
                            viewModel.toggleEditMode();
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
      initialDate: _fromDate,
      onDateSelected: (date) {
        setState(() {
          _fromDate = date;
          if (_toDate.isBefore(_fromDate)) {
            _toDate = _fromDate;
          }
        });
      },
    );
  }

  Future<void> _selectToDate() async {
    await _showCustomCalendar(
      title: 'Select To Date',
      initialDate: _toDate,
      firstDate: _fromDate,
      onDateSelected: (date) {
        setState(() {
          _toDate = date;
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
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveChanges(ProfileViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await viewModel.updateLeave(
      leaveId: _leave!.leaveId,
      userId: widget.userId,
      fromDate: _fromDate,
      toDate: _toDate,
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

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return const Color(0xFF51DC8E); // AppColors.highlightGreen
      case 'PENDING':
        return const Color(0xFFFFA200); // AppColors.highlightOrange
      case 'REJECTED':
        return const Color(0xFFFF3E6C); // AppColors.highlightPink
      case 'CANCELLED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
