import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:leavify/core/utils/components/button/my_app_button.dart';
import 'package:leavify/core/utils/components/confirmation/confirmation_dialog.dart';
import 'package:leavify/core/utils/components/container/my_app_container.dart';
import 'package:leavify/core/utils/components/dropdownmenu/my_app_drop_down_menu.dart';
import 'package:leavify/core/utils/components/statustracking/status_tracking.dart';
import 'package:leavify/core/utils/components/textfield/my_app_text_field.dart';
import 'package:leavify/core/utils/components/toast/app_toast.dart';
import 'package:leavify/core/utils/constants/enums/enums.dart';
import 'package:leavify/core/utils/helpers/documents/ui/document_ui.dart';
import 'package:leavify/core/utils/helpers/documents/ui/viewer/document_viewer.dart';
import 'package:leavify/features/Leave/components/ApplyLeave/custom_calendar_component.dart';
import 'package:leavify/features/Leave/models/request/apply_leave_request_model.dart';
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
  final FocusNode _reasonFocusNode = FocusNode();

  late DateTime _fromDate;
  late DateTime _toDate;
  late bool _isHalfDay;
  late bool _isCompOff;
  late List<DateTime> _compDates;
  GetLeaveByIdResponse? _leave;
  late String _status;
  late ProfileViewModel _profileViewModel;
  int _originalDocumentCount = 0;
  late String _selectedLeaveType;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> handleLeaveAction(LeaveActionType type) async {
    final leaveVM = context.read<LeaveViewModel>();
    final leaveId = widget.leaveId;

    final isLoading = switch (type) {
      LeaveActionType.remind => leaveVM.isRemindLoading,
      LeaveActionType.escalate => leaveVM.isEscalateLoading,
      LeaveActionType.cancel => leaveVM.isCancelLoading,
    };
    if (isLoading) return;

    switch (type) {
      case LeaveActionType.remind:
        await leaveVM.sendReminderForLeave(leaveId: leaveId);
        break;
      case LeaveActionType.escalate:
        await leaveVM.escalateLeave(leaveId: leaveId);
        break;
      case LeaveActionType.cancel:
        await leaveVM.cancelLeave(leaveId: leaveId);
        break;
    }

    if (!mounted) return;

    final error = leaveVM.errorMessage;
    bool success = false;
    String successMessage = '';
    String errorMessage = '';

    switch (type) {
      case LeaveActionType.remind:
        final response = leaveVM.reminderResponse;
        success = response?.success ?? false;
        successMessage = 'Reminder sent!';
        errorMessage = 'Error reminding leave';
        break;

      case LeaveActionType.escalate:
        final response = leaveVM.escalateLeaveResponse;
        success = response?.success ?? false;
        successMessage = 'Escalation sent!';
        errorMessage = 'Error escalating leave';
        break;

      case LeaveActionType.cancel:
        final response = leaveVM.cancelLeaveResponse;
        success = response?.success ?? false;
        successMessage = 'Leave cancelled successfully';
        errorMessage = 'Error cancelling leave';
        break;
    }

    if (error != null) {
      leaveVM.showError(context, errorMessage);
    } else if (success) {
      leaveVM.showSuccess(context, successMessage);
      Navigator.pop(context, true);
    } else {
      leaveVM.showError(context, 'Something went wrong');
    }
  }

  void _resetValues() {
    if (_leave == null) return;

    setState(() {
      _reasonController.text = _leave!.leaveDetails.reason;
      _fromDate = _leave!.leaveDetails.fromDate;
      _toDate = _leave!.leaveDetails.toDate;
      _isHalfDay = _leave!.leaveDetails.isHalfDay;
      _isCompOff = _leave!.leaveDetails.isCompOff;
      _compDates = _leave!.leaveDetails.compDates.map(DateTime.parse).toList();
      _status = _leave!.leaveDetails.status;
      _selectedLeaveType = _leave!.leaveDetails.subType;
    });
  }

  Future<void> _initializeData() async {
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
        _profileViewModel = profileVM;
        _originalDocumentCount = leave.leaveDetails.documents.length;
        _selectedLeaveType = leave.leaveDetails.subType;
      });
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  // MARK: MAIN BUILD
  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        final leaveViewModel = context.watch<LeaveViewModel>();
        if (_leave == null ||
            leaveViewModel.isCancelLoading ||
            leaveViewModel.isEscalateLoading ||
            leaveViewModel.isRemindLoading) {
          return const Scaffold(
            body: Center(
              child: SpinKitSquareCircle(color: Colors.blue, size: 100),
            ),
          );
        }
        return WillPopScope(
          onWillPop: () async {
            if (viewModel.isEditMode) {
              _showConfirmationDialog(
                title: 'Discard Changes?',
                body:
                    'You have unsaved changes in your leave application. If you go back now, all your progress will be lost.',
                confirmButtonText: 'Discard',
                illustrationAsset: 'lib/assets/gifs/remove.gif',
                illustrationHeight: 180,
                onConfirm: () {
                  Navigator.of(context).pop(true);
                },
              );
              return false;
            }
            return true;
          },
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            behavior: HitTestBehavior.translucent,
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
                            if (_status.toLowerCase() != 'cancelled') ...[
                              _buildStatusSection(),
                              const SizedBox(height: 24),
                            ],
                            _buildLeaveCard(viewModel),
                            const SizedBox(height: 20),
                            _buildLeaveTypeCard(viewModel),
                            const SizedBox(height: 20),
                            _buildDetailsCard(viewModel),
                            const SizedBox(height: 20),
                            if (viewModel.isEditMode) ...[
                              DocumentUploadSection(
                                leaveViewModel: leaveViewModel,
                                parentContext: context,
                              ),
                              const SizedBox(height: 20),
                            ],
                            if (_leave!.leaveDetails.documents.isNotEmpty)
                              DocumentsCard(
                                documents: _leave!.leaveDetails.documents,
                                enableDelete: viewModel.isEditMode
                                    ? true
                                    : false,
                                onDelete: (index) {
                                  leaveViewModel.removeDocumentAt(index);
                                },
                              ),
                            const SizedBox(height: 20),
                            if (_leave!
                                .leaveDetails
                                .reqStatusTracking
                                .isNotEmpty)
                              if (_leave!
                                  .leaveDetails
                                  .reqStatusTracking
                                  .isNotEmpty)
                                StatusTrackingCard(
                                  statusTracking: _leave!
                                      .leaveDetails
                                      .reqStatusTracking
                                      .map((tracking) {
                                        return StatusTrackingItem(
                                          status: tracking.status,
                                          processedBy: tracking.processedBy,
                                          processedAt: tracking.processedAt,
                                          comment: tracking.comment,
                                        );
                                      })
                                      .toList(),
                                ),
                          ],
                        ),
                      ),
                    ),
                    _buildBottomActionBar(viewModel),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeaveTypeCard(ProfileViewModel profileViewModel) {
    final List<String> leaveTypes = ['Casual', 'Sick', 'Emergency', 'Annual'];
    final currentType = leaveTypes.firstWhere(
      (type) => type.toUpperCase() == _selectedLeaveType.toUpperCase(),
      orElse: () => leaveTypes[0],
    );

    return MyAppContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Leave Type",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),

          if (!profileViewModel.isEditMode)
            Text(currentType, style: const TextStyle(fontSize: 14))
          else
            MyAppDropDownMenu<String>(
              value: currentType,
              hint: 'Select Leave Type',
              borderRadius: 15,
              borderColor: Colors.transparent,
              dropdownColor: Colors.white,
              textColor: Colors.black87,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 2,
                  offset: const Offset(0, 0),
                ),
              ],
              items: leaveTypes.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedLeaveType = value; // 👈 update local variable
                  });
                }
              },
            ),
        ],
      ),
    );
  }

  // MARK: STATUS SECTION
  Widget _buildStatusSection() {
    final leaveDetails = _leave?.leaveDetails;

    if (leaveDetails == null) {
      return Center(
        child: SpinKitSquareCircle(color: Colors.blueAccent, size: 100),
      );
    }
    final DateTime today = DateTime.now();
    final DateTime todayDateOnly = DateTime(today.year, today.month, today.day);

    final bool isApproved = leaveDetails.status.toLowerCase() == 'approved';
    final bool isPending = leaveDetails.status.toLowerCase() == 'pending';
    final bool canCancelLeave =
        !isApproved ||
        (isApproved && !leaveDetails.fromDate.isBefore(todayDateOnly));

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
                      handleLeaveAction(LeaveActionType.remind);
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
                    handleLeaveAction(LeaveActionType.escalate);
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
                      handleLeaveAction(LeaveActionType.cancel);
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

  // MARK: CONFIRMATION DIALOG
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
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildLeaveCard(ProfileViewModel viewModel) {
    final duration = _leave?.duration ?? 0;
    final appliedOn = _leave?.leaveDetails.createdAt ?? DateTime.now();
    return MyAppContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Leave Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // From Date
              _buildDateField(
                context: context,
                label: 'From Date',
                date: _fromDate,
                isEditMode: viewModel.isEditMode,
                onTap: () => _selectFromDate(),
              ),

              SizedBox(width: 8),
              // To Date
              _buildDateField(
                context: context,
                label: 'To Date',
                date: _toDate,
                isEditMode: viewModel.isEditMode,
                onTap: () => _selectToDate(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Duration
              _buildStaticField(
                context: context,
                label: 'Duration',
                value: '$duration',
              ),

              const SizedBox(width: 8),
              // Applied On
              _buildDateField(
                context: context,
                label: 'Applied On',
                date: appliedOn,
                isEditMode: false,
                onTap: null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStaticField({
    required BuildContext context,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MARK: DATE FIELD
  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required DateTime date,
    required bool isEditMode,
    required VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: isEditMode ? onTap : null,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: isEditMode
                ? LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.1),
                      theme.colorScheme.primary.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isEditMode
                  ? theme.colorScheme.primary.withOpacity(0.3)
                  : (Colors.grey.withOpacity(0.2)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (isEditMode) ...[
                    Icon(
                      Icons.edit_outlined,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('dd/MM/yyyy').format(date),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // MARK: - REASON CARD
  Widget _buildDetailsCard(ProfileViewModel viewModel) {
    return MyAppContainer(
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
            MyAppTextField(
              controller: _reasonController,
              hintText: 'Enter reason for leave',
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a reason';
                }
                return null;
              },
              fillColor: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 5,
                  offset: const Offset(0, 0),
                ),
              ],
              onFocusChanged: (hasFocus) {
                // Optional: add behavior when focus changes, e.g. scroll into view
              },
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withOpacity(0.15)),
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
        ],
      ),
    );
  }

  // MARK: - BOTTOM BAR
  Widget _buildBottomActionBar(ProfileViewModel viewModel) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SafeArea(
        child: Row(
          children: [
            if (viewModel.isEditMode) ...[
              // Cancel Button
              Expanded(
                child: MyAppButton(
                  label: 'Cancel',
                  type: MyButtonType.outlined,
                  onPressed: viewModel.isLoading
                      ? null
                      : () async {
                          await _initializeData();
                          viewModel.resetEditMode();
                        },
                  foregroundColor: theme.colorScheme.primary,
                  backgroundColor: theme.colorScheme.primary.withOpacity(
                    0.3,
                  ), // border color
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  borderRadius: 12,
                ),
              ),
              const SizedBox(width: 4),

              // Save Button
              Expanded(
                child: MyAppButton(
                  label: 'Save Changes',
                  onPressed: viewModel.isLoading ? null : () => _saveChanges(),
                  isLoading: viewModel.isLoading,
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  borderRadius: 12,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // MARK: PRIVATE METHODS
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

  void toggleEditModel() {
    _profileViewModel.toggleEditMode();
    if (_profileViewModel.isEditMode == false) {
      _resetValues();
    }
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

  Future<void> _saveChanges() async {
    final leaveViewModel = context.read<LeaveViewModel>();
    if (!_formKey.currentState!.validate()) return;

    final hasLeaveTypeChanges =
        _selectedLeaveType.toLowerCase() !=
        leaveViewModel.selectedLeaveType?.toLowerCase();

    // Compare new values with old ones
    final hasDateChanges =
        _fromDate != _leave!.leaveDetails.fromDate ||
        _toDate != _leave!.leaveDetails.toDate;

    final hasReasonChange =
        _reasonController.text.trim() != _leave!.leaveDetails.reason.trim();

    final hasNewDocuments = leaveViewModel.selectedDocuments.isNotEmpty;

    // Check if documents were deleted by comparing with original count
    final currentDocumentCount =
        leaveViewModel.selectedLeaveById?.leaveDetails.documents.length ?? 0;
    final hasDeletedDocuments = _originalDocumentCount != currentDocumentCount;

    final hasChanges =
        hasDateChanges ||
        hasLeaveTypeChanges ||
        hasReasonChange ||
        hasNewDocuments ||
        hasDeletedDocuments;

    // If no changes, just pop and don't call update
    if (!hasChanges) {
      _profileViewModel.resetEditMode();
      return;
    }

    // Step 1: Convert remaining existing docs (after deletions)
    final existingDocs = leaveViewModel
        .selectedLeaveById
        ?.leaveDetails
        .documents
        .map((doc) {
          return LeaveDocumentForApply(docType: doc.docType, docBytes: '');
        })
        .toList();

    // Step 2: Convert new uploaded files to LeaveDocumentForApply (includes base64)
    final newDocs = await leaveViewModel.convertDocumentsToLeaveDocuments();

    // Step 3: Combine both into a single list
    final List<LeaveDocumentForApply> allDocuments = [
      ...(existingDocs ?? []),
      ...newDocs,
    ];

    // Step 4: Send update request
    final success = await _profileViewModel.updateLeave(
      leaveId: _leave!.leaveId,
      userId: widget.userId,
      fromDate: _fromDate,
      toDate: _toDate,
      reason: _reasonController.text.trim(),
      isCompOff: _isCompOff,
      isHalfDay: _isHalfDay,
      compDates: _compDates,
      documents: allDocuments,
      leaveType: _selectedLeaveType,
    );

    if (success && mounted) {
      _profileViewModel.showInfo(context, 'Leave updated successfully');
      // Clear selected documents and refresh
      setState(() {
        leaveViewModel.selectedDocuments.clear();
      });
      // Reload the leave data to show updated documents
      await _initializeData();
    } else if (mounted) {
      AppToast.error(context, 'Failed to update leave');
    }
  }
}
