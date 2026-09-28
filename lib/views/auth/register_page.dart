import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../home/home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeTerms = false;

  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  static const String _shoeImage =
      'https://images.unsplash.com/photo-1542291026-7eec264c27ff'
      '?auto=format&fit=crop&w=1200&q=85';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama tidak boleh kosong';
    }

    if (value.trim().length < 3) {
      return 'Nama minimal 3 karakter';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }

    final emailRegex = RegExp(
      r'^[\w.\-+]+@([\w-]+\.)+[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
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

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }

    if (value != _passwordController.text) {
      return 'Password tidak sama';
    }

    return null;
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _autovalidate = AutovalidateMode.onUserInteraction;
    });

    if (!_formKey.currentState!.validate()) return;

    if (!_agreeTerms) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Centang persetujuan syarat & ketentuan terlebih dahulu.',
            ),
            backgroundColor: AppColors.danger,
          ),
        );
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() => _isLoading = false);

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomePage(
          name: name,
          email: email,
        ),
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
                    child: _RegisterVisual(
                      imageUrl: _shoeImage,
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: _RegisterForm(
                      formKey: _formKey,
                      nameController: _nameController,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      confirmPasswordController:
                          _confirmPasswordController,
                      autovalidate: _autovalidate,
                      isLoading: _isLoading,
                      obscurePassword: _obscurePassword,
                      obscureConfirmPassword:
                          _obscureConfirmPassword,
                      agreeTerms: _agreeTerms,
                      onTogglePassword: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      onToggleConfirmPassword: () {
                        setState(() {
                          _obscureConfirmPassword =
                              !_obscureConfirmPassword;
                        });
                      },
                      onAgreeTerms: (value) {
                        setState(() {
                          _agreeTerms = value;
                        });
                      },
                      onRegister: _handleRegister,
                      onBack: () {
                        Navigator.of(context).pop();
                      },
                      validateName: _validateName,
                      validateEmail: _validateEmail,
                      validatePassword: _validatePassword,
                      validateConfirmPassword:
                          _validateConfirmPassword,
                    ),
                  ),
                ],
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                Navigator.of(context).pop();
                              },
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                        ),
                      ),
                      const Spacer(),
                      const _Logo(),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Container(
                    height: 190,
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E4DC),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Image.network(
                      _shoeImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return const Center(
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            size: 65,
                            color: Color(0xFF77736B),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 26),

                  _RegisterForm(
                    formKey: _formKey,
                    nameController: _nameController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    confirmPasswordController:
                        _confirmPasswordController,
                    autovalidate: _autovalidate,
                    isLoading: _isLoading,
                    obscurePassword: _obscurePassword,
                    obscureConfirmPassword:
                        _obscureConfirmPassword,
                    agreeTerms: _agreeTerms,
                    onTogglePassword: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    onToggleConfirmPassword: () {
                      setState(() {
                        _obscureConfirmPassword =
                            !_obscureConfirmPassword;
                      });
                    },
                    onAgreeTerms: (value) {
                      setState(() {
                        _agreeTerms = value;
                      });
                    },
                    onRegister: _handleRegister,
                    onBack: () {
                      Navigator.of(context).pop();
                    },
                    validateName: _validateName,
                    validateEmail: _validateEmail,
                    validatePassword: _validatePassword,
                    validateConfirmPassword:
                        _validateConfirmPassword,
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
// VISUAL
// ============================================================

class _RegisterVisual extends StatelessWidget {
  final String imageUrl;

  const _RegisterVisual({
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(18),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFE8E4DC),
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
                  Colors.black.withOpacity(0.05),
                  Colors.black.withOpacity(0.58),
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
              children: const [
                Text(
                  'FIND YOUR PAIR',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    letterSpacing: 2.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Create your\nSolea account.',
                  style: TextStyle(
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
// REGISTER FORM
// ============================================================

class _RegisterForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  final AutovalidateMode autovalidate;

  final bool isLoading;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final bool agreeTerms;

  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final ValueChanged<bool> onAgreeTerms;

  final VoidCallback onRegister;
  final VoidCallback onBack;

  final String? Function(String?) validateName;
  final String? Function(String?) validateEmail;
  final String? Function(String?) validatePassword;
  final String? Function(String?) validateConfirmPassword;

  const _RegisterForm({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.autovalidate,
    required this.isLoading,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.agreeTerms,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.onAgreeTerms,
    required this.onRegister,
    required this.onBack,
    required this.validateName,
    required this.validateEmail,
    required this.validatePassword,
    required this.validateConfirmPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 44,
          vertical: 30,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Form(
            key: formKey,
            autovalidateMode: autovalidate,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (MediaQuery.of(context).size.width >= 900) ...[
                  Row(
                    children: [
                      IconButton(
                        onPressed: isLoading ? null : onBack,
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 34,
                          minHeight: 34,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Back to sign in',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF77736B),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 20),

                const Text(
                  'Create account',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.2,
                    color: Color(0xFF111111),
                  ),
                ),

                const SizedBox(height: 9),

                const Text(
                  'Create your account and start discovering your next pair.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.55,
                    color: Color(0xFF77736B),
                  ),
                ),

                const SizedBox(height: 36),

                const _CleanLabel('Full name'),

                const SizedBox(height: 9),

                _RegisterTextField(
                  controller: nameController,
                  hintText: 'Your name',
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  validator: validateName,
                ),

                const SizedBox(height: 20),

                const _CleanLabel('Email'),

                const SizedBox(height: 9),

                _RegisterTextField(
                  controller: emailController,
                  hintText: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: validateEmail,
                ),

                const SizedBox(height: 20),

                const _CleanLabel('Password'),

                const SizedBox(height: 9),

                _RegisterTextField(
                  controller: passwordController,
                  hintText: 'Minimum 6 characters',
                  obscureText: obscurePassword,
                  textInputAction: TextInputAction.next,
                  validator: validatePassword,
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

                const SizedBox(height: 20),

                const _CleanLabel('Confirm password'),

                const SizedBox(height: 9),

                _RegisterTextField(
                  controller: confirmPasswordController,
                  hintText: 'Repeat your password',
                  obscureText: obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  validator: validateConfirmPassword,
                  suffix: IconButton(
                    onPressed: onToggleConfirmPassword,
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                    ),
                    color: const Color(0xFF77736B),
                  ),
                  onSubmitted: (_) {
                    if (!isLoading) onRegister();
                  },
                ),

                const SizedBox(height: 16),

                InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () {
                    onAgreeTerms(!agreeTerms);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: agreeTerms,
                            onChanged: (value) {
                              onAgreeTerms(value ?? false);
                            },
                            activeColor: Colors.black,
                            checkColor: Colors.white,
                            side: const BorderSide(
                              color: Color(0xFFBDB8AE),
                            ),
                          ),
                        ),
                        const SizedBox(width: 9),
                        const Expanded(
                          child: Text(
                            'I agree to the terms and conditions.',
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.45,
                              color: Color(0xFF77736B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onRegister,
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
                            'CREATE ACCOUNT',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF77736B),
                      ),
                    ),
                    TextButton(
                      onPressed: isLoading ? null : onBack,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.only(left: 5),
                      ),
                      child: const Text(
                        'Sign in',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
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
// COMMON WIDGET
// ============================================================

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

class _RegisterTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  final bool obscureText;
  final Widget? suffix;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;

  const _RegisterTextField({
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