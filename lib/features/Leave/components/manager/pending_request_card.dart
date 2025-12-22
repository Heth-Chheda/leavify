// Main Pending Request Card - Optimized with Separate Widget Components
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leavify/core/utils/constants/api_endpoints.dart';
import 'package:leavify/core/utils/constants/status_color/status_colors.dart';
import 'package:leavify/core/utils/formatters/date/date_formatter.dart';
import 'package:leavify/features/Authentication/domain/response/get_all_response.dart';
import 'package:leavify/features/Home/viewmodel/home_view_model.dart';
import 'package:provider/provider.dart';

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
    final homeViewModel = context.read<HomeViewModel>();

    final isAboveManager =
        homeViewModel.userRole.toLowerCase() != 'employee' &&
        homeViewModel.userRole.toLowerCase() != 'manager';

    final shouldShowBell = request.escalated && isAboveManager;

    /* ================= LEFT ACCENT PRIORITY ================= */

    final bool isCompOff = request.requestType.toLowerCase() == 'extra';
    final bool isHalfDay = request.isHalfDay == true;

    Color? leftAccentColor;

    // Priority: Comp-Off > Half-Day
    if (isCompOff) {
      leftAccentColor = Colors.purple;
    } else if (isHalfDay) {
      leftAccentColor = Colors.amber.shade700;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        // LEFT ACCENT BORDER (added, does NOT affect escalated logic)
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: leftAccentColor != null
              ? Border(left: BorderSide(color: leftAccentColor, width: 4))
              : null,
        ),
        child: Container(
          // EXISTING CARD DECORATION (unchanged)
          decoration: _buildCardDecoration(context, homeViewModel),
          child: Container(
            decoration: _buildGradientDecoration(),
            child: Stack(
              children: [
                // Main content
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 100, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_requestHeader(request: request)],
                  ),
                ),

                // Status badge (unchanged)
                Positioned(
                  top: 15,
                  right: 15,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _statusBadge(status: request.status),
                      const SizedBox(height: 4),
                      if ((request.actionTaken ?? '').isNotEmpty &&
                          request.status.toLowerCase() == 'pending')
                        _actionTakenTag(request.actionTaken!),
                    ],
                  ),
                ),

                // Escalation bell (unchanged)
                if (shouldShowBell)
                  Positioned(
                    bottom: 8,
                    right: 20,
                    child: FaIcon(
                      FontAwesomeIcons.solidBell,
                      color: const Color(0xFFFFD43B),
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // MARK: - ACTION_TAKEN TAG
  Widget _actionTakenTag(String actionTaken) {
    final normalized = actionTaken.trim().toLowerCase();
    late final Color dotColor;
    late final String statusText;

    switch (normalized) {
      case 'approved':
        dotColor = Colors.green;
        statusText = 'Approved';
        break;
      case 'rejected':
        dotColor = Colors.red;
        statusText = 'Rejected';
        break;
      default:
        dotColor = Colors.grey;
        statusText = 'Pending';
        break;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 3),
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              statusText,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            Text(
              "by me",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // MARK: - BUILD CARD DECORATION (UNCHANGED)
  BoxDecoration _buildCardDecoration(
    BuildContext context,
    HomeViewModel homeViewModel,
  ) {
    final shouldSeeRedBorder =
        homeViewModel.userRole.toLowerCase() != 'manager' &&
        homeViewModel.userRole.toLowerCase() != 'employee' &&
        request.escalated;

    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: shouldSeeRedBorder
          ? Border.all(color: Colors.red, width: 1)
          : Border.all(color: Colors.black.withOpacity(0.13), width: 1.5),
    );
  }

  BoxDecoration _buildGradientDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white, Colors.grey[50]!.withOpacity(0.5)],
      ),
    );
  }
}

// ================= SUB-WIDGETS =================

// MARK: - REQUEST_HEADER
Widget _requestHeader({required GetAllResponse request}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _employeeAvatar(request: request),
      const SizedBox(width: 14),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: _employeeInfo(request: request),
        ),
      ),
    ],
  );
}

// MARK: - EMPLOYEE_AVATAR
Widget _employeeAvatar({required GetAllResponse request}) {
  return Builder(
    builder: (context) {
      String? getProfileImageUrl() {
        if (request.profileImage.isEmpty) return null;
        return "${ApiEndpoints.baseUrl}/${request.profileImage}";
      }

      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context).secondaryHeaderColor.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: getProfileImageUrl() != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  getProfileImageUrl()!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
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
          '${request.firstName.isNotEmpty ? request.firstName[0] : ''}'
          '${request.lastName.isNotEmpty ? request.lastName[0] : ''}',
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
          Text(
            request.designation ?? 'Loading...',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          _requestDurationAndDateRange(request: request),
        ],
      );
    },
  );
}

// MARK: - STATUS_BADGE
Widget _statusBadge({required String status}) {
  return Builder(
    builder: (context) {
      final statusColor = StatusColors.fromStatus(status);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          status.toUpperCase(),
          style: const TextStyle(
            color: Colors.black,
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
  return Row(
    children: [
      const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
      const SizedBox(width: 4),
      Expanded(
        child: Text(
          DateFormatter.formatDateRange(request.startDate, request.endDate),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      ),
    ],
  );
}
