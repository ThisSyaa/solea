import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../core/app_theme.dart';
import '../home/home_page.dart';
import 'register_page.dart';
import '../../core/auth_feedback_dialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  static const String _shoeImage =
      'https://images.unsplash.com/photo-1542291026-7eec264c27ff'
      '?auto=format&fit=crop&w=1200&q=85';

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateIdentifier(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email atau username tidak boleh kosong';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }

    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }

    return null;
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await Future.delayed(
      const Duration(milliseconds: 350),
    );

    if (!mounted) return;

    final success = AuthController.login(
      _identifierController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomePage(
            name: AuthController.currentName!,
            email: AuthController.currentEmail!,
          ),
        ),
      );

      return;
    }

    await showAuthFeedbackDialog(
      context: context,
      type: AuthFeedbackType.error,
      title: 'Belum bisa masuk',
      message:
          'Email, username, atau password belum sesuai. '
          'Coba periksa kembali informasi akunmu.',
      primaryLabel: 'Coba lagi',
      secondaryLabel: 'Tutup',
    );
  }

  void _showForgotPassword() {
  showAuthFeedbackDialog(
    context: context,
    type: AuthFeedbackType.info,
    title: 'Fitur segera hadir',
    message:
        'Fitur lupa password belum tersedia pada versi '
        'SOLEA saat ini.',
    primaryLabel: 'Oke, mengerti',
  );
}

  void _openRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const RegisterPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;

            if (isDesktop) {
              return Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: _ShoeVisual(
                      imageUrl: _shoeImage,
                      eyebrow: 'NEW COLLECTION',
                      title: 'Step into\nsomething new.',
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: _LoginForm(
                      formKey: _formKey,
                      identifierController: _identifierController,
                      passwordController: _passwordController,
                      isLoading: _isLoading,
                      obscurePassword: _obscurePassword,
                      rememberMe: _rememberMe,
                      onTogglePassword: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      onRememberChanged: (value) {
                        setState(() {
                          _rememberMe = value;
                        });
                      },
                      onForgotPassword: _showForgotPassword,
                      onLogin: _handleLogin,
                      onRegister: _openRegister,
                      validateIdentifier: _validateIdentifier,
                      validatePassword: _validatePassword,
                    ),
                  ),
                ],
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
              child: Column(
                children: [
                  const _MobileLogo(),
                  const SizedBox(height: 18),
                  _MobileShoeImage(imageUrl: _shoeImage),
                  const SizedBox(height: 26),
                  _LoginForm(
                    formKey: _formKey,
                    identifierController: _identifierController,
                    passwordController: _passwordController,
                    isLoading: _isLoading,
                    obscurePassword: _obscurePassword,
                    rememberMe: _rememberMe,
                    onTogglePassword: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    onRememberChanged: (value) {
                      setState(() {
                        _rememberMe = value;
                      });
                    },
                    onForgotPassword: _showForgotPassword,
                    onLogin: _handleLogin,
                    onRegister: _openRegister,
                    validateIdentifier: _validateIdentifier,
                    validatePassword: _validatePassword,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// DESKTOP VISUAL PANEL
// ============================================================

class _ShoeVisual extends StatelessWidget {
  final String imageUrl;
  final String eyebrow;
  final String title;

  const _ShoeVisual({
    required this.imageUrl,
    required this.eyebrow,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(18),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFE9E5DD),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return const Center(
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 80,
                  color: Color(0xFF77736B),
                ),
              );
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.08),
                  Colors.black.withOpacity(0.55),
                ],
              ),
            ),
          ),
          Positioned(
            top: 34,
            left: 36,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.directions_run_rounded,
                    size: 19,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 11),
                const Text(
                  'SOLEA',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    letterSpacing: 2.2,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 36,
            right: 36,
            bottom: 38,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    letterSpacing: 2.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    height: 1.03,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LOGIN FORM
// ============================================================

class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController identifierController;
  final TextEditingController passwordController;
  final bool isLoading;
  final bool obscurePassword;
  final bool rememberMe;

  final VoidCallback onTogglePassword;
  final ValueChanged<bool> onRememberChanged;
  final VoidCallback onForgotPassword;
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  final String? Function(String?) validateIdentifier;
  final String? Function(String?) validatePassword;

  const _LoginForm({
    required this.formKey,
    required this.identifierController,
    required this.passwordController,
    required this.isLoading,
    required this.obscurePassword,
    required this.rememberMe,
    required this.onTogglePassword,
    required this.onRememberChanged,
    required this.onForgotPassword,
    required this.onLogin,
    required this.onRegister,
    required this.validateIdentifier,
    required this.validatePassword,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 44,
          vertical: 32,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _DesktopMiniLogo(),
                const SizedBox(height: 58),
                const Text(
                  'Welcome back',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.2,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 9),
                const Text(
                  'Sign in to continue shopping your favorite sneakers.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.55,
                    color: Color(0xFF77736B),
                  ),
                ),
                const SizedBox(height: 38),
                const _CleanLabel('Email atau Username'),
                const SizedBox(height: 9),
                _CleanTextField(
                  controller: identifierController,
                  hintText: 'Masukkan email atau username',
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  validator: validateIdentifier,
                ),
                const SizedBox(height: 23),
                const _CleanLabel('Password'),
                const SizedBox(height: 9),
                _CleanTextField(
                  controller: passwordController,
                  hintText: 'Enter your password',
                  obscureText: obscurePassword,
                  textInputAction: TextInputAction.done,
                  validator: validatePassword,
                  onSubmitted: (_) {
                    if (!isLoading) onLogin();
                  },
                  suffix: IconButton(
                    onPressed: onTogglePassword,
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                    ),
                    color: const Color(0xFF77736B),
                  ),
                ),
                const SizedBox(height: 11),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: rememberMe,
                            onChanged: (value) {
                              onRememberChanged(value ?? false);
                            },
                            side: const BorderSide(
                              color: Color(0xFFBDB8AE),
                            ),
                            activeColor: Colors.black,
                            checkColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Remember me',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF66625C),
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: onForgotPassword,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 36),
                        foregroundColor: Colors.black,
                      ),
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.black,
                      disabledForegroundColor: Colors.white70,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 21,
                            height: 21,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'SIGN IN',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.3,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    const Expanded(
                      child: Divider(color: Color(0xFFE0DDD6)),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFA19C93),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(color: Color(0xFFE0DDD6)),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF77736B),
                      ),
                    ),
                    TextButton(
                      onPressed: isLoading ? null : onRegister,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.only(left: 5),
                      ),
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFEEE9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Demo account  •  syaaxi / Syaaxi@gmail.com  •  123456',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF77736B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// COMMON WIDGETS
// ============================================================

class _MobileLogo extends StatelessWidget {
  const _MobileLogo();

  @override
  Widget build(BuildContext context) {
    return const _Logo();
  }
}

class _DesktopMiniLogo extends StatelessWidget {
  const _DesktopMiniLogo();

  @override
  Widget build(BuildContext context) {
    return const _Logo();
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(
            Icons.directions_run_rounded,
            size: 18,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'SOLEA',
          style: TextStyle(
            fontSize: 17,
            letterSpacing: 2.2,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class _MobileShoeImage extends StatelessWidget {
  final String imageUrl;

  const _MobileShoeImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 215,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFE8E4DC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return const Center(
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 70,
              color: Color(0xFF77736B),
            ),
          );
        },
      ),
    );
  }
}

class _CleanLabel extends StatelessWidget {
  final String text;

  const _CleanLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1C1C1C),
      ),
    );
  }
}

class _CleanTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final Widget? suffix;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;

  const _CleanTextField({
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 14,
          color: Color(0xFFA09B92),
        ),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color(0xFFD8D4CC),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color(0xFFD8D4CC),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.black,
            width: 1.3,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.danger,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.danger,
            width: 1.2,
          ),
        ),
      ),
    );
  }
}