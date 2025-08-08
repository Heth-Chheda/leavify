import 'package:flutter/material.dart';
import 'package:leavify/core/utils/theme/app_colors.dart';
import 'package:leavify/features/User/viewmodel/home_view_model.dart';
import 'package:leavify/features/User/viewmodel/leave_view_model.dart';
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
  final _formKey = GlobalKey<FormState>();

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
      leaveViewModel.initializeForm(LeaveFormType.leave);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SafeArea(
            child: Consumer<LeaveViewModel>(
              builder: (context, leaveViewModel, child) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats cards
                        _buildStatsCards(isDark),
                        const SizedBox(height: 24),
                        // Leave form
                        _buildLeaveForm(isDark, leaveViewModel),
                      ],
                    ),
                  ),
                );
              },
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
          child: _buildStatCard(
            'Balance',
            '${homeViewModel.leaveBalance}',
            AppColors.highlightGreen,
            Icons.calendar_today,
            isDark,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Working Days',
            '${homeViewModel.workingDays}',
            AppColors.highlightOrange,
            Icons.work_outline,
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
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [accentColor.withOpacity(0.2), accentColor.withOpacity(0.1)]
              : [accentColor.withOpacity(0.1), accentColor.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.grey[600],
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveForm(bool isDark, LeaveViewModel leaveViewModel) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 80), // leave space for button
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateSelectionSection(leaveViewModel, isDark),
                  const SizedBox(height: 24),
                  _buildReasonSection(leaveViewModel, isDark),
                  const SizedBox(height: 24),
                  _buildDocumentsSection(leaveViewModel, isDark),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: _buildSubmitButton(leaveViewModel, isDark),
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
                        Colors.white.withOpacity(0.08),
                        Colors.white.withOpacity(0.04),
                      ]
                    : [Colors.grey.shade50, Colors.grey.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.2)
                    : Colors.grey.shade300,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black26
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
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

  Widget _buildLeaveDurationSection(
    LeaveViewModel leaveViewModel,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildRadioOption(
                title: 'Full Day',
                value: leaveViewModel.isLeaveFullDay,
                onChanged: (value) => leaveViewModel.setLeaveFullDay(true),
                isDark: isDark,
                icon: Icons.wb_sunny,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRadioOption(
                title: 'Half Day',
                value: leaveViewModel.isLeaveHalfDay,
                onChanged: (value) => leaveViewModel.setLeaveHalfDay(true),
                isDark: isDark,
                icon: Icons.schedule,
              ),
            ),
          ],
        ),

        if (leaveViewModel.isLeaveHalfDay) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildRadioOption(
                  title: 'WFO',
                  value: leaveViewModel.isHalfDayWorkFromOffice,
                  onChanged: (value) =>
                      leaveViewModel.setHalfDayWorkFromOffice(true),
                  isDark: isDark,
                  icon: Icons.business,
                  isSmall: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRadioOption(
                  title: 'WFH',
                  value: leaveViewModel.isHalfDayWorkFromHome,
                  onChanged: (value) =>
                      leaveViewModel.setHalfDayWorkFromHome(true),
                  isDark: isDark,
                  icon: Icons.home,
                  isSmall: true,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildCompOffSection(LeaveViewModel leaveViewModel, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Compensation',
          isDark,
          icon: Icons.swap_horiz,
          iconColor: AppColors.highlightOrange,
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      Colors.white.withOpacity(0.05),
                      Colors.white.withOpacity(0.02),
                    ]
                  : [Colors.grey.shade50, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.shade200,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: leaveViewModel.hasCompOffPlans,
                      onChanged: (value) =>
                          leaveViewModel.setCompOffPlans(value ?? false),
                      activeColor: AppColors.highlightOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Any Comp off Plans?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),

              if (leaveViewModel.hasCompOffPlans) ...[
                const SizedBox(height: 16),
                _buildCompOffDetails(leaveViewModel, isDark),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompOffDetails(LeaveViewModel leaveViewModel, bool isDark) {
    return Column(
      children: [
        // Comp off date selection
        GestureDetector(
          onTap: () => leaveViewModel.selectCompOffDate(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.2)
                    : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.event_note, color: AppColors.highlightOrange),
                const SizedBox(width: 12),
                Text(
                  'Select Comp Off Dates',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(Icons.add, color: AppColors.highlightOrange),
              ],
            ),
          ),
        ),

        // Selected comp off dates
        if (leaveViewModel.selectedCompOffDates.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...List.generate(leaveViewModel.selectedCompOffDates.length, (index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.highlightOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.highlightOrange.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.highlightOrange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    leaveViewModel.formatDate(
                      leaveViewModel.selectedCompOffDates[index],
                    ),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => leaveViewModel.removeCompOffDate(index),
                    child: Icon(Icons.close, size: 18, color: Colors.red[400]),
                  ),
                ],
              ),
            );
          }),
        ],

        const SizedBox(height: 16),

        // Comp off work location
        Row(
          children: [
            Expanded(
              child: _buildRadioOption(
                title: 'WFO',
                subtitle: 'Office',
                value: leaveViewModel.isCompOffWorkFromOffice,
                onChanged: (value) =>
                    leaveViewModel.setCompOffWorkFromOffice(true),
                isDark: isDark,
                icon: Icons.business,
                isSmall: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRadioOption(
                title: 'WFH',
                value: leaveViewModel.isCompOffWorkFromHome,
                onChanged: (value) =>
                    leaveViewModel.setCompOffWorkFromHome(true),
                isDark: isDark,
                icon: Icons.home,
                isSmall: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // MARK: - RADIO OPTION
  Widget _buildRadioOption({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required bool isDark,
    IconData? icon,
    bool isSmall = false,
  }) {
    return GestureDetector(
      onTap: () => onChanged(true),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(isSmall ? 12 : 16),
        decoration: BoxDecoration(
          gradient: value
              ? const LinearGradient(
                  colors: [AppColors.highlightBlue, AppColors.highlightPink],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: isDark
                      ? [
                          Colors.white.withOpacity(0.05),
                          Colors.white.withOpacity(0.02),
                        ]
                      : [Colors.grey.shade50, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value
                ? Colors.transparent
                : (isDark
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey.shade300),
            width: 1,
          ),
          boxShadow: value
              ? [
                  BoxShadow(
                    color: AppColors.highlightBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: isDark
                        ? Colors.black26
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          children: [
            if (icon != null && !isSmall) ...[
              Icon(
                icon,
                color: value
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.grey[600]),
                size: 24,
              ),
              const SizedBox(height: 8),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null && isSmall) ...[
                  Icon(
                    icon,
                    color: value
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.grey[600]),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmall ? 14 : 16,
                    fontWeight: value ? FontWeight.w600 : FontWeight.w500,
                    color: value
                        ? Colors.white
                        : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ],
            ),
            if (subtitle != null && !isSmall) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: value
                      ? Colors.white70
                      : (isDark ? Colors.white54 : Colors.grey[600]),
                ),
              ),
            ],
          ],
        ),
      ),
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
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
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
            decoration: InputDecoration(
              hintText: 'Tell us why you need this leave...',
              hintStyle: TextStyle(
                color: isDark ? Colors.white54 : Colors.grey[600],
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
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
                borderSide: const BorderSide(color: Colors.red),
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
          'Supporting Documents',
          isDark,
          iconColor: AppColors.highlightGreen,
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
                        Colors.white.withOpacity(0.05),
                        Colors.white.withOpacity(0.02),
                      ]
                    : [Colors.grey.shade50, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.2)
                    : Colors.grey.shade300,
                style: BorderStyle.solid,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black26
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Tap to upload documents',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.highlightGreen,
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
    return Container(
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
            : () => leaveViewModel.submitLeaveForm(context, _showSnackBar),
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
                  const Icon(Icons.send, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Submit Application',
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
    );
  }
}
