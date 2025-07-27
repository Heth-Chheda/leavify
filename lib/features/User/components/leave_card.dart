import 'package:flutter/material.dart';
import 'package:leavify/core/utils/formatters.dart';
import 'package:leavify/features/Authentication/domain/models/leave.dart';

class LeaveCard extends StatelessWidget {
  final Leave leave;
  final VoidCallback? onTap;

  const LeaveCard({super.key, required this.leave, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: Colors.green, width: 5.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              minRadius: 40,
              foregroundImage: NetworkImage('https://picsum.photos/200'),
              child: Text('A'), // fallback if the image fails to load
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Leave Type
                Text(
                  leave.employeeName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                /// Date Range
                Row(
                  children: [
                    const Icon(Icons.date_range, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      "${Formatters.formatDate(leave.startDate)} → ${Formatters.formatDate(leave.endDate)}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                /// Reason
                Text(
                  leave.reason.isNotEmpty
                      ? leave.reason
                      : 'No reason provided.',
                  style: const TextStyle(color: Colors.black54),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
