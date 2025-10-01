import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:leavify/core/utils/constants/api_endpoints.dart';
import 'package:leavify/core/utils/theme/app_colors.dart';
import 'package:leavify/features/Home/components/announcement_card.dart';
import 'package:leavify/features/Home/components/custom_app_bar.dart';
import 'package:leavify/features/Home/components/custom_bottom_nav_bar.dart';
import 'package:leavify/features/Home/components/home_calender_widget.dart';
import 'package:leavify/features/Home/components/home_screen_leave_card.dart';
import 'package:leavify/features/Home/viewmodel/home_view_model.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:leavify/router/app_navigator.dart';
import 'package:leavify/router/route_names.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPage = 0;
  DateTime? _selectedDate;
  late HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
    _viewModel.initialize();
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  // MARK: - BOTTOM TAB SELECTION
  void _onTabSelected(int index) {
    final role = _viewModel.userRole.toLowerCase();
    final bool isManagerOrHR = role != 'employee';

    if (isManagerOrHR) {
      // Manager/HR navigation: Home, Analytics, Add, History, Pending
      switch (index) {
        case 0:
          // Home - stay on current screen
          setState(() {
            _currentIndex = index;
          });
          break;
        case 1:
          // Analytics - navigate to new screen
          // Navigator.pushNamed(context, '/pending');
          AppNavigator.navigateTo(RouteNames.pendingRequests);
          break;
        case 2:
          // Add Leave - navigate to new screen
          // Navigator.pushNamed(context, '/apply-leave');
          AppNavigator.navigateTo(RouteNames.applyLeave);
          break;
        case 3:
          AppNavigator.navigateTo(RouteNames.analytics);
          break;
        case 4:
          // Pending - navigate to new screen
          // Navigator.pushNamed(context, '/profile');
          AppNavigator.navigateTo(RouteNames.profile);
          break;
      }
    } else {
      // Employee navigation: Home, Add, History
      switch (index) {
        case 0:
          // Home - stay on current screen
          setState(() {
            _currentIndex = index;
          });
          break;
        case 1:
          // Add Leave - navigate to new screen
          // Navigator.pushNamed(context, '/apply-leave');
          AppNavigator.navigateTo(RouteNames.applyLeave);
          break;
        case 2:
          // History - navigate to new screen
          // Navigator.pushNamed(context, '/profile');
          AppNavigator.navigateTo(RouteNames.profile);
          break;
      }
    }
  }

  int _currentIndex = 0;

  // MARK: - MAIN CONTENT
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final String role = _viewModel.userRole.toLowerCase();
    final bool isManagerOrHR = role != 'employee';
    int addButtonIndex = isManagerOrHR ? 2 : 1;

    return Container(
      // Theme-aware gradient background for entire screen
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [AppColors.darkBackground, AppColors.darkSurface]
              : [AppColors.lightBackground, AppColors.lightBackground],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,

        body: SafeArea(
          child: _viewModel.isLoading
              ? _buildLoadingWidget()
              : _viewModel.error != null
              ? _buildErrorWidget()
              : RefreshIndicator(
                  onRefresh: _viewModel.refresh,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Container(
                          constraints: BoxConstraints(
                            minHeight:
                                constraints.maxHeight -
                                kBottomNavigationBarHeight -
                                MediaQuery.of(context).padding.bottom,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomAppBar(),
                              _buildAnnouncementSection(),
                              const SizedBox(height: 8),
                              _buildCalendarSection(),
                              const SizedBox(height: 8),
                              _buildUpcomingEventsSection(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),

        // Bottom navigation bar (automatically handles safe area)
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTabSelected: _onTabSelected,
          role: _viewModel.userRole,
        ),

        // Floating action button for the add button
        floatingActionButton: FloatingAddButton(
          onPressed: () => _onTabSelected(addButtonIndex),
          isSelected: _currentIndex == addButtonIndex,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SpinKitCircle(
            color: Colors.blue, // change to your theme color
            size: 60.0,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.onBackground.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            _viewModel.error ?? 'Something went wrong',
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              AppNavigator.setRootView(RouteNames.login);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // MARK: - ANNOUNCEMENTS SECTION
  Widget _buildAnnouncementSection() {
    final theme = Theme.of(context);
    final announcements = _viewModel.announcements;
    final bool hasAnnouncements = _viewModel.announcements.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.brightness == Brightness.dark
                ? AppColors.darkBackground
                : AppColors.lightBackground,
            theme.brightness == Brightness.dark
                ? AppColors.darkBackground.withOpacity(0.95)
                : AppColors.lightBackground.withOpacity(0.95),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnnouncementHeaderSection(),
          const SizedBox(height: 10),
          if (hasAnnouncements) ...[
            CarouselSlider.builder(
              itemCount: announcements.length,
              itemBuilder: (context, index, realIndex) {
                final item = announcements[index];
                return AnnouncementCard(
                  title: item.title,
                  message: item.body,
                  colorIndex: index % 5,
                  timeAgo: item.timeAgo,
                  profileImage: item.profileImage,
                  senderName: item.senderName,
                );
              },
              options: CarouselOptions(
                height: 160,
                viewportFraction: 0.85,
                enableInfiniteScroll: announcements.length > 1,
                autoPlay: announcements.length > 1,
                autoPlayInterval: const Duration(seconds: 4),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: announcements.length > 1,
                enlargeFactor: 0.2,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentPage = index;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildPageIndicators(),
          ] else
            _buildEmptyAnnouncementState(theme),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // MARK: ANNOUNCEMENT HEADER
  Widget _buildAnnouncementHeaderSection() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          // Left decorative line
          Expanded(
            flex: 2,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.highlightBlue.withOpacity(0.6),
                    AppColors.highlightPink.withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),

          // Center title (no box)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Announcements",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onBackground,
                letterSpacing: -0.5,
              ),
            ),
          ),

          // Right decorative line
          Expanded(
            flex: 2,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.highlightBlue.withOpacity(0.6),
                    AppColors.highlightPink.withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - PAGE INDICATORS
  Widget _buildPageIndicators() {
    final theme = Theme.of(context);
    final announcements = _viewModel.announcements;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        announcements.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: _currentPage == index ? 24 : 8,
          decoration: BoxDecoration(
            gradient: _currentPage == index
                ? LinearGradient(
                    colors: [AppColors.highlightBlue, AppColors.highlightPink],
                  )
                : null,
            color: _currentPage != index
                ? (theme.brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.3)
                      : Colors.black.withOpacity(0.3))
                : null,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  // MARK: - EMPTY ANNOUNCEMENTS
  Widget _buildEmptyAnnouncementState(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 160,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.highlightTeal.withOpacity(0.1),
            AppColors.highlightGreen.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 48,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(height: 12),
            Text(
              "🎉 You have no announcements.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Have a great day!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MARK: CALENDAR SECTION
  Widget _buildCalendarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeCalendarWidget(
          selectedDate: _selectedDate,
          onDateSelected: (date) {
            setState(() {
              _selectedDate = date;
            });
            _handleDateSelection(date ?? DateTime.now());
          },
          showToggle: true,
          userLeaves: _viewModel.teamUpcomingLeaves,
        ),
      ],
    );
  }

  bool _isDateInLeaveRange(dynamic leave, DateTime date) {
    try {
      final startDate = DateTime.parse(leave.startDate);
      final endDate = DateTime.parse(leave.endDate);

      // Normalize all dates to remove time
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final normalizedStart = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      );
      final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day);

      return normalizedDate.isAtSameMomentAs(normalizedStart) ||
          normalizedDate.isAtSameMomentAs(normalizedEnd) ||
          (normalizedDate.isAfter(normalizedStart) &&
              normalizedDate.isBefore(normalizedEnd));
    } catch (e) {
      // Fallback if parsing fails
      return leave.startDate == date.toIso8601String().split('T')[0];
    }
  }

  // MARK: UPCOMING LEAVES SECTION
  Widget _buildUpcomingEventsSection() {
    final theme = Theme.of(context);

    // Get actual leave events from ViewModel
    final teamUpcomingLeaves = _selectedDate != null
        ? _viewModel.teamUpcomingLeaves
              .where((leave) => _isDateInLeaveRange(leave, _selectedDate!))
              .toList()
        : _viewModel.teamUpcomingLeaves.where((leave) {
            try {
              return DateTime.parse(
                leave.startDate,
              ).isAfter(DateTime.now().subtract(const Duration(days: 1)));
            } catch (e) {
              return false;
            }
          }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTeamUpcomingLeaveSection(),
        const SizedBox(height: 10),
        if (teamUpcomingLeaves.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Center(
              child: Text(
                _selectedDate != null ? "No leaves" : "No leaves",
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: teamUpcomingLeaves.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final leave = teamUpcomingLeaves[index];
              return LeaveCard(leave: leave, baseUrl: ApiEndpoints.baseUrl);
            },
          ),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildTeamUpcomingLeaveSection() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.only(left: 22),
      child: Text(
        _selectedDate != null
            ? "Leaves for ${_formatDate(_selectedDate!)}"
            : "Upcoming Leaves",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: theme.colorScheme.onBackground,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  void _handleDateSelection(DateTime date) {
    // Add your logic here for when a date is selected
    // For example: navigate to detailed view, show events, etc.
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }
}
