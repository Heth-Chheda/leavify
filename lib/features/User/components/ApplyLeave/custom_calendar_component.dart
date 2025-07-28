import 'package:flutter/material.dart';

class CustomCalendarComponent extends StatefulWidget {
  final Function(DateTime)? onDateSelected;
  final Function(DateTime, DateTime)? onDateRangeSelected;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enableRangeSelection;

  const CustomCalendarComponent({
    super.key,
    this.onDateSelected,
    this.onDateRangeSelected,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.enableRangeSelection = false,
  });

  @override
  _CustomCalendarState createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendarComponent> {
  late DateTime selectedDate;
  late DateTime currentMonth;

  // Range selection variables
  DateTime? rangeStartDate;
  DateTime? rangeEndDate;
  bool isSelectingEndDate = false;

  final List<String> months = [
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

  final List<String> weekDays = [
    'SUN',
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedDate = widget.initialDate ?? now;
    // Always start with the current month view
    currentMonth = DateTime(now.year, now.month, 1);
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
        maxWidth: MediaQuery.of(context).size.width * 0.9,
      ),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildCalendarGrid(),
            const SizedBox(height: 16),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    if (widget.enableRangeSelection) {
      return _buildRangeHeader();
    } else {
      return _buildSingleDateHeader();
    }
  }

  Widget _buildSingleDateHeader() {
    return Row(
      children: [
        const Text(
          'Select Date',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFF8A4C),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text(
                selectedDate.day.toString().padLeft(2, '0'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRangeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Select Date Range',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // From Date
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: rangeStartDate != null
                      ? const Color(0xFFFF8A4C).withOpacity(0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: rangeStartDate != null && !isSelectingEndDate
                      ? Border.all(color: const Color(0xFFFF8A4C), width: 2)
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'From',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: const Color(0xFFFF8A4C),
                        ),
                        if (rangeStartDate != null)
                          Text(
                            '${rangeStartDate!.day}/${rangeStartDate!.month}/${rangeStartDate!.year}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFF8A4C),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // To Date
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: rangeEndDate != null
                      ? const Color(0xFFFF8A4C).withOpacity(0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: isSelectingEndDate && rangeStartDate != null
                      ? Border.all(color: const Color(0xFFFF8A4C), width: 2)
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: rangeEndDate != null
                              ? const Color(0xFFFF8A4C)
                              : Colors.grey[400],
                        ),
                        if (rangeEndDate != null)
                          Text(
                            '${rangeEndDate!.day}/${rangeEndDate!.month}/${rangeEndDate!.year}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFF8A4C),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthYearSelector() {
    // Generate year range: current year ± 1
    final now = DateTime.now();
    final currentYear = now.year;
    final yearOptions = [currentYear - 1, currentYear, currentYear + 1];

    return Row(
      children: [
        // Month Dropdown
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: currentMonth.month - 1,
                icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                isExpanded: true,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                items: months.asMap().entries.map((entry) {
                  return DropdownMenuItem<int>(
                    value: entry.key,
                    child: Text(entry.value, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (int? newMonth) {
                  if (newMonth != null) {
                    setState(() {
                      currentMonth = DateTime(
                        currentMonth.year,
                        newMonth + 1,
                        1,
                      );
                    });
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Year Dropdown
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: currentMonth.year,
                icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                isExpanded: true,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                items: yearOptions.map((year) {
                  return DropdownMenuItem<int>(
                    value: year,
                    child: Text(
                      year.toString(),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (int? newYear) {
                  if (newYear != null) {
                    setState(() {
                      currentMonth = DateTime(newYear, currentMonth.month, 1);
                    });
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    return Column(
      children: [
        _buildMonthYearSelector(),
        const SizedBox(height: 16),
        // Week days header
        Row(
          children: weekDays.map((day) {
            return Expanded(
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        // Calendar days
        ...List.generate(6, (weekIndex) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Row(
              children: List.generate(7, (dayIndex) {
                final dayNumber = _getDayNumber(weekIndex, dayIndex);
                final isCurrentMonth = _isCurrentMonth(weekIndex, dayIndex);
                final currentDate = DateTime(
                  currentMonth.year,
                  currentMonth.month,
                  dayNumber,
                );

                final isSelected = widget.enableRangeSelection
                    ? _isDateInRange(currentDate, isCurrentMonth)
                    : _isSameDay(currentDate, selectedDate) && isCurrentMonth;

                final isRangeStart =
                    widget.enableRangeSelection &&
                    rangeStartDate != null &&
                    _isSameDay(currentDate, rangeStartDate!) &&
                    isCurrentMonth;

                final isRangeEnd =
                    widget.enableRangeSelection &&
                    rangeEndDate != null &&
                    _isSameDay(currentDate, rangeEndDate!) &&
                    isCurrentMonth;

                final isInRange =
                    widget.enableRangeSelection &&
                    _isDateBetweenRange(currentDate, isCurrentMonth);

                final isToday = _isToday(dayNumber, isCurrentMonth);
                final isDisabled = _isDateDisabled(currentDate, isCurrentMonth);

                return Expanded(
                  child: GestureDetector(
                    onTap: isCurrentMonth && dayNumber > 0 && !isDisabled
                        ? () => _handleDateTap(currentDate)
                        : null,
                    child: Container(
                      height: 36,
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: _getDateBackgroundColor(
                          isSelected,
                          isRangeStart,
                          isRangeEnd,
                          isInRange,
                          isToday,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: dayNumber > 0
                            ? Text(
                                dayNumber.toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight:
                                      (isSelected ||
                                          isToday ||
                                          isRangeStart ||
                                          isRangeEnd)
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: _getDateTextColor(
                                    isDisabled,
                                    isSelected,
                                    isRangeStart,
                                    isRangeEnd,
                                    isCurrentMonth,
                                    isToday,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildConfirmButton() {
    // Always keep the button active for range selection
    final isValid = widget.enableRangeSelection
        ? (rangeStartDate != null)
        : true;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isValid ? _handleConfirm : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isValid ? const Color(0xFFFF8A4C) : Colors.grey[300],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Confirm',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // Handle date tap for both single and range selection
  void _handleDateTap(DateTime date) {
    if (widget.enableRangeSelection) {
      setState(() {
        if (rangeStartDate == null) {
          // First tap - set both start and end date to the same date
          rangeStartDate = date;
          rangeEndDate = date;
          isSelectingEndDate = true;
        } else {
          // Second tap onwards - update the end date
          if (date.isBefore(rangeStartDate!)) {
            // If selected date is before start date, swap them
            rangeEndDate = rangeStartDate;
            rangeStartDate = date;
          } else {
            rangeEndDate = date;
          }
          isSelectingEndDate = false;
        }
      });
    } else {
      setState(() {
        selectedDate = date;
      });
    }
  }

  void _resetRangeSelection() {
    setState(() {
      rangeStartDate = null;
      rangeEndDate = null;
      isSelectingEndDate = false;
    });
  }

  void _handleConfirm() {
    if (widget.enableRangeSelection) {
      if (rangeStartDate != null && widget.onDateRangeSelected != null) {
        // Use the same date for both start and end if end date is not set
        final endDate = rangeEndDate ?? rangeStartDate!;
        widget.onDateRangeSelected!(rangeStartDate!, endDate);
      }
    } else {
      if (widget.onDateSelected != null) {
        widget.onDateSelected!(selectedDate);
      }
    }
  }

  // Helper methods for range selection styling
  Color _getDateBackgroundColor(
    bool isSelected,
    bool isRangeStart,
    bool isRangeEnd,
    bool isInRange,
    bool isToday,
  ) {
    if (isRangeStart || isRangeEnd || isSelected) {
      return const Color(0xFFFF8A4C);
    } else if (isInRange) {
      return const Color(0xFFFF8A4C).withOpacity(0.3);
    } else if (isToday) {
      return const Color(0xFFFF8A4C).withOpacity(0.2);
    }
    return Colors.transparent;
  }

  Color _getDateTextColor(
    bool isDisabled,
    bool isSelected,
    bool isRangeStart,
    bool isRangeEnd,
    bool isCurrentMonth,
    bool isToday,
  ) {
    if (isDisabled) {
      return Colors.grey[300]!;
    } else if (isSelected || isRangeStart || isRangeEnd) {
      return Colors.white;
    } else if (isCurrentMonth) {
      return isToday ? const Color(0xFFFF8A4C) : Colors.black87;
    }
    return Colors.grey[400]!;
  }

  bool _isDateInRange(DateTime date, bool isCurrentMonth) {
    if (!isCurrentMonth) return false;
    if (rangeStartDate != null && _isSameDay(date, rangeStartDate!))
      return true;
    if (rangeEndDate != null && _isSameDay(date, rangeEndDate!)) return true;
    return false;
  }

  bool _isDateBetweenRange(DateTime date, bool isCurrentMonth) {
    if (!isCurrentMonth || rangeStartDate == null || rangeEndDate == null)
      return false;
    return date.isAfter(rangeStartDate!) && date.isBefore(rangeEndDate!);
  }

  // Existing helper methods remain the same
  int _getDayNumber(int weekIndex, int dayIndex) {
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 1;

    final daysInMonth = DateTime(
      currentMonth.year,
      currentMonth.month + 1,
      0,
    ).day;

    if (dayNumber <= 0) {
      final prevMonth = currentMonth.month == 1 ? 12 : currentMonth.month - 1;
      final prevYear = currentMonth.month == 1
          ? currentMonth.year - 1
          : currentMonth.year;
      final daysInPrevMonth = DateTime(prevYear, prevMonth + 1, 0).day;
      return daysInPrevMonth + dayNumber;
    } else if (dayNumber > daysInMonth) {
      return dayNumber - daysInMonth;
    } else {
      return dayNumber;
    }
  }

  bool _isCurrentMonth(int weekIndex, int dayIndex) {
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 1;
    final daysInMonth = DateTime(
      currentMonth.year,
      currentMonth.month + 1,
      0,
    ).day;

    return dayNumber > 0 && dayNumber <= daysInMonth;
  }

  bool _isToday(int dayNumber, bool isCurrentMonth) {
    final today = DateTime.now();
    return isCurrentMonth &&
        dayNumber == today.day &&
        currentMonth.month == today.month &&
        currentMonth.year == today.year;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isDateDisabled(DateTime date, bool isCurrentMonth) {
    if (!isCurrentMonth) return true;

    if (widget.firstDate != null && date.isBefore(widget.firstDate!)) {
      return true;
    }

    if (widget.lastDate != null && date.isAfter(widget.lastDate!)) {
      return true;
    }

    return false;
  }
}
