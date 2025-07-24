import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:leavify/features/User/domain/request/apply_leave_request_model.dart';
import 'package:leavify/features/User/viewmodel/leave_view_model.dart';
import 'package:leavify/core/utils/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

enum LeaveFormType { leave, halfDay, compOff, workFromHome }

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

  DateTime? _fromDate;
  DateTime? _toDate;
  bool _isLoading = false;
  bool _isHalfDay = false;
  bool _isCompOff = false;
  List<PlatformFile> _selectedFiles = [];
  List<String> _uploadedDocuments = []; // This will store the uploaded file URLs/paths

  @override
  void initState() {
    super.initState();
    _setInitialValues();
  }

  void _setInitialValues() {
    switch (widget.formType) {
      case LeaveFormType.halfDay:
        _isHalfDay = true;
        break;
      case LeaveFormType.compOff:
        _isCompOff = true;
        break;
      case LeaveFormType.leave:
      case LeaveFormType.workFromHome:
      // Default values are already set
        break;
    }
  }

  String get _leaveType {
    switch (widget.formType) {
      case LeaveFormType.leave:
        return 'LEAVE';
      case LeaveFormType.halfDay:
        return 'HALF_DAY';
      case LeaveFormType.compOff:
        return 'COMP_OFF';
      case LeaveFormType.workFromHome:
        return 'WORK_FROM_HOME';
    }
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
      helpText: isFromDate ? 'Select From Date' : 'Select To Date',
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
          // For single day requests, set toDate same as fromDate
          if (widget.formType == LeaveFormType.halfDay ||
              widget.formType == LeaveFormType.workFromHome) {
            _toDate = picked;
          }
        } else {
          _toDate = picked;
        }
      });
    }
  }

  Future<void> _pickDocuments() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() {
          _selectedFiles.addAll(result.files);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('❌ Error picking files: $e'),
        ),
      );
    }
  }

  void _removeDocument(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select date';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<List<String>> _uploadFiles() async {
    // This is where you would implement actual file upload logic
    // For now, returning mock URLs - replace with your actual upload implementation
    List<String> uploadedUrls = [];

    for (PlatformFile file in _selectedFiles) {
      // Mock upload - replace with actual upload logic
      // String uploadedUrl = await widget.leaveViewModel.uploadFile(file);
      String uploadedUrl = 'uploaded_${file.name}'; // Mock URL
      uploadedUrls.add(uploadedUrl);
    }

    return uploadedUrls;
  }

  Future<void> _submitLeave(BuildContext context) async {
    if (!_formKey.currentState!.validate() || _fromDate == null) return;

    // For multi-day leaves, toDate is required
    if (widget.formType == LeaveFormType.leave && _toDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('❌ Please select To Date'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Upload files if any are selected
      if (_selectedFiles.isNotEmpty) {
        _uploadedDocuments = await _uploadFiles();
      }

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';

      final request = ApplyLeaveRequestModel(
        userId: userId,
        type: _leaveType,
        fromDate: _fromDate!.toUtc().toIso8601String(),
        toDate: (_toDate ?? _fromDate)!.toUtc().toIso8601String(),
        reason: _reasonController.text.trim(),
        isCompOff: _isCompOff,
        isHalfDay: _isHalfDay,
        documents: _uploadedDocuments,
      );

      final success = await widget.leaveViewModel.submitLeaveRequest(request);

      setState(() => _isLoading = false);

      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('✅ ${widget.title} applied successfully'),
          ),
        );
        _resetForm();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(widget.leaveViewModel.errorMessage ?? '❌ Request failed'),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('❌ Error submitting request: $e'),
        ),
      );
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _reasonController.clear();
    setState(() {
      _fromDate = null;
      _toDate = null;
      _selectedFiles.clear();
      _uploadedDocuments.clear();
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 24),

            // From Date
            _DatePickerTile(
              label: widget.formType == LeaveFormType.halfDay ||
                  widget.formType == LeaveFormType.workFromHome
                  ? 'Date'
                  : 'From Date',
              value: _formatDate(_fromDate),
              onTap: () => _selectDate(context, true),
              isRequired: true,
            ),

            const SizedBox(height: 16),

            // To Date (only for multi-day leaves)
            if (widget.formType == LeaveFormType.leave) ...[
              _DatePickerTile(
                label: 'To Date',
                value: _formatDate(_toDate),
                onTap: () => _selectDate(context, false),
                isRequired: true,
              ),
              const SizedBox(height: 16),
            ],

            // Reason Field
            Text(
              'Reason',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _reasonController,
              maxLines: 4,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: _getReasonHint(),
                hintStyle: const TextStyle(color: AppTheme.textHint),
                filled: true,
                fillColor: AppTheme.backgroundSecondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                ),
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
            const SizedBox(height: 24),

            // Document Upload Section
            Text(
              'Supporting Documents (Optional)',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // Upload Button
            GestureDetector(
              onTap: _pickDocuments,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundSecondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.borderLight,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 32,
                      color: AppTheme.primaryBlue,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to upload documents',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'PDF, DOC, DOCX, JPG, PNG (Max 5MB each)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textHint,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Selected Files List
            if (_selectedFiles.isNotEmpty) ...[
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
                      'Selected Files (${_selectedFiles.length})',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(_selectedFiles.length, (index) {
                      final file = _selectedFiles[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              _getFileIcon(file.extension ?? ''),
                              color: AppTheme.primaryBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    file.name,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    _formatFileSize(file.size),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textHint,
                                    ),
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

            const SizedBox(height: 24),

            // Info Card
            _buildInfoCard(),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _submitLeave(context),
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
                  'Submit ${widget.title}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

  String _getReasonHint() {
    switch (widget.formType) {
      case LeaveFormType.leave:
        return 'Please provide a detailed reason for your leave...';
      case LeaveFormType.halfDay:
        return 'Reason for half day leave...';
      case LeaveFormType.compOff:
        return 'Mention the date you worked extra for compensation...';
      case LeaveFormType.workFromHome:
        return 'Reason for work from home request...';
    }
  }

  Widget _buildInfoCard() {
    String infoText;
    IconData infoIcon;
    Color infoColor;

    switch (widget.formType) {
      case LeaveFormType.leave:
        infoText = 'Leave requests require manager approval and will be deducted from your leave balance.';
        infoIcon = Icons.info_outline;
        infoColor = AppTheme.primaryBlue;
        break;
      case LeaveFormType.halfDay:
        infoText = 'Half day leaves are counted as 0.5 days from your leave balance.';
        infoIcon = Icons.schedule;
        infoColor = Colors.orange;
        break;
      case LeaveFormType.compOff:
        infoText = 'Compensatory off requests must be used within 30 days of earning.';
        infoIcon = Icons.swap_horiz;
        infoColor = Colors.green;
        break;
      case LeaveFormType.workFromHome:
        infoText = 'Work from home requests are subject to team and project requirements.';
        infoIcon = Icons.home_work;
        infoColor = Colors.purple;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: infoColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: infoColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(infoIcon, color: infoColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              infoText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: infoColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool isRequired;

  const _DatePickerTile({
    required this.label,
    required this.value,
    required this.onTap,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: value == 'Select date'
                        ? AppTheme.textHint
                        : AppTheme.textPrimary,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}