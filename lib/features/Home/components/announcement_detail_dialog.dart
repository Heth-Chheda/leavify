import 'package:flutter/material.dart';
import 'package:leavify/core/utils/theme/app_colors.dart';

class AnnouncementDetailDialog extends StatelessWidget {
  final String title;
  final String message;
  final String timeAgo;
  final String? profileImage;
  final String senderName;
  final int colorIndex;

  const AnnouncementDetailDialog({
    super.key,
    required this.title,
    required this.message,
    required this.timeAgo,
    this.profileImage,
    required this.senderName,
    required this.colorIndex,
  });

  // Get gradient colors based on index
  List<Color> _getGradientColors() {
    switch (colorIndex % 5) {
      case 0:
        return [AppColors.highlightBlue, AppColors.highlightPink];
      case 1:
        return [AppColors.highlightPink, AppColors.highlightOrange];
      case 2:
        return [AppColors.highlightTeal, AppColors.highlightGreen];
      case 3:
        return [AppColors.highlightOrange, AppColors.highlightBlue];
      case 4:
        return [AppColors.highlightGreen, AppColors.highlightTeal];
      default:
        return [AppColors.highlightBlue, AppColors.highlightPink];
    }
  }

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    required String timeAgo,
    String? profileImage,
    required String senderName,
    required int colorIndex,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => AnnouncementDetailDialog(
        title: title,
        message: message,
        timeAgo: timeAgo,
        profileImage: profileImage,
        senderName: senderName,
        colorIndex: colorIndex,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final gradientColors = _getGradientColors();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with gradient
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Close button and title row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                        color: Colors.white,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Sender info
                  Row(
                    children: [
                      // Profile image
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.3),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: profileImage != null && profileImage!.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  profileImage!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildDefaultAvatar();
                                  },
                                ),
                              )
                            : _buildDefaultAvatar(),
                      ),
                      const SizedBox(width: 12),

                      // Name and time
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              senderName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  timeAgo,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Message content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Decorative line
                    Container(
                      height: 3,
                      width: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradientColors),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Message text
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.9)
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Center(
      child: Text(
        senderName.isNotEmpty ? senderName[0].toUpperCase() : '?',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
