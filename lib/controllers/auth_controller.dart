/// Autentikasi sementara untuk pengembangan SOLEA.
///
/// Akun yang didaftarkan tersimpan di memori dan hilang saat aplikasi
/// atau browser direstart. Bukan autentikasi untuk produksi.
class _LocalAccount {
  String name;
  String username;
  String email;
  String password;

  _LocalAccount({
    required this.name,
    required this.username,
    required this.email,
    required this.password,
  });
}

class AuthController {
  static String? currentName;
  static String? currentUsername;
  static String? currentEmail;
  static String? _currentAccountKey;

  // Akun demo lama tetap bisa dipakai.
  static final Map<String, _LocalAccount> _accounts = {
    'syaaxi@gmail.com': _LocalAccount(
      name: 'Syaaxi',
      username: 'syaaxi',
      email: 'Syaaxi@gmail.com',
      password: '123456',
    ),
  };

  static String _emailKey(String email) =>
      email.trim().toLowerCase();

  static String _usernameKey(String username) =>
      username.trim().toLowerCase();

  // Jika register dipanggil tanpa username, buat dari nama.
  // Ini juga menjaga kompatibilitas pemanggilan register lama.
  static String _usernameFromName(String name) {
    final cleaned = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9._]'), '');

    if (cleaned.length >= 3) {
      return cleaned.length > 20
          ? cleaned.substring(0, 20)
          : cleaned;
    }

    return 'user${_accounts.length + 1}';
  }

  static bool emailExists(String email) {
    return _accounts.containsKey(_emailKey(email));
  }

  static bool usernameExists(String username) {
    final key = _usernameKey(username);

    return _accounts.values.any(
      (account) => _usernameKey(account.username) == key,
    );
  }

  /// Login bisa memakai email ATAU username.
  static bool login(String identifier, String password) {
    final input = identifier.trim().toLowerCase();

    _LocalAccount? account;
    String? accountKey;

    for (final entry in _accounts.entries) {
      final candidate = entry.value;

      if (_emailKey(candidate.email) == input ||
          _usernameKey(candidate.username) == input) {
        account = candidate;
        accountKey = entry.key;
        break;
      }
    }

    if (account == null || account.password != password) {
      return false;
    }

    _currentAccountKey = accountKey;
    currentName = account.name;
    currentUsername = account.username;
    currentEmail = account.email;

    return true;
  }

  /// Membuat akun baru dan langsung mengaktifkan sesi.
  /// Mengembalikan null jika berhasil, atau pesan error jika gagal.
  ///
  /// Parameter username dibuat opsional agar pemanggilan register
  /// versi lama tetap kompatibel.
  static String? register(
    String name,
    String email,
    String password, {
    String? username,
  }) {
    final cleanName = name.trim();
    final providedUsername = username?.trim() ?? '';

    final cleanUsername = providedUsername.isNotEmpty
        ? providedUsername
        : _usernameFromName(cleanName);

    final cleanEmail = email.trim();

    final emailKey = _emailKey(cleanEmail);
    final usernameKey = _usernameKey(cleanUsername);

    if (cleanName.length < 3) {
      return 'Nama minimal 3 karakter.';
    }

    final usernameRegex = RegExp(r'^[a-zA-Z0-9._]{3,20}$');

    if (!usernameRegex.hasMatch(cleanUsername)) {
      return 'Username harus 3–20 karakter, hanya huruf, angka, titik, atau underscore.';
    }

    final emailRegex =
        RegExp(r'^[\w.\-+]+@([\w-]+\.)+[a-zA-Z]{2,}$');

    if (!emailRegex.hasMatch(cleanEmail)) {
      return 'Format email tidak valid.';
    }

    if (password.length < 6) {
      return 'Password minimal 6 karakter.';
    }

    if (_accounts.containsKey(emailKey)) {
      return 'Email sudah terdaftar. Gunakan email lain atau login.';
    }

    if (_accounts.values.any(
      (account) => _usernameKey(account.username) == usernameKey,
    )) {
      return 'Username sudah digunakan. Pilih username lain.';
    }

    final account = _LocalAccount(
      name: cleanName,
      username: cleanUsername,
      email: cleanEmail,
      password: password,
    );

    _accounts[emailKey] = account;

    _currentAccountKey = emailKey;
    currentName = account.name;
    currentUsername = account.username;
    currentEmail = account.email;

    return null;
  }

  /// Memperbarui nama dan email akun aktif.
  /// Username tidak berubah ketika profil diedit.
  static String? updateProfile(String name, String email) {
    final cleanName = name.trim();
    final cleanEmail = email.trim();

    final oldKey = _currentAccountKey;
    final newKey = _emailKey(cleanEmail);

    if (cleanName.length < 3) {
      return 'Nama minimal 3 karakter.';
    }

    final emailRegex =
        RegExp(r'^[\w.\-+]+@([\w-]+\.)+[a-zA-Z]{2,}$');

    if (!emailRegex.hasMatch(cleanEmail)) {
      return 'Format email tidak valid.';
    }

    if (oldKey == null || !_accounts.containsKey(oldKey)) {
      return 'Sesi akun tidak ditemukan. Silakan login kembali.';
    }

    if (newKey != oldKey && _accounts.containsKey(newKey)) {
      return 'Email sudah digunakan akun lain.';
    }

    final account = _accounts.remove(oldKey)!;

    account
      ..name = cleanName
      ..email = cleanEmail;

    _accounts[newKey] = account;

    _currentAccountKey = newKey;
    currentName = account.name;
    currentUsername = account.username;
    currentEmail = account.email;

    return null;
  }

  /// Mengakhiri sesi tanpa menghapus akun dari memori.
  static void logout() {
    currentName = null;
    currentUsername = null;
    currentEmail = null;
    _currentAccountKey = null;
  }
}