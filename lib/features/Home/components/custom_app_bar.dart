import 'package:flutter/material.dart';
import 'package:leavify/core/utils/components/confirmation/confirmation_dialog.dart';
import 'package:leavify/core/utils/constants/api_endpoints.dart';
import 'package:leavify/core/storage/app_storage.dart';
import 'package:leavify/core/utils/theme/app_colors.dart';
import 'package:leavify/features/Home/viewmodel/announcements_view_model.dart';
import 'package:leavify/features/Home/viewmodel/home_view_model.dart';
import 'package:leavify/router/app_navigator.dart';
import 'package:leavify/router/route_names.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(90.0);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

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
                  ? _buildLoadingWidget()
                  : _buildContent(viewModel.userName, context),
            ),
            // Action Icons - Show shimmer when loading, actual icons when loaded
            viewModel.isLoading
                ? const SizedBox.shrink()
                : _buildActionIcons(context, viewModel.canSendAnnouncement),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SpinKitCircle(
            color: Colors.blue, // change to your theme color
            size: 60.0,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(String userName, BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    final displayName = userName.isNotEmpty ? userName : 'Loading ...';
    return Row(
      children: [
        // Profile Avatar
        GestureDetector(
          onTap: () {
            AppNavigator.navigateTo(RouteNames.profile);
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(38),
              border: Border.all(color: AppColors.highlightBlue, width: 2.0),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.85),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
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
                        colors: [
                          Colors.white.withOpacity(0.95),
                          Colors.white.withOpacity(0.85),
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      color: Colors.grey.withOpacity(0.5),
                      size: 20,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Greeting and Name in Row
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
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
              Flexible(
                child: Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionIcons(BuildContext context, bool canSendAnnouncement) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (canSendAnnouncement)
          _buildIcon(
            icon: Icons.campaign_rounded,
            onTap: () {
              _showAnnouncementBottomSheet(context);
            },
          ),
        // Logout Icon
        _buildIcon(
          icon: Icons.logout,
          onTap: () {
            _showLogoutConfirmationDialog(context);
          },
        ),
      ],
    );
  }

  void _showAnnouncementBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _AnnouncementBottomSheetContent();
      },
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return ConfirmationDialog(
          title: 'Logout',
          body: 'Are you sure you want to logout?',
          confirmButtonText: 'Yes, Logout',
          illustrationAsset: 'lib/assets/shutDown.png',
          illustrationHeight: 150,
          buttonBackgroundColor: Colors.red,
          buttonForegroundColor: Colors.white,
          onConfirm: () {
            Navigator.of(dialogContext).pop();
            _performLogout(context);
          },
        );
      },
    );
  }

  void _performLogout(BuildContext context) async {
    try {
      // First, clear the data immediately to prevent further provider access
      if (context.mounted) {
        final homeViewModel = context.read<HomeViewModel>();
        homeViewModel.clearData();
      }

      // Clear SharedPreferences
      await AppStorage.clearAllExcept("USER_FCM_TOKEN");

      // Navigate immediately after clearing data
      if (context.mounted) {
        // Navigator.pushNamed(context, '/login');
        AppNavigator.setRootView(RouteNames.login);
      }
    } catch (e) {
      // If provider access fails during logout, proceed anyway
      debugPrint('Error during logout: $e');

      // Still try to clear storage and navigate
      try {
        await AppStorage.clearAllExcept("USER_FCM_TOKEN");
        if (context.mounted) {
          Navigator.pushNamed(context, '/login');
        }
      } catch (e2) {
        debugPrint('Critical logout error: $e2');
      }
    }
  }

  Widget _buildIcon({required IconData icon, required VoidCallback onTap}) {
    return Container(
      width: 48,
      height: 48,
      margin: const EdgeInsets.only(left: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          splashColor: Colors.black.withOpacity(0.1),
          highlightColor: Colors.black.withOpacity(0.05),
          child: Center(child: Icon(icon, color: Colors.black, size: 24)),
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
  const _AnnouncementBottomSheetContent();

  @override
  State<_AnnouncementBottomSheetContent> createState() =>
      _AnnouncementBottomSheetContentState();
}

class _AnnouncementBottomSheetContentState
    extends State<_AnnouncementBottomSheetContent> {
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
      Navigator.pop(context);
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

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              _buildHandleBar(),
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildModernTextField(
                        controller: _titleController,
                        label: "Title",
                        hint: "Enter announcement title",
                      ),
                      const SizedBox(height: 20),
                      _buildModernTextField(
                        controller: _bodyController,
                        label: "Body",
                        hint: "Enter announcement details",
                        maxLines: 6,
                      ),
                      const SizedBox(height: 32),
                      _buildSendButton(viewModel.isLoading),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandleBar() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 16, 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.campaign_rounded, color: Colors.black, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Create Announcement',
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close_rounded,
              color: Colors.black.withOpacity(0.6),
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withOpacity(0.05),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.black.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            onEditingComplete: () => FocusScope.of(context).unfocus(),
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.black.withOpacity(0.4),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSendButton(bool isLoading) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: isLoading
            ? []
            : [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : _sendAnnouncement,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.blueAccent.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send_rounded, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    "Send Announcement",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
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
