import 'package:flutter/material.dart';
import 'package:leavify/core/storage/app_storage.dart';
import 'package:leavify/router/app_navigator.dart';
import 'package:leavify/router/route_names.dart';
import 'package:leavify/core/utils/theme/app_colors.dart';
import 'package:leavify/services/force_update_checker.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    // 1. Prepare video
    _controller = VideoPlayerController.asset("lib/assets/splash2.mp4")
      ..initialize().then((_) {
        setState(() {}); // refresh after init
        _controller.play();
        _controller.setVolume(0.0);
        _controller.setPlaybackSpeed(2.0);

        Future.delayed(
          _controller.value.duration - const Duration(seconds: 1),
              () {
            if (mounted) _navigateNext();
          },
        );
      });
  }

  Future<void> _navigateNext() async {
    if (!mounted || _hasNavigated) return;

    debugPrint("🚀 [Splash] Checking for force update before navigation...");

    // Check for force update BEFORE navigating
    final updateWrapper = ForceUpdateWrapper.of(context);
    if (updateWrapper != null) {
      final needsUpdate = await updateWrapper.checkForUpdate();

      if (needsUpdate) {
        debugPrint("🛑 [Splash] Update required - blocking navigation");
        _hasNavigated = true; // Mark as handled to prevent duplicate navigation
        return;
      }
    }

    // Only navigate if no update is required
    debugPrint("✅ [Splash] No update required - proceeding with navigation");
    _hasNavigated = true;

    final isLoggedIn =
        await AppStorage.getBoolean('USER_IS_ALREADY_LOGGED_IN') ?? false;
    debugPrint('User logged in: $isLoggedIn');
    final routeName = isLoggedIn ? RouteNames.home : RouteNames.login;

    if (mounted) {
      AppNavigator.setRootView(routeName);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: _controller.value.isInitialized
          ? SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.scaleDown, // full screen
          child: SizedBox(
            width: _controller.value.size.width,
            height: _controller.value.size.height,
            child: VideoPlayer(_controller),
          ),
        ),
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}