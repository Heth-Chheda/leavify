import 'package:flutter/material.dart';
import 'package:leavify/core/utils/components/shimmer_widget.dart';
import 'package:leavify/core/utils/theme/app_colors.dart';

class ShimmerHomeScreen extends StatelessWidget {
  const ShimmerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [AppColors.darkBackground, AppColors.darkSurface]
              : [AppColors.lightBackground, AppColors.lightBackground],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shimmer Custom App Bar
                _buildShimmerAppBar(theme, isDarkMode),

                // Shimmer Announcements Section
                _buildShimmerAnnouncementSection(theme, isDarkMode),

                const SizedBox(height: 8),

                // Shimmer Calendar Section
                _buildShimmerCalendarSection(theme, isDarkMode),

                const SizedBox(height: 8),

                // Shimmer Upcoming Events Section
                _buildShimmerUpcomingEventsSection(theme, isDarkMode),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerAppBar(ThemeData theme, bool isDarkMode) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Profile Image Shimmer
          ShimmerWidget.circular(width: 40, height: 40),
          const SizedBox(width: 12),

          // Greeting Text Shimmer
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerWidget.rectangular(
                  width: 180,
                  height: 20,
                  borderRadius: BorderRadius.circular(10),
                ),
              ],
            ),
          ),

          // Action Icons Shimmer
          Row(
            children: [
              ShimmerWidget.circular(width: 48, height: 48),
              const SizedBox(width: 8),
              ShimmerWidget.circular(width: 48, height: 48),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerAnnouncementSection(ThemeData theme, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.brightness == Brightness.dark
                ? AppColors.darkBackground
                : AppColors.lightBackground,
            theme.brightness == Brightness.dark
                ? AppColors.darkBackground.withOpacity(0.95)
                : AppColors.lightBackground.withOpacity(0.95),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section Shimmer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                // Left decorative line shimmer
                Expanded(
                  flex: 2,
                  child: ShimmerWidget.rectangular(
                    width: double.infinity,
                    height: 2,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),

                // Center title shimmer
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ShimmerWidget.rectangular(
                    width: 150,
                    height: 22,
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),

                // Right decorative line shimmer
                Expanded(
                  flex: 2,
                  child: ShimmerWidget.rectangular(
                    width: double.infinity,
                    height: 2,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Announcement Card Shimmer
          Container(
            height: 160,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ShimmerWidget.rectangular(
              width: double.infinity,
              height: 160,
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          const SizedBox(height: 16),

          // Page Indicators Shimmer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: ShimmerWidget.rectangular(
                  width: index == 1 ? 24 : 8,
                  height: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildShimmerCalendarSection(ThemeData theme, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode
            ? theme.colorScheme.surface.withOpacity(0.3)
            : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ShimmerWidget.rectangular(
        width: double.infinity,
        height: 250, // Adjust height to match your real calendar
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildShimmerUpcomingEventsSection(ThemeData theme, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title Shimmer
        Container(
          padding: const EdgeInsets.only(left: 22),
          child: ShimmerWidget.rectangular(
            width: 200,
            height: 22,
            borderRadius: BorderRadius.circular(11),
          ),
        ),

        const SizedBox(height: 10),

        // Leave Cards Shimmer
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? theme.colorScheme.surface.withOpacity(0.3)
                    : Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.onSurface.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Profile Image Shimmer
                  ShimmerWidget.circular(width: 48, height: 48),

                  const SizedBox(width: 12),

                  // Content Shimmer
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name Shimmer
                        ShimmerWidget.rectangular(
                          width: 120,
                          height: 16,
                          borderRadius: BorderRadius.circular(8),
                        ),

                        const SizedBox(height: 8),

                        // Leave Type Shimmer
                        ShimmerWidget.rectangular(
                          width: 80,
                          height: 14,
                          borderRadius: BorderRadius.circular(7),
                        ),

                        const SizedBox(height: 8),

                        // Date Range Shimmer
                        ShimmerWidget.rectangular(
                          width: 150,
                          height: 14,
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ],
                    ),
                  ),

                  // Status Badge Shimmer
                  ShimmerWidget.rectangular(
                    width: 60,
                    height: 24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
