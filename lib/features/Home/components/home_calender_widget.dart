// calendar_widget.dart
import 'package:flutter/material.dart';
import 'package:leavify/features/Authentication/domain/models/leave.dart';
import 'package:leavify/features/Authentication/domain/response/get_holiday_list_response.dart';
import 'package:leavify/features/Leave/components/calendar/week_calendar_view.dart';
import 'package:leavify/features/Leave/components/calendar/month_calendar_view.dart';

class HomeCalendarWidget extends StatefulWidget {
  final Function(DateTime?)? onDateSelected;
  final DateTime? selectedDate;
  final bool showToggle;
  final List<LeaveDetailsWithoutLeaveId> userLeaves;
  final GetHolidayListResponse? holidayListResponse;

  const HomeCalendarWidget({
    super.key,
    this.onDateSelected,
    this.selectedDate,
    this.showToggle = true,
    required this.userLeaves,
    this.holidayListResponse,
  });

  @override
  State<HomeCalendarWidget> createState() => _HomeCalendarWidgetState();
}

class _HomeCalendarWidgetState extends State<HomeCalendarWidget> {
  late DateTime _currentDate;
  DateTime? _selectedDate;
  late PageController _weekPageController;
  late PageController _monthPageController;
  final int _initialWeekPage = 52;
  final int _initialMonthPage = 60;
  bool _isWeekView = true;

  // Modern color palette for different users using your highlight colors
  final List<Color> _userColors = [
    const Color(0xFFFF3E6C),
    const Color(0xFF61BFC2),
    const Color(0xFFFFA200),
    const Color(0xFF51DC8E),
    const Color(0xFF10B981),
    const Color(0xFFEF4444),
    const Color(0xFF06B6D4),
    const Color(0xFFF97316),
  ];

  final Map<String, Color> _userColorMap = {};

  late Map<String, HolidayDate> _holidayMap;
  late Map<String, List<HolidayDate>> _groupedHolidays;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _selectedDate = widget.selectedDate ?? DateTime.now();
    _weekPageController = PageController(initialPage: _initialWeekPage);
    _monthPageController = PageController(initialPage: _initialMonthPage);
    _generateUserColorMap();
    _buildHolidayMaps();
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

  void _buildHolidayMaps() {
    _holidayMap = {};
    _groupedHolidays = {};

    final holidays =
        widget.holidayListResponse?.holidayList?.holidayDates ?? [];

    for (final holiday in holidays) {
      if (holiday.date != null && holiday.date!.isNotEmpty) {
        _holidayMap[holiday.date!] = holiday;

        // Group holidays by groupCode
        if (holiday.groupCode != null && holiday.groupCode!.isNotEmpty) {
          if (!_groupedHolidays.containsKey(holiday.groupCode)) {
            _groupedHolidays[holiday.groupCode!] = [];
          }
          _groupedHolidays[holiday.groupCode!]!.add(holiday);
        }
      }
    }
  }

  @override
  void dispose() {
    _weekPageController.dispose();
    _monthPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E1E1E) // Dark greyish card
            : Colors.white, // Pure white card for light theme
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.06),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(children: [_buildHeader(), _buildCalendarContent()]),
      ),
    );
  }

  // MARK: BUILD HEADER
  Widget _buildHeader() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getHeaderTitle(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? Colors.white.withOpacity(0.95)
                        : const Color(0xFF1A1A1A),
                    letterSpacing: -0.8,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          // Icons Row
          Row(
            children: [
              IconButton(
                tooltip: 'Refresh selected date',
                icon: Icon(
                  Icons.refresh_rounded,
                  size: 20,
                  color: isDark
                      ? Colors.white.withOpacity(0.7)
                      : Colors.black.withOpacity(0.6),
                ),
                onPressed: () {
                  setState(() {
                    _selectedDate = null;
                    _currentDate = DateTime.now();
                  });
                  // Optionally notify parent widget of the change:
                  widget.onDateSelected?.call(_selectedDate);
                },
              ),
              IconButton(
                tooltip: _isWeekView
                    ? 'Switch to month view'
                    : 'Switch to week view',
                icon: Icon(
                  Icons.calendar_month_rounded,
                  size: 20,
                  color: isDark
                      ? Colors.white.withOpacity(0.7)
                      : Colors.black.withOpacity(0.6),
                ),
                onPressed: () {
                  setState(() {
                    _isWeekView = !_isWeekView;
                    _currentDate = DateTime.now();
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarContent() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.0, 0.1),
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
        child: _isWeekView
            ? WeekCalendarView(
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
                holidayMap: _holidayMap,
                groupedHolidays: _groupedHolidays,
              )
            : MonthCalendarView(
                key: const ValueKey('month'),
                currentDate: _currentDate,
                selectedDate: _selectedDate,
                onDateSelected: _onDateSelected,
                pageController: _monthPageController,
                initialPage: _initialMonthPage,
                onMonthChanged: (date) {
                  setState(() {
                    _currentDate = date;
                  });
                },
                userLeaves: widget.userLeaves,
                userColorMap: _userColorMap,
                holidayMap: _holidayMap,
                groupedHolidays: _groupedHolidays,
              ),
      ),
    );
  }

  String _getHeaderTitle() {
    if (_isWeekView) {
      final weekStart = _getWeekStart(_currentDate);
      final weekEnd = weekStart.add(const Duration(days: 6));

      if (weekStart.month == weekEnd.month) {
        return '${_getMonthName(weekStart.month)} ${weekStart.year}';
      } else {
        return '${_getMonthName(weekStart.month)} - ${_getMonthName(weekEnd.month)} ${weekStart.year}';
      }
    } else {
      return '${_getMonthName(_currentDate.month)} ${_currentDate.year}';
    }
  }

  void _onDateSelected(DateTime date) {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final holiday = _holidayMap[dateStr];

    if (holiday != null) {
      _showHolidayDialog(holiday);
    }
    setState(() {
      _selectedDate = date;
      _currentDate = date;
    });
    widget.onDateSelected?.call(date);
  }

  void _showHolidayDialog(HolidayDate holiday) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Holiday', style: TextStyle(fontWeight: FontWeight.w700)),
          content: Text(holiday.description ?? 'No description available'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
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
