import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/home_button.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() =>
      _SecurityPageState();
}

class _SecurityPageState
    extends State<SecurityPage> {
  final _formKey =
      GlobalKey<FormState>();

  final _oldPassword =
      TextEditingController();

  final _newPassword =
      TextEditingController();

  final _confirmPassword =
      TextEditingController();

  bool _hideOld = true;
  bool _hideNew = true;
  bool _hideConfirm = true;

  @override
  void dispose() {
    _oldPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Password berhasil diperbarui untuk sesi ini.',
          ),
        ),
      );

    _oldPassword.clear();
    _newPassword.clear();
    _confirmPassword.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand,
      appBar: AppBar(
        backgroundColor:
            AppColors.sand,
        elevation: 0,
        title: const Text(
          'Keamanan Akun',
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
                children: [
                  Container(
                    padding:
                        const EdgeInsets.all(
                      20,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        const Text(
                          'Ganti Password',
                          style:
                              TextStyle(
                            fontSize:
                                18,
                            fontWeight:
                                FontWeight
                                    .w800,
                          ),
                        ),
                        const SizedBox(
                            height: 18),
                        TextFormField(
                          controller:
                              _oldPassword,
                          obscureText:
                              _hideOld,
                          decoration:
                              InputDecoration(
                            labelText:
                                'Password lama',
                            prefixIcon:
                                const Icon(
                              Icons
                                  .lock_outline_rounded,
                            ),
                            suffixIcon:
                                IconButton(
                              onPressed:
                                  () {
                                setState(
                                  () {
                                    _hideOld =
                                        !_hideOld;
                                  },
                                );
                              },
                              icon:
                                  Icon(
                                _hideOld
                                    ? Icons
                                        .visibility_off_outlined
                                    : Icons
                                        .visibility_outlined,
                              ),
                            ),
                          ),
                          validator:
                              (value) {
                            if (value ==
                                    null ||
                                value.isEmpty) {
                              return 'Password lama wajib diisi';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(
                            height: 15),
                        TextFormField(
                          controller:
                              _newPassword,
                          obscureText:
                              _hideNew,
                          decoration:
                              InputDecoration(
                            labelText:
                                'Password baru',
                            prefixIcon:
                                const Icon(
                              Icons
                                  .lock_reset_outlined,
                            ),
                            suffixIcon:
                                IconButton(
                              onPressed:
                                  () {
                                setState(
                                  () {
                                    _hideNew =
                                        !_hideNew;
                                  },
                                );
                              },
                              icon:
                                  Icon(
                                _hideNew
                                    ? Icons
                                        .visibility_off_outlined
                                    : Icons
                                        .visibility_outlined,
                              ),
                            ),
                          ),
                          validator:
                              (value) {
                            if (value ==
                                    null ||
                                value.length <
                                    6) {
                              return 'Minimal 6 karakter';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(
                            height: 15),
                        TextFormField(
                          controller:
                              _confirmPassword,
                          obscureText:
                              _hideConfirm,
                          decoration:
                              InputDecoration(
                            labelText:
                                'Konfirmasi password',
                            prefixIcon:
                                const Icon(
                              Icons
                                  .verified_user_outlined,
                            ),
                            suffixIcon:
                                IconButton(
                              onPressed:
                                  () {
                                setState(
                                  () {
                                    _hideConfirm =
                                        !_hideConfirm;
                                  },
                                );
                              },
                              icon:
                                  Icon(
                                _hideConfirm
                                    ? Icons
                                        .visibility_off_outlined
                                    : Icons
                                        .visibility_outlined,
                              ),
                            ),
                          ),
                          validator:
                              (value) {
                            if (value !=
                                _newPassword
                                    .text) {
                              return 'Password tidak sama';
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
                        'Simpan Password',
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