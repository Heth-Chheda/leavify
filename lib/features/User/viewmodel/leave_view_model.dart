import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leavify/core/storage/app_storage.dart';
import 'package:leavify/features/Authentication/domain/response/get_user_summary_response.dart';
import 'package:leavify/features/User/components/ApplyLeave/custom_calendar_component.dart';

import '../data/leave_repository.dart';
import '../domain/request/apply_leave_request_model.dart';

enum LeaveFormType { leave, extra, workFromHome }

class LeaveViewModel extends ChangeNotifier {
  final LeaveRepository _repository = LeaveRepository();

  // MARK: - FORM CONTROLLERS
  final TextEditingController reasonController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
  bool isLoading = false;
  String? errorMessage;
  String? successLeaveId;

  // MARK: - FORM TYPE PROPERTY
  LeaveFormType? currentFormType;

  // MARK: - INITIALIZATION
  void initializeForm(LeaveFormType formType) {
    currentFormType = formType;
    _resetFormState();
  }

  void _resetFormState() {
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
    errorMessage = null;
    successLeaveId = null;

    // Defer notifyListeners to avoid calling during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
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
            firstDate: now,
            lastDate: DateTime(now.year + 1),
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

  Future<List<String>> _uploadDocuments() async {
    // Mock implementation - replace with actual upload logic
    List<String> uploadedUrls = [];
    for (PlatformFile file in selectedDocuments) {
      String uploadedUrl = 'uploaded_${file.name}';
      uploadedUrls.add(uploadedUrl);
    }
    return uploadedUrls;
  }

  // MARK: - FORM VALIDATION METHODS
  bool validateForm(Function(String, Color) showSnackBar) {
    if (!formKey.currentState!.validate()) return false;

    if (selectedStartDate == null) {
      showSnackBar('Please select a date', Colors.red);
      return false;
    }

    if (hasCompOffPlans && selectedCompOffDates.isEmpty) {
      showSnackBar('Please select comp off dates', Colors.red);
      return false;
    }

    return true;
  }

  // MARK: - FORM SUBMISSION METHODS
  Future<void> submitLeaveForm(
    BuildContext context,
    Function(String, Color) showSnackBar,
  ) async {
    if (!validateForm(showSnackBar)) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Upload documents if any
      if (selectedDocuments.isNotEmpty) {
        uploadedDocumentUrls = await _uploadDocuments();
      }

      // Load user ID from SharedPreferences
      final userId = await _loadUserId();
      if (userId == null || userId.isEmpty) {
        isLoading = false;
        notifyListeners();
        showSnackBar('User ID not found. Please login again.', Colors.red);
        return;
      }

      // Create and submit request
      final request = await _createLeaveRequest(userId);
      final success = await submitLeaveRequest(request);

      isLoading = false;
      notifyListeners();

      if (!context.mounted) return;

      if (success) {
        final formTitle = _getFormTitle();
        showSnackBar('$formTitle applied successfully', Colors.green);
        resetForm();
        Navigator.pushNamed(context, '/home');
      } else {
        showSnackBar(errorMessage ?? 'Request failed', Colors.red);
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      showSnackBar('Error submitting request: $e', Colors.red);
    }
  }

  // MARK: SUBMIT LEAVE REQUEST
  Future<bool> submitLeaveRequest(ApplyLeaveRequestModel request) async {
    final response = await _repository.applyLeave(request);

    if (response.success != null) {
      successLeaveId = response.leaveId;
      errorMessage = null;
      return true;
    } else {
      errorMessage = response.error;
      successLeaveId = null;
      return false;
    }
  }

  // MARK: CREATE LEAVE REQUEST
  Future<ApplyLeaveRequestModel> _createLeaveRequest(String userId) async {
    final adjustedRange = getAdjustedDateRange();
    List<String> compOffDateStrings = selectedCompOffDates.map((date) {
      // Create a DateTime with specific time (similar to your date range adjustment)
      final adjustedDate = DateTime(
        date.year,
        date.month,
        date.day,
        00, // Set to 20:55:44 to match your format
        00,
        00,
        00, // milliseconds
      );
      return adjustedDate.toUtc().toIso8601String();
    }).toList();
    return ApplyLeaveRequestModel(
      userId: userId,
      type: _getLeaveType(),
      fromDate: adjustedRange['from']!.toUtc().toIso8601String(),
      toDate: adjustedRange['to']!.toUtc().toIso8601String(),
      reason: reasonController.text.trim(),
      isCompOff: hasCompOffPlans,
      isHalfDay: isLeaveHalfDay,
      compDates: compOffDateStrings,
      documents: uploadedDocumentUrls,
    );
  }

  // MARK: MANAGER SPECIFIC FUNCTIONS

  // MARK: - UTILITY METHODS
  Future<String?> _loadUserId() async {
    final user = await AppStorage.getObject<GetUserSummaryResponse>(
      "user_details",
      (json) => GetUserSummaryResponse.fromJson(json),
    );
    return user?.currentUser?.id;
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

  String _getFormTitle() {
    switch (currentFormType) {
      case LeaveFormType.leave:
        return 'Leave';
      case LeaveFormType.extra:
        return 'Extra Day';
      case LeaveFormType.workFromHome:
        return 'Work From Home';
      default:
        return 'Leave';
    }
  }

  String formatDateRange() {
    if (selectedStartDate == null) {
      return 'Select date range';
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
    final fromDateTime = DateTime(
      selectedStartDate!.year,
      selectedStartDate!.month,
      selectedStartDate!.day,
      0,
      0,
      0,
    );

    final endDate = selectedEndDate ?? selectedStartDate!;
    final toDateTime = DateTime(
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
    errorMessage = null;
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
