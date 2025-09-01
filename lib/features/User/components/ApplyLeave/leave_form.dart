import 'package:flutter/material.dart';
import 'package:leavify/core/utils/theme/app_theme.dart';
import 'package:leavify/features/User/viewmodel/leave_view_model.dart';
import 'package:provider/provider.dart';

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
  @override
  void initState() {
    super.initState();
    // Initialize the form with the current form type after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.leaveViewModel.initializeForm(widget.formType);
    });
  }

  // MARK: - SNACKBAR HELPER
  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: backgroundColor, content: Text(message)),
    );
  }

  // MARK: - MAIN BUILD SECTION
  @override
  Widget build(BuildContext context) {
    return Consumer<LeaveViewModel>(
      builder: (context, leaveViewModel, child) {
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
                _buildDateSelectionSection(leaveViewModel),
                const SizedBox(height: 24),

                // Leave Duration Section
                _buildLeaveDurationSection(leaveViewModel),
                const SizedBox(height: 24),

                // Comp Off Section (only for leave form)
                if (widget.formType == LeaveFormType.leave) ...[
                  _buildCompOffSection(leaveViewModel),
                  const SizedBox(height: 24),
                ],

                // Reason Section
                _buildReasonSection(leaveViewModel),
                const SizedBox(height: 24),

                // Documents Section
                _buildDocumentsSection(leaveViewModel),
                const SizedBox(height: 24),

                // Submit Button
                _buildSubmitButton(leaveViewModel),
              ],
            ),
          ),
        );
      },
    );
  }

  // MARK: - TITLE SECTION
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
      ),
    );
  }

  // MARK: - DATE SELECTION SECTION
  Widget _buildDateSelectionSection(LeaveViewModel leaveViewModel) {
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
          onTap: () => leaveViewModel.selectDateRange(context),
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
                        leaveViewModel.formatDateRange(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: leaveViewModel.selectedStartDate == null
                              ? AppTheme.textHint
                              : AppTheme.textPrimary,
                        ),
                      ),
                      if (leaveViewModel.isSelectingEndDate)
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

  // MARK: - LEAVE DURATION SECTION
  Widget _buildLeaveDurationSection(LeaveViewModel leaveViewModel) {
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
                value: leaveViewModel.isLeaveFullDay,
                onChanged: (value) => leaveViewModel.setLeaveFullDay(true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRadioOption(
                title: 'Half Day',
                value: leaveViewModel.isLeaveHalfDay,
                onChanged: (value) => leaveViewModel.setLeaveHalfDay(true),
              ),
            ),
          ],
        ),

        // Half day work location options
        if (leaveViewModel.isLeaveHalfDay &&
                widget.formType != LeaveFormType.workFromHome ||
            widget.formType == LeaveFormType.extra) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildRadioOption(
                  title: 'WFO',
                  value: leaveViewModel.isHalfDayWorkFromOffice,
                  onChanged: (value) =>
                      leaveViewModel.setHalfDayWorkFromOffice(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRadioOption(
                  title: 'WFH',
                  value: leaveViewModel.isHalfDayWorkFromHome,
                  onChanged: (value) =>
                      leaveViewModel.setHalfDayWorkFromHome(true),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // MARK: - COMP OFF SECTION
  Widget _buildCompOffSection(LeaveViewModel leaveViewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Comp off checkbox
        Row(
          children: [
            Checkbox(
              value: leaveViewModel.hasCompOffPlans,
              onChanged: (value) =>
                  leaveViewModel.setCompOffPlans(value ?? false),
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
        if (leaveViewModel.hasCompOffPlans) ...[
          const SizedBox(height: 16),
          // Date selection for comp off
          GestureDetector(
            onTap: () => leaveViewModel.selectCompOffDate(context),
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
          if (leaveViewModel.selectedCompOffDates.isNotEmpty) ...[
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
                    'Selected Comp Off Dates (${leaveViewModel.selectedCompOffDates.length})',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(leaveViewModel.selectedCompOffDates.length, (
                    index,
                  ) {
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
                              leaveViewModel.formatDate(
                                leaveViewModel.selectedCompOffDates[index],
                              ),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                leaveViewModel.removeCompOffDate(index),
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
                  value: leaveViewModel.isCompOffWorkFromOffice,
                  onChanged: (value) =>
                      leaveViewModel.setCompOffWorkFromOffice(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRadioOption(
                  title: 'WFH',
                  value: leaveViewModel.isCompOffWorkFromHome,
                  onChanged: (value) =>
                      leaveViewModel.setCompOffWorkFromHome(true),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // MARK: - RADIO BUTTON
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

  // MARK: - REASON SECTION
  Widget _buildReasonSection(LeaveViewModel leaveViewModel) {
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
            controller: leaveViewModel.reasonController,
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
          valueListenable: leaveViewModel.reasonController,
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

  // MARK: - DOCUMENT SECTION
  Widget _buildDocumentsSection(LeaveViewModel leaveViewModel) {
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
          onTap: () => leaveViewModel.pickDocuments(_showSnackBar),
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
        if (leaveViewModel.selectedDocuments.isNotEmpty) ...[
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
                  'Selected Documents (${leaveViewModel.selectedDocuments.length})',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(leaveViewModel.selectedDocuments.length, (
                  index,
                ) {
                  final document = leaveViewModel.selectedDocuments[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          leaveViewModel.getFileIcon(document.extension ?? ''),
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
                                leaveViewModel.formatFileSize(document.size),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppTheme.textHint),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => leaveViewModel.removeDocument(index),
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

  // MARK: - SUBMIT BUTTON
  Widget _buildSubmitButton(LeaveViewModel leaveViewModel) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: leaveViewModel.isLoading
            ? null
            : () => leaveViewModel.submitLeaveForm(context, _showSnackBar),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppTheme.primaryBlue,
          disabledBackgroundColor: AppTheme.primaryBlue.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: leaveViewModel.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Apply? 🤔',
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
