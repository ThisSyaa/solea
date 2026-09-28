import 'package:flutter/material.dart';
import 'app_theme.dart';

class ProfilePage extends StatelessWidget {
  final String name;
  final String email;

  const ProfilePage({
    super.key,
    required this.name,
    required this.email,
  });


  static const String urlFoto = 'https://avatars.githubusercontent.com/u/174694675?v=4';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand,

      appBar: AppBar(
        backgroundColor: AppColors.sand,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
          ),
          color: AppColors.ink,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),

        title: const Text(
          'Profil',
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            // Desktop
            if (width >= 1000) {
              return _DesktopProfile(
                name: name,
                email: email,
              );
            }

            // Tablet / HP
            return _MobileProfile(
              name: name,
              email: email,
              isTablet: width >= 650,
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// DESKTOP
// ============================================================

class _DesktopProfile extends StatelessWidget {
  final String name;
  final String email;

  const _DesktopProfile({
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1050,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            32,
            20,
            32,
            32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // HEADER PROFILE
              // ==================================================

              Container(
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.line,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const _ProfileAvatar(
                      radius: 52,
                    ),

                    const SizedBox(width: 24),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              const _MemberBadge(),
                            ],
                          ),

                          const SizedBox(height: 7),

                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.muted,
                            ),
                          ),

                          const SizedBox(height: 18),

                          const Text(
                            'Kelola akun dan aktivitas belanja kamu.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 20),

                    OutlinedButton.icon(
                      onPressed: () {
                        _showMessage(
                          context,
                          'Fitur edit profile belum tersedia.',
                        );
                      },
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 17,
                      ),
                      label: const Text('Edit Profile'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.ink,
                        side: const BorderSide(
                          color: AppColors.line,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ==================================================
              // MAIN CONTENT
              // ==================================================

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ----------------------------------------------
                  // LEFT
                  // ----------------------------------------------
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        const _SectionTitle(
                          title: 'Aktivitas kamu',
                        ),

                        const SizedBox(height: 11),

                        const _StatsCard(),

                        const SizedBox(height: 22),

                        const _SectionTitle(
                          title: 'Akun',
                        ),

                        const SizedBox(height: 11),

                        _MenuCard(
                          children: [
                            _MenuTile(
                              icon: Icons.person_outline_rounded,
                              title: 'Informasi pribadi',
                              subtitle:
                                  'Nama, email, dan detail akun',
                              onTap: () {
                                _showMessage(
                                  context,
                                  'Informasi pribadi',
                                );
                              },
                            ),
                            const _MenuDivider(),
                            _MenuTile(
                              icon: Icons.lock_outline_rounded,
                              title: 'Keamanan akun',
                              subtitle:
                                  'Password dan keamanan login',
                              onTap: () {
                                _showMessage(
                                  context,
                                  'Keamanan akun',
                                );
                              },
                            ),
                            const _MenuDivider(),
                            _MenuTile(
                              icon:
                                  Icons.notifications_none_rounded,
                              title: 'Notifikasi',
                              subtitle:
                                  'Kelola notifikasi aplikasi',
                              onTap: () {
                                _showMessage(
                                  context,
                                  'Pengaturan notifikasi',
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 22),

                  // ----------------------------------------------
                  // RIGHT
                  // ----------------------------------------------
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const _SectionTitle(
                          title: 'Belanja',
                        ),

                        const SizedBox(height: 11),

                        _MenuCard(
                          children: [
                            _MenuTile(
                              icon: Icons.inventory_2_outlined,
                              title: 'Pesanan Saya',
                              subtitle:
                                  'Lihat riwayat dan status pesanan',
                              onTap: () {
                                _showMessage(
                                  context,
                                  'Pesanan Saya',
                                );
                              },
                            ),
                            const _MenuDivider(),
                            _MenuTile(
                              icon: Icons.favorite_border_rounded,
                              title: 'Wishlist',
                              subtitle:
                                  'Sepatu yang kamu simpan',
                              onTap: () {
                                _showMessage(
                                  context,
                                  'Wishlist',
                                );
                              },
                            ),
                            const _MenuDivider(),
                            _MenuTile(
                              icon:
                                  Icons.location_on_outlined,
                              title: 'Alamat Saya',
                              subtitle:
                                  'Kelola alamat pengiriman',
                              onTap: () {
                                _showMessage(
                                  context,
                                  'Alamat Saya',
                                );
                              },
                            ),
                            const _MenuDivider(),
                            _MenuTile(
                              icon:
                                  Icons.credit_card_outlined,
                              title: 'Metode Pembayaran',
                              subtitle:
                                  'Kelola pembayaran kamu',
                              onTap: () {
                                _showMessage(
                                  context,
                                  'Metode Pembayaran',
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        const _SectionTitle(
                          title: 'Lainnya',
                        ),

                        const SizedBox(height: 11),

                        _MenuCard(
                          children: [
                            _MenuTile(
                              icon:
                                  Icons.help_outline_rounded,
                              title: 'Bantuan & FAQ',
                              subtitle:
                                  'Cari jawaban dan bantuan',
                              onTap: () {
                                _showMessage(
                                  context,
                                  'Bantuan & FAQ',
                                );
                              },
                            ),
                            const _MenuDivider(),
                            _MenuTile(
                              icon:
                                  Icons.info_outline_rounded,
                              title: 'Tentang aplikasi',
                              subtitle:
                                  'Solea Store v1.0.0',
                              onTap: () {
                                _showMessage(
                                  context,
                                  'Tentang aplikasi',
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _showLogoutDialog(context);
                            },
                            icon: const Icon(
                              Icons.logout_rounded,
                              size: 18,
                            ),
                            label: const Text(
                              'Logout',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor:
                                  AppColors.danger,
                              side: BorderSide(
                                color: AppColors.danger
                                    .withOpacity(0.25),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(9),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// MOBILE / TABLET
// ============================================================

class _MobileProfile extends StatelessWidget {
  final String name;
  final String email;
  final bool isTablet;

  const _MobileProfile({
    required this.name,
    required this.email,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isTablet ? 720 : 560,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 28 : 18,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // PROFILE CARD
              // ==================================================

              Container(
                padding: EdgeInsets.all(
                  isTablet ? 24 : 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.line,
                  ),
                ),
                child: Row(
                  children: [
                    _ProfileAvatar(
                      radius: isTablet ? 47 : 42,
                    ),

                    const SizedBox(width: 18),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: isTablet ? 23 : 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.muted,
                            ),
                          ),

                          const SizedBox(height: 10),

                          const _MemberBadge(),
                        ],
                      ),
                    ),

                    IconButton(
                      tooltip: 'Edit Profile',
                      onPressed: () {
                        _showMessage(
                          context,
                          'Fitur edit profile belum tersedia.',
                        );
                      },
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 19,
                      ),
                      color: AppColors.ink,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              const _StatsCard(),

              const SizedBox(height: 22),

              const _SectionTitle(
                title: 'Belanja',
              ),

              const SizedBox(height: 10),

              _MenuCard(
                children: [
                  _MenuTile(
                    icon: Icons.inventory_2_outlined,
                    title: 'Pesanan Saya',
                    subtitle:
                        'Lihat riwayat dan status pesanan',
                    onTap: () {
                      _showMessage(
                        context,
                        'Pesanan Saya',
                      );
                    },
                  ),
                  const _MenuDivider(),
                  _MenuTile(
                    icon: Icons.favorite_border_rounded,
                    title: 'Wishlist',
                    subtitle: 'Sepatu yang kamu simpan',
                    onTap: () {
                      _showMessage(
                        context,
                        'Wishlist',
                      );
                    },
                  ),
                  const _MenuDivider(),
                  _MenuTile(
                    icon: Icons.location_on_outlined,
                    title: 'Alamat Saya',
                    subtitle:
                        'Kelola alamat pengiriman',
                    onTap: () {
                      _showMessage(
                        context,
                        'Alamat Saya',
                      );
                    },
                  ),
                  const _MenuDivider(),
                  _MenuTile(
                    icon: Icons.credit_card_outlined,
                    title: 'Metode Pembayaran',
                    subtitle:
                        'Kelola pembayaran kamu',
                    onTap: () {
                      _showMessage(
                        context,
                        'Metode Pembayaran',
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 22),

              const _SectionTitle(
                title: 'Akun',
              ),

              const SizedBox(height: 10),

              _MenuCard(
                children: [
                  _MenuTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Informasi pribadi',
                    subtitle:
                        'Nama, email, dan detail akun',
                    onTap: () {
                      _showMessage(
                        context,
                        'Informasi pribadi',
                      );
                    },
                  ),
                  const _MenuDivider(),
                  _MenuTile(
                    icon: Icons.lock_outline_rounded,
                    title: 'Keamanan akun',
                    subtitle:
                        'Password dan keamanan login',
                    onTap: () {
                      _showMessage(
                        context,
                        'Keamanan akun',
                      );
                    },
                  ),
                  const _MenuDivider(),
                  _MenuTile(
                    icon:
                        Icons.notifications_none_rounded,
                    title: 'Notifikasi',
                    subtitle:
                        'Kelola notifikasi aplikasi',
                    onTap: () {
                      _showMessage(
                        context,
                        'Pengaturan notifikasi',
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 22),

              const _SectionTitle(
                title: 'Lainnya',
              ),

              const SizedBox(height: 10),

              _MenuCard(
                children: [
                  _MenuTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Bantuan & FAQ',
                    subtitle:
                        'Cari jawaban dan bantuan',
                    onTap: () {
                      _showMessage(
                        context,
                        'Bantuan & FAQ',
                      );
                    },
                  ),
                  const _MenuDivider(),
                  _MenuTile(
                    icon: Icons.info_outline_rounded,
                    title: 'Tentang aplikasi',
                    subtitle:
                        'Solea Store v1.0.0',
                    onTap: () {
                      _showMessage(
                        context,
                        'Tentang aplikasi',
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                  icon: const Icon(
                    Icons.logout_rounded,
                    size: 18,
                  ),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: BorderSide(
                      color:
                          AppColors.danger.withOpacity(0.25),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(9),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// AVATAR
// ============================================================

class _ProfileAvatar extends StatelessWidget {
  final double radius;

  const _ProfileAvatar({
    required this.radius,
  });

  static const String _photoUrl = ProfilePage.urlFoto;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = _photoUrl.isNotEmpty;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.line,
              width: 1.4,
            ),
          ),
          child: CircleAvatar(
            radius: radius,
            backgroundColor: const Color(0xFFE8E4DA),
            backgroundImage:
                hasPhoto ? const NetworkImage(_photoUrl) : null,
            child: hasPhoto
                ? null
                : Icon(
                    Icons.person_rounded,
                    size: radius * 0.9,
                    color: AppColors.forest,
                  ),
          ),
        ),

        Positioned(
          right: -1,
          bottom: -1,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
              size: 14,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// MEMBER BADGE
// ============================================================

class _MemberBadge extends StatelessWidget {
  const _MemberBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EEE8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.workspace_premium_outlined,
            size: 14,
            color: AppColors.ink,
          ),
          SizedBox(width: 5),
          Text(
            'Member',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// STATS
// ============================================================

class _StatsCard extends StatelessWidget {
  const _StatsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 19,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.line,
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            child: _StatItem(
              number: '12',
              label: 'Pesanan',
            ),
          ),

          _StatDivider(),

          Expanded(
            child: _StatItem(
              number: '5',
              label: 'Wishlist',
            ),
          ),

          _StatDivider(),

          Expanded(
            child: _StatItem(
              number: '320',
              label: 'Poin',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String number;
  final String label;

  const _StatItem({
    required this.number,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      width: 1,
      color: AppColors.line,
    );
  }
}

// ============================================================
// SECTION TITLE
// ============================================================

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
      ),
    );
  }
}

// ============================================================
// MENU CARD
// ============================================================

class _MenuCard extends StatelessWidget {
  final List<Widget> children;

  const _MenuCard({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.line,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

// ============================================================
// MENU TILE
// ============================================================

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 17,
            vertical: 14,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F1EC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 19,
                  color: AppColors.ink,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFAAA69E),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DIVIDER
// ============================================================

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(
        left: 70,
      ),
      child: Divider(
        height: 1,
        thickness: 1,
        color: AppColors.line,
      ),
    );
  }
}

// ============================================================
// HELPER
// ============================================================

void _showMessage(
  BuildContext context,
  String message,
) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
}

void _showLogoutDialog(
  BuildContext context,
) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Yakin ingin keluar dari akun?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Batal',
              style: TextStyle(
                color: AppColors.ink,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context)
                ..pop()
                ..pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Logout'),
          ),
        ],
      );
    },
  );
}