
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthController {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  static String? currentName;
  static String? currentUsername;
  static String? currentEmail;

  // Dipakai RegisterPage untuk menentukan pesan sukses.
  static bool lastVerificationEmailSent = false;

  static User? get firebaseUser => _auth.currentUser;
  // =========================================================
  // MEMPERBARUI NAMA PROFIL FIREBASE
  // =========================================================

  static Future<String?> updateFirebaseProfile({
    required String name,
  }) async {
    final cleanName = name.trim();

    if (cleanName.length < 3) {
      return 'Nama minimal 3 karakter.';
    }

    final user = _auth.currentUser;

    if (user == null) {
      return 'Sesi login tidak ditemukan. Silakan login kembali.';
    }

    if (!user.emailVerified) {
      return 'Verifikasi email terlebih dahulu.';
    }

    try {
      // Simpan nama baru ke dokumen users/{uid} di Firestore.
      await _db.collection('users').doc(user.uid).update({
        'name': cleanName,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Selaraskan nama profil Firebase Authentication.
      // Firestore tetap menjadi sumber utama nama profil SOLEA.
      try {
        await user.updateDisplayName(cleanName);
      } on FirebaseAuthException {
        // Kegagalan sinkronisasi display name tidak membatalkan
        // penyimpanan nama yang sudah berhasil di Firestore.
      }

      currentName = cleanName;
      currentEmail = user.email;

      return null;
    } on FirebaseAuthException catch (e) {
      return _authErrorMessage(e);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return 'Perubahan nama ditolak Firestore Rules. '
            'Pastikan kamu sudah login, email terverifikasi, '
            'dan aturan update mengizinkan field name serta updatedAt.';
      }

      if (e.code == 'not-found') {
        return 'Dokumen profil tidak ditemukan di Firestore.';
      }

      return 'Gagal menyimpan nama ke Firestore (${e.code}).';
    } catch (_) {
      return 'Terjadi kesalahan saat menyimpan profil. Coba lagi.';
    }
  }

  static String? get currentUid => _auth.currentUser?.uid;

  static Stream<User?> get authStateChanges =>
      _auth.authStateChanges();

  static void _clearSession() {
    currentName = null;
    currentUsername = null;
    currentEmail = null;
  }

  static String _emailKey(String email) =>
      email.trim().toLowerCase();

  static String _usernameKey(String username) =>
      username.trim().toLowerCase();

  static Future<String?> registerWithFirebase({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    lastVerificationEmailSent = false;

    final cleanName = name.trim();
    final cleanUsername = username.trim();
    final cleanEmail = email.trim();
    final usernameLower = _usernameKey(cleanUsername);

    if (cleanName.length < 3) {
      return 'Nama minimal 3 karakter.';
    }

    if (!RegExp(r'^[a-zA-Z0-9._]{3,20}$')
        .hasMatch(cleanUsername)) {
      return 'Username harus 3–20 karakter dan hanya boleh berisi huruf, angka, titik, atau underscore.';
    }

    if (!RegExp(r'^[\w.\-+]+@([\w-]+\.)+[a-zA-Z]{2,}$')
        .hasMatch(cleanEmail)) {
      return 'Format email tidak valid.';
    }

    if (password.length < 6) {
      return 'Password minimal 6 karakter.';
    }

    User? newUser;
    bool profileSaved = false;

    try {
      // Buat akun Firebase Authentication.
      final credential =
          await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      newUser = credential.user;

      if (newUser == null) {
        await _auth.signOut();
        return 'Akun gagal dibuat. Silakan coba lagi.';
      }

      await newUser.updateDisplayName(cleanName);

      final userRef =
          _db.collection('users').doc(newUser.uid);

      final usernameRef =
          _db.collection('usernames').doc(usernameLower);

      // Kedua dokumen ditulis secara atomik.
      final batch = _db.batch();

      batch.set(userRef, {
        'uid': newUser.uid,
        'name': cleanName,
        'username': cleanUsername,
        'usernameLower': usernameLower,
        'email': cleanEmail,
        'createdAt': FieldValue.serverTimestamp(),
      });

      batch.set(usernameRef, {
        'uid': newUser.uid,
        'username': cleanUsername,
        'usernameLower': usernameLower,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      profileSaved = true;

      try {
        await newUser.sendEmailVerification();
        lastVerificationEmailSent = true;
      } on FirebaseAuthException {
        lastVerificationEmailSent = false;
      }

      await _auth.signOut();
      _clearSession();

      return null;
    } on FirebaseAuthException catch (e) {
      // Akun yang gagal menyelesaikan proses profil dicoba
      // untuk dihapus. Jika penghapusan gagal, akun mungkin
      // perlu diperiksa melalui Firebase Console.
      if (newUser != null && !profileSaved) {
        try {
          await newUser.delete();
        } catch (_) {}
      }

      try {
        await _auth.signOut();
      } catch (_) {}

      _clearSession();

      return _authErrorMessage(e);
    } on FirebaseException catch (e) {
      if (newUser != null && !profileSaved) {
        try {
          await newUser.delete();
        } catch (_) {}
      }

      try {
        await _auth.signOut();
      } catch (_) {}

      _clearSession();

      if (e.code == 'permission-denied') {
        return 'Firestore menolak penyimpanan profil. Periksa Rules dan pastikan username belum digunakan.';
      }

      return 'Gagal menyimpan profil ke Firestore (${e.code}).';
    } catch (_) {
      if (newUser != null && !profileSaved) {
        try {
          await newUser.delete();
        } catch (_) {}
      }

      try {
        await _auth.signOut();
      } catch (_) {}

      _clearSession();

      return 'Terjadi kesalahan saat membuat akun. Coba lagi.';
    }
  }

  // =========================================================
  // LOGIN FIREBASE
  // Email + password; email belum terverifikasi ditolak.
  // =========================================================

  static Future<String?> loginWithFirebase({
    required String email,
    required String password,
  }) async {
    try {
      final credential =
          await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        await _auth.signOut();
        _clearSession();
        return 'Login gagal. Silakan coba lagi.';
      }

      // Ambil status email terverifikasi yang terbaru.
      await user.reload();

      final refreshedUser = _auth.currentUser;

      if (refreshedUser == null) {
        _clearSession();
        return 'Sesi login berakhir. Silakan coba lagi.';
      }

      await refreshedUser.getIdToken(true);

      if (!refreshedUser.emailVerified) {
        var resendSucceeded = false;

        try {
          await refreshedUser.sendEmailVerification();
          resendSucceeded = true;
        } on FirebaseAuthException {
          resendSucceeded = false;
        }

        await _auth.signOut();
        _clearSession();

        if (resendSucceeded) {
          return 'EMAIL_BELUM_DIVERIFIKASI: Kami sudah mengirim ulang tautan verifikasi ke emailmu. Buka email tersebut, klik tautannya, lalu login kembali.';
        }

        return 'EMAIL_BELUM_DIVERIFIKASI: Email belum terverifikasi dan tautan verifikasi gagal dikirim. Coba lagi nanti.';
      }

      // Jangan masuk Home jika profil belum bisa dimuat.
      await loadFirebaseProfile();

      return null;
    } on FirebaseAuthException catch (e) {
      try {
        await _auth.signOut();
      } catch (_) {}

      _clearSession();
      return _authErrorMessage(e);
    } on FirebaseException catch (e) {
      _clearSession();

      if (e.code == 'permission-denied') {
        return 'Akses profil ditolak oleh Firestore Rules. Pastikan email terverifikasi dan Rules sudah benar.';
      }

      return 'Gagal memuat profil (${e.code}). Coba lagi.';
    } catch (_) {
      _clearSession();
      return 'Tidak dapat terhubung ke layanan. Periksa internetmu.';
    }
  }

  // =========================================================
  // MEMUAT PROFIL DARI FIRESTORE
  // =========================================================

  static Future<void> loadFirebaseProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      _clearSession();
      return;
    }

    if (!user.emailVerified) {
      throw FirebaseAuthException(
        code: 'email-not-verified',
        message: 'Email belum diverifikasi.',
      );
    }

    final snapshot =
        await _db.collection('users').doc(user.uid).get();

    final data = snapshot.data();

    if (!snapshot.exists || data == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'profile-not-found',
        message: 'Dokumen profil pengguna tidak ditemukan.',
      );
    }

    currentName =
        data['name'] as String? ??
        user.displayName ??
        'Pengguna SOLEA';

    currentUsername = data['username'] as String?;
    currentEmail = user.email;
  }

  // =========================================================
  // LUPA PASSWORD
  // =========================================================

  static Future<String?> sendFirebasePasswordResetEmail(
    String email,
  ) async {
    if (email.trim().isEmpty) {
      return 'Masukkan email terlebih dahulu.';
    }

    try {
      await _auth.sendPasswordResetEmail(
        email: email.trim(),
      );

      return null;
    } on FirebaseAuthException catch (e) {
      return _authErrorMessage(e);
    } catch (_) {
      return 'Gagal mengirim email reset password.';
    }
  }

  // =========================================================
  // GANTI PASSWORD
  // =========================================================

  static Future<String?> changeFirebasePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;

    if (user == null || user.email == null) {
      return 'Silakan login terlebih dahulu.';
    }

    if (!user.emailVerified) {
      return 'Verifikasi email terlebih dahulu.';
    }

    if (oldPassword.isEmpty || newPassword.isEmpty) {
      return 'Semua kolom password wajib diisi.';
    }

    if (newPassword.length < 6) {
      return 'Password baru minimal 6 karakter.';
    }

    if (oldPassword == newPassword) {
      return 'Password baru harus berbeda dari password lama.';
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      return null;
    } on FirebaseAuthException catch (e) {
      return _authErrorMessage(e);
    } catch (_) {
      return 'Gagal mengubah password.';
    }
  }

  // =========================================================
  // LOGOUT FIREBASE
  // =========================================================

  static Future<void> logoutFromFirebase() async {
    _clearSession();
    await _auth.signOut();
  }

  // Kompatibilitas untuk halaman lama yang memanggil logout().
  static Future<void> logout() => logoutFromFirebase();

  // =========================================================
  // PESAN ERROR FIREBASE AUTH
  // =========================================================

  static String _authErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email sudah terdaftar. Silakan login.';

      case 'invalid-email':
        return 'Format email tidak valid.';

      case 'weak-password':
        return 'Password terlalu lemah. Gunakan minimal 6 karakter.';

      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau password salah.';

      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan.';

      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';

      case 'network-request-failed':
        return 'Jaringan bermasalah. Periksa koneksi internetmu.';

      case 'requires-recent-login':
        return 'Silakan login ulang sebelum melakukan perubahan ini.';

      default:
        return 'Autentikasi gagal (${e.code}).';
    }
  }

  static final Map<String, Map<String, String>> _localAccounts = {
    'syaaxi@gmail.com': {
      'name': 'Syaaxi',
      'username': 'syaaxi',
      'email': 'Syaaxi@gmail.com',
      'password': '123456',
    },
  };

  static bool emailExists(String email) =>
      _localAccounts.containsKey(_emailKey(email));

  static bool usernameExists(String username) =>
      _localAccounts.values.any(
        (a) => _usernameKey(a['username'] ?? '') ==
            _usernameKey(username),
      );

  static bool login(String identifier, String password) {
    for (final account in _localAccounts.values) {
      if ((_emailKey(account['email'] ?? '') ==
                  _emailKey(identifier) ||
              _usernameKey(account['username'] ?? '') ==
                  _usernameKey(identifier)) &&
          account['password'] == password) {
        currentName = account['name'];
        currentUsername = account['username'];
        currentEmail = account['email'];
        return true;
      }
    }

    return false;
  }

  static String? register(
    String name,
    String email,
    String password, {
    String? username,
  }) {
    final cleanName = name.trim();
    final cleanEmail = email.trim();
    final cleanUsername = username?.trim().isNotEmpty == true
        ? username!.trim()
        : cleanName.toLowerCase().replaceAll(
              RegExp(r'[^a-z0-9._]'),
              '',
            );

    if (cleanName.length < 3) {
      return 'Nama minimal 3 karakter.';
    }

    if (!RegExp(r'^[\w.\-+]+@([\w-]+\.)+[a-zA-Z]{2,}$')
        .hasMatch(cleanEmail)) {
      return 'Format email tidak valid.';
    }

    if (password.length < 6) {
      return 'Password minimal 6 karakter.';
    }

    if (emailExists(cleanEmail)) {
      return 'Email sudah terdaftar.';
    }

    if (usernameExists(cleanUsername)) {
      return 'Username sudah digunakan.';
    }

    _localAccounts[_emailKey(cleanEmail)] = {
      'name': cleanName,
      'username': cleanUsername,
      'email': cleanEmail,
      'password': password,
    };

    currentName = cleanName;
    currentUsername = cleanUsername;
    currentEmail = cleanEmail;

    return null;
  }

  static String? updateProfile(String name, String email) {
    final oldKey = _emailKey(currentEmail ?? '');
    final newKey = _emailKey(email);
    final account = _localAccounts[oldKey];

    if (account == null) {
      return 'Profil Firebase belum diintegrasikan ke halaman ini.';
    }

    if (newKey != oldKey && _localAccounts.containsKey(newKey)) {
      return 'Email sudah digunakan akun lain.';
    }

    if (name.trim().length < 3) {
      return 'Nama minimal 3 karakter.';
    }

    _localAccounts.remove(oldKey);

    account['name'] = name.trim();
    account['email'] = email.trim();

    _localAccounts[newKey] = account;

    currentName = account['name'];
    currentEmail = account['email'];
    currentUsername = account['username'];

    return null;
  }
}
