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

class _PersonalInfoPageState
    extends State<PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();

    _nameController =
        TextEditingController(text: widget.name);
    _emailController =
        TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    AuthController.updateProfile(
      name,
      email,
    );

    Navigator.pop(
      context,
      {
        'name': name,
        'email': email,
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
        padding:
            const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          30,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 620,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.all(20),
                    decoration:
                        BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 45,
                          backgroundColor:
                              Color(0xFFE8E4DA),
                          backgroundImage:
                              NetworkImage(
                            'https://avatars.githubusercontent.com/u/174694675?v=4',
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller:
                              _nameController,
                          decoration:
                              const InputDecoration(
                            labelText: 'Nama',
                            prefixIcon:
                                Icon(
                              Icons
                                  .person_outline_rounded,
                            ),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value
                                    .trim()
                                    .isEmpty) {
                              return 'Nama wajib diisi';
                            }

                            if (value.trim().length <
                                3) {
                              return 'Nama minimal 3 karakter';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller:
                              _emailController,
                          keyboardType:
                              TextInputType.emailAddress,
                          decoration:
                              const InputDecoration(
                            labelText: 'Email',
                            prefixIcon:
                                Icon(
                              Icons
                                  .email_outlined,
                            ),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value
                                    .trim()
                                    .isEmpty) {
                              return 'Email wajib diisi';
                            }

                            final regex = RegExp(
                              r'^[\w.\-+]+@([\w-]+\.)+[a-zA-Z]{2,}$',
                            );

                            if (!regex.hasMatch(
                              value.trim(),
                            )) {
                              return 'Format email tidak valid';
                            }

                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width:
                        double.infinity,
                    height: 52,
                    child:
                        ElevatedButton(
                      onPressed: _save,
                      child:
                          const Text(
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