import 'package:flutter/material.dart';

class MyAppDateSelectionCalendar extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final bool enableRangeSelection;
  final Function(DateTime startDate, DateTime? endDate)? onDateSelected;
  final List<DateTime> highlightDates;

  const MyAppDateSelectionCalendar({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    this.enableRangeSelection = true,
    this.onDateSelected,
    this.highlightDates = const [],
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
  bool _isSelectingEndDate = false;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.initialStartDate ?? DateTime.now();
    _selectedStartDate = widget.initialStartDate;
    _selectedEndDate = widget.initialEndDate;
  }

  bool _isHighlighted(DateTime date) {
    return widget.highlightDates.any((d) =>
    d.year == date.year &&
        d.month == date.month &&
        d.day == date.day);
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
    setState(() {
      if (!widget.enableRangeSelection) {
        // Single date selection - just set start date
        _selectedStartDate = date;
        _selectedEndDate = null;
      } else {
        // Range selection
        if (_selectedStartDate == null) {
          // First tap - select start date
          _selectedStartDate = date;
          _selectedEndDate = null;
        } else if (_selectedEndDate == null) {
          // Second tap - determine if it's end date or new start date
          if (date.isBefore(_selectedStartDate!)) {
            // Date is before current start, so it becomes the new start date
            _selectedStartDate = date;
            _selectedEndDate = null;
          } else if (_isSameDay(date, _selectedStartDate!)) {
            // Tapped same date - keep as single date
            _selectedEndDate = null;
          } else {
            // Date is after start, so it becomes end date
            _selectedEndDate = date;
          }
        } else {
          // Both dates already selected - start new selection
          _selectedStartDate = date;
          _selectedEndDate = null;
        }
      }
    });

    // Notify parent
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

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month/Year header with navigation
          Text(
            'Select Dates',
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
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
          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) {
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
          // Calendar grid
          ..._buildCalendarGrid(),
        ],
      ),
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

    // Add empty cells for days before the month starts
    for (int i = 0; i < startingWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 40, height: 40));
    }

    // Add day cells
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final isSelected = _isDateSelected(date);
      final isInRange = _isDateInRange(date);
      Color backgroundColor;

      if (isSelected) {
        backgroundColor = const Color(0xFF7BA5B8);              // selected
      } else if (isInRange) {
        backgroundColor = const Color(0xFFE0EDF2);              // range
      } else if (_isHighlighted(date)) {
        backgroundColor = const Color(0xFFB4E7C1);              // green highlight
      } else {
        backgroundColor = Colors.transparent;
      }

      dayWidgets.add(
        GestureDetector(
          onTap: () => _onDateTap(date),
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
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      );

      // Create a new row after every 7 days
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

    // Add remaining days in the last week if any
    if (dayWidgets.isNotEmpty) {
      // Fill remaining cells with empty space to complete the week
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

// Month and Year Picker Dialog
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
          // Header
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
          // Grid
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
