import 'package:flutter/material.dart';

class MyAppDateSelectionCalendar extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final bool enableRangeSelection;
  final Function(DateTime startDate, DateTime? endDate)? onDateSelected;

  // Existing highlight list (used for Applied Leaves - Green)
  final List<DateTime> highlightDates;

  // NEW: List specifically for Holidays (Red/Pink)
  final List<DateTime> holidayDates;

  const MyAppDateSelectionCalendar({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    this.enableRangeSelection = true,
    this.onDateSelected,
    this.highlightDates = const [],
    this.holidayDates = const [],
  });

  @override
  State<MyAppDateSelectionCalendar> createState() =>
      _MyAppDateSelectionCalendarState();
}

class _MyAppDateSelectionCalendarState
    extends State<MyAppDateSelectionCalendar> {
  late DateTime _currentMonth;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  // Define the minimum allowed date
  late DateTime _minSelectableDate;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.initialStartDate ?? DateTime.now();
    _selectedStartDate = widget.initialStartDate;
    _selectedEndDate = widget.initialEndDate;

    // Logic: Set minimum date to the 1st day of the PREVIOUS month.
    final now = DateTime.now();
    _minSelectableDate = DateTime(now.year, now.month - 1, 1);
  }

  bool _isHighlighted(DateTime date) {
    return widget.highlightDates.any((d) => _isSameDay(d, date));
  }

  bool _isHoliday(DateTime date) {
    return widget.holidayDates.any((d) => _isSameDay(d, date));
  }

  // Helper: Check if date is before the allowed limit (Previous Month 1st)
  bool _isRestricted(DateTime date) {
    final dateToCheck = DateTime(date.year, date.month, date.day);
    return dateToCheck.isBefore(_minSelectableDate);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _showMonthYearPicker() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: _MonthYearPickerDialog(
            initialDate: _currentMonth,
            onDateSelected: (selectedDate) {
              setState(() {
                _currentMonth = selectedDate;
              });
            },
          ),
        );
      },
    );
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  void _onDateTap(DateTime date) {
    // 1. UPDATE: Removed weekend check. Only check for Restricted dates.
    if (_isRestricted(date)) return;

    setState(() {
      if (!widget.enableRangeSelection) {
        _selectedStartDate = date;
        _selectedEndDate = null;
      } else {
        if (_selectedStartDate == null) {
          _selectedStartDate = date;
          _selectedEndDate = null;
        } else if (_selectedEndDate == null) {
          if (date.isBefore(_selectedStartDate!)) {
            _selectedStartDate = date;
            _selectedEndDate = null;
          } else if (_isSameDay(date, _selectedStartDate!)) {
            _selectedEndDate = null;
          } else {
            _selectedEndDate = date;
          }
        } else {
          _selectedStartDate = date;
          _selectedEndDate = null;
        }
      }
    });
    widget.onDateSelected?.call(_selectedStartDate!, _selectedEndDate);
  }

  bool _isDateInRange(DateTime date) {
    if (_selectedStartDate == null) return false;
    if (_selectedEndDate == null) return false;
    return date.isAfter(
          _selectedStartDate!.subtract(const Duration(days: 1)),
        ) &&
        date.isBefore(_selectedEndDate!.add(const Duration(days: 1)));
  }

  bool _isDateSelected(DateTime date) {
    if (_selectedStartDate != null && _isSameDay(date, _selectedStartDate!)) {
      return true;
    }
    if (_selectedEndDate != null && _isSameDay(date, _selectedEndDate!)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 3,
            spreadRadius: 0,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            _previousMonth();
          } else if (details.primaryVelocity! < 0) {
            _nextMonth();
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // UPDATED HEADER ROW
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Dates',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                // LEGEND WIDGET
                Row(
                  children: [
                    _buildLegendItem(
                      color: const Color(0xFFB4E7C1), // Green
                      label: 'My Leaves',
                    ),
                    const SizedBox(width: 12),
                    _buildLegendItem(
                      color: const Color(0xFFFFCDD2), // Pink/Red
                      label: 'Holidays',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _previousMonth,
                ),
                InkWell(
                  onTap: _showMonthYearPicker,
                  child: Text(
                    _getMonthYearString(_currentMonth),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextMonth,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((
                day,
              ) {
                return SizedBox(
                  width: 40,
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            ..._buildCalendarGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCalendarGrid() {
    final daysInMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    ).day;
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final startingWeekday = firstDayOfMonth.weekday - 1;

    List<Widget> rows = [];
    List<Widget> dayWidgets = [];

    for (int i = 0; i < startingWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 40, height: 40));
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);

      final isSelected = _isDateSelected(date);
      final isInRange = _isDateInRange(date);

      // 2. UPDATE: Removed isWeekend check from disabled logic
      final bool isRestricted = _isRestricted(date);
      final bool isDisabled = isRestricted;

      Color backgroundColor;
      Color textColor = Colors.black87;

      if (isDisabled) {
        // Only old dates are disabled now
        backgroundColor = Colors.transparent;
        textColor = Colors.grey.withOpacity(0.4);
      } else if (isSelected) {
        backgroundColor = const Color(0xFF7BA5B8);
        textColor = Colors.white;
      } else if (isInRange) {
        backgroundColor = const Color(0xFFE0EDF2);
      } else if (_isHoliday(date)) {
        backgroundColor = const Color(0xFFFFCDD2);
      } else if (_isHighlighted(date)) {
        backgroundColor = const Color(0xFFB4E7C1);
      } else {
        backgroundColor = Colors.transparent;
      }

      dayWidgets.add(
        GestureDetector(
          onTap: isDisabled ? null : () => _onDateTap(date),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      );

      if (dayWidgets.length == 7) {
        rows.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.from(dayWidgets),
            ),
          ),
        );
        dayWidgets.clear();
      }
    }

    if (dayWidgets.isNotEmpty) {
      while (dayWidgets.length < 7) {
        dayWidgets.add(const SizedBox(width: 40, height: 40));
      }
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.from(dayWidgets),
          ),
        ),
      );
    }

    return rows;
  }

  String _getMonthYearString(DateTime date) {
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
    return '${months[date.month - 1]} ${date.year}';
  }
}

// Keep _MonthYearPickerDialog class as it is
class _MonthYearPickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;

  const _MonthYearPickerDialog({
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<_MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<_MonthYearPickerDialog> {
  late int _selectedYear;
  late int _selectedMonth;
  bool _showingMonths = true;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    if (_showingMonths) {
                      _selectedYear--;
                    } else {
                      _selectedYear -= 12;
                    }
                  });
                },
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _showingMonths = !_showingMonths;
                  });
                },
                child: Text(
                  _showingMonths
                      ? '$_selectedYear'
                      : '${_selectedYear - 11} - $_selectedYear',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    if (_showingMonths) {
                      _selectedYear++;
                    } else {
                      _selectedYear += 12;
                    }
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _showingMonths ? _buildMonthGrid() : _buildYearGrid(),
        ],
      ),
    );
  }

  Widget _buildMonthGrid() {
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

    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final isSelected = (index + 1) == _selectedMonth;
        return InkWell(
          onTap: () {
            widget.onDateSelected(DateTime(_selectedYear, index + 1));
            Navigator.of(context).pop();
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF7BA5B8) : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                months[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildYearGrid() {
    final startYear = _selectedYear - 11;
    final years = List.generate(12, (index) => startYear + index);

    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final year = years[index];
        final isSelected = year == widget.initialDate.year;
        return InkWell(
          onTap: () {
            setState(() {
              _selectedYear = year;
              _showingMonths = true;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF7BA5B8) : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$year',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
