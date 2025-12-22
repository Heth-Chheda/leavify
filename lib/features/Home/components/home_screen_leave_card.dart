import 'package:flutter/material.dart';
import 'package:leavify/core/utils/formatters/date/date_formatter.dart';
import 'package:leavify/features/Authentication/domain/models/leave.dart';

class LeaveCard extends StatelessWidget {
  final LeaveDetailsWithoutLeaveId leave;
  final VoidCallback? onTap;

  // Profile image info
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    /* ================= PRIORITY LOGIC ================= */

    // Comp-Off has highest priority
    final bool isCompOff = leave.requestType.toLowerCase() == 'extra';

    // Half-day applies only if NOT comp-off
    final bool isHalfDay = leave.isHalfDay;

    Color? leftBorderColor;
    if (isCompOff) {
      leftBorderColor = Colors.purple;
    } else if (isHalfDay) {
      leftBorderColor = Colors.amber.shade700;
    }

    /* ================= PROFILE IMAGE ================= */

    final String? fullImageUrl =
        (profileImagePath != null && profileImagePath!.isNotEmpty)
        ? '$baseUrl/$profileImagePath'
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(24),

        // LEFT BORDER ONLY (Accent)
        border: leftBorderColor != null
            ? Border(left: BorderSide(color: leftBorderColor, width: 4))
            : null,

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
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                /* ========== PROFILE IMAGE / INITIAL ========== */
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: fullImageUrl != null
                      ? Image.network(
                          fullImageUrl,
                          width: 75,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 75,
                          height: 60,
                          color: Colors.grey[400],
                          alignment: Alignment.center,
                          child: Text(
                            leave.employeeName.isNotEmpty
                                ? leave.employeeName[0].toUpperCase()
                                : 'A',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),

                const SizedBox(width: 16),

                /* ================= CONTENT ================= */
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
                        DateFormatter.formatDateRange(
                          leave.startDate,
                          leave.endDate,
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white60 : Colors.grey[600],
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
}
