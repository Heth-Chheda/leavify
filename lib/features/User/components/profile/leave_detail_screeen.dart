import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leavify/features/User/components/ApplyLeave/custom_calendar_component.dart';
import 'package:leavify/features/User/domain/models/my_leaves.dart';
import 'package:leavify/features/User/viewmodel/profile_view_model.dart';
import 'package:provider/provider.dart';

// Import your custom calendar component
// import 'package:leavify/widgets/custom_calendar_component.dart';

class LeaveDetailScreen extends StatefulWidget {
  final MyLeaves leave;
  final String userId;

  const LeaveDetailScreen({
    super.key,
    required this.leave,
    required this.userId,
  });

  @override
  State<LeaveDetailScreen> createState() => _LeaveDetailScreenState();
}

class _LeaveDetailScreenState extends State<LeaveDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  late DateTime _fromDate;
  late DateTime _toDate;
  late bool _isHalfDay;
  late bool _isCompOff;
  late List<DateTime> _compDates;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _reasonController.text = widget.leave.reason;
    _fromDate = widget.leave.fromDate;
    _toDate = widget.leave.toDate;
    _isHalfDay = widget.leave.isHalfDay;
    _isCompOff = widget.leave.isCompOff;
    _compDates = List.from(widget.leave.compDates);
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text('Leave Details'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: Colors.grey[200]),
            ),
          ),
          body: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Badge
                        _buildStatusBadge(),
                        const SizedBox(height: 24),

                        // Leave Duration Card - Updated with date selection
                        _buildLeaveCard(viewModel),
                        const SizedBox(height: 20),

                        // Leave Details Form
                        _buildDetailsCard(viewModel),
                        const SizedBox(height: 20),

                        // Additional Options
                        if (viewModel.isEditMode) _buildOptionsCard(viewModel),
                      ],
                    ),
                  ),
                ),

                // Bottom Action Bar
                _buildBottomActionBar(viewModel),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _getStatusColor(widget.leave.status).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _getStatusColor(widget.leave.status).withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getStatusIcon(widget.leave.status),
              color: _getStatusColor(widget.leave.status),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              widget.leave.status.toUpperCase(),
              style: TextStyle(
                color: _getStatusColor(widget.leave.status),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveCard(ProfileViewModel viewModel) {
    final durationInDays = _toDate.difference(_fromDate).inDays + 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // From Date
              Expanded(
                child: GestureDetector(
                  onTap: viewModel.isEditMode ? () => _selectFromDate() : null,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: viewModel.isEditMode
                          ? Theme.of(context).primaryColor.withOpacity(0.05)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: viewModel.isEditMode
                          ? Border.all(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.2),
                            )
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'From Date',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (viewModel.isEditMode) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.edit,
                                size: 12,
                                color: Theme.of(context).primaryColor,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd MMM yyyy').format(_fromDate),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(height: 40, width: 1, color: Colors.grey[300]),
              // To Date
              Expanded(
                child: GestureDetector(
                  onTap: viewModel.isEditMode ? () => _selectToDate() : null,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: viewModel.isEditMode
                          ? Theme.of(context).primaryColor.withOpacity(0.05)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: viewModel.isEditMode
                          ? Border.all(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.2),
                            )
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (viewModel.isEditMode) ...[
                              Icon(
                                Icons.edit,
                                size: 12,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              'To Date',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd MMM yyyy').format(_toDate),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).primaryColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  '$durationInDays ${durationInDays == 1 ? 'Day' : 'Days'}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(ProfileViewModel viewModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Leave Details',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Leave Type
          _buildDetailRow('Leave Type', widget.leave.type, Icons.work_outline),
          const SizedBox(height: 16),

          // Reason
          Text(
            'Reason',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          if (viewModel.isEditMode)
            TextFormField(
              controller: _reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter reason for leave',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a reason';
                }
                return null;
              },
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                widget.leave.reason,
                style: const TextStyle(fontSize: 14),
              ),
            ),

          const SizedBox(height: 16),

          // Created/Updated dates
          _buildDetailRow(
            'Applied On',
            DateFormat('dd MMM yyyy, hh:mm a').format(widget.leave.createdAt),
            Icons.schedule,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            'Last Updated',
            DateFormat('dd MMM yyyy, hh:mm a').format(widget.leave.updatedAt),
            Icons.update,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsCard(ProfileViewModel viewModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Leave Options',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Half Day Option
          SwitchListTile(
            title: const Text('Half Day'),
            subtitle: const Text('Apply for half day leave'),
            value: _isHalfDay,
            onChanged: (value) {
              setState(() {
                _isHalfDay = value;
                if (_isHalfDay) _isCompOff = false; // Can't be both
              });
            },
            contentPadding: EdgeInsets.zero,
          ),

          // Comp Off Option
          SwitchListTile(
            title: const Text('Compensatory Off'),
            subtitle: const Text('Use comp off for this leave'),
            value: _isCompOff,
            onChanged: (value) {
              setState(() {
                _isCompOff = value;
                if (_isCompOff) _isHalfDay = false; // Can't be both
              });
            },
            contentPadding: EdgeInsets.zero,
          ),

          // Comp Dates (if comp off is selected)
          if (_isCompOff) ...[
            const SizedBox(height: 16),
            Text(
              'Comp Off Dates',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ..._compDates.map(
                  (date) => Chip(
                    label: Text(DateFormat('dd MMM').format(date)),
                    onDeleted: () {
                      setState(() {
                        _compDates.remove(date);
                      });
                    },
                  ),
                ),
                ActionChip(
                  label: const Text('+ Add Date'),
                  onPressed: () => _selectCompDate(),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(ProfileViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (viewModel.isEditMode) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: viewModel.isLoading
                      ? null
                      : () {
                          setState(() {
                            _initializeData(); // Reset to original values
                          });
                          viewModel.toggleEditMode();
                        },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: viewModel.isLoading
                      ? null
                      : () => _saveChanges(viewModel),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: viewModel.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Changes'),
                ),
              ),
            ] else ...[
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.leave.status.toUpperCase() == 'PENDING'
                      ? () => viewModel.toggleEditMode()
                      : null,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Leave'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Custom Calendar Integration Methods
  Future<void> _selectFromDate() async {
    await _showCustomCalendar(
      title: 'Select From Date',
      initialDate: _fromDate,
      onDateSelected: (date) {
        setState(() {
          _fromDate = date;
          // Ensure to date is not before from date
          if (_toDate.isBefore(_fromDate)) {
            _toDate = _fromDate;
          }
        });
      },
    );
  }

  Future<void> _selectToDate() async {
    await _showCustomCalendar(
      title: 'Select To Date',
      initialDate: _toDate,
      firstDate: _fromDate, // Can't select date before from date
      onDateSelected: (date) {
        setState(() {
          _toDate = date;
        });
      },
    );
  }

  Future<void> _selectDateRange() async {
    await _showCustomCalendarRange(
      initialStartDate: _fromDate,
      initialEndDate: _toDate,
      onDateRangeSelected: (startDate, endDate) {
        setState(() {
          _fromDate = startDate;
          _toDate = endDate;
        });
      },
    );
  }

  Future<void> _showCustomCalendar({
    required String title,
    required DateTime initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    required Function(DateTime) onDateSelected,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: CustomCalendarComponent(
            initialDate: initialDate,
            firstDate:
                firstDate ?? DateTime.now().subtract(const Duration(days: 365)),
            lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365)),
            enableRangeSelection: false,
            onDateSelected: (selectedDate) {
              onDateSelected(selectedDate);
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  Future<void> _showCustomCalendarRange({
    required DateTime initialStartDate,
    required DateTime initialEndDate,
    required Function(DateTime, DateTime) onDateRangeSelected,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: CustomCalendarComponent(
            initialDate: initialStartDate,
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            enableRangeSelection: true,
            onDateRangeSelected: (startDate, endDate) {
              onDateRangeSelected(startDate, endDate);
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  Future<void> _selectCompDate() async {
    await _showCustomCalendar(
      title: 'Select Comp Off Date',
      initialDate: DateTime.now(),
      lastDate: DateTime.now(), // Can only select past dates for comp off
      onDateSelected: (date) {
        if (!_compDates.contains(date)) {
          setState(() {
            _compDates.add(date);
          });
        }
      },
    );
  }

  Future<void> _saveChanges(ProfileViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await viewModel.updateLeave(
      leaveId: widget.leave.id,
      userId: widget.userId,
      fromDate: _fromDate,
      toDate: _toDate,
      reason: _reasonController.text.trim(),
      isCompOff: _isCompOff,
      isHalfDay: _isHalfDay,
      compDates: _compDates,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Leave updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Return true to indicate update
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Failed to update leave'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'REJECTED':
        return Colors.red;
      case 'CANCELLED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return Icons.check_circle;
      case 'PENDING':
        return Icons.pending;
      case 'REJECTED':
        return Icons.cancel;
      case 'CANCELLED':
        return Icons.block;
      default:
        return Icons.help;
    }
  }
}
