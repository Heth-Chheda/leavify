import 'package:flutter/material.dart';
import 'package:leavify/core/utils/components/shimmer_widget.dart';
import 'package:leavify/features/User/viewmodel/home_view_model.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(90.0);

  //
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 100,
      flexibleSpace: Container(
        margin: const EdgeInsets.only(top: 30),
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Profile Section
            Expanded(
              child: viewModel.isLoading
                  ? _buildShimmerContent()
                  : _buildContent(viewModel.userFullName),
            ),
            // Action Icons
            _buildActionIcons(),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerContent() {
    return Row(
      children: [
        // Profile Image Shimmer
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: Colors.white.withOpacity(0.2),
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

  Widget _buildContent(String userName) {
    final displayName = userName.isNotEmpty ? userName : 'Loading ...';

    return Row(
      children: [
        // Modern Profile Avatar
        Container(
          width: 75,
          height: 75,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.blueAccent, width: 2.0),
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
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
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
                      colors: [
                        Colors.white.withOpacity(0.95),
                        Colors.white.withOpacity(0.85),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(displayName),
                      style: TextStyle(
                        color: const Color(0xFF667EEA),
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Greeting and Name Section
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getGreeting(),
                style: TextStyle(
                  color: Colors.black.withOpacity(0.85),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                displayName,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  height: 1.1,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionIcons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Notifications Icon
        _buildGlassIcon(
          icon: Icons.notifications_none_rounded,
          onTap: () {
            // TODO: Handle notifications
          },
        ),
        const SizedBox(width: 12),
        // Settings Icon
        _buildGlassIcon(
          icon: Icons.settings,
          onTap: () {
            // TODO: Navigate to settings screen
          },
        ),
      ],
    );
  }

  Widget _buildGlassIcon({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Center(child: Icon(icon, color: Colors.white, size: 24)),
        ),
      ),
    );
  }

  static String _getInitials(String name) {
    if (name.trim().isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  static String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning!';
    } else if (hour < 17) {
      return 'Good afternoon!';
    } else {
      return 'Good evening!';
    }
  }
}
