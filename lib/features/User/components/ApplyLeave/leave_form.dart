import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leavify/core/storage/app_storage.dart';
import 'package:leavify/core/utils/theme/app_theme.dart';
import 'package:leavify/features/Authentication/domain/response/login_response.dart';
import 'package:leavify/features/User/components/ApplyLeave/custom_calendar_component.dart';
import 'package:leavify/features/User/domain/request/apply_leave_request_model.dart';
import 'package:leavify/features/User/viewmodel/leave_view_model.dart';

enum LeaveFormType { leave, extra, workFromHome }

class LeaveForm extends StatefulWidget {
  final LeaveViewModel leaveViewModel;
  final LeaveFormType formType;
  final String title;

  const LeaveForm({
    super.key,
    required this.leaveViewModel,
    required this.formType,
    required this.title,
  });

  @override
  State<LeaveForm> createState() => _LeaveFormState();
}

class _LeaveFormState extends State<LeaveForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();

  // Date selection variables
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  bool _isSelectingEndDate = false;

  // Leave duration variables
  bool _isLeaveFullDay = true;
  bool _isLeaveHalfDay = false;

  // Half day work location variables
  bool _isHalfDayWorkFromOffice = true;
  bool _isHalfDayWorkFromHome = false;

  // Comp off variables
  bool _hasCompOffPlans = false;
  final List<DateTime> _selectedCompOffDates = [];

  // Comp off work location variables
  bool _isCompOffWorkFromOffice = true;
  bool _isCompOffWorkFromHome = false;

  // Comp off duration variables
  bool _isCompOffFullDay = true;
  bool _isCompOffHalfDay = false;

  // Form state variables
  bool _isLoading = false;
  final List<PlatformFile> _selectedDocuments = [];
  List<String> _uploadedDocumentUrls = [];

  @override
  void initState() {
    super.initState();
    _initializeFormDefaults();
  }

  void _initializeFormDefaults() {
    // Set default values based on form type
    _isLeaveFullDay = true;
    _isLeaveHalfDay = false;
    _isHalfDayWorkFromOffice = true;
    _isHalfDayWorkFromHome = false;
    _hasCompOffPlans = false;
    _isCompOffWorkFromOffice = true;
    _isCompOffWorkFromHome = false;
    _isCompOffFullDay = true;
    _isCompOffHalfDay = false;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Date selection methods
  Future<void> _selectDateRange(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: CustomCalendarComponent(
            enableRangeSelection: true,
            initialDate: _selectedStartDate ?? DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(DateTime.now().year + 1),
            onDateRangeSelected: (startDate, endDate) {
              setState(() {
                _selectedStartDate = startDate;
                _selectedEndDate = endDate;
                _isSelectingEndDate = false;
              });
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  Future<void> _selectCompOffDate(BuildContext context) async {
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
              // Close the dialog and return the selected date
              Navigator.of(context).pop(selectedDate);
            },
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (!_selectedCompOffDates.contains(picked)) {
          _selectedCompOffDates.add(picked);
        }
      });
    }
  }

  void _removeCompOffDate(int index) {
    setState(() {
      _selectedCompOffDates.removeAt(index);
    });
  }

  // Document handling methods
  Future<void> _pickDocuments() async {
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
          bool fileExists = _selectedDocuments.any(
            (existingFile) => existingFile.name == file.name,
          );

          if (!fileExists) {
            newFiles.add(file);
          } else {
            _showSnackBar(
              'File "${file.name}" already selected',
              Colors.orange,
            );
          }
        }

        if (newFiles.isNotEmpty) {
          setState(() {
            _selectedDocuments.addAll(newFiles);
          });
        }
      }
    } catch (e) {
      _showSnackBar('Error picking files: $e', Colors.red);
    }
  }

  void _removeDocument(int index) {
    setState(() {
      _selectedDocuments.removeAt(index);
    });
  }

  // Form submission methods
  Future<void> _submitLeaveForm(BuildContext context) async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      // Upload documents if any
      if (_selectedDocuments.isNotEmpty) {
        _uploadedDocumentUrls = await _uploadDocuments();
      }

      // Load user ID from SharedPreferences
      final userId = await _loadUserId();
      if (userId == null || userId.isEmpty) {
        setState(() => _isLoading = false);
        _showSnackBar('User ID not found. Please login again.', Colors.red);
        return;
      }

      // Create and submit request
      final request = await _createLeaveRequest();
      final success = await widget.leaveViewModel.submitLeaveRequest(request);

      setState(() => _isLoading = false);

      if (success) {
        _showSnackBar('${widget.title} applied successfully', Colors.green);
        _resetForm();
      } else {
        _showSnackBar(
          widget.leaveViewModel.errorMessage ?? 'Request failed',
          Colors.red,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error submitting request: $e', Colors.red);
    }
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) return false;

    if (_selectedStartDate == null) {
      _showSnackBar('Please select a date', Colors.red);
      return false;
    }

    if (_hasCompOffPlans && _selectedCompOffDates.isEmpty) {
      _showSnackBar('Please select comp off dates', Colors.red);
      return false;
    }

    return true;
  }

  // MARK: LOAD USER ID
  Future<String?> _loadUserId() async {
    final user = await AppStorage.getObject<LoginResponseModel>(
      "user_details",
      (json) => LoginResponseModel.fromJson(json),
    );
    final id = user?.currentUser?.id;
    return id;
  }

  // MARK: CREATE LEAVE REQUEST
  Future<ApplyLeaveRequestModel> _createLeaveRequest() async {
    // Load user ID from SharedPreferences
    final userId = await _loadUserId();

    return ApplyLeaveRequestModel(
      userId: userId ?? '', // Use the loaded user ID
      type: _getLeaveType(),
      fromDate: _selectedStartDate!.toUtc().toIso8601String(),
      toDate: (_selectedEndDate ?? _selectedStartDate)!
          .toUtc()
          .toIso8601String(),
      reason: _reasonController.text.trim(),
      isCompOff: _hasCompOffPlans,
      isHalfDay: _isLeaveHalfDay,
      documents: _uploadedDocumentUrls,
    );
  }

  String _getLeaveType() {
    switch (widget.formType) {
      case LeaveFormType.leave:
        return 'LEAVE';
      case LeaveFormType.extra:
        return 'EXTRA';
      case LeaveFormType.workFromHome:
        return 'WFH';
    }
  }

  Future<List<String>> _uploadDocuments() async {
    // Mock implementation - replace with actual upload logic
    List<String> uploadedUrls = [];
    for (PlatformFile file in _selectedDocuments) {
      String uploadedUrl = 'uploaded_${file.name}';
      uploadedUrls.add(uploadedUrl);
    }
    return uploadedUrls;
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _reasonController.clear();
    setState(() {
      _selectedStartDate = null;
      _selectedEndDate = null;
      _isSelectingEndDate = false;
      _isLeaveFullDay = true;
      _isLeaveHalfDay = false;
      _isHalfDayWorkFromOffice = true;
      _isHalfDayWorkFromHome = false;
      _hasCompOffPlans = false;
      _selectedCompOffDates.clear();
      _isCompOffWorkFromOffice = true;
      _isCompOffWorkFromHome = false;
      _isCompOffFullDay = true;
      _isCompOffHalfDay = false;
      _selectedDocuments.clear();
      _uploadedDocumentUrls.clear();
    });
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: backgroundColor, content: Text(message)),
    );
  }

  // Helper methods
  String _formatDate(DateTime? date) {
    if (date == null) return 'Select date';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Updated date formatting method
  String _formatDateRange() {
    if (_selectedStartDate == null) {
      return 'Select date range';
    }

    if (_selectedEndDate == null) {
      return 'From ${_formatDate(_selectedStartDate!)} - Select end date';
    }

    if (_isSameDay(_selectedStartDate!, _selectedEndDate!)) {
      return _formatDate(_selectedStartDate!);
    }

    return '${_formatDate(_selectedStartDate!)} - ${_formatDate(_selectedEndDate!)}';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  IconData _getFileIcon(String extension) {
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

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  // MARK: MAIN BUILD SECTION
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            _buildSectionTitle(widget.title),
            const SizedBox(height: 24),

            // Date Selection Section
            _buildDateSelectionSection(),
            const SizedBox(height: 24),

            // Leave Duration Section
            _buildLeaveDurationSection(),
            const SizedBox(height: 24),

            // Comp Off Section (only for leave form)
            if (widget.formType == LeaveFormType.leave) ...[
              _buildCompOffSection(),
              const SizedBox(height: 24),
            ],

            // Reason Section
            _buildReasonSection(),
            const SizedBox(height: 24),

            // Documents Section
            _buildDocumentsSection(),
            const SizedBox(height: 24),

            // Submit Button
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  // MARK: TITLE SECTION
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
      ),
    );
  }

  // MARK: DATE SELECTION SECTION
  Widget _buildDateSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Date',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Date picker button
        GestureDetector(
          onTap: () => _selectDateRange(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundSecondary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDateRange(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: _selectedStartDate == null
                              ? AppTheme.textHint
                              : AppTheme.textPrimary,
                        ),
                      ),
                      if (_isSelectingEndDate)
                        Text(
                          'Tap to select end date',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppTheme.primaryBlue,
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                    ],
                  ),
                ),
                Icon(Icons.calendar_today, color: Colors.blueAccent, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // MARK: REASON SECTION
  Widget _buildLeaveDurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duration',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        // Full day / Half day radio buttons
        Row(
          children: [
            Expanded(
              child: _buildRadioOption(
                title: 'Full Day',
                value: _isLeaveFullDay,
                onChanged: (value) {
                  setState(() {
                    _isLeaveFullDay = true;
                    _isLeaveHalfDay = false;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRadioOption(
                title: 'Half Day',
                value: _isLeaveHalfDay,
                onChanged: (value) {
                  setState(() {
                    _isLeaveFullDay = false;
                    _isLeaveHalfDay = true;
                  });
                },
              ),
            ),
          ],
        ),

        // Half day work location options
        if (_isLeaveHalfDay && widget.formType != LeaveFormType.workFromHome ||
            widget.formType == LeaveFormType.extra) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildRadioOption(
                  title: 'WFO',
                  value: _isHalfDayWorkFromOffice,
                  onChanged: (value) {
                    setState(() {
                      _isHalfDayWorkFromOffice = true;
                      _isHalfDayWorkFromHome = false;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRadioOption(
                  title: 'WFH',
                  value: _isHalfDayWorkFromHome,
                  onChanged: (value) {
                    setState(() {
                      _isHalfDayWorkFromOffice = false;
                      _isHalfDayWorkFromHome = true;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // MARK: COMP OFF SECTION
  Widget _buildCompOffSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Comp off checkbox
        Row(
          children: [
            Checkbox(
              value: _hasCompOffPlans,
              onChanged: (value) {
                setState(() {
                  _hasCompOffPlans = value ?? false;
                  if (!_hasCompOffPlans) {
                    _selectedCompOffDates.clear();
                  }
                });
              },
              activeColor: AppTheme.primaryBlue,
            ),
            Text(
              'Any Comp off Plans?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        // Comp off details
        if (_hasCompOffPlans) ...[
          const SizedBox(height: 16),
          // Date selection for comp off
          GestureDetector(
            onTap: () => _selectCompOffDate(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Comp Off Dates',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Selected comp off dates
          if (_selectedCompOffDates.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Comp Off Dates (${_selectedCompOffDates.length})',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(_selectedCompOffDates.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: AppTheme.primaryBlue,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _formatDate(_selectedCompOffDates[index]),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _removeCompOffDate(index),
                            icon: const Icon(
                              Icons.close,
                              color: Colors.grey,
                              size: 18,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Comp off work location
          Row(
            children: [
              Expanded(
                child: _buildRadioOption(
                  title: 'WFO',
                  value: _isCompOffWorkFromOffice,
                  onChanged: (value) {
                    setState(() {
                      _isCompOffWorkFromOffice = true;
                      _isCompOffWorkFromHome = false;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRadioOption(
                  title: 'WFH',
                  value: _isCompOffWorkFromHome,
                  onChanged: (value) {
                    setState(() {
                      _isCompOffWorkFromOffice = false;
                      _isCompOffWorkFromHome = true;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // MARK: RADIO BUTTON
  Widget _buildRadioOption({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(true),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: value
              ? Colors.blueAccent.withOpacity(0.6)
              : AppTheme.backgroundSecondary,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.09),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: value ? AppTheme.black : Colors.grey,
                fontWeight: value ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MARK: REASION SECTION
  Widget _buildReasonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Reason',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: TextFormField(
            controller: _reasonController,
            maxLines: 1,
            style: Theme.of(context).textTheme.bodyLarge,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => {FocusScope.of(context).unfocus()},
            decoration: InputDecoration(
              hintText: 'Is everything okay ???',
              filled: true,
              fillColor: AppTheme.backgroundSecondary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppTheme.primaryBlue,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              // Remove error text from showing inside the field
              errorStyle: const TextStyle(height: 0, fontSize: 0),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a reason';
              }
              if (value.trim().length < 10) {
                return 'Reason must be at least 10 characters';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 8),
        // Hint text and validation messages shown here
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _reasonController,
          builder: (context, value, child) {
            // Check validation state
            String? errorMessage;
            if (value.text.trim().isEmpty) {
              errorMessage = null; // Show hint when empty
            } else if (value.text.trim().length < 10) {
              errorMessage = 'Reason must be at least 10 characters';
            } else {
              errorMessage = '';
            }

            return Text(
              errorMessage ?? "Please enter at least 10 characters...",
              style: TextStyle(
                color: errorMessage != null ? Colors.red : Colors.grey,
                fontSize: 13,
              ),
            );
          },
        ),
      ],
    );
  }

  // MARK: DOCUMENT SECTION
  Widget _buildDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Supporting Documents (Optional)',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),

        // Upload button
        GestureDetector(
          onTap: _pickDocuments,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundSecondary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 32,
                  color: AppTheme.primaryBlue,
                ),
                const SizedBox(width: 15),
                Text(
                  'Tap to upload documents',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Selected documents list
        if (_selectedDocuments.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Documents (${_selectedDocuments.length})',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(_selectedDocuments.length, (index) {
                  final document = _selectedDocuments[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          _getFileIcon(document.extension ?? ''),
                          color: AppTheme.primaryBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                document.name,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                _formatFileSize(document.size),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppTheme.textHint),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _removeDocument(index),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // MARK: SUBMIT BUTTON
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () => _submitLeaveForm(context),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppTheme.primaryBlue,
          disabledBackgroundColor: AppTheme.primaryBlue.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Apply ${widget.title}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
