// force_update_checker.dart
import 'package:flutter/material.dart';
import 'package:leavify/features/Authentication/data/authentication_repository.dart';
import 'package:leavify/router/app_navigator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdateWrapper extends StatefulWidget {
  final Widget child;

  const ForceUpdateWrapper({super.key, required this.child});

  static _ForceUpdateWrapperState? of(BuildContext context) {
    return context.findAncestorStateOfType<_ForceUpdateWrapperState>();
  }

  @override
  State<ForceUpdateWrapper> createState() => _ForceUpdateWrapperState();
}

class _ForceUpdateWrapperState extends State<ForceUpdateWrapper> {
  bool _hasCheckedForUpdate = false;
  bool _isUpdateRequired = false;

  bool get isUpdateRequired => _isUpdateRequired;

  /// Called by SplashScreen before navigation
  Future<bool> checkForUpdate() async {
    if (_hasCheckedForUpdate) {
      debugPrint("⚠️ [ForceUpdate] Returning cached result: $_isUpdateRequired");
      return _isUpdateRequired;
    }

    _hasCheckedForUpdate = true;
    debugPrint("🔍 [ForceUpdate] Starting version check...");

    try {
      final info = await PackageInfo.fromPlatform();
      final currentVersion = info.version;
      debugPrint("📱 [ForceUpdate] Current App Version: $currentVersion");

      final repo = AuthenticationRepository();
      debugPrint("🌐 [ForceUpdate] Calling version API...");
      final response = await repo.getVersionInfo();

      final requiredVersion = response.version;
      debugPrint("📝 [ForceUpdate] Server Minimum Version: $requiredVersion");

      _isUpdateRequired = _isVersionOutdated(currentVersion, requiredVersion);
      debugPrint("🔎 [ForceUpdate] Outdated? → $_isUpdateRequired");

      if (_isUpdateRequired) {
        debugPrint("🚫 [ForceUpdate] Update required - blocking navigation");
        // Show dialog after a short delay to ensure Navigator is ready
        Future.delayed(const Duration(milliseconds: 300), () {
          _showForceUpdateDialog();
        });
      } else {
        debugPrint("✅ [ForceUpdate] Version is OK");
      }

      return _isUpdateRequired;
    } catch (e) {
      debugPrint("⚠️ [ForceUpdate] Version check failed: $e");
      // On error, allow navigation (fail open)
      return false;
    }
  }

  bool _isVersionOutdated(String current, String required) {
    final c = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final r = required.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    while (c.length < r.length) c.add(0);
    while (r.length < c.length) r.add(0);

    for (int i = 0; i < r.length; i++) {
      if (c[i] < r[i]) return true;
      if (c[i] > r[i]) return false;
    }
    return false;
  }

  Future<void> _showForceUpdateDialog() async {
    final context = AppNavigator.navigatorKey.currentContext;
    if (context == null) {
      debugPrint("⚠️ [ForceUpdate] Navigator context not available yet");
      return;
    }

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: const UpdateDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}


/// UI for the forced update dialog
class UpdateDialog extends StatelessWidget {
  const UpdateDialog({super.key});

  Future<void> _openStore() async {
    try {
      if (Platform.isAndroid) {
        // Replace with your app's package name
        final Uri playStoreUri = Uri.parse('market://details?id=com.yourcompany.leavify');
        final Uri playStoreWebUri = Uri.parse('https://play.google.com/store/apps/details?id=com.yourcompany.leavify');

        if (await canLaunchUrl(playStoreUri)) {
          await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
        } else {
          await launchUrl(playStoreWebUri, mode: LaunchMode.externalApplication);
        }
      } else if (Platform.isIOS) {
        // Replace with your app's App Store ID
        final Uri appStoreUri = Uri.parse('https://apps.apple.com/app/idYOUR_APP_ID');
        await launchUrl(appStoreUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('❌ [ForceUpdate] Failed to open store: $e');
    }
  }

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
              Colors.blueAccent,
              Colors.lightBlueAccent,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top illustration
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

            // Content section
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
                    'Update Required',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'A new version of the app is available.\nPlease update to continue using Leavify.',
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
                      onPressed: _openStore,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Update Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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