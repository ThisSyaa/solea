
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../views/auth/login_page.dart';
import '../views/home/home_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  StreamSubscription<User?>? _authSubscription;

  User? _user;

  bool _isChecking = true;
  bool _needsVerification = false;

  String? _error;

  int _requestId = 0;

  @override
  void initState() {
    super.initState();

    _authSubscription = AuthController.authStateChanges.listen(
      _handleAuthChanged,
      onError: (Object error) {
        if (!mounted) return;

        setState(() {
          _isChecking = false;
          _error = 'Gagal memeriksa sesi login. Silakan coba lagi.';
        });
      },
    );
  }

  Future<void> _handleAuthChanged(User? user) async {
    final requestId = ++_requestId;

    if (!mounted) return;

    if (user == null) {
      setState(() {
        _user = null;
        _isChecking = false;
        _needsVerification = false;
        _error = null;
      });
      return;
    }

    await _resolveUser(user, requestId);
  }

  Future<void> _resolveUser(
    User incomingUser, [
    int? existingRequestId,
  ]) async {
    final requestId = existingRequestId ?? ++_requestId;

    if (!mounted) return;

    setState(() {
      _isChecking = true;
      _error = null;
      _needsVerification = false;
    });

    try {
      // Muat ulang status terbaru dari Firebase.
      await incomingUser.reload();

      if (!mounted || requestId != _requestId) return;

      final user = AuthController.firebaseUser;

      if (user == null) {
        setState(() {
          _user = null;
          _isChecking = false;
        });
        return;
      }

      // Refresh token agar klaim email_verified terbaru digunakan.
      await user.getIdToken(true);

      if (!mounted || requestId != _requestId) return;

      if (!user.emailVerified) {
        // Jangan tampilkan Home bagi akun yang belum terverifikasi.
        setState(() {
          _user = user;
          _needsVerification = true;
          _isChecking = false;
        });
        return;
      }

      // Profil wajib tersedia sebelum pengguna masuk Home.
      await AuthController.loadFirebaseProfile();

      if (!mounted || requestId != _requestId) return;

      setState(() {
        _user = AuthController.firebaseUser;
        _isChecking = false;
        _needsVerification = false;
        _error = null;
      });
    } on FirebaseAuthException catch (e) {
      if (!mounted || requestId != _requestId) return;

      setState(() {
        _isChecking = false;
        _error = 'Gagal memeriksa akun (${e.code}).';
      });
    } catch (_) {
      if (!mounted || requestId != _requestId) return;

      setState(() {
        _isChecking = false;
        _error =
            'Profil tidak dapat dimuat. Periksa koneksi atau akses database.';
      });
    }
  }

  Future<void> _checkVerificationAgain() async {
    final user = AuthController.firebaseUser;

    if (user == null) {
      await AuthController.logoutFromFirebase();
      return;
    }

    await _resolveUser(user);
  }

  Future<void> _logout() async {
    await AuthController.logoutFromFirebase();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const _AuthLoadingScreen();
    }

    if (_error != null) {
      return _AuthErrorScreen(
        message: _error!,
        onRetry: () {
          final user = AuthController.firebaseUser;

          if (user == null) {
            setState(() {
              _error = null;
              _user = null;
            });
          } else {
            _resolveUser(user);
          }
        },
        onLogout: _logout,
        hasSession: AuthController.firebaseUser != null,
      );
    }

    if (_user != null && _needsVerification) {
      return _VerificationRequiredScreen(
        email: _user!.email ?? '',
        onCheck: _checkVerificationAgain,
        onLogout: _logout,
      );
    }

    if (_user != null) {
      return HomePage(
        name: AuthController.currentName ??
            _user!.displayName ??
            'Pengguna SOLEA',
        email: AuthController.currentEmail ??
            _user!.email ??
            '',
      );
    }

    return const LoginPage();
  }
}

class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF7F6F2),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 34,
              height: 34,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Menyiapkan SOLEA...',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF77736B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerificationRequiredScreen extends StatelessWidget {
  final String email;
  final Future<void> Function() onCheck;
  final Future<void> Function() onLogout;

  const _VerificationRequiredScreen({
    required this.email,
    required this.onCheck,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFECE8E0),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF0D8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mark_email_unread_outlined,
                      size: 36,
                      color: Color(0xFF9B7429),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Verifikasi email dulu',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF191919),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Akunmu belum dapat masuk ke SOLEA sebelum '
                    'alamat email terverifikasi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.6,
                      color: Color(0xFF77736B),
                    ),
                  ),
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      email,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        await onCheck();

                        if (context.mounted) {
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Status verifikasi sudah diperiksa.',
                                ),
                              ),
                            );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Saya sudah verifikasi'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () async {
                      await onLogout();
                    },
                    child: const Text(
                      'Kembali ke Login',
                      style: TextStyle(
                        color: Color(0xFF77736B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final Future<void> Function() onLogout;
  final bool hasSession;

  const _AuthErrorScreen({
    required this.message,
    required this.onRetry,
    required this.onLogout,
    required this.hasSession,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xFFECE8E0),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_outlined,
                    size: 44,
                    color: Color(0xFF77736B),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum bisa membuka SOLEA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.6,
                      color: Color(0xFF77736B),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: onRetry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Coba lagi'),
                    ),
                  ),
                  if (hasSession)
                    TextButton(
                      onPressed: () async {
                        await onLogout();
                      },
                      child: const Text('Logout'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
