import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 1. Add this import
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:leavify/core/storage/app_storage.dart';
import 'package:leavify/core/utils/constants/api_endpoints.dart';
import 'package:leavify/core/utils/theme/app_colors.dart';
import 'package:leavify/features/Home/components/announcement_card.dart';
import 'package:leavify/features/Home/components/custom_app_bar.dart';
import 'package:leavify/features/Home/components/custom_bottom_nav_bar.dart';
import 'package:leavify/features/Home/components/home_calender_widget.dart';
import 'package:leavify/features/Home/components/home_screen_leave_card.dart';
import 'package:leavify/features/Home/viewmodel/home_view_model.dart';
import 'package:leavify/router/app_navigator.dart';
import 'package:leavify/router/route_names.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPage = 0;
  int _currentIndex = 0;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();

    // 2. FORCE STATUS BAR VISIBILITY
    // This ensures that if a Splash screen hid the bar, it comes back now.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().initialize();
    });
  }

  Future<void> _navigateAndRefresh(
    String routeName,
    HomeViewModel viewModel,
  ) async {
    // 1. Navigate and wait for the user to come back
    await AppNavigator.navigateTo(routeName);

    // 2. Check if the widget is still in the tree
    if (!mounted) return;

    // 3. Refresh the data
    viewModel.refresh();
  }

  // MARK: - BOTTOM TAB SELECTION
  void _onTabSelected(int index, HomeViewModel viewModel) async {
    final role = viewModel.userRole.toLowerCase();
    final bool isManagerOrHR = role != 'employee';

    if (isManagerOrHR) {
      switch (index) {
        case 0:
          setState(() => _currentIndex = index);
          break;
        case 1:
          _navigateAndRefresh(RouteNames.pendingRequests, viewModel);
          break;
        case 2:
          _navigateAndRefresh(RouteNames.applyLeave, viewModel);
          break;
        case 3:
          _navigateAndRefresh(RouteNames.analytics, viewModel);
          break;
        case 4:
          _navigateAndRefresh(RouteNames.profile, viewModel);
          break;
      }
    } else {
      switch (index) {
        case 0:
          setState(() => _currentIndex = index);
          break;
        case 1:
          _navigateAndRefresh(RouteNames.applyLeave, viewModel);
          break;
        case 2:
          _navigateAndRefresh(RouteNames.profile, viewModel);
          break;
      }
    }
  }

  // MARK: - MAIN CONTENT
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final String role = viewModel.userRole.toLowerCase();
    final bool isManagerOrHR = role != 'employee';
    int addButtonIndex = isManagerOrHR ? 2 : 1;

    // 3. STYLE THE STATUS BAR
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        // Transparent background so your gradient shows through
        statusBarColor: Colors.transparent,
        // Icon brightness: White icons for Dark Mode, Black icons for Light Mode
        statusBarIconBrightness: isDarkMode
            ? Brightness.light
            : Brightness.dark,
        // For iOS:
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      child: Container(
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
            // SafeArea ensures content doesn't overlap the status bar,
            // but the gradient behind it (from Container) will still show.
            child: viewModel.isLoading
                ? _buildLoadingWidget()
                : viewModel.error != null
                ? _buildErrorWidget(viewModel)
                : RefreshIndicator(
                    onRefresh: viewModel.refresh,
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
                                const CustomAppBar(),
                                _buildAnnouncementSection(viewModel),
                                const SizedBox(height: 8),

                                // Restored Calendar Section
                                _buildCalendarSection(viewModel),

                                const SizedBox(height: 8),

                                // Restored Team Leaves Section
                                _buildUpcomingEventsSection(viewModel),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),

          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: _currentIndex,
            onTabSelected: (index) => _onTabSelected(index, viewModel),
            role: viewModel.userRole,
            profileImageUrl: viewModel.profileImageUrl,
            // Fix: safely convert nullable num to int
            pendingRequestCount:
                viewModel.homeData?.pendingLeavesFromTeam?.toInt() ?? 0,
          ),

          floatingActionButton: FloatingAddButton(
            onPressed: () => _onTabSelected(addButtonIndex, viewModel),
            isSelected: _currentIndex == addButtonIndex,
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        ),
      ),
    );
  }

  // MARK: - CALENDAR SECTION
  Widget _buildCalendarSection(HomeViewModel viewModel) {
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
          userLeaves: viewModel.teamUpcomingLeaves,
          holidayListResponse: viewModel.holidayListResponse,
        ),
      ],
    );
  }

  // MARK: - UPCOMING LEAVES SECTION
  Widget _buildUpcomingEventsSection(HomeViewModel viewModel) {
    final theme = Theme.of(context);

    // Get actual leave events from ViewModel
    final teamUpcomingLeaves = _selectedDate != null
        ? viewModel.teamUpcomingLeaves
              .where((leave) => _isDateInLeaveRange(leave, _selectedDate!))
              .toList()
        : viewModel.teamUpcomingLeaves.where((leave) {
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
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Center(
              child: Text(
                _selectedDate != null
                    ? "No leaves on this date"
                    : "No upcoming leaves",
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
              return LeaveCard(
                leave: leave,
                baseUrl: ApiEndpoints.baseUrl,
                profileImagePath: leave.profileImageUrl,
              );
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
            : "Upcoming Team Leaves",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: theme.colorScheme.onBackground,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  // MARK: - HELPER FUNCTIONS
  bool _isDateInLeaveRange(dynamic leave, DateTime date) {
    try {
      final startDate = DateTime.parse(leave.startDate);
      final endDate = DateTime.parse(leave.endDate);

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
      return leave.startDate == date.toIso8601String().split('T')[0];
    }
  }

  void _handleDateSelection(DateTime date) {
    // Logic for date selection if needed
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

  // MARK: - LOADING & ERROR WIDGETS
  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpinKitSquareCircle(color: AppColors.highlightBlue, size: 100.0),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(HomeViewModel viewModel) {
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
            viewModel.error ?? 'Something went wrong',
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              AppStorage.clearAllExcept('USER_FCM_TOKEN');
              AppNavigator.setRootView(RouteNames.login);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // MARK: - ANNOUNCEMENTS SECTION
  Widget _buildAnnouncementSection(HomeViewModel viewModel) {
    final theme = Theme.of(context);
    final announcements = viewModel.announcements;
    final bool hasAnnouncements = viewModel.announcements.isNotEmpty;

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
            _buildPageIndicators(viewModel),
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
  Widget _buildPageIndicators(HomeViewModel viewModel) {
    final theme = Theme.of(context);
    final announcements = viewModel.announcements;

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
                      ? Colors.grey.shade800
                      : Colors.grey.shade300)
                : null,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyAnnouncementState(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 161,
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
}
