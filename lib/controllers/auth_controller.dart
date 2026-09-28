class AuthController {
  static const String demoEmail = 'Syaaxi@gmail.com';
  static const String demoPassword = '123456';
  static const String demoName = 'Syaaxi';

  bool login({required String email, required String password}) {
    return email.trim() == demoEmail && password == demoPassword;
  }

  Future<void> simulateRequest() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await simulateRequest();
    return name.trim().isNotEmpty &&
        email.trim().isNotEmpty &&
        password.isNotEmpty;
  }
}
