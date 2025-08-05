import 'package:flutter/material.dart';
import 'package:leavify/core/utils/components/shimmer_widget.dart';
import 'package:leavify/core/utils/theme/app_colors.dart';
import 'package:leavify/features/User/viewmodel/home_view_model.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(90.0);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 80,
      flexibleSpace: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Profile Section
            Expanded(
              child: viewModel.isLoading
                  ? _buildShimmerContent(theme)
                  : _buildContent(viewModel.userName, theme),
            ),
            // Action Icons
            _buildActionIcons(context, viewModel.userRole, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerContent(ThemeData theme) {
    return Row(
      children: [
        // Profile Image Shimmer
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: theme.colorScheme.onBackground.withOpacity(0.1),
          ),
          child: ShimmerWidget(
            width: 68,
            height: 68,
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        const SizedBox(width: 20),
        // Text Shimmer
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShimmerWidget(
                width: 120,
                height: 14,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 8),
              ShimmerWidget(
                width: 160,
                height: 20,
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent(String userName, ThemeData theme) {
    final displayName = userName.isNotEmpty ? userName : 'Loading ...';
    final isDarkMode = theme.brightness == Brightness.dark;

    return Row(
      children: [
        // Profile Avatar
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(38),
            border: Border.all(color: AppColors.highlightBlue, width: 2.0),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                      theme.colorScheme.surface.withOpacity(0.95),
                      theme.colorScheme.surface.withOpacity(0.85),
                    ]
                  : [
                      Colors.white.withOpacity(0.95),
                      Colors.white.withOpacity(0.85),
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(38),
            child: Image.network(
              'https://picsum.photos/200',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDarkMode
                          ? [
                              theme.colorScheme.surface.withOpacity(0.95),
                              theme.colorScheme.surface.withOpacity(0.85),
                            ]
                          : [
                              Colors.white.withOpacity(0.95),
                              Colors.white.withOpacity(0.85),
                            ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Greeting and Name in Column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getGreeting(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onBackground.withOpacity(0.8),
                  letterSpacing: -0.1,
                ),
              ),
              Text(
                displayName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onBackground,
                  letterSpacing: -0.2,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionIcons(BuildContext context, String role, ThemeData theme) {
    final isManagerOrHr = role.toLowerCase() != 'employee';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isManagerOrHr)
          _buildIcon(
            icon: Icons.campaign_rounded,
            onTap: () {
              Navigator.pushNamed(context, '/announcements');
            },
            theme: theme,
          ),

        if (isManagerOrHr) const SizedBox(width: 12),
        // Notifications Icon
        _buildIcon(
          icon: Icons.settings,
          onTap: () {
            Navigator.pushNamed(context, '/notifications');
          },
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildIcon({
    required IconData icon,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isDarkMode
            ? theme.colorScheme.surface.withOpacity(0.1)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.onBackground.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          splashColor: theme.colorScheme.onBackground.withOpacity(0.1),
          highlightColor: theme.colorScheme.onBackground.withOpacity(0.05),
          child: Center(
            child: Icon(icon, color: theme.colorScheme.onBackground, size: 24),
          ),
        ),
      ),
    );
  }

  static String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Morning,';
    } else if (hour < 17) {
      return 'Afternoon,';
    } else {
      return 'Evening,';
    }
  }
}
