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
    final bool isHalfDay = leave.isHalfDay == true;

    Color? leftBorderColor;
    if (isCompOff) {
      leftBorderColor = Colors.purple;
    } else if (isHalfDay) {
      leftBorderColor = Colors.amber.shade700;
    }

    final bool showCompOff = isCompOff;
    final bool showHalfDay = isHalfDay;

    /* ================= PROFILE IMAGE ================= */

    final String? fullImageUrl =
        (profileImagePath != null && profileImagePath!.isNotEmpty)
        ? '$baseUrl/$profileImagePath'
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: leftBorderColor != null
            ? Border(left: BorderSide(color: leftBorderColor, width: 4))
            : null,
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                          errorBuilder: (_, __, ___) => _fallbackAvatar(),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const SizedBox(
                              width: 75,
                              height: 60,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                        )
                      : _fallbackAvatar(),
                ),

                const SizedBox(width: 16),

                /* ================= CONTENT ================= */
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Employee Name
                      Text(
                        leave.employeeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white60 : Colors.grey[600],
                        ),
                      ),

                      // TAG LINE (COMP OFF / HALF DAY)
                      if (showCompOff || showHalfDay) ...[
                        const SizedBox(height: 4),
                        SizedBox(
                          width: double.infinity,
                          child: RichText(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              children: [
                                if (showCompOff)
                                  const TextSpan(
                                    text: 'COMP OFF',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.purple,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                if (showCompOff && showHalfDay)
                                  const TextSpan(
                                    text: ' / ',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                if (showHalfDay)
                                  TextSpan(
                                    text: '(HALF DAY)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.amber.shade700,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  /* ================= FALLBACK AVATAR ================= */

  Widget _fallbackAvatar() {
    return Container(
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
    );
  }
}
