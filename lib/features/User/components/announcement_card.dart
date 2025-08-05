import 'package:flutter/material.dart';
import 'package:leavify/core/utils/theme/app_colors.dart';

class AnnouncementCard extends StatelessWidget {
  final String title;
  final String message;
  final String? date;
  final bool isNew;
  final int? colorIndex;

  const AnnouncementCard({
    super.key,
    required this.title,
    required this.message,
    this.date,
    this.isNew = false,
    this.colorIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Define color schemes using AppColors
    final colorSchemes = [
      {
        'colors': [
          AppColors.highlightBlue,
          AppColors.highlightBlue.withOpacity(0.8),
        ],
        'shadowColor': AppColors.highlightBlue,
      },
      {
        'colors': [
          AppColors.highlightPink,
          AppColors.highlightPink.withOpacity(0.8),
        ],
        'shadowColor': AppColors.highlightPink,
      },
      {
        'colors': [
          AppColors.highlightTeal,
          AppColors.highlightTeal.withOpacity(0.8),
        ],
        'shadowColor': AppColors.highlightTeal,
      },
      {
        'colors': [
          AppColors.highlightOrange,
          AppColors.highlightOrange.withOpacity(0.8),
        ],
        'shadowColor': AppColors.highlightOrange,
      },
      {
        'colors': [
          AppColors.highlightGreen,
          AppColors.highlightGreen.withOpacity(0.8),
        ],
        'shadowColor': AppColors.highlightGreen,
      },
    ];

    final selectedScheme =
        colorSchemes[colorIndex ?? title.hashCode.abs() % colorSchemes.length];

    return Container(
      margin: const EdgeInsets.only(right: 12),
      height: 160, // Fixed height to match CarouselOptions
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: selectedScheme['colors'] as List<Color>,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (selectedScheme['shadowColor'] as Color).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          16,
        ), // Increased padding for better content spacing
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with title and badges
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Simple announcement icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.campaign_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Title and badges
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.2,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isNew) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.highlightOrange,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'NEW',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (date != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              date!,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Message content - removed glass effect container
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.95),
                  height: 1.4,
                  letterSpacing: 0.1,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
