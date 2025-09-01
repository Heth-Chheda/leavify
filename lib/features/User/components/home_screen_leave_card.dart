import 'package:flutter/material.dart';
import 'package:leavify/features/Authentication/domain/models/leave.dart';

class LeaveCard extends StatelessWidget {
  final Leave leave;
  final VoidCallback? onTap;

  // Add these to get profile image info
  final String baseUrl;
  final String? profileImagePath;

  const LeaveCard({
    super.key,
    required this.leave,
    this.onTap,
    required this.baseUrl,
    this.profileImagePath,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final String? fullImageUrl =
        (profileImagePath != null && profileImagePath!.isNotEmpty)
        ? '$baseUrl/$profileImagePath'
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Profile Picture or Initials
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[300],
                  foregroundImage: fullImageUrl != null
                      ? NetworkImage(fullImageUrl)
                      : null,
                  child: fullImageUrl == null
                      ? Text(
                          leave.employeeName.isNotEmpty
                              ? leave.employeeName[0].toUpperCase()
                              : 'A',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),

                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Employee Name
                      Text(
                        leave.employeeName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Date Range
                      Text(
                        "${_formatDateShort(leave.startDate)} to ${_formatDateShort(leave.endDate)}",
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white60 : Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateShort(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        '',
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
      return '${date.day} ${months[date.month]}';
    } catch (e) {
      return dateString;
    }
  }
}
