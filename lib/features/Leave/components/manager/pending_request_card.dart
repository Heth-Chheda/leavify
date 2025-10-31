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

    debugPrint('IS ABOVE MANAGER : $isAboveManager');
    final shouldShowBell = request.escalated && isAboveManager;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: _buildCardDecoration(context, homeViewModel),
        child: Container(
          decoration: _buildGradientDecoration(),
          child: Stack(
            children: [
              // Main content
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_requestHeader(request: request)],
                ),
              ),

              // Status badge positioned on top-right corner
              Positioned(
                top: 15,
                right: 15,
                child: _statusBadge(status: request.status),
              ),

              if (shouldShowBell)
                Positioned(
                  bottom: 15,
                  right: 20, // You can change this position as needed
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
    );
  }

  // MARK: - BUILD CARD DECORATION
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
        final baseUrl = ApiEndpoints.baseUrl;
        return "$baseUrl/${request.profileImage}";
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
          Text(
            request.designation ?? 'Loading...',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w400,
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
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          status.toUpperCase(),
          style: TextStyle(
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
  return Builder(
    builder: (context) {
      final textColor = Colors.grey[700];

      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _iconContainer(icon: Icons.calendar_today_outlined),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              DateFormatter.formatDateRange(request.startDate, request.endDate),
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    },
  );
}

// MARK: - ICON_CONTAINER
Widget _iconContainer({
  required IconData icon,
  double size = 14,
  double padding = 4,
}) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: padding),
    child: Icon(icon, size: size, color: Colors.grey[600]),
  );
}
