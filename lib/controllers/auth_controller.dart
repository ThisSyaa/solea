class AuthController {
  static String? currentName;
  static String? currentEmail;

  static bool login(
    String email,
    String password,
  ) {
    const demoEmail =
        'Syaaxi@gmail.com';
    const demoPassword =
        '123456';

    if (email.trim() == demoEmail &&
        password == demoPassword) {
      currentName = 'Syaaxi';
      currentEmail = demoEmail;
      return true;
    }

    return false;
  }

  static void register(
    String name,
    String email,
  ) {
    currentName =
        name.trim();
    currentEmail =
        email.trim();
  }

  static void updateProfile(
    String name,
    String email,
  ) {
    currentName =
        name.trim();
    currentEmail =
        email.trim();
  }

  static void logout() {
    currentName = null;
    currentEmail = null;
  }
}