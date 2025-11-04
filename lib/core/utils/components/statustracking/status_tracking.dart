// lib/core/widgets/status_tracking/status_tracking_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leavify/core/utils/components/container/my_app_container.dart';
import 'package:leavify/core/utils/constants/status_color/status_colors.dart';

class StatusTrackingCard extends StatelessWidget {
  final String title;
  final List<StatusTrackingItem> statusTracking;

  const StatusTrackingCard({
    super.key,
    required this.statusTracking,
    this.title = 'Status History',
  });

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: title,
      children: [
        ...statusTracking.asMap().entries.map((entry) {
          final index = entry.key;
          final tracking = entry.value;
          final isLast = index == statusTracking.length - 1;

          return TimelineItem(tracking: tracking, isLast: isLast);
        }),
      ],
    );
  }
}

// Generic model to represent status tracking
class StatusTrackingItem {
  final String status;
  final String processedBy;
  final DateTime processedAt;
  final String comment;

  StatusTrackingItem({
    required this.status,
    required this.processedBy,
    required this.processedAt,
    this.comment = '',
  });
}

// Timeline Item widget
class TimelineItem extends StatelessWidget {
  final StatusTrackingItem tracking;
  final bool isLast;

  const TimelineItem({super.key, required this.tracking, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: StatusColors.fromStatus(tracking.status),
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: colorScheme.onSurface.withOpacity(0.2),
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tracking.status.toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: StatusColors.fromStatus(tracking.status),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'By: ${tracking.processedBy}',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                DateFormat('dd MMM yyyy, hh:mm a').format(tracking.processedAt),
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              if (tracking.comment.isNotEmpty) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tracking.comment,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
              if (!isLast) const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}

// Simple InfoCard wrapper (generalized)
class InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const InfoCard({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MyAppContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
