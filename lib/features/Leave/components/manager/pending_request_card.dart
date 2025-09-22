// Main Pending Request Card - Optimized with Separate Widget Components
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leavify/core/utils/constants/api_endpoints.dart';
import 'package:leavify/features/Authentication/domain/response/get_all_response.dart';

class PendingRequestCard extends StatelessWidget {
  final GetAllResponse request;
  final VoidCallback onTap;

  const PendingRequestCard({
    super.key,
    required this.request,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: _buildCardDecoration(context, isDark),
        child: Container(
          decoration: _buildGradientDecoration(isDark),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _requestHeader(request: request),
                const SizedBox(height: 18),
                _requestDurationAndDateRange(request: request),
                // const SizedBox(height: 12),
                // _requestFooter(request: request),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // MARK: - BUILD CARD DECORATION
  BoxDecoration _buildCardDecoration(BuildContext context, bool isDark) {
    return BoxDecoration(
      color: isDark ? Colors.black.withOpacity(0.6) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withOpacity(0.3)
              : Colors.black.withOpacity(0.2),
          blurRadius: 12,
          offset: const Offset(0, 2),
          spreadRadius: isDark ? 0 : -2,
        ),
      ],
    );
  }

  BoxDecoration _buildGradientDecoration(bool isDark) {
    return BoxDecoration(
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
              colors: [Colors.white, Colors.grey[50]!.withOpacity(0.5)],
            ),
    );
  }
}

// MARK: - REQUEST_HEADER
Widget _requestHeader({required GetAllResponse request}) {
  return Row(
    children: [
      _employeeAvatar(request: request),
      const SizedBox(width: 14),
      Expanded(child: _employeeInfo(request: request)),
      _statusBadge(status: request.status),
    ],
  );
}

// MARK: - EMPLOYEE_AVATAR
Widget _employeeAvatar({required GetAllResponse request}) {
  return Builder(
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;

      String? getProfileImageUrl() {
        if (request.profileImage.isEmpty) return null;
        final baseUrl = ApiEndpoints.baseUrl;
        return "$baseUrl/${request.profileImage}";
      }

      return Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).primaryColor.withOpacity(isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: Theme.of(
              context,
            ).secondaryHeaderColor.withOpacity(isDark ? 0.8 : 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).primaryColor.withOpacity(isDark ? 0.1 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: getProfileImageUrl() != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Image.network(
                  getProfileImageUrl()!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _employeeInitials(request: request),
                ),
              )
            : _employeeInitials(request: request),
      );
    },
  );
}

// MARK: - EMPLOYEE_INITIALS
Widget _employeeInitials({required GetAllResponse request}) {
  return Builder(
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;

      return Center(
        child: Text(
          '${request.firstName.isNotEmpty ? request.firstName[0] : ''}${request.lastName.isNotEmpty ? request.lastName[0] : ''}',
          style: TextStyle(
            color: isDark
                ? Theme.of(context).secondaryHeaderColor
                : Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      );
    },
  );
}

// MARK: - EMPLOYEE_INFO
Widget _employeeInfo({required GetAllResponse request}) {
  return Builder(
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;

      return Column(
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
            request.designation ?? 'Loading...',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      );
    },
  );
}

// MARK: - STATUS_BADGE
Widget _statusBadge({required String status}) {
  return Builder(
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;

      Color getStatusColor() {
        switch (status.toLowerCase()) {
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

      final statusColor = getStatusColor();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(isDark ? 0.1 : 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          status.toUpperCase(),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
      );
    },
  );
}

// MARK: - REQUEST DURATION AND DATE RANGE
Widget _requestDurationAndDateRange({required GetAllResponse request}) {
  return Builder(
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;

      int getDuration() {
        return request.endDate.difference(request.startDate).inDays + 1;
      }

      String formatDate(DateTime date) {
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
        return "${date.day} ${months[date.month - 1]} ${date.year}";
      }

      bool isSameDay(DateTime d1, DateTime d2) {
        return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
      }

      final duration = getDuration();
      final textColor = isDark ? Colors.grey[300] : Colors.grey[700];

      // Build date string based on whether start & end are the same day
      final dateText = isSameDay(request.startDate, request.endDate)
          ? formatDate(request.startDate)
          : "${formatDate(request.startDate)} - ${formatDate(request.endDate)}";

      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left section: icon, duration, dot, date
          Row(
            children: [
              _iconContainer(
                icon: Icons.calendar_today_outlined,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              Text(
                '$duration day${duration > 1 ? 's' : ''}',
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Text("•", style: TextStyle(color: textColor, fontSize: 14)),
              const SizedBox(width: 8),
              Text(
                dateText,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // Right section: ">"
          FaIcon(
            FontAwesomeIcons.chevronRight,
            color: Colors.black.withOpacity(0.6),
            size: 18,
          ),
        ],
      );
    },
  );
}

// MARK: - ICON_CONTAINER
Widget _iconContainer({
  required IconData icon,
  required bool isDark,
  double size = 14,
  double padding = 4,
}) {
  return Container(
    padding: EdgeInsets.all(padding),
    child: Icon(
      icon,
      size: size,
      color: isDark ? Colors.grey[400] : Colors.grey[600],
    ),
  );
}
