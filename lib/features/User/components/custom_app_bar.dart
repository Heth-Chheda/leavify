import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:leavify/features/User/viewmodel/home_view_model.dart';
import 'package:leavify/core/utils/components/shimmer_widget.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: viewModel.isLoading
          ? _buildShimmerContent()
          : _buildContent(viewModel.userName),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.grey),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.grey),
          onPressed: () {
            // TODO: Navigate to settings screen
          },
        ),
      ],
    );
  }

  Widget _buildShimmerContent() {
    return const Row(
      children: [
        ShimmerWidget(
          width: 40,
          height: 40,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShimmerWidget(width: 120, height: 16),
              SizedBox(height: 4),
              ShimmerWidget(width: 80, height: 12),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent(String userName) {
    final displayName = userName.isNotEmpty ? userName : 'User';

    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.blue.shade100,
          child: Text(
            _getInitials(displayName),
            style: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Hello, $displayName',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _getGreeting(),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _getInitials(String name) {
    if (name.trim().isEmpty) return 'U';
    final parts = name.trim().split(' ');
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
