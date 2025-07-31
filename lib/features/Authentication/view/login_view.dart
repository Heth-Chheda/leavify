import 'package:flutter/material.dart';
import 'package:leavify/core/utils/components/custom_loading_screen.dart';
import 'package:leavify/core/utils/theme/app_theme.dart'; // Import your theme file
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
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundPrimary,
        body: Stack(
          children: [
            // Enhanced gradient wave background
            _buildBackground(),
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    _buildHeader(),
                    const SizedBox(height: 40),
                    _buildMainCard(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            if (viewModel.isLoading) const CustomLoadingScreen(),
          ],
        ),
      ),
    );
  }

  // MARK: BACKGROUND
  Widget _buildBackground() {
    return Stack(
      children: [
        // Primary wave with blue gradient
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: ClipPath(
            clipper: EnhancedWaveClipper(),
            child: Container(
              height: 350,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: AppTheme.waveGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
        ),
        // Secondary overlay wave for depth with indigo/purple gradient
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: ClipPath(
            clipper: SecondaryWaveClipper(),
            child: Container(
              height: 320,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentIndigo.withOpacity(0.3),
                    AppTheme.accentPurple.withOpacity(0.3),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // MARK: HEADER
  Widget _buildHeader() {
    return Column(
      children: [
        // Enhanced logo with glassmorphism effect
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppTheme.logoGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppTheme.white.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: AppTheme.accentIndigo.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: -5,
              ),
            ],
            border: Border.all(
              color: AppTheme.white.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBlue.withOpacity(0.1),
                  AppTheme.primaryBlueDark.withOpacity(0.1),
                ],
              ),
            ),
            child: const Icon(
              Icons.eco_rounded,
              color: AppTheme.primaryBlueDark,
              size: 50,
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Enhanced app name with gradient text effect
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: AppTheme.logoGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            "Leavify",
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w800,
              color: AppTheme.white,
              letterSpacing: 2.0,
              fontFamily: 'Montserrat',
              shadows: [
                Shadow(
                  offset: Offset(0, 4),
                  blurRadius: 8,
                  color: AppTheme.shadowDark,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // MARK: MAIN CARD
  Widget _buildMainCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.backgroundSecondary,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 40,
              offset: const Offset(0, 20),
              spreadRadius: -5,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              _buildTabBar(),
              const SizedBox(height: 32),
              _buildLoginForm(),
              const SizedBox(height: 10),
              _buildForgotPassword(),
              _buildLoginButton(),
            ],
          ),
        ),
      ),
    );
  }

  // MARK: TAB BAR
  Widget _buildTabBar() {
    return Container(
      height: 65,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: AppTheme.borderLight, width: 1.5),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppTheme.secondaryGradient,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(29),
        ),
        labelColor: AppTheme.white,
        unselectedLabelColor: AppTheme.textMuted,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: AppTheme.transparent,
        tabs: const [
          Tab(text: 'Email'),
          Tab(text: 'Phone'),
        ],
      ),
    );
  }

  // MARK: LOGIN FORM
  Widget _buildLoginForm() {
    return SizedBox(
      height: 220,
      child: TabBarView(
        controller: _tabController,
        children: [_buildEmailForm(), _buildPhoneForm()],
      ),
    );
  }

  // MARK: EMAIL FORM
  Widget _buildEmailForm() {
    return Column(
      children: [
        _buildUsernameField(
          label: 'Email Address',
          hintText: 'Enter your email',
          prefixIcon: Icons.email_rounded,
          keyboardType: TextInputType.emailAddress,
          gradientColors: AppTheme.emailGradient,
        ),
        const SizedBox(height: 25),
        _buildPasswordField(),
      ],
    );
  }

  // MARK: PHONE FORM
  Widget _buildPhoneForm() {
    return Column(
      children: [
        _buildUsernameField(
          label: 'Phone Number',
          hintText: 'Enter your phone number',
          prefixIcon: Icons.phone_rounded,
          keyboardType: TextInputType.phone,
          gradientColors: AppTheme.phoneGradient,
        ),
        const SizedBox(height: 25),
        _buildPasswordField(),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppTheme.backgroundCard,
            border: Border.all(color: AppTheme.borderLight, width: 2),
          ),
          child: TextFormField(
            controller: _viewModel.usernameController,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: AppTheme.textHint,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(prefixIcon, color: AppTheme.white, size: 18),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // MARK: PASSWORD FIELD
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppTheme.backgroundCard,
            border: Border.all(color: AppTheme.borderLight, width: 2),
          ),
          child: TextFormField(
            controller: _viewModel.passwordController,
            obscureText: !_isPasswordVisible,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your password',
              hintStyle: const TextStyle(
                color: AppTheme.textHint,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppTheme.passwordGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: AppTheme.white,
                  size: 18,
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: AppTheme.textTertiary,
                  size: 22,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // MARK: FORGOT PASSWORD
  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // Handle forgot password
        },
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.accentViolet,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        child: const Text(
          'Forgot Password?',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  // MARK: LOGIN BUTTON
  Widget _buildLoginButton() {
    return Consumer<LoginViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          width: double.infinity,
          height: 65,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppTheme.buttonGradient,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.all(Radius.circular(25)),
          ),
          child: Material(
            color: AppTheme.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: viewModel.isLoading ? null : () => _handleLogin(),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: AppTheme.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sign In',
                        style: TextStyle(
                          color: AppTheme.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: AppTheme.white,
                        size: 20,
                      ),
                    ],
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

// Enhanced wave clipper with more curvy and realistic wave pattern
class EnhancedWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Start from top-left
    path.lineTo(0, size.height - 120);

    // Create multiple wave curves for more realistic and curvy wave effect
    var firstControlPoint = Offset(size.width * 0.15, size.height - 40);
    var firstEndPoint = Offset(size.width * 0.35, size.height - 80);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width * 0.55, size.height - 140);
    var secondEndPoint = Offset(size.width * 0.75, size.height - 60);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    var thirdControlPoint = Offset(size.width * 0.9, size.height - 20);
    var thirdEndPoint = Offset(size.width, size.height - 50);
    path.quadraticBezierTo(
      thirdControlPoint.dx,
      thirdControlPoint.dy,
      thirdEndPoint.dx,
      thirdEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Secondary wave for layered effect with more curves
class SecondaryWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, size.height - 90);

    // More control points for curvier waves
    var firstControlPoint = Offset(size.width * 0.2, size.height - 30);
    var firstEndPoint = Offset(size.width * 0.4, size.height - 70);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width * 0.6, size.height - 120);
    var secondEndPoint = Offset(size.width * 0.8, size.height - 40);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    var thirdControlPoint = Offset(size.width * 0.95, size.height - 10);
    var thirdEndPoint = Offset(size.width, size.height - 30);
    path.quadraticBezierTo(
      thirdControlPoint.dx,
      thirdControlPoint.dy,
      thirdEndPoint.dx,
      thirdEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
