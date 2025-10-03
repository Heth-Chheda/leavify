import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leavify/core/utils/theme/app_colors.dart';
import 'package:leavify/features/Home/viewmodel/home_view_model.dart';
import 'package:leavify/features/Leave/models/response/reportee_response.dart';
import 'package:leavify/features/Leave/viewModel/leave_view_model.dart';
import 'package:provider/provider.dart';

class ApplyLeaveScreen extends StatefulWidget {
  const ApplyLeaveScreen({super.key});

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();

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
    _animationController.dispose();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [Colors.grey.shade900, Colors.grey.shade800]
                        : [Colors.white, Colors.grey.shade50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.2)
                        : Colors.grey.shade300,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black54
                          : Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Warning Icon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.highlightOrange.withOpacity(0.2),
                            AppColors.highlightOrange.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        size: 48,
                        color: AppColors.highlightOrange,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      'Discard Changes?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description
                    Text(
                      'You have unsaved changes in your leave application. If you go back now, all your progress will be lost.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark
                            ? Colors.white.withOpacity(0.8)
                            : Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Action Buttons
                    Row(
                      children: [
                        // Cancel Button (Stay)
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? Colors.black.withOpacity(0.4)
                                      : Colors.grey.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [
                                        Colors.white.withOpacity(0.15),
                                        Colors.white.withOpacity(0.1),
                                      ]
                                    : [
                                        Colors.grey.shade100,
                                        Colors.grey.shade200,
                                      ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Stay',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Discard Button
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.red, Colors.redAccent],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Discard',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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

  // MARK: - SNACK BAR HELPER
  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

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
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SafeArea(
                child: Consumer<LeaveViewModel>(
                  builder: (context, leaveViewModel, child) {
                    return Stack(
                      children: [
                        // Main scrollable content
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(
                            20,
                          ).copyWith(bottom: 100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStatsCards(isDark),
                              const SizedBox(height: 30),
                              _buildDateSelectionSection(
                                leaveViewModel,
                                isDark,
                              ),
                              const SizedBox(height: 24),
                              _buildLeaveTypeSection(isDark, leaveViewModel),
                              const SizedBox(height: 24),
                              _buildReasonSection(leaveViewModel, isDark),
                              const SizedBox(height: 24),
                              _buildDocumentsSection(leaveViewModel, isDark),
                              const SizedBox(height: 24),
                              if (homeViewModel.userRole.toLowerCase() !=
                                  'employee') ...[
                                _buildRequestedForToggle(
                                  leaveViewModel,
                                  isDark,
                                ),
                                const SizedBox(height: 100),
                              ],
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: _buildSubmitButton(leaveViewModel, isDark),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(bool isDark) {
    final homeViewModel = context.watch<HomeViewModel>();

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _buildStatCard(
                'Balance',
                '${homeViewModel.leaveBalance}',
                AppColors.highlightGreen,
                Icons.calendar_today,
                FaIcon(
                  FontAwesomeIcons.solidCalendarCheck,
                  color: AppColors.highlightGreen,
                  size: 22,
                ),
                isDark,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Working Days',
            '${homeViewModel.workingDays}',
            AppColors.highlightOrange,
            Icons.work_outline,
            FaIcon(
              FontAwesomeIcons.briefcase,
              color: AppColors.highlightOrange,
              size: 22,
            ),
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color accentColor,
    IconData icon,
    Widget favIcon,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : accentColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: favIcon,
          ),
          const SizedBox(height: 10),
          Container(
            margin: EdgeInsets.only(top: 7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$title : ',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? Colors.white70
                        : Colors.black.withOpacity(0.6),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.white
                        : Colors.black.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveTypeSection(bool isDark, LeaveViewModel leaveViewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          "Leave Type",
          isDark,
          icon: Icons.event_note,
          iconColor: Colors.teal,
        ),
        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(
              197,
              253,
              253,
              253,
            ), // background of the box
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15), // shadow color
                blurRadius: 4, // soften the shadow
                offset: const Offset(0, 4), // move shadow down
              ),
            ],
          ),
          child: DropdownButtonFormField2<String>(
            isExpanded: true,
            decoration: const InputDecoration(
              border: InputBorder.none, // remove default border
              contentPadding: EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 12,
              ),
            ),
            hint: const Text(
              'Select Leave Type',
              style: TextStyle(fontSize: 14),
            ),
            items: leaveTypes
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item, style: const TextStyle(fontSize: 14)),
                  ),
                )
                .toList(),
            validator: (value) {
              if (value == null) {
                return 'Please select leave type.';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                leaveViewModel.selectedLeaveType = value;
              });
            },
            onSaved: (value) {
              leaveViewModel.selectedLeaveType = value;
            },
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.only(right: 8),
            ),
            iconStyleData: const IconStyleData(
              icon: Icon(Icons.arrow_drop_down, color: Colors.black45),
              iconSize: 24,
            ),
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              padding: EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(
    String title,
    bool isDark, {
    IconData? icon,
    Color? iconColor,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: iconColor ?? AppColors.highlightBlue, size: 20),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelectionSection(
    LeaveViewModel leaveViewModel,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => leaveViewModel.selectDateRange(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.15),
                      ]
                    : [Colors.grey.shade50, Colors.grey.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black26
                      : Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.date_range,
                    color: AppColors.highlightPink,
                    size: 24,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        leaveViewModel.formatDateRange(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: leaveViewModel.selectedStartDate == null
                              ? (isDark ? Colors.white54 : Colors.grey[600])
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                      if (leaveViewModel.isSelectingEndDate)
                        Text(
                          'Tap to select end date',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.highlightBlue,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showUserPicker(
    BuildContext context,
    List<Reportee> users,
    LeaveViewModel leaveViewModel,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return ListView.separated(
          shrinkWrap: true,
          itemCount: users.length,
          separatorBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(height: 1, color: Colors.grey),
          ),
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              title: Text('${user.fName} ${user.lName}'),
              onTap: () {
                Navigator.pop(context);
                // TODO: HERE WE HAVE SELECT THE NAME OF THE EMPLOYEE WHICH THE MANAGER WANTS TO APPLY THE LEAVE FOR.
                // TODO: TASKS TO BE COMPLETED:
                /*
                1. THE SHOULD REFLECT ON THE BUTTON
                2. ON SELECTING THE NAME, AND WHEN WE APPLY THE FORM
                WE WOULD NEED THE USERID TO BE SENT IN THE REQUEST.
                3. WHAT WE NEED TO DO IS THAT IN THE REQUESTEDBY WE WILL HAVE THE MANAGER'S USER ID AND IN THE USER ID WE WILL HAVE THE USER'S ID FOR WHOM WE NEED TO APPLY LEAVE FOR.
                */
                // do something with selected user
                leaveViewModel.selectedUser = user;
                debugPrint(
                  "Selected: ${leaveViewModel.selectedUser?.fName} ${leaveViewModel.selectedUser?.lName} ${leaveViewModel.selectedUser?.id}",
                );
                // maybe call _navigateNext(user);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRequestedForToggle(LeaveViewModel leaveViewModel, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Leave on behalf',
          isDark,
          iconColor: AppColors.highlightTeal,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              _showUserPicker(
                context,
                leaveViewModel.teamUsers,
                leaveViewModel,
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color.fromARGB(255, 243, 13, 116),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            child: Text(
              leaveViewModel.selectedUser != null
                  ? 'Requested for ${leaveViewModel.selectedUser!.fName} ${leaveViewModel.selectedUser!.lName}'
                  : 'Request For',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // MARK: - REASON SECTION
  Widget _buildReasonSection(LeaveViewModel leaveViewModel, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Reason',
          isDark,
          iconColor: AppColors.highlightTeal,
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.15),
                    ]
                  : [Colors.grey.shade50, Colors.grey.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextFormField(
            controller: leaveViewModel.reasonController,
            maxLines: 4,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
            focusNode: FocusNode(),
            decoration: InputDecoration(
              hintText: 'Tell us why you need this leave...',
              hintStyle: TextStyle(
                color: isDark ? Colors.white54 : Colors.grey[600],
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey[50],
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey.shade300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.highlightBlue,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              contentPadding: const EdgeInsets.all(16),
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
                color: errorMessage != null
                    ? Colors.red
                    : (isDark ? Colors.white54 : Colors.grey[600]),
                fontSize: 13,
              ),
            );
          },
        ),
      ],
    );
  }

  // MARK: - DOCUMENT SECTION
  Widget _buildDocumentsSection(LeaveViewModel leaveViewModel, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Documents',
          isDark,
          iconColor: const Color.fromARGB(255, 217, 0, 255),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => leaveViewModel.pickDocuments(_showSnackBar),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.15),
                      ]
                    : [Colors.grey.shade50, Colors.grey.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black26
                      : Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Upload documents',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color.fromARGB(255, 201, 9, 253),
                  ),
                ),
                Text(
                  'PDF, DOC, JPG, PNG up to 10MB',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.grey[600],
                  ),
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
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.shade200,
              ),
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
                        color: isDark ? Colors.white : Colors.black87,
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
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.grey.shade300,
                      ),
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
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                leaveViewModel.formatFileSize(document.size),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.grey[600],
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
  Widget _buildSubmitButton(LeaveViewModel leaveViewModel, bool isDark) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: leaveViewModel.isLoading
              ? LinearGradient(
                  colors: [
                    AppColors.highlightBlue.withOpacity(0.6),
                    AppColors.highlightPink.withOpacity(0.6),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : const LinearGradient(
                  colors: [AppColors.highlightBlue, AppColors.highlightPink],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: leaveViewModel.isLoading
              ? []
              : [
                  BoxShadow(
                    color: AppColors.highlightBlue.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: leaveViewModel.isLoading
              ? null
              : () => leaveViewModel.submitLeaveForm(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: leaveViewModel.isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Submitting...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Apply',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text('🚀', style: TextStyle(fontSize: 16)),
                  ],
                ),
        ),
      ),
    );
  }
}
