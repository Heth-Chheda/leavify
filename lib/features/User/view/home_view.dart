import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevents popping back to login
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Hides the back button
          title: const Text('Home'),
        ),
        body: const Center(child: Text('Welcome to Home Screen!')),
      ),
    );
  }
}
