import 'package:flutter/material.dart';
import 'package:leavify/app/router/app_navigator.dart';
import 'package:leavify/app/router/route_names.dart';
import 'package:leavify/core/utils/theme/app_colors.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    // 1. Prepare video
    _controller = VideoPlayerController.asset("lib/assets/splash.mp4")
      ..initialize().then((_) {
        setState(() {}); // refresh after init
        _controller.play();
        _controller.setVolume(0.0);
        _controller.setPlaybackSpeed(5.0);

        Future.delayed(_controller.value.duration, () {
          if (mounted) _navigateNext();
        });
      });
  }

  void _navigateNext() {
    if (!mounted) return;

    final routeName = RouteNames.login;

    AppNavigator.setRootView(routeName);
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
