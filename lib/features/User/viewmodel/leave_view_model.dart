import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leavify/base/base_view_model.dart';
import 'package:leavify/core/storage/app_storage.dart';
import 'package:leavify/features/Authentication/domain/response/get_all_response.dart';
import 'package:leavify/features/Authentication/domain/response/get_user_summary_response.dart';
import 'package:leavify/features/User/components/ApplyLeave/custom_calendar_component.dart';
import 'package:leavify/features/User/domain/response/get_leave_by_id_response.dart';
import 'package:leavify/features/User/domain/response/send_reminder_response.dart';
import 'package:leavify/models/general_response.dart';

import '../data/leave_repository.dart';
import '../domain/request/apply_leave_request_model.dart';

enum LeaveFormType { leave, extra, workFromHome }

class LeaveViewModel extends BaseViewModel {
  final LeaveRepository _repository = LeaveRepository();

  // MARK: - FORM CONTROLLERS
  final TextEditingController reasonController = TextEditingController();

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

  // MARK: - INITIALIZATION
  void initializeForm(LeaveFormType formType) {
    currentFormType = formType;
    _resetFormState();
  }

  void _resetFormState() {
    resetForm();
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

  // MARK: - DOCUMENT HANDLING METHODS
  Future<void> pickDocuments(Function(String, Color) showSnackBar) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        List<PlatformFile> newFiles = [];
        for (PlatformFile file in result.files) {
          // Check if file with same name already exists
          bool fileExists = selectedDocuments.any(
            (existingFile) => existingFile.name == file.name,
          );

          if (!fileExists) {
            newFiles.add(file);
          } else {
            showSnackBar('File "${file.name}" already selected', Colors.orange);
          }
        }

        if (newFiles.isNotEmpty) {
          selectedDocuments.addAll(newFiles);
          notifyListeners();
        }
      }
    } catch (e) {
      showSnackBar('Error picking files: $e', Colors.red);
    }
  }

  void removeDocument(int index) {
    if (index >= 0 && index < selectedDocuments.length) {
      selectedDocuments.removeAt(index);
      notifyListeners();
    }
  }

  // MARK: - FORM VALIDATION METHODS
  bool validateForm() {
    if (selectedStartDate == null) {
      return false;
    }

    if (hasCompOffPlans && selectedCompOffDates.isEmpty) {
      return false;
    }

    return true;
  }

  // MARK: - SUBMIT LEAVE FORM METHOD
  Future<void> submitLeaveForm(BuildContext context) async {
    if (!validateForm()) return;

    update(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      if (reasonController.text.length < 10) {
        update(isLoading: false);
        notifyListeners();
        return;
      }
      // Load user ID from SharedPreferences
      final userId = await _loadUserId();
      if (userId == null || userId.isEmpty) {
        update(isLoading: false);
        notifyListeners();
        return;
      }

      final request = await _createLeaveRequest(userId);

      // Submit the request
      final success = await submitLeaveRequest(request);

      update(isLoading: false);
      notifyListeners();

      if (!context.mounted) return;

      if (success) {
        resetForm();
        Navigator.pushNamed(context, '/home');
      }
    } catch (e) {
      update(isLoading: false);
      notifyListeners();
      debugPrint("Error in submitLeaveForm: $e");
    }
  }

  // MARK: - SUBMIT LEAVE REQUEST
  Future<bool> submitLeaveRequest(ApplyLeaveRequestModel request) async {
    final response = await _repository.applyLeave(request);
    if (response.success == true) {
      successLeaveId = response.leaveId;
      update(errorMessage: null);
      return true;
    } else {
      update(errorMessage: response.error);
      debugPrint("Error applying leave: $errorMessage");
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
    List<LeaveDocument> documents = [];
    if (selectedDocuments.isNotEmpty) {
      debugPrint(
        "Converting ${selectedDocuments.length} documents to LeaveDocuments...",
      );
      try {
        documents = await _convertDocumentsToLeaveDocuments();
        debugPrint("Successfully converted ${documents.length} documents");
      } catch (e) {
        debugPrint("Error converting documents: $e");
        rethrow; // Re-throw to be handled by the calling method
      }
    }

    final request = ApplyLeaveRequestModel(
      userId: userId,
      type: _getLeaveType(),
      fromDate: adjustedRange['from']!.toUtc().toIso8601String(),
      toDate: adjustedRange['to']!.toUtc().toIso8601String(),
      reason: reasonController.text.trim(),
      isCompOff: hasCompOffPlans,
      isHalfDay: isLeaveHalfDay,
      compDates: compOffDateStrings,
      documents: documents, // Now using LeaveDocument objects
    );
    debugPrint("Created Leave Request: ${request.toJson()}");
    return request;
  }

  // MARK: - CONVERT DOCUMENTS TO BASE64 (Fixed Version)
  Future<List<LeaveDocument>> _convertDocumentsToLeaveDocuments() async {
    List<LeaveDocument> leaveDocuments = [];

    try {
      for (int i = 0; i < selectedDocuments.length; i++) {
        PlatformFile file = selectedDocuments[i];
        debugPrint(
          "Processing document ${i + 1}/${selectedDocuments.length}: ${file.name}",
        );

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
        LeaveDocument leaveDocument = LeaveDocument(
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
    final userId = await _loadUserId();
    try {
      if (userId != null) {
        final leaves = await _repository.getPendingLeaves(userId: userId);
        _getAllPendingLeaves = leaves;
      }
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

      final response = await _repository.processLeave(
        leaveId: leaveId,
        status: status,
        actionTakenBy: userId ?? '',
        comment: comment,
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

      final userId = await _loadUserId();

      final result = await _repository.getLeaveById(
        userId: userId ?? '',
        leaveId: leaveId,
      );

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
      update(isLoading: true, errorMessage: null);
      reminderResponse = null;
      notifyListeners();

      final userId = await _loadUserId();

      final response = await _repository.sendReminderForLeave(
        userId: userId ?? '',
        leaveId: leaveId,
      );

      reminderResponse = response;
    } catch (e) {
      update(isLoading: false, errorMessage: e.toString());
    } finally {
      notifyListeners();
    }
  }

  // MARK: - ESCALATE LEAVE
  Future<void> escalateLeave({required String leaveId}) async {
    try {
      update(isLoading: true, errorMessage: null);
      escalateLeaveResponse = null;
      notifyListeners();

      final userId = await _loadUserId();

      final response = await _repository.escalateLeave(
        userId: userId ?? '',
        leaveId: leaveId,
      );

      escalateLeaveResponse = response;
    } catch (e) {
      update(isLoading: false, errorMessage: e.toString());
    } finally {
      notifyListeners();
    }
  }

  // MARK: - CANCEL LEAVE
  Future<void> cancelLeave({required String leaveId}) async {
    try {
      update(isLoading: true, errorMessage: null);
      cancelLeaveResponse = null;
      notifyListeners();

      final userId = await _loadUserId();

      final response = await _repository.cancelLeave(
        userId: userId ?? '',
        leaveId: leaveId,
      );

      cancelLeaveResponse = response;
    } catch (e) {
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

    try {
      final response = await _repository.processEscalatedLeaves(
        userId: userId ?? '',
        leaveId: leaveId,
        comment: comment,
      );

      if (response.success == true) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    } finally {
      isProcessEscalatedLeaveLoading = false;
      notifyListeners();
    }
  }

  String _getLeaveType() {
    switch (currentFormType) {
      case LeaveFormType.leave:
        return 'LEAVE';
      case LeaveFormType.extra:
        return 'EXTRA';
      case LeaveFormType.workFromHome:
        return 'WFH';
      default:
        return 'LEAVE';
    }
  }

  String formatDateRange() {
    if (selectedStartDate == null) {
      return 'Select dates';
    }

    if (selectedEndDate == null) {
      return 'From ${formatDate(selectedStartDate!)} - Select end date';
    }

    if (isSameDay(selectedStartDate!, selectedEndDate!)) {
      return formatDate(selectedStartDate!);
    }

    return '${formatDate(selectedStartDate!)} - ${formatDate(selectedEndDate!)}';
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
    notifyListeners();
  }

  // MARK: - DISPOSE METHOD
  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }
}
