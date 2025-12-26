// force_update_checker.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:leavify/features/Authentication/data/authentication_repository.dart';
import 'package:leavify/router/app_navigator.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
  bool _isMaintenanceMode = false;
  bool get isMaintenanceMode => _isMaintenanceMode;

  bool get isUpdateRequired => _isUpdateRequired;

  /// Called by SplashScreen before navigation
  Future<bool> checkForUpdate() async {
    if (_hasCheckedForUpdate) {
      return _isUpdateRequired || _isMaintenanceMode;
    }

    _hasCheckedForUpdate = true;

    try {
      final info = await PackageInfo.fromPlatform();
      final currentVersion = info.version;

      final repo = AuthenticationRepository();
      final response = await repo.getVersionInfo();

      // Maintenance check FIRST
      _isMaintenanceMode = response.isMaintenanceMode;
      // _isMaintenanceMode = true;

      if (_isMaintenanceMode) {
        debugPrint("🚧 [ForceUpdate] Maintenance mode enabled");

        Future.delayed(const Duration(milliseconds: 300), () {
          _showMaintenanceDialog();
        });

        return true;
      }

      //  Existing update logic
      final requiredVersion = response.version;
      _isUpdateRequired = _isVersionOutdated(currentVersion, requiredVersion);

      if (_isUpdateRequired) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _showForceUpdateDialog();
        });
      }

      return _isUpdateRequired;
    } catch (e) {
      debugPrint("⚠️ [ForceUpdate] Version check failed: $e");
      return false; // Fail open
    }
  }

  Future<void> _showMaintenanceDialog() async {
    final context = AppNavigator.navigatorKey.currentContext;
    if (context == null) return;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(canPop: false, child: MaintenanceDialog()),
    );
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
      builder: (_) => PopScope(canPop: false, child: const UpdateDialog()),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class MaintenanceDialog extends StatelessWidget {
  const MaintenanceDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 290,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orangeAccent, Colors.deepOrangeAccent],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustration
            SizedBox(
              height: 100,
              child: Icon(Icons.build_circle, size: 80, color: Colors.white),
            ),

            // Content
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
                children: const [
                  Text(
                    'Maintenance in Progress',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Leavify is currently under maintenance.\nPlease try again later.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.4,
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

/// UI for the forced update dialog
class UpdateDialog extends StatelessWidget {
  const UpdateDialog({super.key});

  Future<void> _openStore() async {
    try {
      if (Platform.isAndroid) {
        // Replace with your app's package name
        final Uri playStoreUri = Uri.parse(
          'https://play.google.com/store/apps/details?id=com.ritetechnologies.leavify&pcampaignid=web_share',
        );
        final Uri playStoreWebUri = Uri.parse(
          'https://play.google.com/store/apps/details?id=com.ritetechnologies.leavify&hl=en',
        );

        if (await canLaunchUrl(playStoreUri)) {
          await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
        } else {
          await launchUrl(
            playStoreWebUri,
            mode: LaunchMode.externalApplication,
          );
        }
      } else if (Platform.isIOS) {
        // Replace with your app's App Store ID
        final Uri appStoreUri = Uri.parse(
          'https://apps.apple.com/in/app/leavify/id6753981242',
        );
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
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
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
