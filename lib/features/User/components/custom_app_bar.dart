import 'package:flutter/material.dart';
import 'package:leavify/core/utils/theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;

  const CustomAppBar({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Container(
        margin: EdgeInsets.all(0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: AppTheme.primaryBlueLight,
            ),
            const SizedBox(width: 10),
            Text(
              "Hello $userName!",
              style: TextStyle(color: Colors.black, fontSize: 25),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {},
        ),
        IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
