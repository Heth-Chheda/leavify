import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leavify/base/base_view_model.dart';
import 'package:leavify/core/storage/app_storage.dart';
import 'package:leavify/core/utils/constants/enums/enums.dart';
import 'package:leavify/core/utils/formatters/date/date_formatter.dart';
// import 'package:leavify/dummydata/leave/dummy_leave_detail.dart';
// import 'package:leavify/dummydata/leave/dummy_pending_request_user.dart';
// import 'package:leavify/dummydata/leave/dummy_team_users.dart';
import 'package:leavify/features/Authentication/domain/response/get_all_response.dart';
import 'package:leavify/features/Authentication/domain/response/get_user_summary_response.dart';
import 'package:leavify/features/Home/viewmodel/home_view_model.dart';
import 'package:leavify/features/Leave/components/ApplyLeave/custom_calendar_component.dart';
import 'package:leavify/features/Leave/models/request/apply_leave_request_model.dart';
import 'package:leavify/features/Leave/models/response/get_leave_by_id_response.dart';
import 'package:leavify/features/Leave/models/response/reportee_response.dart';
import 'package:leavify/features/Leave/models/response/send_reminder_response.dart';
import 'package:leavify/models/general_response.dart';
import 'package:leavify/router/app_navigator.dart';
import 'package:leavify/router/route_names.dart';

import '../data/leave_repository.dart';

class LeaveViewModel extends BaseViewModel {
  final LeaveRepository _repository = LeaveRepository();

  // MARK: - FORM CONTROLLERS
  final TextEditingController reasonController = TextEditingController();

  final String displayErrorMessage = 'Something went wrong';

  // MARK: - DATE SELECTION PROPERTIES
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  bool isSelectingEndDate = false;

  // MARK: - LEAVE DURATION PROPERTIES
  bool isLeaveFullDay = true;
  bool isLeaveHalfDay = false;

  // MARK: - HALF DAY LOCATION PROPERTIES
  bool isHalfDayWorkFromOffice = true;
  bool isHalfDayWorkFromHome = false;

  // MARK: - COMP-OFF PROPERTIES
  bool hasCompOffPlans = false;
  final List<DateTime> selectedCompOffDates = [];
  bool isCompOffWorkFromOffice = true;
  bool isCompOffWorkFromHome = false;
  bool isCompOffFullDay = true;
  bool isCompOffHalfDay = false;

  // MARK: - DOCUMENT PROPERTIES
  final List<PlatformFile> selectedDocuments = [];
  List<String> uploadedDocumentUrls = [];

  // MARK: - REQUEST STATE PROPERTIES
  bool isRejectLoading = false;
  bool isApproveLoading = false;
  String? successLeaveId;

  // MARK: - GET ALL PENDING LEAVES (MANAGER)
  List<GetAllResponse> _getAllPendingLeaves = [];
  List<GetAllResponse> get getAllPendingLeaves => _getAllPendingLeaves;

  // MARK: - FORM TYPE PROPERTY
  LeaveFormType? currentFormType;

  // MARK: - LEAVE BY ID
  GetLeaveByIdResponse? selectedLeaveById;
  String? processLeaveError;

  // MARK: - SEND REMINDER
  SendReminderResponse? reminderResponse;

  // MARK: - ESCALATE LEVE
  GeneralResponse? escalateLeaveResponse;
  bool isProcessEscalatedLeaveLoading = false;

  GeneralResponse? cancelLeaveResponse;

  // MARK: REQEUSTED FOR
  bool isReqeustedFor = false;
  List<Reportee> teamUsers = [];
  Reportee? _selectedUser;
  Reportee? get selectedUser => _selectedUser;

  bool isRemindLoading = false;
  bool isEscalateLoading = false;
  bool isCancelLoading = false;

  // MARK: LEAVE TYPE
  String? selectedLeaveType;

  // MARK: CATEGORY
  String? _selectedLeaveCategory;
  String? get selectedLeaveCategory => _selectedLeaveCategory;

  // MARK: - INITIALIZATION
  void initializeForm({required HomeViewModel homeViewModel}) async {
    await homeViewModel.getLeaveBalance();
    await getReportees();
    await homeViewModel.getCategory();
    // teamUsers = dummyTeamUsers;
    _resetFormState();
  }

  void updateSelectedLeaveType(String? value) {
    selectedLeaveType = value;
    notifyListeners();
  }

  void updateDates(DateTime? start, DateTime? end) {
    selectedStartDate = start;
    selectedEndDate = end;
    notifyListeners();
  }

  void selectLeaveCategory(String categoryName) {
    _selectedLeaveCategory = categoryName;
    notifyListeners();
  }

  set selectedUser(Reportee? user) {
    _selectedUser = user;
    notifyListeners();
  }

  void _resetFormState() {
    resetForm();
  }

  void clearSelectedLeave() {
    selectedLeaveById = null;
    notifyListeners();
  }

  // MARK: - Document Helpers
  void removeDocumentAt(int index) {
    if (selectedLeaveById == null) return;
    final docs = selectedLeaveById!.leaveDetails.documents;

    if (index < 0 || index >= docs.length) return;

    docs.removeAt(index);
    notifyListeners();
  }

  Future<void> getReportees() async {
    try {
      update(isLoading: true, errorMessage: null);
      final userId = await AppStorage.getString("USER_ID") ?? "";
      final accessToken = await AppStorage.getString('JWT_TOKEN') ?? '';
      final response = await _repository.getReprtees(
        userId: userId,
        accessToken: accessToken,
      );
      teamUsers = response.reportees;
      update(isLoading: false);
    } catch (e) {
      debugPrint("Error fetching reportees: $e");
      update(isLoading: false);
    }
  }

  // MARK: - DATE SELECTION METHODS
  Future<void> selectDateRange(BuildContext context) async {
    final now = DateTime.now();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: CustomCalendarComponent(
            enableRangeSelection: true,
            initialDate: selectedStartDate ?? now,
            onClose: () => Navigator.of(context).pop(),
            onDateRangeSelected: (startDate, endDate) {
              selectedStartDate = startDate;
              selectedEndDate = endDate;
              isSelectingEndDate = false;
              notifyListeners();
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  Future<void> selectCompOffDate(BuildContext context) async {
    final now = DateTime.now();

    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: CustomCalendarComponent(
            initialDate: now,
            firstDate: now.subtract(const Duration(days: 365)),
            lastDate: DateTime(now.year + 1),
            onDateSelected: (DateTime selectedDate) {
              Navigator.of(context).pop(selectedDate);
            },
          ),
        );
      },
    );

    if (picked != null && !selectedCompOffDates.contains(picked)) {
      selectedCompOffDates.add(picked);
      notifyListeners();
    }
  }

  void removeCompOffDate(int index) {
    if (index >= 0 && index < selectedCompOffDates.length) {
      selectedCompOffDates.removeAt(index);
      notifyListeners();
    }
  }

  // MARK: - LEAVE DURATION METHODS
  void setLeaveFullDay(bool value) {
    isLeaveFullDay = value;
    isLeaveHalfDay = !value;
    notifyListeners();
  }

  void setLeaveHalfDay(bool value) {
    isLeaveHalfDay = value;
    isLeaveFullDay = !value;
    notifyListeners();
  }

  void setHalfDayWorkFromOffice(bool value) {
    isHalfDayWorkFromOffice = value;
    isHalfDayWorkFromHome = !value;
    notifyListeners();
  }

  void setHalfDayWorkFromHome(bool value) {
    isHalfDayWorkFromHome = value;
    isHalfDayWorkFromOffice = !value;
    notifyListeners();
  }

  // MARK: - COMP-OFF METHODS
  void setCompOffPlans(bool value) {
    hasCompOffPlans = value;
    if (!value) {
      selectedCompOffDates.clear();
    }
    notifyListeners();
  }

  void setCompOffWorkFromOffice(bool value) {
    isCompOffWorkFromOffice = value;
    isCompOffWorkFromHome = !value;
    notifyListeners();
  }

  void setCompOffWorkFromHome(bool value) {
    isCompOffWorkFromHome = value;
    isCompOffWorkFromOffice = !value;
    notifyListeners();
  }

  void updateSelectedDocuments(List<PlatformFile> newFiles) {
    selectedDocuments
      ..clear()
      ..addAll(newFiles);
    notifyListeners();
  }

  // MARK: - FORM VALIDATION METHODS
  bool validateForm(BuildContext context) {
    if (selectedStartDate == null) {
      showError(context, 'Please select the date.');
      return false;
    }
    if (selectedLeaveType == '' || selectedLeaveType == null) {
      showError(context, 'Leave type is necessary!');
      return false;
    }
    return true;
  }

  // MARK: - SUBMIT LEAVE FORM METHOD
  Future<void> submitLeaveForm(
    BuildContext context,
    FocusNode reasonFocusNode,
  ) async {
    if (!validateForm(context)) {
      return;
    }

    update(isLoading: true, errorMessage: null);

    try {
      if (reasonController.text.length < 10) {
        reasonFocusNode.requestFocus();
        update(isLoading: false);
        return;
      }
      // Load user ID from SharedPreferences
      final userId = await _loadUserId();
      if (userId == null || userId.isEmpty) {
        update(isLoading: false);
        return;
      }

      final request = await _createLeaveRequest(userId);

      // Submit the request
      final success = await submitLeaveRequest(request);

      update(isLoading: false);

      if (!context.mounted) return;

      if (success) {
        resetForm();
        showSuccess(context, 'Leave applied!');
        AppNavigator.setRootView(RouteNames.home);
      }
    } catch (e) {
      update(isLoading: false);
      showError(context, 'Error submitting leave.');
    }
  }

  // MARK: - SUBMIT LEAVE REQUEST
  Future<bool> submitLeaveRequest(ApplyLeaveRequestModel request) async {
    final accessToken = await AppStorage.getString('JWT_TOKEN') ?? '';
    final response = await _repository.applyLeave(request, accessToken);
    if (response.success == true) {
      successLeaveId = response.leaveId;
      update(errorMessage: null);
      return true;
    } else {
      update(errorMessage: displayErrorMessage);
      debugPrint(displayErrorMessage);
      successLeaveId = null;
      return false;
    }
  }

  // MARK: - CREATE LEAVE REQUEST METHOD
  Future<ApplyLeaveRequestModel> _createLeaveRequest(String userId) async {
    final adjustedRange = getAdjustedDateRange();
    List<String> compOffDateStrings = selectedCompOffDates.map((date) {
      final adjustedDate = DateTime(
        date.year,
        date.month,
        date.day,
        00,
        00,
        00,
        00,
      );
      return adjustedDate.toUtc().toIso8601String();
    }).toList();

    // Convert documents to LeaveDocument objects with base64
    List<LeaveDocumentForApply> documents = [];
    if (selectedDocuments.isNotEmpty) {
      try {
        documents = await convertDocumentsToLeaveDocuments();
      } catch (e) {
        rethrow; // Re-throw to be handled by the calling method
      }
    }

    final request = selectedUser != null
        ? ApplyLeaveRequestModel(
            userId: _selectedUser!.id,
            requestedBy: userId,
            type: 'LEAVE',
            subType: selectedLeaveType ?? 'GENERAL',
            fromDate: adjustedRange['from']!.toUtc().toIso8601String(),
            toDate: adjustedRange['to']!.toUtc().toIso8601String(),
            reason: reasonController.text.trim(),
            isCompOff: hasCompOffPlans,
            isHalfDay: isLeaveHalfDay,
            compDates: compOffDateStrings,
            documents: documents,
            category: _selectedLeaveCategory,
          )
        : ApplyLeaveRequestModel(
            userId: userId,
            requestedBy: userId,
            type: 'LEAVE',
            subType: selectedLeaveType ?? 'GENERAL',
            fromDate: adjustedRange['from']!.toUtc().toIso8601String(),
            toDate: adjustedRange['to']!.toUtc().toIso8601String(),
            reason: reasonController.text.trim(),
            isCompOff: hasCompOffPlans,
            isHalfDay: isLeaveHalfDay,
            compDates: compOffDateStrings,
            documents: documents,
          );

    debugPrint("Created Leave Request: ${request.toJson()}");
    return request;
  }

  // MARK: - CONVERT DOCUMENTS TO BASE64 (Fixed Version)
  Future<List<LeaveDocumentForApply>> convertDocumentsToLeaveDocuments() async {
    List<LeaveDocumentForApply> leaveDocuments = [];

    try {
      for (int i = 0; i < selectedDocuments.length; i++) {
        PlatformFile file = selectedDocuments[i];
        Uint8List? fileBytes;

        // Try to get bytes from different sources
        if (file.bytes != null) {
          // Web platform or when bytes are available
          fileBytes = file.bytes!;
        } else if (file.path != null) {
          // Mobile platforms - read from file path
          File fileFromPath = File(file.path!);
          if (await fileFromPath.exists()) {
            fileBytes = await fileFromPath.readAsBytes();
          } else {
            throw Exception('File not found at path: ${file.path}');
          }
        } else {
          throw Exception('Unable to access file data for ${file.name}');
        }

        // Convert bytes to base64
        String base64String = base64Encode(fileBytes);
        // Get file extension and determine docType
        String extension = file.extension?.toLowerCase() ?? '';
        String docType = _getDocumentType(extension);
        // Create LeaveDocument object
        LeaveDocumentForApply leaveDocument = LeaveDocumentForApply(
          docType: docType,
          docBytes: base64String,
        );

        leaveDocuments.add(leaveDocument);
      }
      return leaveDocuments;
    } catch (e) {
      throw Exception('Failed to process documents: $e');
    }
  }

  // MARK: - GET DOCUMENT TYPE HELPER
  String _getDocumentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'PDF';
      case 'doc':
      case 'docx':
        return 'DOC';
      case 'jpg':
      case 'jpeg':
        return 'JPG';
      case 'png':
        return 'PNG';
      default:
        return 'OTHER';
    }
  }

  // MARK: - UTILITY METHODS
  Future<String?> _loadUserId() async {
    final user = await AppStorage.getObject<GetUserSummaryResponse>(
      "user_details",
      (json) => GetUserSummaryResponse.fromJson(json),
    );
    return user?.currentUser?.id;
  }

  // MARK: - MANAGER FUNCTIONS
  /// FETCH PENDING LEAVES
  Future<void> fetchPendingLeaves() async {
    update(isLoading: true, errorMessage: null);
    notifyListeners();
    try {
      final userId = await _loadUserId();
      final accessToken = await AppStorage.getString('JWT_TOKEN') ?? '';
      final leaves = await _repository.getPendingLeaves(
        userId: userId ?? '',
        accessToken: accessToken,
      );
      // final leaves = dummyGetAllData;
      _getAllPendingLeaves = leaves;
      debugPrint("Fetched ${leaves.length} pending leaves");
      update(isLoading: false);
      notifyListeners();
    } catch (e) {
      update(errorMessage: e.toString());
    } finally {
      update(isLoading: false);
      notifyListeners();
    }
  }

  // MARK: - PROCESS LEAVES
  Future<bool> processLeaveRequest({
    required String leaveId,
    required String status,
    required BuildContext context,
    required String comment,
  }) async {
    try {
      update(isLoading: true, errorMessage: null);
      if (status.toLowerCase() == 'rejected') {
        isRejectLoading = true;
      } else {
        isApproveLoading = true;
      }
      processLeaveError = null;
      notifyListeners();

      final userId = await _loadUserId();

      debugPrint(
        "User ID: $userId, Leave ID: $leaveId, Status: $status, Comment: $comment",
      );

      final accessToken = await AppStorage.getString('JWT_TOKEN') ?? '';

      final response = await _repository.processLeave(
        leaveId: leaveId,
        status: status,
        actionTakenBy: userId ?? '',
        comment: comment,
        accessToken: accessToken,
      );

      if (response.success == true) {
        await fetchPendingLeaves();
        return true;
      } else {
        debugPrint("Error processing leave: ${response.error}");
        processLeaveError = response.error ?? 'Something went wrong.';
        return false;
      }
    } catch (e) {
      processLeaveError = e.toString();
      return false;
    } finally {
      update(isLoading: false);
      isApproveLoading = false;
      isRejectLoading = false;
      notifyListeners();
    }
  }

  // MARK: - GET LEAVE BY ID
  Future<void> getLeaveById({required String leaveId}) async {
    try {
      update(isLoading: true, errorMessage: null);
      selectedLeaveById = null;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      final accessToken = await AppStorage.getString('JWT_TOKEN') ?? '';

      final result = await _repository.getLeaveById(
        userId: userId ?? '',
        leaveId: leaveId,
        accessToken: accessToken,
      );

      // final result = dummyLeaveByIdData;

      selectedLeaveById = result;
    } catch (e) {
      update(errorMessage: e.toString());
      debugPrint("getLeaveById error: $errorMessage");
    } finally {
      update(isLoading: false);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // MARK: SEND REMINDER FOR LEAVE
  Future<void> sendReminderForLeave({required String leaveId}) async {
    try {
      isRemindLoading = true;
      update(isLoading: true, errorMessage: null);
      reminderResponse = null;
      notifyListeners();

      final userId = await _loadUserId();
      final accessToken = await AppStorage.getString('JWT_TOKEN') ?? '';

      final response = await _repository.sendReminderForLeave(
        userId: userId ?? '',
        leaveId: leaveId,
        accessToken: accessToken,
      );

      reminderResponse = response;
      isRemindLoading = false;
    } catch (e) {
      update(isLoading: false, errorMessage: e.toString());
      isRemindLoading = false;
    } finally {
      notifyListeners();
    }
  }

  // MARK: - ESCALATE LEAVE
  Future<void> escalateLeave({required String leaveId}) async {
    try {
      isEscalateLoading = true;
      update(isLoading: true, errorMessage: null);
      escalateLeaveResponse = null;
      notifyListeners();

      final userId = await _loadUserId();
      final accessToken = await AppStorage.getString('JWT_TOKEN') ?? '';

      final response = await _repository.escalateLeave(
        userId: userId ?? '',
        leaveId: leaveId,
        accessToken: accessToken,
      );

      escalateLeaveResponse = response;
      isEscalateLoading = false;
    } catch (e) {
      update(isLoading: false, errorMessage: e.toString());
      isEscalateLoading = false;
    } finally {
      notifyListeners();
    }
  }

  // MARK: - CANCEL LEAVE
  Future<void> cancelLeave({required String leaveId}) async {
    try {
      isCancelLoading = true;
      update(isLoading: true, errorMessage: null);
      cancelLeaveResponse = null;
      notifyListeners();

      final userId = await _loadUserId();
      final accessToken = await AppStorage.getString('JWT_TOKEN') ?? '';

      final response = await _repository.cancelLeave(
        userId: userId ?? '',
        leaveId: leaveId,
        accessToken: accessToken,
      );

      isCancelLoading = false;
      cancelLeaveResponse = response;
    } catch (e) {
      isCancelLoading = false;
      update(isLoading: false, errorMessage: e.toString());
    } finally {
      notifyListeners();
    }
  }

  // MARK: - PROCESS ESCALATED LEAVES
  Future<bool> processEscalatedLeaveRequest({
    required String leaveId,
    required String comment,
  }) async {
    isProcessEscalatedLeaveLoading = true;
    notifyListeners();

    final userId = await _loadUserId();
    final accessToken = await AppStorage.getString('JWT_TOKEN') ?? '';

    try {
      final response = await _repository.processEscalatedLeaves(
        userId: userId ?? '',
        leaveId: leaveId,
        comment: comment,
        accessToken: accessToken,
      );
      if (response.success == true) {
        await fetchPendingLeaves();
        return true;
      } else {
        debugPrint("Error processing escalated leave: ${response.message}");
        processLeaveError = response.message;
        return false;
      }
    } catch (e) {
      return false;
    } finally {
      isProcessEscalatedLeaveLoading = false;
      notifyListeners();
    }
  }

  String formatDateRange() {
    if (selectedStartDate == null) {
      return 'Select dates';
    }

    if (isSameDay(selectedStartDate!, selectedEndDate!)) {
      return DateFormatter.formatMonthDayYear(
        selectedStartDate!.toIso8601String(),
      );
    }

    return '${DateFormatter.formatMonthDayYear(selectedStartDate!.toIso8601String())} - ${DateFormatter.formatMonthDayYear(selectedEndDate!.toIso8601String())}';
  }

  Map<String, DateTime> getAdjustedDateRange() {
    // Create dates in UTC to avoid timezone conversion issues
    final fromDateTime = DateTime.utc(
      selectedStartDate!.year,
      selectedStartDate!.month,
      selectedStartDate!.day,
      0,
      0,
      0,
    );

    final endDate = selectedEndDate ?? selectedStartDate!;
    final toDateTime = DateTime.utc(
      endDate.year,
      endDate.month,
      endDate.day,
      23,
      59,
      59,
    );

    return {'from': fromDateTime, 'to': toDateTime};
  }

  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  IconData getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  void resetForm() {
    selectedStartDate = null;
    selectedEndDate = null;
    isSelectingEndDate = false;
    isLeaveFullDay = true;
    isLeaveHalfDay = false;
    isHalfDayWorkFromOffice = true;
    isHalfDayWorkFromHome = false;
    hasCompOffPlans = false;
    selectedCompOffDates.clear();
    isCompOffWorkFromOffice = true;
    isCompOffWorkFromHome = false;
    selectedDocuments.clear();
    uploadedDocumentUrls.clear();
    reasonController.clear();
    update(errorMessage: null);
    successLeaveId = null;
    _selectedUser = null;
    selectedLeaveType = null;
    _selectedLeaveCategory = null;
    isRemindLoading = false;
    isEscalateLoading = false;
    isCancelLoading = false;
    notifyListeners();
  }

  // MARK: - DISPOSE METHOD
  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }
}
