// calendar_widget.dart
import 'package:flutter/material.dart';
import 'package:leavify/features/Authentication/domain/models/leave.dart';

class CalendarWidget extends StatefulWidget {
  final Function(DateTime)? onDateSelected;
  final DateTime? selectedDate;
  final bool showToggle;
  final List<Leave> userLeaves;

  const CalendarWidget({
    super.key,
    this.onDateSelected,
    this.selectedDate,
    this.showToggle = true,
    required this.userLeaves,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  bool _isWeekView = true;
  late DateTime _currentDate;
  late DateTime _selectedDate;
  late PageController _weekPageController;
  int _initialWeekPage = 52; // Start from middle to allow backward scrolling

  // Color palette for different users
  final List<Color> _userColors = [
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
    Colors.lime,
    Colors.deepOrange,
    Colors.brown,
  ];

  Map<String, Color> _userColorMap = {};

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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: [_buildHeader(), _buildCalendarContent()]),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade600, Colors.blue.shade700],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getHeaderTitle(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getSubtitle(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.showToggle) ...[
                const SizedBox(width: 12),
                _buildToggleButton(),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              if (!_isWeekView) {
                setState(() {
                  _isWeekView = true;
                  _currentDate = DateTime.now(); // Reset to current week
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isWeekView ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.view_week,
                    size: 14,
                    color: _isWeekView ? Colors.blue.shade700 : Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Week',
                    style: TextStyle(
                      color: _isWeekView ? Colors.blue.shade700 : Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (_isWeekView) {
                setState(() {
                  _isWeekView = false;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: !_isWeekView ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_month,
                    size: 14,
                    color: !_isWeekView ? Colors.blue.shade700 : Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Month',
                    style: TextStyle(
                      color: !_isWeekView ? Colors.blue.shade700 : Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarContent() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      child: _isWeekView
          ? WeekCalendarView(
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
            )
          : MonthCalendarView(
              currentDate: _currentDate,
              selectedDate: _selectedDate,
              onDateSelected: _onDateSelected,
              onMonthChanged: (date) {
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
    if (_isWeekView) {
      final weekStart = _getWeekStart(_currentDate);
      final weekEnd = weekStart.add(const Duration(days: 6));

      if (weekStart.month == weekEnd.month) {
        return '${_getMonthName(weekStart.month)} ${weekStart.year}';
      } else {
        return '${_getShortMonthName(weekStart.month)} - ${_getShortMonthName(weekEnd.month)} ${weekStart.year}';
      }
    } else {
      return '${_getMonthName(_currentDate.month)} ${_currentDate.year}';
    }
  }

  String _getSubtitle() {
    if (_isWeekView) {
      final weekStart = _getWeekStart(_currentDate);
      final weekEnd = weekStart.add(const Duration(days: 6));
      return '${weekStart.day} - ${weekEnd.day}';
    } else {
      final daysInMonth = DateTime(
        _currentDate.year,
        _currentDate.month + 1,
        0,
      ).day;
      return '$daysInMonth days';
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

  String _getShortMonthName(int month) {
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
    return months[month - 1];
  }
}

class WeekCalendarView extends StatefulWidget {
  final DateTime currentDate;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final PageController pageController;
  final int initialPage;
  final Function(DateTime) onWeekChanged;
  final List<Leave> userLeaves;
  final Map<String, Color> userColorMap;

  const WeekCalendarView({
    super.key,
    required this.currentDate,
    required this.selectedDate,
    required this.onDateSelected,
    required this.pageController,
    required this.initialPage,
    required this.onWeekChanged,
    required this.userLeaves,
    required this.userColorMap,
  });

  @override
  State<WeekCalendarView> createState() => _WeekCalendarViewState();
}

class _WeekCalendarViewState extends State<WeekCalendarView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildWeekDaysHeader(),
          const SizedBox(height: 16),
          SizedBox(
            height: 60,
            child: PageView.builder(
              controller: widget.pageController,
              onPageChanged: (page) {
                final weeksFromInitial = page - widget.initialPage;
                final newDate = DateTime.now().add(
                  Duration(days: weeksFromInitial * 7),
                );
                widget.onWeekChanged(newDate);
              },
              itemBuilder: (context, page) {
                final weeksFromInitial = page - widget.initialPage;
                final weekStart = _getWeekStart(
                  DateTime.now().add(Duration(days: weeksFromInitial * 7)),
                );
                return _buildWeekDates(weekStart);
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.swipe_left, size: 16, color: Colors.grey.shade400),
              const SizedBox(width: 8),
              Text(
                'Swipe to navigate weeks',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.swipe_right, size: 16, color: Colors.grey.shade400),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDaysHeader() {
    const weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekDays
          .map(
            (day) => Expanded(
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildWeekDates(DateTime weekStart) {
    final today = DateTime.now();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        final date = weekStart.add(Duration(days: index));
        final isToday = _isSameDay(date, today);
        final isSelected = _isSameDay(date, widget.selectedDate);
        final leaveInfo = _getLeaveInfoForDate(date);

        return Expanded(
          child: GestureDetector(
            onTap: () => widget.onDateSelected(date),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.blue.shade500,
                                Colors.blue.shade600,
                              ],
                            )
                          : null,
                      color: isSelected
                          ? null
                          : isToday
                          ? Colors.blue.shade50
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: isToday && !isSelected
                          ? Border.all(color: Colors.blue.shade300, width: 2)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                spreadRadius: 0,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isToday || isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : isToday
                              ? Colors.blue.shade700
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                  // Leave indicators
                  if (leaveInfo.isNotEmpty)
                    Positioned(
                      bottom: 4,
                      left: 0,
                      right: 0,
                      child: _buildLeaveIndicators(leaveInfo, date),
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLeaveIndicators(List<LeaveInfo> leaveInfo, DateTime date) {
    return Column(
      children: leaveInfo.map((info) {
        final color = widget.userColorMap[info.userId] ?? Colors.grey;

        if (info.isSingleDay) {
          // Single day leave - show dot
          return Container(
            margin: const EdgeInsets.only(bottom: 1),
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          );
        } else {
          // Multi-day leave - show underline
          return Container(
            margin: const EdgeInsets.only(bottom: 1),
            height: 2,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(1),
            ),
          );
        }
      }).toList(),
    );
  }

  List<LeaveInfo> _getLeaveInfoForDate(DateTime date) {
    final List<LeaveInfo> leaveInfo = [];

    for (final leave in widget.userLeaves) {
      try {
        final startDate = DateTime.parse(leave.startDate);
        final endDate = DateTime.parse(leave.endDate);

        // Check if date falls within leave period
        if (_isSameDay(date, startDate) ||
            _isSameDay(date, endDate) ||
            (date.isAfter(startDate) && date.isBefore(endDate))) {
          final isSingleDay = _isSameDay(startDate, endDate);
          leaveInfo.add(
            LeaveInfo(
              userId: leave.userId,
              isSingleDay: isSingleDay,
              isStart: _isSameDay(date, startDate),
              isEnd: _isSameDay(date, endDate),
            ),
          );
        }
      } catch (e) {
        // Handle date parsing errors
        continue;
      }
    }

    return leaveInfo;
  }

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class MonthCalendarView extends StatelessWidget {
  final DateTime currentDate;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final Function(DateTime) onMonthChanged;
  final List<Leave> userLeaves;
  final Map<String, Color> userColorMap;

  const MonthCalendarView({
    super.key,
    required this.currentDate,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onMonthChanged,
    required this.userLeaves,
    required this.userColorMap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildMonthNavigation(),
          const SizedBox(height: 20),
          _buildWeekDaysHeader(),
          const SizedBox(height: 16),
          _buildMonthGrid(),
        ],
      ),
    );
  }

  Widget _buildMonthNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildNavButton(Icons.chevron_left, () => _navigateMonth(-1)),
        _buildNavButton(Icons.chevron_right, () => _navigateMonth(1)),
      ],
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Icon(icon, size: 20, color: Colors.grey.shade600),
      ),
    );
  }

  Widget _buildWeekDaysHeader() {
    const weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekDays
          .map(
            (day) => Expanded(
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildMonthGrid() {
    final firstDayOfMonth = DateTime(currentDate.year, currentDate.month, 1);
    final lastDayOfMonth = DateTime(currentDate.year, currentDate.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;
    final today = DateTime.now();

    final daysFromPrevMonth = firstWeekday - 1;
    final prevMonth = DateTime(currentDate.year, currentDate.month - 1, 0);
    final totalCells = ((daysFromPrevMonth + daysInMonth) / 7).ceil() * 7;

    return Column(
      children: List.generate((totalCells / 7).ceil(), (weekIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (dayIndex) {
              final cellIndex = weekIndex * 7 + dayIndex;
              DateTime date;
              bool isCurrentMonth = true;

              if (cellIndex < daysFromPrevMonth) {
                date = DateTime(
                  prevMonth.year,
                  prevMonth.month,
                  prevMonth.day - (daysFromPrevMonth - cellIndex - 1),
                );
                isCurrentMonth = false;
              } else if (cellIndex < daysFromPrevMonth + daysInMonth) {
                date = DateTime(
                  currentDate.year,
                  currentDate.month,
                  cellIndex - daysFromPrevMonth + 1,
                );
              } else {
                date = DateTime(
                  currentDate.year,
                  currentDate.month + 1,
                  cellIndex - daysFromPrevMonth - daysInMonth + 1,
                );
                isCurrentMonth = false;
              }

              final isToday = _isSameDay(date, today);
              final isSelected = _isSameDay(date, selectedDate);
              final leaveInfo = _getLeaveInfoForDate(date);

              return Expanded(
                child: GestureDetector(
                  onTap: () => onDateSelected(date),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    child: Stack(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.blue.shade500,
                                      Colors.blue.shade600,
                                    ],
                                  )
                                : null,
                            color: isSelected
                                ? null
                                : isToday
                                ? Colors.blue.shade50
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: isToday && !isSelected
                                ? Border.all(
                                    color: Colors.blue.shade300,
                                    width: 2,
                                  )
                                : null,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.3),
                                      spreadRadius: 0,
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isToday || isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : isToday
                                    ? Colors.blue.shade700
                                    : isCurrentMonth
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade400,
                              ),
                            ),
                          ),
                        ),
                        // Leave indicators
                        if (leaveInfo.isNotEmpty)
                          Positioned(
                            bottom: 2,
                            left: 0,
                            right: 0,
                            child: _buildLeaveIndicators(leaveInfo, date),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildLeaveIndicators(List<LeaveInfo> leaveInfo, DateTime date) {
    return Column(
      children: leaveInfo.map((info) {
        final color = userColorMap[info.userId] ?? Colors.grey;

        if (info.isSingleDay) {
          // Single day leave - show dot
          return Container(
            margin: const EdgeInsets.only(bottom: 1),
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          );
        } else {
          // Multi-day leave - show underline
          return Container(
            margin: const EdgeInsets.only(bottom: 1),
            height: 2,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(1),
            ),
          );
        }
      }).toList(),
    );
  }

  List<LeaveInfo> _getLeaveInfoForDate(DateTime date) {
    final List<LeaveInfo> leaveInfo = [];

    for (final leave in userLeaves) {
      try {
        final startDate = DateTime.parse(leave.startDate);
        final endDate = DateTime.parse(leave.endDate);

        // Check if date falls within leave period
        if (_isSameDay(date, startDate) ||
            _isSameDay(date, endDate) ||
            (date.isAfter(startDate) && date.isBefore(endDate))) {
          final isSingleDay = _isSameDay(startDate, endDate);
          leaveInfo.add(
            LeaveInfo(
              userId: leave.userId,
              isSingleDay: isSingleDay,
              isStart: _isSameDay(date, startDate),
              isEnd: _isSameDay(date, endDate),
            ),
          );
        }
      } catch (e) {
        // Handle date parsing errors
        continue;
      }
    }

    return leaveInfo;
  }

  void _navigateMonth(int direction) {
    final newDate = DateTime(
      currentDate.year,
      currentDate.month + direction,
      1,
    );
    onMonthChanged(newDate);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

// Helper class to store leave information for a specific date
class LeaveInfo {
  final String userId;
  final bool isSingleDay;
  final bool isStart;
  final bool isEnd;

  LeaveInfo({
    required this.userId,
    required this.isSingleDay,
    required this.isStart,
    required this.isEnd,
  });
}
