
import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../core/app_theme.dart';
import '../../core/home_button.dart';

class PersonalInfoPage extends StatefulWidget {
  final String name;
  final String email;

  const PersonalInfoPage({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  State<PersonalInfoPage> createState() =>
      _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final error = await AuthController.updateFirebaseProfile(
      name: _nameController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error),
            behavior: SnackBarBehavior.floating,
          ),
        );

      return;
    }

    // Kembalikan data terbaru ke ProfilePage.
    Navigator.pop(
      context,
      {
        'name': AuthController.currentName ??
            _nameController.text.trim(),
        'email': AuthController.currentEmail ??
            widget.email,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand,
      appBar: AppBar(
        backgroundColor: AppColors.sand,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Informasi Pribadi',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: const [
          HomeButton(),
          SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          30,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 620,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 45,
                          backgroundColor: Color(0xFFE8E4DA),
                          backgroundImage: NetworkImage(
                            'https://avatars.githubusercontent.com/u/174694675?v=4',
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Nama bisa diedit dan disimpan ke Firestore.
                        TextFormField(
                          controller: _nameController,
                          textCapitalization:
                              TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Nama',
                            prefixIcon: Icon(
                              Icons.person_outline_rounded,
                            ),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Nama wajib diisi';
                            }

                            if (value.trim().length < 3) {
                              return 'Nama minimal 3 karakter';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 15),

                        // Email mengikuti Firebase Authentication.
                        // Perubahan email memerlukan proses tersendiri.
                        TextFormField(
                          controller: _emailController,
                          readOnly: true,
                          keyboardType:
                              TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(
                              Icons.email_outlined,
                            ),
                            helperText:
                                'Email akun tidak dapat diubah dari halaman ini.',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Simpan Perubahan',
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
