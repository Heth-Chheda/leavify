import 'package:flutter/material.dart';
import 'package:leavify/features/Authentication/domain/response/get_all_response.dart';
import 'package:leavify/features/User/viewmodel/leave_view_model.dart';
import 'package:provider/provider.dart';

class PendingRequestDetailScreen extends StatefulWidget {
  final GetAllResponse request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const PendingRequestDetailScreen({
    super.key,
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<PendingRequestDetailScreen> createState() => _PendingRequestDetailScreenState();
}

class _PendingRequestDetailScreenState extends State<PendingRequestDetailScreen> {
  final TextEditingController _commentsController = TextEditingController();

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  int _getDuration() {
    return widget.request.endDate.difference(widget.request.startDate).inDays + 1;
  }

  Future<void> _handleApprove() async {
    final leaveViewModel = context.read<LeaveViewModel>();

    // Note: You'll need to add leaveId to GetAllResponse model
    final success = await leaveViewModel.processLeaveRequest(
      // leaveId: widget.request.leaveId ?? '', // Add this field to GetAllResponse
      status: 'approved',
      context: context,
      leaveId: ""
    );

    if (success && mounted) {
      Navigator.pop(context);
      widget.onApprove();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request approved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(leaveViewModel.errorMessage ?? 'Failed to approve request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleReject() async {
    if (_commentsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a reason for rejection'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final leaveViewModel = context.read<LeaveViewModel>();

    // Note: You'll need to add leaveId to GetAllResponse model
    final success = await leaveViewModel.processLeaveRequest(
      // leaveId: widget.request.leaveId ?? '', // Add this field to GetAllResponse
      status: 'rejected',
      context: context,
      leaveId: ""
    );

    if (success && mounted) {
      Navigator.pop(context);
      widget.onReject();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request rejected successfully'),
          backgroundColor: Colors.orange,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(leaveViewModel.errorMessage ?? 'Failed to reject request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Review Request',
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
      body: Consumer<LeaveViewModel>(
        builder: (context, leaveViewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Employee Header Card
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
                      // Employee avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: widget.request.profileImage.isNotEmpty
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: Image.network(
                            widget.request.profileImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildInitials(),
                          ),
                        )
                            : _buildInitials(),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${widget.request.firstName} ${widget.request.lastName}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.request.role,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildStatusChip(),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Leave Request Details Card
                _buildInfoCard(
                  title: 'Leave Request Details',
                  children: [
                    _buildInfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Duration',
                      value: '${_getDuration()} day${_getDuration() > 1 ? 's' : ''}',
                    ),
                    _buildInfoRow(
                      icon: Icons.date_range_outlined,
                      label: 'Start Date',
                      value: _formatDate(widget.request.startDate),
                    ),
                    _buildInfoRow(
                      icon: Icons.date_range_outlined,
                      label: 'End Date',
                      value: _formatDate(widget.request.endDate),
                    ),
                    _buildInfoRow(
                      icon: Icons.info_outline,
                      label: 'Current Status',
                      value: widget.request.status.toUpperCase(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Reason Card
                if (widget.request.reason.isNotEmpty)
                  _buildInfoCard(
                    title: 'Reason for Leave',
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.request.reason,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                if (widget.request.reason.isNotEmpty)
                  const SizedBox(height: 16),

                // Comments Section (only show for pending requests)
                if (widget.request.status.toLowerCase() == 'pending')
                  _buildInfoCard(
                    title: 'Add Comments (Optional)',
                    children: [
                      TextField(
                        controller: _commentsController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Add any comments or feedback for the employee...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Theme.of(context).primaryColor),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Note: Comments are required when rejecting a request',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),

                if (widget.request.status.toLowerCase() == 'pending')
                  const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: widget.request.status.toLowerCase() == 'pending'
          ? Consumer<LeaveViewModel>(
        builder: (context, leaveViewModel, child) {
          return
          SafeArea(
              child:
              Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: leaveViewModel.isLoading ? null : _handleReject,
                    icon: leaveViewModel.isLoading
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.close_rounded),
                    label: Text(leaveViewModel.isLoading ? 'Processing...' : 'Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: leaveViewModel.isLoading ? null : _handleApprove,
                    icon: leaveViewModel.isLoading
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Icon(Icons.check_rounded),
                    label: Text(leaveViewModel.isLoading ? 'Processing...' : 'Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ) )
            ;
        },
      )
          : null,
    );
  }

  Widget _buildInitials() {
    return Center(
      child: Text(
        '${widget.request.firstName.isNotEmpty ? widget.request.firstName[0] : ''}${widget.request.lastName.isNotEmpty ? widget.request.lastName[0] : ''}',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 28,
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    final status = widget.request.status.toLowerCase();
    Color chipColor;
    Color textColor;

    switch (status) {
      case 'pending':
        chipColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        break;
      case 'approved':
        chipColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        break;
      case 'rejected':
        chipColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        break;
      case 'escalated':
        chipColor = Colors.purple.withOpacity(0.1);
        textColor = Colors.purple;
        break;
      default:
        chipColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        widget.request.status.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
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
      padding: const EdgeInsets.only(bottom: 16),
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
                const SizedBox(height: 4),
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

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }
}