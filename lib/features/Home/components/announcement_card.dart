import 'package:flutter/material.dart';
import 'package:leavify/core/utils/constants/api_endpoints.dart';
import 'package:leavify/core/utils/theme/app_colors.dart';

class AnnouncementCard extends StatelessWidget {
  final String title;
  final String message;
  final int? colorIndex;
  final String? profileImage;
  final String? timeAgo;
  final String senderName;

  const AnnouncementCard({
    super.key,
    required this.title,
    required this.message,
    this.colorIndex,
    this.profileImage,
    this.timeAgo,
    required this.senderName,
  });

  // Static color schemes to avoid recreating on every build
  static const List<ColorScheme> _colorSchemes = [
    ColorScheme(
      primary: AppColors.highlightBlue,
      shadow: AppColors.highlightBlue,
    ),
    ColorScheme(
      primary: AppColors.highlightPink,
      shadow: AppColors.highlightPink,
    ),
    ColorScheme(
      primary: AppColors.highlightTeal,
      shadow: AppColors.highlightTeal,
    ),
    ColorScheme(
      primary: AppColors.highlightOrange,
      shadow: AppColors.highlightOrange,
    ),
    ColorScheme(
      primary: AppColors.highlightGreen,
      shadow: AppColors.highlightGreen,
    ),
  ];

  // MARK: - CONSTANTS
  // Static constants to avoid recreating
  static const EdgeInsets _cardMargin = EdgeInsets.only(right: 12);
  static const EdgeInsets _cardPadding = EdgeInsets.all(16);
  static const BorderRadius _borderRadius = BorderRadius.all(
    Radius.circular(16),
  );
  static const double _cardHeight = 160.0;
  static const Offset _shadowOffset = Offset(0, 4);

  // MARK: - TEXT STYLES
  // Pre-computed text styles
  static const TextStyle _titleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: -0.2,
    height: 1.2,
  );

  ColorScheme get _selectedColorScheme {
    final index = colorIndex ?? title.hashCode.abs() % _colorSchemes.length;
    return _colorSchemes[index];
  }

  // MARK: - MAIN BUILD FUNCTION
  @override
  Widget build(BuildContext context) {
    final scheme = _selectedColorScheme;

    return Container(
      margin: _cardMargin,
      height: _cardHeight,
      decoration: _buildCardDecoration(scheme),
      child: Padding(
        padding: _cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 10),
            _buildMessage(),
          ],
        ),
      ),
    );
  }

  // MARK: - CARD DECORATION
  BoxDecoration _buildCardDecoration(ColorScheme scheme) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [scheme.primary, scheme.primary.withOpacity(0.8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: _borderRadius,
      boxShadow: [
        BoxShadow(
          color: scheme.shadow.withOpacity(0.2),
          blurRadius: 8,
          offset: _shadowOffset,
          spreadRadius: 0,
        ),
      ],
    );
  }

  // MARK: - HEADER
  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildIcon(),
        const SizedBox(width: 12),
        Expanded(child: _buildTitleSection()),
      ],
    );
  }

  // MARK: - ICON
  Widget _buildIcon() {
    final imageUrl = profileImage != null && profileImage!.isNotEmpty
        ? "${ApiEndpoints.baseUrl}/$profileImage"
        : null;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
      clipBehavior: Clip.antiAlias, // Ensures image respects border radius
      child: imageUrl != null
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback icon if image fails
                return const Icon(Icons.person, color: Colors.white, size: 20);
              },
            )
          : const Icon(Icons.person, color: Colors.white, size: 20),
    );
  }

  // MARK: - TITLE SECTION
  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [_buildTitleRow()],
    );
  }

  // MARK: - TITLE ROW
  Widget _buildTitleRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            senderName,
            style: _titleStyle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // MARK: - BUILD MESSAGE
  Widget _buildMessage() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              height: 1.4,
              letterSpacing: 0.1,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.95),
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              letterSpacing: 0.1,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.95),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// MARK: - COLOR SCHEME
// Helper class for color schemes
class ColorScheme {
  final Color primary;
  final Color shadow;

  const ColorScheme({required this.primary, required this.shadow});
}
