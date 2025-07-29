import 'package:flutter/material.dart';
import 'package:leavify/core/utils/helpers/calendar/leave_info.dart';
import 'package:leavify/features/Authentication/domain/models/leave.dart';

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
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildMonthNavigation(),
          const SizedBox(height: 24),
          _buildWeekDaysHeader(),
          const SizedBox(height: 20),
          _buildMonthGrid(),
        ],
      ),
    );
  }

  Widget _buildMonthNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildNavButton(Icons.chevron_left_rounded, () => _navigateMonth(-1)),
        _buildNavButton(Icons.chevron_right_rounded, () => _navigateMonth(1)),
      ],
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1F2937).withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF6B7280)),
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                    letterSpacing: -0.2,
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
                      alignment: Alignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          width: 40,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blueAccent
                                : isToday
                                ? const Color(0xFFF3F4F6)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: isToday && !isSelected
                                ? Border.all(
                                    color: const Color(
                                      0xFF667EEA,
                                    ).withOpacity(0.3),
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isToday || isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : isToday
                                    ? const Color(0xFF667EEA)
                                    : isCurrentMonth
                                    ? const Color(0xFF374151)
                                    : const Color(0xFF9CA3AF),
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                        ),
                        // Modern overlapping leave indicators
                        if (leaveInfo.isNotEmpty)
                          Positioned(
                            bottom: 5,
                            child: _buildModernLeaveIndicators(leaveInfo),
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

  Widget _buildModernLeaveIndicators(List<LeaveInfo> leaveInfo) {
    if (leaveInfo.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      width: 24,
      height: 8,
      child: Stack(
        children: leaveInfo.asMap().entries.map((entry) {
          final index = entry.key;
          final info = entry.value;
          final color = userColorMap[info.userId] ?? const Color(0xFF9CA3AF);
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
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          );
        }).toList(),
      ),
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
