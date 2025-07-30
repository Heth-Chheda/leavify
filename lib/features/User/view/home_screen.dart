import 'package:flutter/material.dart';
import 'package:leavify/core/utils/components/shimmer_widget.dart';
import 'package:leavify/features/User/components/announcement_card.dart';
import 'package:leavify/features/User/components/home_calender_widget.dart';
import 'package:leavify/features/User/components/home_screen_leave_card.dart';
import 'package:leavify/features/User/viewmodel/home_view_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  DateTime? _selectedDate;
  late HomeViewModel _viewModel;

  final List<Map<String, String>> _dummyAnnouncements = [
    {
      "title": "Company Holiday",
      "message": "We will be closed on 15th Aug for Independence Day.",
    },
    {
      "title": "Leave Policy Updated",
      "message": "New leave carry-forward rules apply from this month.",
    },
    {
      "title": "Server Maintenance",
      "message": "Portal will be offline on Sunday 12–3 AM.",
    },
  ];

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

  @override
  Widget build(BuildContext context) {
    if (_viewModel.isLoading) {
      return const ShimmerHomeScreen();
    }

    if (_viewModel.error != null) {
      return _buildErrorWidget();
    }

    return RefreshIndicator(
      onRefresh: _viewModel.refresh,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAnnouncementSection(),
            const SizedBox(height: 24),
            _buildCalendarSection(),
            const SizedBox(height: 24),
            _buildUpcomingEventsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            _viewModel.error ?? 'Something went wrong',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // MARK: ANNOUNCEMENTS SECTION
  Widget _buildAnnouncementSection() {
    final bool hasAnnouncements = _dummyAnnouncements.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAnnouncementHeaderSection(),
        const SizedBox(height: 12),
        if (hasAnnouncements) ...[
          SizedBox(
            height: 140,
            child: PageView.builder(
              controller: PageController(
                viewportFraction: 0.89,
              ), // This shows peek of next/previous cards
              itemCount: _dummyAnnouncements.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final item = _dummyAnnouncements[index];
                return AnnouncementCard(
                  title: item['title']!,
                  message: item['message']!,
                );
              },
            ),
          ),
          // Removed the dot indicator section completely
        ] else
          Container(
            width: double.infinity,
            height: 140,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                "🎉 You have no announcements.\nHave a great day!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
      ],
    );
  }

  // MARK: ANNOUNCEMENT HEADER
  Widget _buildAnnouncementHeaderSection() {
    return Padding(
      padding: EdgeInsets.only(top: 16, left: 16),
      child: const Text(
        "Announcements",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
            _handleDateSelection(date);
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
        const SizedBox(height: 12),
        if (teamUpcomingLeaves.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Center(
              child: Text(
                _selectedDate != null
                    ? "No leaves scheduled for this date"
                    : "No upcoming leaves",
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
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
              return LeaveCard(leave: leave);
            },
          ),
      ],
    );
  }

  Widget _buildTeamUpcomingLeaveSection() {
    return Container(
      padding: EdgeInsets.only(left: 16),
      child: Text(
        _selectedDate != null
            ? "Leaves for ${_formatDate(_selectedDate!)}"
            : "Upcoming Team Leaves",
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _handleDateSelection(DateTime date) {
    // Add your logic here for when a date is selected
    // For example: navigate to detailed view, show events, etc.
    print("Selected date: ${_formatDate(date)}");
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
