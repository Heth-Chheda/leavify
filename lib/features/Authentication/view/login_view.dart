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

  final FocusNode _emailFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _viewModel = LoginViewModel();
    _viewModel.addListener(_onViewModelChanged);

    // 🔴 REMOVED: The listener that was auto-hiding the list is gone.
    // This allows the click to register properly.
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

  final List<String> emailDomains = [
    "ritetechnologies.net",
    "ritetechnologies.co.in"
  ];

  bool showDomainDropdown = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        // Added keyboard dismissal on drag to improve UX
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
          border: Border.all(color: const Color.fromRGBO(143, 148, 251, 1)),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(143, 148, 251, .2),
              blurRadius: 20.0,
              offset: Offset(0, 10),
            ),
          ],
        ),
        // Stack with clipBehavior: Clip.none allows drawing the dropdown
        // completely outside the box bounds.
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: <Widget>[
                _buildEmailTextField(),
                _buildPasswordTextField()
              ],
            ),

            // Dropdown Positioned ABOVE the input fields
            if (showDomainDropdown)
              Positioned(
                bottom: 135, // Pushes it upwards above the container
                left: 0,
                right: 0,
                child: Material(
                  elevation: 10,
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: const BoxConstraints(maxHeight: 150),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: emailDomains.length,
                      separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            _applyEmailDomain(emailDomains[index]);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12.0,
                              horizontal: 16.0,
                            ),
                            child: Text(
                              emailDomains[index],
                              style: const TextStyle(
                                fontSize: 16, // Slightly larger for easier tap
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _applyEmailDomain(String domain) {
    debugPrint("Selected Domain: $domain"); // Debug print to verify tap
    final text = _viewModel.usernameController.text;

    // Safety check
    if (!text.contains('@')) return;

    final prefix = text.split('@').first;
    final newEmail = "$prefix@$domain";

    setState(() {
      _viewModel.usernameController.text = newEmail;

      // Move cursor to end of text
      _viewModel.usernameController.selection = TextSelection.fromPosition(
        TextPosition(offset: newEmail.length),
      );

      // Close dropdown
      showDomainDropdown = false;
    });
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
        onChanged: (value) {
          final containsAt = value.contains('@');
          // Hide if the user manually types a full domain (optional logic)
          // For now, simple logic: Show if @ is present
          setState(() {
            showDomainDropdown = containsAt;
          });
        },
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