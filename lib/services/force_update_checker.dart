import 'package:flutter/material.dart';
import 'package:leavify/core/utils/theme/app_theme.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// A wrapper widget that checks for a forced app update as soon as the app starts.
/// If the current app version is lower than the minimum required version,
/// a non-dismissible update dialog is shown to prevent usage until updated.
class ForceUpdateWrapper extends StatefulWidget {
  /// The actual app UI to display if update is not required
  final Widget child;

  const ForceUpdateWrapper({super.key, required this.child});

  @override
  State<ForceUpdateWrapper> createState() => _ForceUpdateWrapperState();
}

class _ForceUpdateWrapperState extends State<ForceUpdateWrapper> {
  bool _hasCheckedForUpdate = false;

  @override
  void initState() {
    super.initState();
    // Start version check after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdate();
    });
  }

  /// Checks if the current app version is less than the required version
  /// If yes, displays a force update dialog
  Future<void> _checkForUpdate() async {
    if (_hasCheckedForUpdate) return;
    _hasCheckedForUpdate = true;

    try {
      // Fetch the current app version from platform (e.g., 1.2.3)
      final info = await PackageInfo.fromPlatform();
      final currentVersion = info.version;

      // Fetch the required minimum version from remote (API or Firebase)
      final latestVersion = await _getRequiredVersionFromServer();

      // Compare versions: if outdated, prompt update
      // NOTE: Using `true ||` forces the update dialog to always show for now
      if (_isVersionOutdated(currentVersion, latestVersion)) {
        if (mounted) {
          await _showForceUpdateDialog(context);
        }
      }
    } catch (e) {
      // If there's an error checking for updates, allow the app to continue
    }
  }

  /// Mock method to return required app version from backend or remote config
  /// In production, replace this with an actual API or Firebase Remote Config call
  Future<String> _getRequiredVersionFromServer() async {
    // Simulate network delay (optional - remove in production for faster check)
    await Future.delayed(const Duration(milliseconds: 500));
    return '1.0.0'; // Example: Server mandates 2.0.0 or above
  }

  /// Compares the current version to the required one
  /// Returns true if the current version is *older*
  bool _isVersionOutdated(String current, String required) {
    final currentParts = current.split('.').map(int.parse).toList();
    final requiredParts = required.split('.').map(int.parse).toList();

    // Compare each segment of the version (major.minor.patch)
    for (int i = 0; i < requiredParts.length; i++) {
      if (currentParts.length <= i || currentParts[i] < requiredParts[i]) {
        return true; // Current version is less than required
      }
      if (currentParts[i] > requiredParts[i]) {
        return false; // Current version is already newer
      }
    }

    return false; // Versions are equal
  }

  /// Shows a modal dialog that prevents usage unless the app is updated
  Future<void> _showForceUpdateDialog(BuildContext context) async {
    if (!context.mounted) return;

    return showDialog(
      context: context,
      barrierDismissible: false, // User cannot dismiss by tapping outside
      builder: (_) => WillPopScope(
        onWillPop: () async => false, // Prevent back button dismiss
        child: const UpdateDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Simply return the child app - no loading screens or duplicate MaterialApps
    return widget.child;
  }
}

class UpdateDialog extends StatelessWidget {
  const UpdateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryBlueDark, // Deep blue
              AppTheme.secondaryBlueDark, // Bright blue
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top section with rocket illustration
            Container(
              height: 100,
              padding: const EdgeInsets.all(20),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -10,
                    height: 150,
                    child: Image.asset('lib/assets/earth.png'),
                  ),
                  Positioned(
                    top: -120,
                    height: 200,
                    child: Image.asset('lib/assets/rocket.png'),
                  ),
                ],
              ),
            ),
            // White content section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Update Notice',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'For more features and a better\nuser experience, upgrade your\napp please.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // You can use `url_launcher` like:
                        // launchUrl(Uri.parse('https://your-app-store-link'));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFEF4444),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(
                            color: Color(0xFFEF4444),
                            width: 1,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Go to update',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
