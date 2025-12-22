import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final String? imagePath;
  final String baseUrl;

  const ProfileAvatar({
    super.key,
    required this.initials,
    required this.baseUrl,
    this.size = 80,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final String? fullImageUrl = (imagePath != null && imagePath!.isNotEmpty)
        ? "$baseUrl/$imagePath"
        : null;

    // 🔍 DEBUG: URL resolution
    debugPrint('🖼️ ProfileAvatar');
    debugPrint('   imagePath: $imagePath');
    debugPrint('   fullImageUrl: $fullImageUrl');

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: fullImageUrl != null
          ? ClipOval(
              child: Image.network(
                fullImageUrl,
                fit: BoxFit.cover,

                // 🔍 DEBUG: loading lifecycle
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    debugPrint('✅ Image loaded successfully: $fullImageUrl');
                    return child;
                  }

                  debugPrint(
                    '⏳ Image loading: $fullImageUrl '
                    '(${loadingProgress.cumulativeBytesLoaded}'
                    '/${loadingProgress.expectedTotalBytes ?? 'unknown'})',
                  );

                  return _buildInitialsWidget();
                },

                // 🔍 DEBUG: error handling
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('❌ Image failed to load: $fullImageUrl');
                  debugPrint('   Error: $error');
                  return _buildInitialsWidget();
                },
              ),
            )
          : _buildInitialsWidget(),
    );
  }

  Widget _buildInitialsWidget() {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.3,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
