import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:leavify/core/utils/components/button/my_app_button.dart';
import 'package:leavify/core/utils/components/confirmation/confirmation_dialog.dart';
import 'package:leavify/core/utils/components/container/my_app_container.dart';
import 'package:leavify/core/utils/components/dropdownmenu/my_app_drop_down_menu.dart';
import 'package:leavify/core/utils/components/statustracking/status_tracking.dart';
import 'package:leavify/core/utils/components/textfield/my_app_text_field.dart';
import 'package:leavify/core/utils/constants/enums/enums.dart';
import 'package:leavify/core/utils/helpers/documents/ui/document_ui.dart';
import 'package:leavify/core/utils/helpers/documents/ui/viewer/document_viewer.dart';
import 'package:leavify/core/utils/theme/app_colors.dart';
import 'package:leavify/features/Leave/components/ApplyLeave/custom_calendar_component.dart';
import 'package:leavify/features/Leave/models/request/apply_leave_request_model.dart';
import 'package:leavify/features/Leave/models/response/get_leave_by_id_response.dart';
import 'package:leavify/features/Leave/viewModel/leave_view_model.dart';
import 'package:leavify/features/profile/viewmodel/profile_view_model.dart';
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
        _isHalfDay = leave.leaveDetails.isHalfDay; // From API
        _isCompOff = leave.leaveDetails.isCompOff;
        _compDates = leave.leaveDetails.compDates.map(DateTime.parse).toList();
        _status = leave.leaveDetails.status;
        _profileViewModel = profileVM;
        _originalDocumentCount = leave.leaveDetails.documents.length;
        _selectedLeaveType = leave.leaveDetails.subType;
      });
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

  @override
  Widget build(BuildContext context) {
    final isAppliedByManager = _leave?.userId != _leave?.requestedById;
    debugPrint('_status: $isAppliedByManager');
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        final leaveViewModel = context.watch<LeaveViewModel>();
        if (_leave == null ||
            leaveViewModel.isCancelLoading ||
            leaveViewModel.isEscalateLoading ||
            leaveViewModel.isRemindLoading) {
          return const Scaffold(
            body: Center(
              child: SpinKitSquareCircle(
                color: AppColors.highlightBlue,
                size: 100,
              ),
            ),
          );
        }
        return PopScope(
          canPop: !viewModel.isEditMode,
          onPopInvoked: (didPop) async {
            if (didPop) return;
            _showConfirmationDialog(
              title: 'Discard Changes?',
              body: 'You have unsaved changes. Progress will be lost.',
              confirmButtonText: 'Discard',
              onConfirm: () => Navigator.of(context).pop(),
            );
          },
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              backgroundColor: Colors.white,
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
                                !isAppliedByManager) ...[
                              _buildStatusSection(),
                              const SizedBox(height: 24),
                            ],
                            _buildLeaveCard(viewModel),
                            const SizedBox(height: 20),
                            _buildHalfDayToggle(viewModel), // Half Day Logic
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
                                enableDelete: viewModel.isEditMode,
                                onDelete: (index) =>
                                    leaveViewModel.removeDocumentAt(index),
                              ),
                            const SizedBox(height: 20),
                            if (_leave!
                                .leaveDetails
                                .reqStatusTracking
                                .isNotEmpty)
                              StatusTrackingCard(
                                statusTracking: _leave!
                                    .leaveDetails
                                    .reqStatusTracking
                                    .map(
                                      (t) => StatusTrackingItem(
                                        status: t.status,
                                        processedBy: t.processedBy,
                                        processedAt: t.processedAt,
                                        comment: t.comment,
                                      ),
                                    )
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

  // MARK: - HALF DAY WIDGET
  Widget _buildHalfDayToggle(ProfileViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CheckboxListTile(
        value: _isHalfDay,
        enabled: viewModel.isEditMode,
        onChanged: (bool? value) {
          if (value != null) setState(() => _isHalfDay = value);
        },
        title: const Text(
          "Half Day Leave",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        subtitle: const Text(
          "Apply for only half of the working day",
          style: TextStyle(fontSize: 12),
        ),
        activeColor: AppColors.highlightBlue,
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }

  // MARK: - SAVE CHANGES
  Future<void> _saveChanges() async {
    final leaveViewModel = context.read<LeaveViewModel>();
    if (!_formKey.currentState!.validate()) return;

    final details = _leave!.leaveDetails;

    // Check for changes
    final hasHalfDayChange = _isHalfDay != details.isHalfDay;
    final hasDateChanges =
        _fromDate != details.fromDate || _toDate != details.toDate;
    final hasReasonChange =
        _reasonController.text.trim() != details.reason.trim();
    final hasLeaveTypeChanges =
        _selectedLeaveType.toLowerCase() != details.subType.toLowerCase();

    final newDocsSelected = leaveViewModel.selectedDocuments;
    final currentDocCount =
        (_leave?.leaveDetails.documents.length ?? 0) + newDocsSelected.length;
    final hasDocumentChange =
        newDocsSelected.isNotEmpty || _originalDocumentCount != currentDocCount;

    if (!hasHalfDayChange &&
        !hasDateChanges &&
        !hasReasonChange &&
        !hasLeaveTypeChanges &&
        !hasDocumentChange) {
      _profileViewModel.resetEditMode();
      return;
    }

    List<LeaveDocumentForApply>? documents;
    if (hasDocumentChange) {
      final existingDocs =
          leaveViewModel.selectedLeaveById?.leaveDetails.documents ?? [];
      final keptDocs = existingDocs
          .map(
            (doc) => LeaveDocumentForApply(
              docType: doc.docType,
              docBytes: doc.docBytes,
            ),
          )
          .toList();
      final newDocs = await leaveViewModel.convertDocumentsToLeaveDocuments();
      documents = [...keptDocs, ...newDocs];
    }

    final success = await _profileViewModel.updateLeave(
      leaveId: _leave!.leaveId,
      userId: widget.userId,
      fromDate: hasDateChanges ? _fromDate : null,
      toDate: hasDateChanges ? _toDate : null,
      reason: hasReasonChange ? _reasonController.text.trim() : null,
      isHalfDay: _isHalfDay, // Pass the local state
      isCompOff: _isCompOff,
      documents: documents,
      leaveType: hasLeaveTypeChanges ? _selectedLeaveType : null,
    );

    if (success && mounted) {
      _profileViewModel.showInfo(context, 'Leave updated successfully');
      leaveViewModel.selectedDocuments.clear();
      await _initializeData();
    }
  }

  // Supporting Widgets (Leave Card, Static Fields, etc.)
  Widget _buildLeaveCard(ProfileViewModel viewModel) {
    final duration = _leave?.duration ?? 0;
    return MyAppContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Leave Period',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildDateField(
                context: context,
                label: 'From Date',
                date: _fromDate,
                isEditMode: viewModel.isEditMode,
                onTap: () => _selectFromDate(),
              ),
              const SizedBox(width: 8),
              _buildDateField(
                context: context,
                label: 'To Date',
                date: _toDate,
                isEditMode: viewModel.isEditMode,
                onTap: () => _selectToDate(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStaticField(
                context: context,
                label: 'Days',
                value: '$duration',
              ),
              const SizedBox(width: 8),
              _buildDateField(
                context: context,
                label: 'Applied On',
                date: _leave!.leaveDetails.createdAt,
                isEditMode: false,
                onTap: null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required DateTime date,
    required bool isEditMode,
    required VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: isEditMode ? onTap : null,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isEditMode
                ? AppColors.highlightBlue.withOpacity(0.05)
                : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isEditMode
                  ? AppColors.highlightBlue.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('dd MMM yyyy').format(date),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStaticField({
    required BuildContext context,
    required String label,
    required String value,
  }) {
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
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveTypeCard(ProfileViewModel profileViewModel) {
    final List<String> leaveTypes = ['Casual', 'Sick', 'Emergency', 'Annual'];
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
            Text(_selectedLeaveType, style: const TextStyle(fontSize: 14))
          else
            MyAppDropDownMenu<String>(
              value:
                  leaveTypes.any(
                    (e) => e.toLowerCase() == _selectedLeaveType.toLowerCase(),
                  )
                  ? leaveTypes.firstWhere(
                      (e) =>
                          e.toLowerCase() == _selectedLeaveType.toLowerCase(),
                    )
                  : leaveTypes[0],
              items: leaveTypes
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _selectedLeaveType = val!),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(ProfileViewModel viewModel) {
    return MyAppContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reason',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (viewModel.isEditMode)
            MyAppTextField(
              controller: _reasonController,
              maxLines: 3,
              hintText: 'Enter reason',
            )
          else
            Text(
              _leave!.leaveDetails.reason,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(ProfileViewModel viewModel) {
    if (!viewModel.isEditMode) return const SizedBox.shrink();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: MyAppButton(
                label: 'Cancel',
                type: MyButtonType.outlined,
                foregroundColor: Colors.black,
                onPressed: () {
                  _resetValues();
                  viewModel.resetEditMode();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MyAppButton(
                label: 'Save Changes',
                gradient: const LinearGradient(
                  colors: [AppColors.highlightBlue, AppColors.highlightPink],
                ),
                onPressed: _saveChanges,
                isLoading: viewModel.isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialogs and Date Pickers...
  Future<void> _selectFromDate() async {
    await _showCustomCalendar(
      title: 'From Date',
      initialDate: _fromDate,
      onDateSelected: (d) => setState(() {
        _fromDate = d;
        if (_toDate.isBefore(_fromDate)) _toDate = _fromDate;
      }),
    );
  }

  Future<void> _selectToDate() async {
    await _showCustomCalendar(
      title: 'To Date',
      initialDate: _toDate,
      firstDate: _fromDate,
      onDateSelected: (d) => setState(() => _toDate = d),
    );
  }

  Future<void> _showCustomCalendar({
    required String title,
    required DateTime initialDate,
    DateTime? firstDate,
    required Function(DateTime) onDateSelected,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: CustomCalendarComponent(
          initialDate: initialDate,
          firstDate:
              firstDate ?? DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          onDateSelected: (d) {
            onDateSelected(d);
            Navigator.pop(context);
          },
          onClose: () => Navigator.pop(context),
        ),
      ),
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
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildStatusSection() {
    final isPending = _leave?.leaveDetails.status.toLowerCase() == 'pending';

    return Row(
      children: [
        if (isPending)
          Expanded(
            child: MyAppButton(
              label: 'Remind',
              backgroundColor: Colors.orange,
              onPressed: () => _confirmLeaveAction(
                type: LeaveActionType.remind,
                title: 'Send Reminder?',
                body: 'Do you want to send a reminder for this leave request?',
                confirmText: 'Send',
                buttonBackgroundColor: Colors.orange,
              ),
            ),
          ),
        const SizedBox(width: 8),
        Expanded(
          child: MyAppButton(
            label: 'Escalate',
            backgroundColor: Colors.red,
            onPressed: () => _confirmLeaveAction(
              type: LeaveActionType.escalate,
              title: 'Escalate Leave?',
              body: 'This will escalate the leave request to higher authority.',
              confirmText: 'Escalate',
              buttonBackgroundColor: Colors.red,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: MyAppButton(
            label: 'Cancel',
            backgroundColor: Colors.grey,
            onPressed: () => _confirmLeaveAction(
              type: LeaveActionType.cancel,
              title: 'Cancel Leave?',
              body: 'Are you sure you want to cancel this leave request?',
              confirmText: 'Cancel Leave',
              buttonBackgroundColor: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  void _confirmLeaveAction({
    required LeaveActionType type,
    required String title,
    required String body,
    required String confirmText,
    required Color buttonBackgroundColor,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfirmationDialog(
        title: title,
        body: body,
        confirmButtonText: confirmText,
        buttonBackgroundColor: buttonBackgroundColor,
        onConfirm: () async {
          Navigator.pop(context); // close dialog
          await _handleLeaveAction(type);
        },
      ),
    );
  }

  Future<void> _handleLeaveAction(LeaveActionType type) async {
    final leaveVM = context.read<LeaveViewModel>();

    switch (type) {
      case LeaveActionType.cancel:
        await leaveVM.cancelLeave(leaveId: widget.leaveId);
        break;

      case LeaveActionType.remind:
        await leaveVM.sendReminderForLeave(leaveId: widget.leaveId);
        break;

      case LeaveActionType.escalate:
        await leaveVM.escalateLeave(leaveId: widget.leaveId);
        break;
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }
}
