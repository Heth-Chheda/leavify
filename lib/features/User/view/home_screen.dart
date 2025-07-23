import 'package:flutter/material.dart';
import 'package:leavify/core/utils/components/shimmer_widget.dart';
import 'package:leavify/features/User/components/announcement_card.dart';
import 'package:leavify/features/User/components/calender_widget.dart';
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
      "title": "📣 Company Holiday",
      "message": "We will be closed on 15th Aug for Independence Day.",
    },
    {
      "title": "📢 Leave Policy Updated",
      "message": "New leave carry-forward rules apply from this month.",
    },
    {
      "title": "🚨 Server Maintenance",
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
            onPressed: _viewModel.refresh,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementSection() {
    final bool hasAnnouncements = _dummyAnnouncements.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Announcements",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (hasAnnouncements) ...[
          SizedBox(
            height: 140,
            child: PageView.builder(
              controller: _pageController,
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
          const SizedBox(height: 8),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_dummyAnnouncements.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 8 : 4,
                  height: _currentPage == index ? 8 : 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Colors.blue
                        : Colors.grey.shade400,
                  ),
                );
              }),
            ),
          ),
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

  Widget _buildCalendarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CalendarWidget(
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

  Widget _buildUpcomingEventsSection() {
    // Get actual leave events from ViewModel
    final upcomingLeaves = _selectedDate != null
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
        Text(
          _selectedDate != null
              ? "Leaves for ${_formatDate(_selectedDate!)}"
              : "Upcoming Leaves",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (upcomingLeaves.isEmpty)
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
            itemCount: upcomingLeaves.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final leave = upcomingLeaves[index];
              return _buildLeaveCard(leave);
            },
          ),
      ],
    );
  }

  Widget _buildLeaveCard(dynamic leave) {
    Color getStatusColor(String status) {
      switch (status.toLowerCase()) {
        case 'approved':
          return Colors.green;
        case 'pending':
          return Colors.orange;
        case 'rejected':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    IconData getStatusIcon(String status) {
      switch (status.toLowerCase()) {
        case 'approved':
          return Icons.check_circle;
        case 'pending':
          return Icons.schedule;
        case 'rejected':
          return Icons.cancel;
        default:
          return Icons.info;
      }
    }

    final color = getStatusColor(leave.status);
    final isMyLeave = leave.userId == _viewModel.homeData?.currentUser?.id;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(getStatusIcon(leave.status), color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        leave.employeeName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isMyLeave)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'You',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "${leave.reason} • ${leave.formattedDateRange}",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        leave.status,
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${leave.leaveDuration} day${leave.leaveDuration > 1 ? 's' : ''}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  void _handleDateSelection(DateTime date) {
    // Add your logic here for when a date is selected
    // For example: navigate to detailed view, show events, etc.
    print("Selected date: ${_formatDate(date)}");
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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
