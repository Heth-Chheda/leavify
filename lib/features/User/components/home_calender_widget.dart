// calendar_widget.dart
import 'package:flutter/material.dart';
import 'package:leavify/core/utils/theme/app_colors.dart';
import 'package:leavify/features/Authentication/domain/models/leave.dart';
import 'package:leavify/features/User/components/calendar/week_calendar_view.dart';

class HomeCalendarWidget extends StatefulWidget {
  final Function(DateTime)? onDateSelected;
  final DateTime? selectedDate;
  final bool showToggle;
  final List<Leave> userLeaves;

  const HomeCalendarWidget({
    super.key,
    this.onDateSelected,
    this.selectedDate,
    this.showToggle = true,
    required this.userLeaves,
  });

  @override
  State<HomeCalendarWidget> createState() => _HomeCalendarWidgetState();
}

class _HomeCalendarWidgetState extends State<HomeCalendarWidget> {
  late DateTime _currentDate;
  late DateTime _selectedDate;
  late PageController _weekPageController;
  final int _initialWeekPage =
      52; // Start from middle to allow backward scrolling

  // Modern color palette for different users using your highlight colors
  final List<Color> _userColors = [
    const Color(0xFF4735DD), // highlightBlue
    const Color(0xFFFF3E6C), // highlightPink
    const Color(0xFF61BFC2), // highlightTeal
    const Color(0xFFFFA200), // highlightOrange
    const Color(0xFF51DC8E), // highlightGreen
    const Color(0xFF10B981), // Emerald
    const Color(0xFFEF4444), // Red
    const Color(0xFF06B6D4), // Cyan
    const Color(0xFFF97316), // Orange
  ];

  final Map<String, Color> _userColorMap = {};

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _selectedDate = widget.selectedDate ?? DateTime.now();
    _weekPageController = PageController(initialPage: _initialWeekPage);
    _generateUserColorMap();
  }

  void _generateUserColorMap() {
    final uniqueUsers = widget.userLeaves
        .map((leave) => leave.userId)
        .toSet()
        .toList();
    for (int i = 0; i < uniqueUsers.length; i++) {
      _userColorMap[uniqueUsers[i]] = _userColors[i % _userColors.length];
    }
  }

  @override
  void dispose() {
    _weekPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.highlightOrange,
        borderRadius: BorderRadius.circular(28),
        border: Border(
          left: BorderSide(color: theme.colorScheme.secondary, width: 10.0),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : const Color(0xFF1A1A1A).withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: [_buildHeader(), _buildCalendarContent()]),
    );
  }

  // MARK: BUILD HEADER
  Widget _buildHeader() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      decoration: BoxDecoration(
        color: AppColors.highlightOrange,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getHeaderTitle(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        letterSpacing: -1.0,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.transparent,
                  theme.colorScheme.primary.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0.0, 0.15),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          ),
        );
      },
      child: WeekCalendarView(
        key: const ValueKey('week'),
        currentDate: _currentDate,
        selectedDate: _selectedDate,
        onDateSelected: _onDateSelected,
        pageController: _weekPageController,
        initialPage: _initialWeekPage,
        onWeekChanged: (date) {
          setState(() {
            _currentDate = date;
          });
        },
        userLeaves: widget.userLeaves,
        userColorMap: _userColorMap,
      ),
    );
  }

  String _getHeaderTitle() {
    final weekStart = _getWeekStart(_currentDate);
    final weekEnd = weekStart.add(const Duration(days: 6));

    if (weekStart.month == weekEnd.month) {
      return '${_getMonthName(weekStart.month)} ${weekStart.year}';
    } else {
      return '${_getMonthName(weekStart.month)} - ${_getMonthName(weekEnd.month)} ${weekStart.year}';
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _currentDate = date;
    });
    widget.onDateSelected?.call(date);
  }

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
