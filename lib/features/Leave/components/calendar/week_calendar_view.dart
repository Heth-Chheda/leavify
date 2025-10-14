import 'package:flutter/material.dart';
import 'package:leavify/features/Authentication/domain/response/get_holiday_list_response.dart';
import 'package:leavify/models/leave_info.dart';
import 'package:leavify/features/Authentication/domain/models/leave.dart';

class WeekCalendarView extends StatefulWidget {
  final DateTime currentDate;
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final PageController pageController;
  final int initialPage;
  final Function(DateTime) onWeekChanged;
  final List<Leave> userLeaves;
  final Map<String, Color> userColorMap;
  final Map<String, HolidayDate> holidayMap;
  final Map<String, List<HolidayDate>> groupedHolidays;

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
    required this.holidayMap,
    required this.groupedHolidays,
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
                    color: isDark ? Colors.white : Colors.black,
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
        final isSelected = _isSameDay(
          date,
          widget.selectedDate ?? DateTime.now(),
        );
        final leaveInfo = _getLeaveInfoForDate(date);
        final holiday = _getHolidayForDate(date);
        final hasGroupedHoliday = _hasGroupedHoliday(holiday);

        return Expanded(
          child: GestureDetector(
            onTap: () => widget.onDateSelected(date),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Holiday background
                  if (holiday != null)
                    Positioned.fill(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFED4E).withOpacity(0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
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
                                  : (isDark ? Colors.white : Colors.black),
                              letterSpacing: -0.5,
                            ),
                          ),
                          if (hasGroupedHoliday)
                            Container(
                              width: 20,
                              height: 2,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Leave indicators
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

  HolidayDate? _getHolidayForDate(DateTime date) {
    final dateStr = _formatDateForLookup(date);
    return widget.holidayMap[dateStr];
  }

  bool _hasGroupedHoliday(HolidayDate? holiday) {
    return holiday != null &&
        holiday.groupCode != null &&
        holiday.groupCode!.isNotEmpty;
  }

  String _formatDateForLookup(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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

          double leftOffset = totalDots > 1
              ? (index * 6.0).clamp(0.0, 16.0)
              : 8.0;

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
