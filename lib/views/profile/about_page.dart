import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/home_button.dart';

class AboutPage
    extends StatelessWidget {
  const AboutPage({super.key});

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
          'Tentang Aplikasi',
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
      body: Center(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(
            20,
          ),
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 520,
            ),
            child: Container(
              padding:
                  const EdgeInsets.all(
                28,
              ),
              decoration:
                  BoxDecoration(
                color:
                    Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  22,
                ),
              ),
              child:
                  Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration:
                        BoxDecoration(
                      color:
                          Colors.black,
                      borderRadius:
                          BorderRadius.circular(
                        18,
                      ),
                    ),
                    child:
                        const Icon(
                      Icons
                          .directions_run_rounded,
                      color:
                          Colors.white,
                      size: 34,
                    ),
                  ),
                  const SizedBox(
                      height: 18),
                  const Text(
                    'SOLEA',
                    style:
                        TextStyle(
                      fontSize: 24,
                      fontWeight:
                          FontWeight.w900,
                      letterSpacing:
                          1.5,
                    ),
                  ),
                  const SizedBox(
                      height: 6),
                  const Text(
                    'Sneaker Store',
                    style:
                        TextStyle(
                      color:
                          AppColors.muted,
                    ),
                  ),
                  const SizedBox(
                      height: 22),
                  const Divider(),
                  const SizedBox(
                      height: 18),
                  const Text(
                    'SOLEA adalah aplikasi toko sepatu berbasis Flutter yang dibuat sebagai project pembelajaran PBP.',
                    textAlign:
                        TextAlign.center,
                    style:
                        TextStyle(
                      height: 1.5,
                      color:
                          AppColors.muted,
                    ),
                  ),
                  const SizedBox(
                      height: 20),
                  const Text(
                    'Version 1.0.0',
                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight.w700,
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