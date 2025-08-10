import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:leavify/core/utils/components/custom_loading_screen.dart';
import 'package:leavify/core/utils/theme/app_colors.dart';
import 'package:leavify/features/Authentication/viewmodel/login_view_model.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late LoginViewModel _viewModel;

  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _viewModel = Provider.of<LoginViewModel>(context, listen: false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // MARK: MAIN BUILD SECTION
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
            return AnimatedPadding(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Stack(
                children: [
                  _buildBackground(),
                  SafeArea(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [const SizedBox(height: 10), _buildHeader()],
                      ),
                    ),
                  ),
                  _buildMainCard(isDark),
                  if (viewModel.isLoading) const CustomLoadingScreen(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // MARK: BACKGROUND
  Widget _buildBackground() {
    return Stack(
      children: [
        // Full-screen gradient background (always blue)
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0A0A1F), Color(0xFF203A74), Colors.black],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        // Wave texture overlays
        Positioned.fill(child: CustomPaint(painter: WaveTexturePainter())),
      ],
    );
  }

  // MARK: HEADER
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 10),
          width: 60, // increased size
          height: 60, // increased size
          child: ClipOval(
            child: Image.asset(
              'lib/assets/rite.jpeg',
              fit: BoxFit.cover, // makes sure image covers the circle nicely
              width: 80,
              height: 80,
            ),
          ),
        ),
      ],
    );
  }

  // MARK: MAIN CARD
  Widget _buildMainCard(bool isDark) {
    final notchDepth = 55.0;
    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main card with notch
          ClipPath(
            clipper: TopNotchClipper(),
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.80,
              ),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                // Add subtle shadow for light mode
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 50),
                    _buildEmailForm(isDark),
                    const SizedBox(height: 150),
                    _buildLoginButton(),
                    // const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
          // Floating lock icon
          Positioned(
            top: -notchDepth,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.5 : 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_person,
                  color: AppColors.highGreen,
                  size: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // MARK: EMAIL FORM
  Widget _buildEmailForm(bool isDark) {
    return Column(
      children: [
        _buildUsernameField(
          label: 'Email',
          hintText: 'Enter your email',
          prefixIcon: Icons.email_rounded,
          keyboardType: TextInputType.emailAddress,
          gradientColors: [AppColors.highlightBlue, AppColors.highlightTeal],
          isDark: isDark,
        ),
        const SizedBox(height: 25),
        _buildPasswordField(isDark),
      ],
    );
  }

  // MARK: USERNAME FIELD
  Widget _buildUsernameField({
    required String label,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    required List<Color> gradientColors,
    required bool isDark,
  }) {
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.2)
        : Colors.grey.withOpacity(0.3);

    return TextFormField(
      controller: _viewModel.usernameController,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.highlightBlue,
          fontWeight: FontWeight.w600,
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: textColor.withOpacity(0.5),
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(60),
          borderSide: BorderSide(color: borderColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(60),
          borderSide: BorderSide(color: borderColor, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(60),
          borderSide: BorderSide(color: AppColors.highlightBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
      ),
    );
  }

  // MARK: PASSWORD FIELD
  Widget _buildPasswordField(bool isDark) {
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.2)
        : Colors.grey.withOpacity(0.3);

    return TextFormField(
      controller: _viewModel.passwordController,
      onFieldSubmitted: (_) => _handleLogin(),
      obscureText: !_isPasswordVisible,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: TextStyle(
          color: AppColors.highlightBlue,
          fontWeight: FontWeight.w600,
        ),
        hintText: 'Enter your password',
        hintStyle: TextStyle(
          color: textColor.withOpacity(0.5),
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
            color: textColor.withOpacity(0.6),
            size: 22,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(60),
          borderSide: BorderSide(color: borderColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(60),
          borderSide: BorderSide(color: borderColor, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(60),
          borderSide: BorderSide(color: AppColors.highlightBlue, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
      ),
    );
  }

  // MARK: LOGIN BUTTON
  Widget _buildLoginButton() {
    return Consumer<LoginViewModel>(
      builder: (context, viewModel, child) {
        return SafeArea(
          bottom: true,
          top: false,
          child: Container(
            width: double.infinity,
            height: 65,
            decoration: const BoxDecoration(
              color: AppColors.highBlue,
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: viewModel.isLoading ? null : () => _handleLogin(),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Log in',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleLogin() {
    _viewModel.login(context);
  }
}

class TopNotchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const notchWidth = 180.0;
    const notchDepth = 60.0;

    final path = Path();
    path.moveTo(0, 0);

    // Calculate notch boundaries (centered)
    final leftNotchStart = (size.width - notchWidth) / 2;
    final rightNotchEnd = (size.width + notchWidth) / 2;
    final notchCenter = size.width / 2;

    path.lineTo(leftNotchStart, 0);

    // Ultra-smooth left curve into notch with very gentle control points
    path.quadraticBezierTo(
      leftNotchStart + notchWidth * 0.15, // very gentle control point
      notchDepth * 0.1, // shallow control for gradual curve
      notchCenter - notchWidth * 0.268,
      notchDepth * 0.38,
    );

    // Center curve (bottom of notch) for ultra-smooth transition - made smoother
    path.quadraticBezierTo(
      notchCenter,
      notchDepth * 1.05, // slightly deeper for smoother curve
      notchCenter + notchWidth * 0.268, // symmetric to left side
      notchDepth * 0.38, // symmetric to left side
    );

    // Ultra-smooth right curve out of notch - made symmetric to left
    path.quadraticBezierTo(
      rightNotchEnd - notchWidth * 0.15, // symmetric to left side
      notchDepth * 0.1, // symmetric shallow control
      rightNotchEnd,
      0,
    );

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class WaveTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.overlay;

    // Create multiple wave layers for texture
    _paintWaveLayer(
      canvas,
      size,
      paint,
      color: Colors.white.withOpacity(0.05),
      amplitude: 30,
      frequency: 0.02,
      phase: 0,
      yOffset: size.height * 0.1,
    );

    _paintWaveLayer(
      canvas,
      size,
      paint,
      color: Colors.white.withOpacity(0.08),
      amplitude: 45,
      frequency: 0.015,
      phase: math.pi / 3,
      yOffset: size.height * 0.3,
    );

    _paintWaveLayer(
      canvas,
      size,
      paint,
      color: Colors.blue.withOpacity(0.08),
      amplitude: 25,
      frequency: 0.025,
      phase: math.pi / 2,
      yOffset: size.height * 0.7,
    );

    _paintWaveLayer(
      canvas,
      size,
      paint,
      color: Colors.white.withOpacity(0.02),
      amplitude: 60,
      frequency: 0.01,
      phase: math.pi,
      yOffset: size.height * 0.8,
    );
  }

  void _paintWaveLayer(
    Canvas canvas,
    Size size,
    Paint paint, {
    required Color color,
    required double amplitude,
    required double frequency,
    required double phase,
    required double yOffset,
  }) {
    paint.color = color;

    final path = Path();
    path.moveTo(0, size.height);

    // Create wave points
    for (double x = 0; x <= size.width; x += 2) {
      final y = yOffset + amplitude * math.sin(frequency * x + phase);
      if (x == 0) {
        path.lineTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Close the path to fill the bottom area
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
