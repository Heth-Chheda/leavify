import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:leavify/features/Authentication/viewmodel/login_view_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late LoginViewModel _viewModel;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _viewModel = LoginViewModel();
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    setState(() {});
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildTopBackgroundContainer(),
            _buildLoginFormSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBackgroundContainer() {
    return Container(
      height: 400,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('lib/assets/background3.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: Stack(
        children: <Widget>[
          _buildLightImage1(),
          _buildLightImage2(),
          _buildClockImage(),
          _buildManLuggageSection(),
          _buildLoginTitle(),
        ],
      ),
    );
  }

  Widget _buildLightImage1() {
    return Positioned(
      left: 30,
      width: 80,
      height: 200,
      child: FadeInUp(
        duration: const Duration(seconds: 1),
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/assets/light-1.png'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLightImage2() {
    return Positioned(
      left: 140,
      width: 80,
      height: 150,
      child: FadeInUp(
        duration: const Duration(milliseconds: 1200),
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/assets/light-2.png'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClockImage() {
    return Positioned(
      right: 40,
      top: 40,
      width: 80,
      height: 150,
      child: FadeInUp(
        duration: const Duration(milliseconds: 1300),
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/assets/clock.png'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginTitle() {
    return Positioned(
      child: FadeInUp(
        duration: const Duration(milliseconds: 1600),
        child: Container(
          margin: const EdgeInsets.only(top: 100),
          child: const Center(
            child: Text(
              "Leavify",
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginFormSection() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        children: <Widget>[
          _buildInputFieldsContainer(),
          const SizedBox(height: 60),
          _buildLoginButton(),
        ],
      ),
    );
  }

  Widget _buildManLuggageSection() {
    return Positioned(
      right: 10,
      top: 200,
      width: 150,
      height: 200,
      child: FadeInUp(
        duration: const Duration(milliseconds: 1300),
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/assets/man-login.png'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputFieldsContainer() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1800),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color.fromRGBO(143, 148, 251, 1),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(143, 148, 251, .2),
              blurRadius: 20.0,
              offset: Offset(0, 10),
            )
          ],
        ),
        child: Column(
          children: <Widget>[
            _buildEmailTextField(),
            _buildPasswordTextField(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailTextField() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color.fromRGBO(143, 148, 251, 1),
          ),
        ),
      ),
      child: TextField(
        controller: _viewModel.usernameController,
        enabled: !_viewModel.isLoading,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Email or Phone number",
          hintStyle: TextStyle(color: Colors.grey[700]),
        ),
      ),
    );
  }

  Widget _buildPasswordTextField() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _viewModel.passwordController,
        enabled: !_viewModel.isLoading,
        obscureText: !_isPasswordVisible,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Password",
          hintStyle: TextStyle(color: Colors.grey[700]),
          suffixIcon: IconButton(
            onPressed: _togglePasswordVisibility,
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: const Color.fromRGBO(143, 148, 251, 1),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1900),
      child: GestureDetector(
        onTap: _viewModel.isLoading
            ? null
            : () => _viewModel.login(context),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: _viewModel.isLoading
                  ? [
                Colors.grey,
                Colors.grey.withOpacity(0.6),
              ]
                  : [
                const Color.fromRGBO(13, 71, 161, 1),
                const Color.fromRGBO(13, 71, 161, 0.6),
              ],
            ),
          ),
          child: Center(
            child: _viewModel.isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white,
                ),
              ),
            )
                : const Text(
              "Login",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}