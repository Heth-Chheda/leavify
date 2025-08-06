// Reusable Pending Request Card - Modern Theme Adaptive
import 'package:flutter/material.dart';
import 'package:leavify/features/Authentication/domain/response/get_all_response.dart';

class PendingRequestCard extends StatelessWidget {
  final GetAllResponse request;
  final VoidCallback onTap;

  const PendingRequestCard({
    super.key,
    required this.request,
    required this.onTap,
  });

  Color _getStatusColor() {
    switch (request.status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFA200); // highlightOrange
      case 'approved':
        return const Color(0xFF51DC8E); // highlightGreen
      case 'rejected':
        return const Color(0xFFFF3E6C); // highlightPink
      case 'escalated':
        return const Color(0xFF4735DD); // highlightBlue
      default:
        return const Color(0xFF61BFC2); // highlightTeal
    }
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  int _getDuration() {
    return request.endDate.difference(request.startDate).inDays + 1;
  }

  String _getDaysAgoText() {
    final daysSinceStart = DateTime.now().difference(request.startDate).inDays;
    if (daysSinceStart == 0) return "Today";
    if (daysSinceStart == 1) return "Yesterday";
    if (daysSinceStart > 0) return "$daysSinceStart days ago";

    final daysUntilStart = request.startDate.difference(DateTime.now()).inDays;
    if (daysUntilStart == 1) return "Tomorrow";
    return "In $daysUntilStart days";
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? Colors.black.withOpacity(0.6)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.grey[800]!.withOpacity(0.5)
                : Colors.grey[200]!.withOpacity(0.8),
            width:   1.5 ,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: isDark ? 0 : -2,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: isDark
                ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[900]!.withOpacity(0.3),
                Colors.grey[900]!.withOpacity(0.1),
              ],
            )
                : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey[50]!.withOpacity(0.5),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with employee info and status
                Row(
                  children: [
                    // Employee avatar with subtle glow
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(isDark ? 0.15 : 0.08),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: Theme.of(context).secondaryHeaderColor.withOpacity(isDark ? 0.8 : 0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withOpacity(isDark ? 0.1 : 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: request.profileImage.isNotEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: Image.network(
                          request.profileImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildInitials(context),
                        ),
                      )
                          : _buildInitials(context),
                    ),
                    const SizedBox(width: 14),

                    // Employee details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${request.firstName} ${request.lastName}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            request.role,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status badge with modern styling
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? Colors.white : Colors.black,
                          width: 0.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withOpacity(isDark ? 0.1 : 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        request.status.toUpperCase(),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Duration with subtle icon styling
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey[800]!.withOpacity(0.3)
                            : Colors.grey[100]!.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_getDuration()} day${_getDuration() > 1 ? 's' : ''}',
                      style: TextStyle(
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Date range with subtle styling
                // TODO: CREATED AT DATE WILL COME AND BASED ON THE CREATED AT DATE WE NEED TO SHOW THE TEXT
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey[800]!.withOpacity(0.3)
                            : Colors.grey[100]!.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.date_range_outlined,
                        size: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${_formatDate(request.startDate)} - ${_formatDate(request.endDate)}",
                      style: TextStyle(
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Reason (truncated)
                if (request.reason.isNotEmpty) ...[
                  Text(
                    request.reason.length > 40
                        ? "${request.reason.substring(0, 40)}..."
                        : request.reason,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[200] : Colors.black87,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Bottom row with timing and action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.grey[800]!.withOpacity(0.3)
                                : Colors.grey[100]!.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Icon(
                            Icons.schedule_outlined,
                            size: 12,
                            color:  isDark ? Colors.grey[400] : Colors.grey[500],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getDaysAgoText(),
                          style: TextStyle(
                            color:  isDark ? Colors.grey[400] : Colors.grey[500],
                            fontSize: 12,
                            fontWeight:  FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(isDark ? 0.12 : 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).primaryColor.withOpacity(isDark ? 0.2 : 0.1),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Tap to review",
                            style: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 10,
                            color: Theme.of(context).secondaryHeaderColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInitials(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Text(
        '${request.firstName.isNotEmpty ? request.firstName[0] : ''}${request.lastName.isNotEmpty ? request.lastName[0] : ''}',
        style: TextStyle(
          color: isDark ? Theme.of(context).secondaryHeaderColor : Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}