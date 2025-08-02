import 'package:flutter/material.dart';
import 'package:leavify/core/utils/helpers/calendar/leave_info.dart';
import 'package:leavify/features/Authentication/domain/models/leave.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildWeekDaysHeader(),
          SizedBox(
            height: 70,
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
        ],
      ),
    );
  }

  Widget _buildWeekDaysHeader() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    letterSpacing: -0.2,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : isToday
                          ? (isDark
                                ? Colors.grey.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.1))
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isToday && !isSelected
                          ? Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              width: 2,
                            )
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isToday || isSelected
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : isToday
                              ? theme.colorScheme.primary
                              : Colors.black,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                  // Modern overlapping leave indicators
                  if (leaveInfo.isNotEmpty)
                    Positioned(
                      bottom: 4,
                      child: _buildModernLeaveIndicators(leaveInfo),
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildModernLeaveIndicators(List<LeaveInfo> leaveInfo) {
    if (leaveInfo.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: 24,
      height: 8,
      child: Stack(
        children: leaveInfo.asMap().entries.map((entry) {
          final index = entry.key;
          final info = entry.value;
          final color =
              widget.userColorMap[info.userId] ??
              (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280));
          final totalDots = leaveInfo.length;

          // Calculate position for overlapping effect
          double leftOffset = 0;
          if (totalDots > 1) {
            leftOffset = (index * 6.0).clamp(0.0, 16.0);
          } else {
            leftOffset = 8.0; // Center single dot
          }

          return Positioned(
            left: leftOffset,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.2)
                      : Colors.black.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
            ),
          );
        }).toList(),
      ),
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
