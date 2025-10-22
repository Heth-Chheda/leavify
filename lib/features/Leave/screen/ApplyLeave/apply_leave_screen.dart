import 'package:flutter/material.dart';
import 'package:leavify/core/utils/components/button/my_app_button.dart';
import 'package:leavify/core/utils/components/calendar/my_app_date_selection_calendar.dart';
import 'package:leavify/core/utils/components/confirmation/confirmation_dialog.dart';
import 'package:leavify/core/utils/components/dropdownmenu/my_app_drop_down_menu.dart';
import 'package:leavify/core/utils/components/textfield/my_app_text_field.dart';
import 'package:leavify/core/utils/theme/app_colors.dart';
import 'package:leavify/features/Home/viewmodel/home_view_model.dart';
import 'package:leavify/features/Leave/components/ApplyLeave/reportee_picker.dart';
import 'package:leavify/features/Leave/models/response/reportee_response.dart';
import 'package:leavify/features/Leave/viewModel/leave_view_model.dart';
import 'package:provider/provider.dart';

class ApplyLeaveScreen extends StatefulWidget {
  const ApplyLeaveScreen({super.key});

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  final FocusNode reasonFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Initialize form after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final leaveViewModel = Provider.of<LeaveViewModel>(
        context,
        listen: false,
      );
      final homeViewModel = context.read<HomeViewModel>();
      leaveViewModel.initializeForm(homeViewModel: homeViewModel);
    });
  }

  @override
  void dispose() {
    reasonFocusNode.dispose();
    super.dispose();
  }

  // MARK: - CHECK IF FORM HAS DATA
  bool _hasFormData(LeaveViewModel leaveViewModel) {
    return leaveViewModel.selectedStartDate != null ||
        leaveViewModel.reasonController.text.trim().isNotEmpty ||
        leaveViewModel.selectedDocuments.isNotEmpty ||
        leaveViewModel.hasCompOffPlans ||
        leaveViewModel.selectedCompOffDates.isNotEmpty;
  }

  final List<String> leaveTypes = ['Casual', 'Sick', 'Emergency'];

  // MARK: - SHOW CONFIRMATION DIALOG
  Future<bool> _showConfirmationDialog() async {
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

  // MARK: - HANDLE BACK NAVIGATION
  Future<bool> _onWillPop() async {
    final leaveViewModel = Provider.of<LeaveViewModel>(context, listen: false);

    // If form has data, show confirmation dialog
    if (_hasFormData(leaveViewModel)) {
      return await _showConfirmationDialog();
    }

    // If no data, allow back navigation
    return true;
  }

  // MARK: - BUILD METHOD
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final HomeViewModel homeViewModel = context.watch<HomeViewModel>();

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;

        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Consumer<LeaveViewModel>(
              builder: (context, leaveViewModel, child) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatsCards(),
                      const SizedBox(height: 30),
                      _buildDateSelectionSection(leaveViewModel),
                      const SizedBox(height: 24),
                      _buildLeaveTypeSection(leaveViewModel),
                      const SizedBox(height: 24),
                      _buildReasonSection(leaveViewModel),
                      const SizedBox(height: 24),
                      _buildDocumentsSection(leaveViewModel),
                      const SizedBox(height: 24),
                      if (homeViewModel.userRole.toLowerCase() !=
                          'employee') ...[
                        _buildRequestedForToggle(leaveViewModel, isDark),
                        _buildLeaveTypeDropdownSection(
                          leaveViewModel,
                          homeViewModel,
                        ),
                      ],
                      const SizedBox(height: 24),
                      _buildSubmitButton(leaveViewModel),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    final homeViewModel = context.watch<HomeViewModel>();

    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Balance',
              '${homeViewModel.leaveBalance}',
              Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Working Days',
              '${homeViewModel.workingDays}',
              Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black.withOpacity(0.6),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveTypeSection(LeaveViewModel leaveViewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Leave Type"),
        const SizedBox(height: 12),

        // Use dropdown directly, all styling inside
        MyAppDropDownMenu<String>(
          value: leaveViewModel.selectedLeaveType,
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
              leaveViewModel.updateSelectedLeaveType(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelectionSection(LeaveViewModel leaveViewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Inline Calendar - directly embedded
        MyAppDateSelectionCalendar(
          initialStartDate: leaveViewModel.selectedStartDate,
          initialEndDate: leaveViewModel.selectedEndDate,
          enableRangeSelection: true,
          onDateSelected: (startDate, endDate) {
            leaveViewModel.updateDates(startDate, endDate);
          },
        ),
      ],
    );
  }

  void _showUserPicker(
    BuildContext context,
    List<Reportee> users,
    LeaveViewModel leaveViewModel,
  ) {
    ModernUserPicker.show(
      context: context,
      users: users,
      title: 'Select Employee',
      onUserSelected: (user) {
        // 1. THE SHOULD REFLECT ON THE BUTTON
        // 2. ON SELECTING THE NAME, AND WHEN WE APPLY THE FORM
        // WE WOULD NEED THE USERID TO BE SENT IN THE REQUEST.
        // 3. WHAT WE NEED TO DO IS THAT IN THE REQUESTEDBY WE WILL HAVE
        // THE MANAGER'S USER ID AND IN THE USER ID WE WILL HAVE THE
        // USER'S ID FOR WHOM WE NEED TO APPLY LEAVE FOR.

        leaveViewModel.selectedUser = user;

        // This will trigger a rebuild and update the button text
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  Widget _buildLeaveTypeDropdownSection(
    LeaveViewModel leaveViewModel,
    HomeViewModel homeViewModel,
  ) {
    // Only show if a user is selected
    if (leaveViewModel.selectedUser == null) return const SizedBox.shrink();

    final categories = homeViewModel.leaveCategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Leave Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),

        // Generalized dropdown with full design control
        MyAppDropDownMenu<String>(
          value: leaveViewModel.selectedLeaveCategory,
          hint: 'Select Leave Type',
          borderColor: Colors.transparent, // border color
          dropdownColor: Colors.white, // background color of dropdown menu
          textColor: Colors.black87, // text color for items and hint
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          borderRadius: 12,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 2,
              offset: const Offset(0, 0),
            ),
          ],
          items: categories.map((category) {
            return DropdownMenuItem<String>(
              value: category.name,
              child: Text(category.name),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) leaveViewModel.selectLeaveCategory(value);
          },
        ),
      ],
    );
  }

  // MARK: - REQUESTED FOR TOGGLE
  Widget _buildRequestedForToggle(LeaveViewModel leaveViewModel, bool isDark) {
    final selectedUser = leaveViewModel.selectedUser;
    final label = selectedUser != null
        ? 'Requested for ${selectedUser.fName} ${selectedUser.lName}'
        : 'Request For';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Leave on behalf'),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: MyAppButton(
            label: label,
            onPressed: () => _showUserPicker(
              context,
              leaveViewModel.teamUsers,
              leaveViewModel,
            ),
            backgroundColor: Colors.black.withOpacity(0.08),
            foregroundColor: Colors.black,
            borderRadius: 16,
            padding: const EdgeInsets.symmetric(vertical: 16),
            icon: const Icon(
              Icons.person_add_alt_1_rounded,
              color: Colors.black,
            ),
            type: MyButtonType.outlined,
          ),
        ),
      ],
    );
  }

  // MARK: - REASON SECTION
  Widget _buildReasonSection(LeaveViewModel leaveViewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Reason'),
        const SizedBox(height: 12),

        // MyAppTextField now handles background, radius, and shadow internally
        MyAppTextField(
          controller: leaveViewModel.reasonController,
          hintText: 'Tell us why you need this leave...',
          maxLines: 4,
          borderRadius: 24,
          fillColor: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 5,
              offset: const Offset(0, 0),
            ),
          ],
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

        const SizedBox(height: 8),

        // Dynamic error message below the text field
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: leaveViewModel.reasonController,
          builder: (context, value, child) {
            String? errorMessage;
            if (value.text.trim().isEmpty) {
              errorMessage = null;
            } else if (value.text.trim().length < 10) {
              errorMessage = 'Reason must be at least 10 characters';
            } else {
              errorMessage = '';
            }

            return Text(
              errorMessage ?? "Please enter at least 10 characters...",
              style: TextStyle(
                color: errorMessage != null ? Colors.red : Colors.grey[600],
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
        GestureDetector(
          onTap: () => leaveViewModel.pickDocuments(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload documents',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'PDF, DOC, JPG, PNG up to 10MB',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),

        if (leaveViewModel.selectedDocuments.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.folder,
                      color: AppColors.highlightGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Selected Documents (${leaveViewModel.selectedDocuments.length})',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...List.generate(leaveViewModel.selectedDocuments.length, (
                  index,
                ) {
                  final document = leaveViewModel.selectedDocuments[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.highlightBlue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            leaveViewModel.getFileIcon(
                              document.extension ?? '',
                            ),
                            color: AppColors.highlightBlue,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                document.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                leaveViewModel.formatFileSize(document.size),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => leaveViewModel.removeDocument(index),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 16,
                            ),
                          ),
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
      child: MyAppButton(
        label: 'Apply',
        onPressed: () => leaveViewModel.submitLeaveForm(context),
        isLoading: leaveViewModel.isLoading,
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(vertical: 16),
        gradient: const LinearGradient(
          colors: [AppColors.highlightBlue, AppColors.highlightPink],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        icon: const Text('🚀', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
