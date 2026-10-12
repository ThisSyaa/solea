
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../core/app_theme.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  final List<String> _subjects = const [
    'Pesanan',
    'Produk',
    'Pembayaran',
    'Akun',
    'Lainnya',
  ];

  String _subject = 'Pesanan';
  bool _isSending = false;

  @override
  void initState() {
    super.initState();

    _nameController.text =
        AuthController.currentName ?? '';

    _emailController.text =
        AuthController.currentEmail ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _submitMessage() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final user = AuthController.firebaseUser;

    if (user == null || !user.emailVerified) {
      _showMessage(
        'Silakan login dengan email terverifikasi terlebih dahulu.',
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('supportMessages')
          .add({
        'uid': user.uid,
        'name': _nameController.text.trim(),
        'email': user.email ?? '',
        'subject': _subject,
        'message': _messageController.text.trim(),
        'status': 'new',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      _messageController.clear();

      setState(() {
        _isSending = false;
      });

      _showMessage(
        'Pesan berhasil dicatat. Terima kasih sudah menghubungi SOLEA.',
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;

      setState(() {
        _isSending = false;
      });

      _showMessage(
        e.code == 'permission-denied'
            ? 'Pengiriman ditolak oleh Firestore Rules. Periksa aturan supportMessages.'
            : 'Pesan gagal disimpan (${e.code}). Coba lagi.',
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isSending = false;
      });

      _showMessage(
        'Terjadi kesalahan. Periksa koneksi lalu coba lagi.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand,
      appBar: AppBar(
        backgroundColor: AppColors.sand,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Contact SOLEA',
          style: TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding =
              constraints.maxWidth < 600 ? 18.0 : 28.0;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              18,
              horizontalPadding,
              36,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 700,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.forest,
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: const Icon(
                        Icons.mark_email_unread_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Ada yang bisa kami bantu?',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.7,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Kirim pertanyaan atau sampaikan kendala '
                      'yang kamu alami saat menggunakan SOLEA.',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 14,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.line,
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Kirim pesan',
                              style: TextStyle(
                                color: AppColors.ink,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 22),

                            const FieldLabel('Nama'),
                            TextFormField(
                              controller: _nameController,
                              textCapitalization:
                                  TextCapitalization.words,
                              decoration: const InputDecoration(
                                hintText: 'Masukkan nama kamu',
                                prefixIcon: Icon(
                                  Icons.person_outline_rounded,
                                ),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.trim().length < 3) {
                                  return 'Nama minimal 3 karakter.';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 18),

                            const FieldLabel('Email akun'),
                            TextFormField(
                              controller: _emailController,
                              readOnly: true,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            const FieldLabel('Kategori pertanyaan'),
                            DropdownButtonFormField<String>(
                              value: _subject,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(
                                  Icons.topic_outlined,
                                ),
                              ),
                              items: _subjects.map((subject) {
                                return DropdownMenuItem<String>(
                                  value: subject,
                                  child: Text(subject),
                                );
                              }).toList(),
                              onChanged: _isSending
                                  ? null
                                  : (value) {
                                      if (value == null) return;

                                      setState(() {
                                        _subject = value;
                                      });
                                    },
                            ),

                            const SizedBox(height: 18),

                            const FieldLabel('Pesan'),
                            TextFormField(
                              controller: _messageController,
                              minLines: 5,
                              maxLines: 8,
                              maxLength: 2000,
                              textCapitalization:
                                  TextCapitalization.sentences,
                              decoration: const InputDecoration(
                                hintText:
                                    'Ceritakan pertanyaan atau kendalamu...',
                                alignLabelWithHint: true,
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.trim().length < 10) {
                                  return 'Pesan minimal 10 karakter.';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 14),

                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: _isSending
                                    ? null
                                    : _submitMessage,
                                icon: _isSending
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.send_rounded,
                                      ),
                                label: Text(
                                  _isSending
                                      ? 'Mengirim pesan...'
                                      : 'Kirim pesan',
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            const Text(
                              'Pesan tersimpan di sistem SOLEA. '
                              'Halaman ini belum mengirim email atau '
                              'notifikasi balasan secara otomatis.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 11,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
