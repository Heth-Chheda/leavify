import 'package:flutter/material.dart';
import 'package:leavify/core/api/api_endpoints.dart';
import 'package:leavify/core/storage/app_storage.dart';
import 'package:leavify/core/utils/components/shimmer_widget.dart';
import 'package:leavify/core/utils/theme/app_colors.dart';
import 'package:leavify/features/User/viewmodel/home_view_model.dart';
import 'package:leavify/features/User/viewmodel/announcements_view_model.dart';
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
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Profile Section
            Expanded(
              child: viewModel.isLoading
                  ? _buildShimmerContent(theme)
                  : _buildContent(viewModel.userName, theme, context),
            ),
            // Action Icons
            _buildActionIcons(context, theme, viewModel.canSendAnnouncement),
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

  Widget _buildContent(String userName, ThemeData theme, BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    final displayName = userName.isNotEmpty ? userName : 'Loading ...';
    final isDarkMode = theme.brightness == Brightness.dark;

    return Row(
      children: [
        // Profile Avatar
        Container(
          width: 40,
          height: 40,
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
              (viewModel.profileImageUrl.isNotEmpty)
                  ? '${ApiEndpoints.baseUrl}/${viewModel.profileImageUrl}'
                  : 'https://picsum.photos/200',
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.onBackground,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                displayName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.onBackground,
                  letterSpacing: -0.5,
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

  Widget _buildActionIcons(
      BuildContext context,
      ThemeData theme,
      bool canSendAnnouncement,
      ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (canSendAnnouncement)
          _buildIcon(
            icon: Icons.campaign_rounded,
            onTap: () {
              _showAnnouncementBottomSheet(context, theme);
            },
            theme: theme,
          ),
        // Settings Icon
        _buildIcon(
          icon: Icons.logout,
          onTap: () {
            _showLogoutConfirmationDialog(context, theme);
          },
          theme: theme,
        ),
      ],
    );
  }

  void _showAnnouncementBottomSheet(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _AnnouncementBottomSheetContent(theme: theme);
      },
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: theme.colorScheme.error, size: 24),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _performLogout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Yes, Logout',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _performLogout(BuildContext context) {
    // Clear the HomeViewModel data before logout
    final homeViewModel = context.read<HomeViewModel>();
    homeViewModel.clearData();

    // Clear storage
    AppStorage.remove("USER_ID");
    AppStorage.remove("JWT_TOKEN");
    AppStorage.remove("USER_IS_ALREADY_LOGGED_IN");
    AppStorage.remove("user_details");

    // Navigate to login
    Navigator.pushNamedAndRemoveUntil(
      context,
      "/login",
          (route) => false, // This removes all previous routes
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
      return 'Good Morning, ';
    } else if (hour < 17) {
      return 'Good Afternoon, ';
    } else {
      return 'Good Evening, ';
    }
  }
}

class _AnnouncementBottomSheetContent extends StatefulWidget {
  final ThemeData theme;

  const _AnnouncementBottomSheetContent({required this.theme});

  @override
  State<_AnnouncementBottomSheetContent> createState() => _AnnouncementBottomSheetContentState();
}

class _AnnouncementBottomSheetContentState extends State<_AnnouncementBottomSheetContent> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  void _sendAnnouncement() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both title and body")),
      );
      return;
    }

    final viewModel = context.read<AnnouncementViewModel>();
    final homeViewModel = context.read<HomeViewModel>();

    final success = await viewModel.addAnnouncement(title, body);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            viewModel.latestAnnouncement?.message ?? "Announcement sent",
          ),
        ),
      );
      _titleController.clear();
      _bodyController.clear();
      Navigator.pop(context); // Close bottom sheet instead of navigating to home
      homeViewModel.refresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            viewModel.errorMessage ?? "Failed to send announcement",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AnnouncementViewModel>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: widget.theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: widget.theme.colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.campaign_rounded,
                  color: widget.theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Create Announcement',
                  style: TextStyle(
                    color: widget.theme.colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: widget.theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: "Title",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelStyle: TextStyle(
                        color: widget.theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    style: TextStyle(
                      color: widget.theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _bodyController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: "Body",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelStyle: TextStyle(
                        color: widget.theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      alignLabelWithHint: true,
                    ),
                    style: TextStyle(
                      color: widget.theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      icon: viewModel.isLoading
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(Icons.send),
                      label: const Text("Send Announcement"),
                      onPressed: viewModel.isLoading ? null : _sendAnnouncement,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }
}