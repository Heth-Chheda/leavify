// leave_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:leavify/features/User/domain/models/leave_application_model.dart';

class LeaveDetailScreen extends StatelessWidget {
  final LeaveApplication leave;
  final bool canEdit;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;

  const LeaveDetailScreen({
    super.key,
    required this.leave,
    this.canEdit = false,
    this.onEdit,
    this.onCancel,
  });

  Color _getStatusColor() {
    switch (leave.status) {
      case LeaveStatus.pending:
        return Colors.orange;
      case LeaveStatus.approved:
        return Colors.green;
      case LeaveStatus.rejected:
        return Colors.red;
      case LeaveStatus.escalated:
        return Colors.purple;
    }
  }

  IconData _getStatusIcon() {
    switch (leave.status) {
      case LeaveStatus.pending:
        return Icons.schedule;
      case LeaveStatus.approved:
        return Icons.check_circle;
      case LeaveStatus.rejected:
        return Icons.cancel;
      case LeaveStatus.escalated:
        return Icons.arrow_upward;
    }
  }

  String _getStatusText() {
    switch (leave.status) {
      case LeaveStatus.pending:
        return "Pending Review";
      case LeaveStatus.approved:
        return "Approved";
      case LeaveStatus.rejected:
        return "Rejected";
      case LeaveStatus.escalated:
        return "Escalated";
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  String _formatDateTime(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  int _getDuration() {
    return leave.endDate.difference(leave.startDate).inDays + 1;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Leave Details',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header Card
            Container(
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStatusIcon(),
                      size: 32,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getStatusText(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    leave.leaveType,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Leave Information Card
            _buildInfoCard(
              title: 'Leave Information',
              children: [
                _buildInfoRow(
                  icon: Icons.confirmation_number_outlined,
                  label: 'Application ID',
                  value: leave.id,
                ),
                _buildInfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Duration',
                  value: '${_getDuration()} day${_getDuration() > 1 ? 's' : ''}',
                ),
                _buildInfoRow(
                  icon: Icons.date_range_outlined,
                  label: 'Start Date',
                  value: _formatDate(leave.startDate),
                ),
                _buildInfoRow(
                  icon: Icons.date_range_outlined,
                  label: 'End Date',
                  value: _formatDate(leave.endDate),
                ),
                _buildInfoRow(
                  icon: Icons.access_time_outlined,
                  label: 'Applied On',
                  value: _formatDateTime(leave.appliedDate),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Employee Information Card (if available)
            if (leave.employeeName != null || leave.employeeId != null || leave.department != null)
              _buildInfoCard(
                title: 'Employee Information',
                children: [
                  if (leave.employeeName != null)
                    _buildInfoRow(
                      icon: Icons.person_outline,
                      label: 'Employee Name',
                      value: leave.employeeName!,
                    ),
                  if (leave.employeeId != null)
                    _buildInfoRow(
                      icon: Icons.badge_outlined,
                      label: 'Employee ID',
                      value: leave.employeeId!,
                    ),
                  if (leave.department != null)
                    _buildInfoRow(
                      icon: Icons.business_outlined,
                      label: 'Department',
                      value: leave.department!,
                    ),
                ],
              ),

            if (leave.employeeName != null || leave.employeeId != null || leave.department != null)
              const SizedBox(height: 16),

            // Reason Card
            _buildInfoCard(
              title: 'Reason for Leave',
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    leave.reason,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Attachments Card (if available)
            if (leave.attachments != null && leave.attachments!.isNotEmpty)
              _buildInfoCard(
                title: 'Attachments',
                children: [
                  ...leave.attachments!.map((attachment) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.attach_file,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            attachment,
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.download_outlined),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Downloading $attachment')),
                            );
                          },
                        ),
                      ],
                    ),
                  )).toList(),
                ],
              ),

            if (leave.attachments != null && leave.attachments!.isNotEmpty)
              const SizedBox(height: 16),

            // Review Information Card (if available)
            if (leave.approverName != null || leave.comments != null || leave.reviewedDate != null)
              _buildInfoCard(
                title: 'Review Information',
                children: [
                  if (leave.approverName != null)
                    _buildInfoRow(
                      icon: Icons.person_outline,
                      label: 'Reviewed By',
                      value: leave.approverName!,
                    ),
                  if (leave.reviewedDate != null)
                    _buildInfoRow(
                      icon: Icons.schedule_outlined,
                      label: 'Reviewed On',
                      value: _formatDateTime(leave.reviewedDate!),
                    ),
                  if (leave.comments != null) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Comments:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: statusColor.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        leave.comments!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

            const SizedBox(height: 24),

            // Action Buttons (if applicable)
            if (canEdit && leave.status == LeaveStatus.pending)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCancel,
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Cancel Leave'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit Leave'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
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
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}