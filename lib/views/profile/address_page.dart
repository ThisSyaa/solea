import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/home_button.dart';

class AddressPage
    extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage>
      createState() =>
          _AddressPageState();
}

class _AddressPageState
    extends State<AddressPage> {
  final _nameController =
      TextEditingController();
  final _phoneController =
      TextEditingController();
  final _addressController =
      TextEditingController();

  bool _hasAddress = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Semua data alamat wajib diisi.',
            ),
          ),
        );
      return;
    }

    setState(() {
      _hasAddress = true;
    });

    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Alamat berhasil disimpan.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.sand,
      appBar: AppBar(
        backgroundColor:
            AppColors.sand,
        elevation: 0,
        title: const Text(
          'Alamat Saya',
          style: TextStyle(
            fontWeight:
                FontWeight.w800,
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
              maxWidth: 650,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                if (_hasAddress)
                  Container(
                    width:
                        double.infinity,
                    margin:
                        const EdgeInsets.only(
                      bottom: 16,
                    ),
                    padding:
                        const EdgeInsets.all(
                      18,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                        18,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Alamat tersimpan',
                          style:
                              TextStyle(
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          _nameController
                              .text,
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          _phoneController
                              .text,
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        Text(
                          _addressController
                              .text,
                          style:
                              const TextStyle(
                            color:
                                AppColors
                                    .muted,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                    children: [
                      TextField(
                        controller:
                            _nameController,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Nama penerima',
                          prefixIcon:
                              Icon(
                            Icons
                                .person_outline_rounded,
                          ),
                        ),
                      ),
                      const SizedBox(
                          height: 15),
                      TextField(
                        controller:
                            _phoneController,
                        keyboardType:
                            TextInputType.phone,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Nomor HP',
                          prefixIcon:
                              Icon(
                            Icons
                                .phone_outlined,
                          ),
                        ),
                      ),
                      const SizedBox(
                          height: 15),
                      TextField(
                        controller:
                            _addressController,
                        maxLines: 4,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Alamat lengkap',
                          alignLabelWithHint:
                              true,
                        ),
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
                    onPressed:
                        _saveAddress,
                    child:
                        const Text(
                      'Simpan Alamat',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}