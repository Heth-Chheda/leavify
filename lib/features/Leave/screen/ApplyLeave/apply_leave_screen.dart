import 'package:flutter/material.dart';
import 'package:leavify/core/utils/components/button/my_app_button.dart';
import 'package:leavify/core/utils/components/calendar/my_app_date_selection_calendar.dart';
import 'package:leavify/core/utils/components/confirmation/confirmation_dialog.dart';
import 'package:leavify/core/utils/components/dropdownmenu/my_app_drop_down_menu.dart';
import 'package:leavify/core/utils/components/textfield/my_app_text_field.dart';
import 'package:leavify/core/utils/constants/enums/enums.dart';
import 'package:leavify/core/utils/helpers/documents/ui/document_ui.dart';
import 'package:leavify/core/utils/theme/app_colors.dart';
import 'package:leavify/features/Home/viewmodel/home_view_model.dart';
import 'package:leavify/features/Leave/components/ApplyLeave/reportee_picker.dart';
import 'package:leavify/features/Leave/viewModel/leave_view_model.dart';
import 'package:provider/provider.dart';

class ApplyLeaveScreen extends StatefulWidget {
  const ApplyLeaveScreen({super.key});

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen>
    with TickerProviderStateMixin {
  // CHANGED: Use TickerProviderStateMixin instead of SingleTickerProviderStateMixin
  // to allow re-creating the controller if needed (though typically not needed here).

  late TabController _tabController;
  final FocusNode reasonFocusNode = FocusNode();

  // Track current role state to init controller correctly
  bool _isEmployee = true;

  final List<String> leaveTypes = [
    'Casual',
    'Sick',
    'Emergency',
    'Annual Leave',
  ];

  @override
  void initState() {
    super.initState();

    // We need to initialize the controller, but we might not have the role yet.
    // However, usually ViewModel data is loaded. We'll default to 1 and update
    // in didChangeDependencies if needed, or rely on the fact that role
    // should be available from HomeViewModel.

    // Safety fallback: Init with 1, will re-init in didChangeDependencies
    _tabController = TabController(length: 1, vsync: this);

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
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 1. Check Role Here
    final homeViewModel = context.read<HomeViewModel>();
    final isEmployee = homeViewModel.userRole.toLowerCase() == 'employee';

    // 2. Re-initialize Controller if the role/tab count changed
    if (_isEmployee != isEmployee ||
        _tabController.length != (isEmployee ? 1 : 2)) {
      _isEmployee = isEmployee;
      _tabController.dispose();
      _tabController = TabController(length: isEmployee ? 1 : 2, vsync: this);
      _tabController.addListener(_handleTabSelection);
    }
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    reasonFocusNode.dispose();
    super.dispose();
  }

  // MARK: - CHECK DATA PRESENCE
  bool _hasFormData(LeaveViewModel leaveViewModel) {
    return leaveViewModel.selectedStartDate != null ||
        leaveViewModel.reasonController.text.trim().isNotEmpty ||
        leaveViewModel.selectedDocuments.isNotEmpty ||
        leaveViewModel.hasCompOffPlans ||
        leaveViewModel.selectedCompOffDates.isNotEmpty;
  }

  // MARK: - CONFIRMATION DIALOG
  Future<bool> _showConfirmationDialog() async {
    FocusScope.of(context).unfocus();
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return ConfirmationDialog(
              title: 'Discard Changes?',
              body:
                  'You have unsaved changes. If you go back now, all your progress will be lost.',
              illustrationAsset: 'lib/assets/gifs/trash2.gif',
              illustrationHeight: 180,
              confirmButtonText: 'Discard',
              onConfirm: () => Navigator.of(context).pop(true),
              buttonBackgroundColor: Colors.red,
            );
          },
        ) ??
        false;
  }

  Future<bool> _onWillPop() async {
    final leaveViewModel = Provider.of<LeaveViewModel>(context, listen: false);
    FocusScope.of(context).unfocus();
    if (_hasFormData(leaveViewModel)) {
      return await _showConfirmationDialog();
    }
    return true;
  }

  // MARK: - MAIN BUILD
  @override
  Widget build(BuildContext context) {
    final homeViewModel = context.watch<HomeViewModel>();
    final bool isEmployee = homeViewModel.userRole.toLowerCase() == 'employee';

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) Navigator.of(context).pop();
      },
      child: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Column(
              children: [
                // 1. Stats and Header (Fixed at top)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: _buildStatsCards(homeViewModel),
                ),

                // 2. Animated Tabs (Only show if NOT Employee, or show simplified title if Employee)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: isEmployee
                      ? _buildEmployeeTitle() // Just a title for employees
                      : _buildCustomTabBar(), // Tabs for Managers/HR
                ),

                // 3. Tab Views (Scrollable Content)
                Expanded(
                  child: Consumer<LeaveViewModel>(
                    builder: (context, leaveViewModel, child) {
                      return TabBarView(
                        controller: _tabController,
                        physics: isEmployee
                            ? const NeverScrollableScrollPhysics()
                            : null, // Disable swipe if only 1 tab
                        children: [
                          // Tab 1: Apply Leave (Always present)
                          _buildScrollableForm(
                            context,
                            leaveViewModel,
                            homeViewModel,
                            isCompOff: false,
                          ),

                          // Tab 2: Comp Off (Only present if NOT Employee)
                          if (!isEmployee)
                            _buildScrollableForm(
                              context,
                              leaveViewModel,
                              homeViewModel,
                              isCompOff: true,
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // MARK: - EMPLOYEE TITLE (When tabs are hidden)
  Widget _buildEmployeeTitle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text(
          "Apply Leave",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  // MARK: - CUSTOM TAB BAR
  Widget _buildCustomTabBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: const LinearGradient(
            colors: [AppColors.highlightBlue, AppColors.highlightPink],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.highlightBlue.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        tabs: const [
          Tab(text: "Apply Leave"),
          Tab(text: "Comp Off"),
        ],
      ),
    );
  }

  // MARK: - SCROLLABLE FORM CONTENT
  Widget _buildScrollableForm(
    BuildContext context,
    LeaveViewModel leaveViewModel,
    HomeViewModel homeViewModel, {
    required bool isCompOff,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateSelectionSection(leaveViewModel, homeViewModel),
          const SizedBox(height: 24),

          // Show Half Day checkbox only for Normal Leaves (Tab 1)
          // You can decide if Comp Off also supports Half Day logic here
          _buildHalfDayCheckbox(leaveViewModel),
          const SizedBox(height: 24),

          // Only show basic leave types if NOT Comp Off
          if (!isCompOff) ...[
            _buildLeaveTypeSection(leaveViewModel),
            const SizedBox(height: 24),
          ],

          _buildReasonSection(leaveViewModel),
          const SizedBox(height: 24),

          DocumentUploadSection(
            leaveViewModel: leaveViewModel,
            parentContext: context,
          ),
          const SizedBox(height: 24),

          // Manager options
          // NOTE: homeViewModel.userRole check is redundant here if we assume this logic
          // only applies to the 'Apply Leave' tab, but kept for safety.
          if (homeViewModel.userRole.toLowerCase() != 'employee') ...[
            _buildRequestedForToggle(leaveViewModel, isDark),

            // Only show category dropdown if user selected AND not comp off
            if (!isCompOff)
              _buildLeaveTypeDropdownSection(leaveViewModel, homeViewModel),
          ],

          const SizedBox(height: 32),
          _buildSubmitButton(leaveViewModel, isCompOff),
          const SizedBox(height: 20), // Bottom padding
        ],
      ),
    );
  }

  // MARK: - WIDGETS COMPONENTS (Keeping existing implementations)

  Widget _buildStatsCards(HomeViewModel homeViewModel) {
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
      padding: const EdgeInsets.all(20),
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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black.withOpacity(0.6),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildLeaveTypeSection(LeaveViewModel leaveViewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Application Type"),
        const SizedBox(height: 12),
        MyAppDropDownMenu<String>(
          value: leaveViewModel.selectedLeaveType,
          hint: 'Select Application Type',
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
            if (value != null) leaveViewModel.updateSelectedLeaveType(value);
          },
        ),
      ],
    );
  }

  Widget _buildDateSelectionSection(
    LeaveViewModel leaveViewModel,
    HomeViewModel homeViewModel,
  ) {
    final List<DateTime> leaveDates = homeViewModel.upcomingLeaveDates;
    final List<DateTime> holidayDates =
        homeViewModel.holidayListResponse?.holidayList?.holidayDates
            .map((holidayDate) => DateTime.tryParse(holidayDate.date ?? ''))
            .whereType<DateTime>()
            .toList() ??
        [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyAppDateSelectionCalendar(
          highlightDates: leaveDates,
          holidayDates: holidayDates,
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

  Widget _buildHalfDayCheckbox(LeaveViewModel leaveViewModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: CheckboxListTile(
          value: leaveViewModel.isLeaveHalfDay,
          onChanged: (bool? value) {
            leaveViewModel.setHalfDay(value);
          },
          title: const Text(
            "Half Day",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          subtitle: Text(
            "Apply for only half of the working day",
            style: TextStyle(
              fontSize: 12,
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          activeColor: AppColors.highlightBlue,
          checkColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          controlAffinity: ListTileControlAffinity.trailing,
        ),
      ),
    );
  }

  Widget _buildRequestedForToggle(LeaveViewModel leaveViewModel, bool isDark) {
    final selectedUser = leaveViewModel.selectedUser;
    final label = selectedUser != null
        ? 'Requested for ${selectedUser.fName} ${selectedUser.lName}'
        : 'Request For';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('On behalf'),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: MyAppButton(
            label: label,
            onPressed: () => _showUserPicker(leaveViewModel),
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

  void _showUserPicker(LeaveViewModel leaveViewModel) {
    ModernUserPicker.show(
      context: context,
      users: leaveViewModel.teamUsers,
      title: 'Select Employee',
      onUserSelected: (user) {
        leaveViewModel.selectedUser = user;
        if (mounted) setState(() {});
      },
    );
  }

  Widget _buildLeaveTypeDropdownSection(
    LeaveViewModel leaveViewModel,
    HomeViewModel homeViewModel,
  ) {
    if (leaveViewModel.selectedUser == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _buildSectionTitle('Application Type (Manager)'),
        const SizedBox(height: 12),
        MyAppDropDownMenu<String>(
          value: leaveViewModel.selectedLeaveCategory,
          hint: 'Select Application Type',
          borderColor: Colors.transparent,
          dropdownColor: Colors.white,
          textColor: Colors.black87,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          borderRadius: 12,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 2,
              offset: const Offset(0, 0),
            ),
          ],
          items: homeViewModel.leaveCategories.map((category) {
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

  Widget _buildReasonSection(LeaveViewModel leaveViewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Reason'),
        const SizedBox(height: 12),
        MyAppTextField(
          controller: leaveViewModel.reasonController,
          focusNode: reasonFocusNode,
          hintText: 'Tell us why...',
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

  Widget _buildSubmitButton(LeaveViewModel leaveViewModel, bool isCompOff) {
    return SizedBox(
      width: double.infinity,
      child: MyAppButton(
        label: isCompOff ? 'Apply Comp Off' : 'Apply Leave',
        onPressed: () {
          reasonFocusNode.unfocus();
          // Submit the form
          leaveViewModel.submitLeaveForm(
            context,
            reasonFocusNode,
            isCompOff: isCompOff,
          );
        },
        isLoading: leaveViewModel.isLoading,
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(vertical: 16),
        gradient: const LinearGradient(
          colors: [AppColors.highlightBlue, AppColors.highlightPink],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        icon: Text(
          isCompOff ? '🎯' : '🚀',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
