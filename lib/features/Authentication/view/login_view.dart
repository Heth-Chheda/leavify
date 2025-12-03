import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 1. Add this import
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

  final FocusNode _emailFocusNode = FocusNode();

  final List<String> emailDomains = [
    "ritetechnologies.net",
    "ritetechnologies.co.in"
  ];

  @override
  void initState() {
    super.initState();
    _viewModel = LoginViewModel();
    _viewModel.addListener(_onViewModelChanged);

    // 2. FORCE STATUS BAR TO BE VISIBLE
    // This handles cases where a Splash Screen might have hidden it.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _emailFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    _emailFocusNode.dispose();
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

  void _applyEmailDomain(String domain) {
    String currentText = _viewModel.usernameController.text;
    String newText;

    if (currentText.contains('@')) {
      final prefix = currentText.split('@')[0];
      newText = "$prefix@$domain";
    } else {
      newText = "$currentText@$domain";
    }

    setState(() {
      _viewModel.usernameController.text = newText;
      _viewModel.usernameController.selection = TextSelection.fromPosition(
        TextPosition(offset: newText.length),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool showSuggestionBar = _emailFocusNode.hasFocus;

    // 3. CONTROL STATUS BAR COLOR/BRIGHTNESS
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        // Make the status bar transparent so the image shows behind it
        statusBarColor: Colors.transparent,

        // Use Brightness.light for WHITE icons (if your bg is dark)
        // Use Brightness.dark for BLACK icons (if your bg is light)
        statusBarIconBrightness: Brightness.light,

        // For Android: match the brightness logic
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  children: <Widget>[
                    _buildTopBackgroundContainer(),
                    _buildLoginFormSection(),
                  ],
                ),
              ),
            ),
            if (showSuggestionBar)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: emailDomains.map((domain) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          elevation: 1,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => _applyEmailDomain(domain),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Text(
                                domain,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // MARK: - UI COMPONENTS (Unchanged)
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

  // ... Keep the rest of your widgets (_buildLightImage1, etc.) exactly as they were

  Widget _buildLightImage1() {
    return Positioned(
      left: 30,
      width: 80,
      height: 200,
      child: FadeInUp(
        duration: const Duration(seconds: 1),
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage('lib/assets/light-1.png')),
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
            image: DecorationImage(image: AssetImage('lib/assets/light-2.png')),
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
            image: DecorationImage(image: AssetImage('lib/assets/clock.png')),
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

  Widget _buildInputFieldsContainer() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1800),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color.fromRGBO(143, 148, 251, 1)),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(143, 148, 251, .2),
              blurRadius: 20.0,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            _buildEmailTextField(),
            _buildPasswordTextField()
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
          bottom: BorderSide(color: Color.fromRGBO(143, 148, 251, 1)),
        ),
      ),
      child: TextField(
        controller: _viewModel.usernameController,
        focusNode: _emailFocusNode,
        enabled: !_viewModel.isLoading,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Email: eg: abc@xyz.com",
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
        onTap: _viewModel.isLoading ? null : () => _viewModel.login(context),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: _viewModel.isLoading
                  ? [Colors.grey, Colors.grey.withOpacity(0.6)]
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
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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