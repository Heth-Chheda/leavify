import 'package:flutter/material.dart';
import 'package:leavify/core/utils/components/shimmer_widget.dart';
import 'package:leavify/core/utils/theme/app_colors.dart';

class ShimmerCustomAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const ShimmerCustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(90.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 80,
      flexibleSpace: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Profile Section Shimmer
            Expanded(child: _buildShimmerProfileSection(theme, isDarkMode)),
            // Action Icons Shimmer
            _buildShimmerActionIcons(theme, isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerProfileSection(ThemeData theme, bool isDarkMode) {
    return Row(
      children: [
        // Profile Avatar Shimmer
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(38),
            border: Border.all(
              color: theme.colorScheme.onBackground.withOpacity(0.2),
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ShimmerWidget.circular(width: 36, height: 36),
        ),

        const SizedBox(width: 12),

        // Greeting and Name Shimmer
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Greeting Text Shimmer
              ShimmerWidget.rectangular(
                width: 180,
                height: 20,
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerActionIcons(ThemeData theme, bool isDarkMode) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Campaign/Announcement Icon Shimmer
        _buildShimmerIcon(theme, isDarkMode),

        // Logout Icon Shimmer
        _buildShimmerIcon(theme, isDarkMode),
      ],
    );
  }

  Widget _buildShimmerIcon(ThemeData theme, bool isDarkMode) {
    return Container(
      width: 48,
      height: 48,
      margin: const EdgeInsets.only(left: 4),
      decoration: BoxDecoration(
        color: isDarkMode
            ? theme.colorScheme.surface.withOpacity(0.1)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: ShimmerWidget.circular(width: 24, height: 24),
    );
  }
}

/// Alternative version with more detailed shimmer animation
class ShimmerCustomAppBarDetailed extends StatelessWidget
    implements PreferredSizeWidget {
  const ShimmerCustomAppBarDetailed({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(90.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 80,
      flexibleSpace: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [
                    AppColors.darkBackground.withOpacity(0.8),
                    AppColors.darkBackground.withOpacity(0.6),
                  ]
                : [
                    AppColors.lightBackground.withOpacity(0.8),
                    AppColors.lightBackground.withOpacity(0.6),
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Row(
          children: [
            // Enhanced Profile Section Shimmer
            Expanded(
              child: _buildEnhancedShimmerProfileSection(theme, isDarkMode),
            ),
            // Enhanced Action Icons Shimmer
            _buildEnhancedShimmerActionIcons(theme, isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedShimmerProfileSection(ThemeData theme, bool isDarkMode) {
    return Row(
      children: [
        // Profile Avatar with Border Shimmer
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(38),
            gradient: LinearGradient(
              colors: [
                AppColors.highlightBlue.withOpacity(0.3),
                AppColors.highlightPink.withOpacity(0.3),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(child: ShimmerWidget.circular(width: 36, height: 36)),
        ),

        const SizedBox(width: 12),

        // Staggered Text Shimmer Animation
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main greeting text with varied width for realism
              ShimmerWidget.rectangular(
                width: 200,
                height: 20,
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedShimmerActionIcons(ThemeData theme, bool isDarkMode) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Campaign Icon with Pulsing Effect
        _buildEnhancedShimmerIcon(theme, isDarkMode, delay: 0),

        // Logout Icon with Staggered Animation
        _buildEnhancedShimmerIcon(theme, isDarkMode, delay: 200),
      ],
    );
  }

  Widget _buildEnhancedShimmerIcon(
    ThemeData theme,
    bool isDarkMode, {
    int delay = 0,
  }) {
    return Container(
      width: 48,
      height: 48,
      margin: const EdgeInsets.only(left: 4),
      decoration: BoxDecoration(
        color: isDarkMode
            ? theme.colorScheme.surface.withOpacity(0.1)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.onBackground.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Center(child: ShimmerWidget.circular(width: 24, height: 24)),
    );
  }
}
