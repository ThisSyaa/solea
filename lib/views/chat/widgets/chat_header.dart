import 'package:flutter/material.dart';

import '../../../controllers/chat_controller.dart';
import '../../../core/home_button.dart';
import '../chat_theme.dart';

/// AppBar untuk halaman daftar percakapan (`ChatListPage` di `/chat`).
class ChatListAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback onOpenPrivacySettings;

  const ChatListAppBar({
    super.key,
    required this.onOpenPrivacySettings,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 16,
      title: Row(
        children: [
          Semantics(
            label: 'SOLEA',
            image: true,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.forum_rounded,
                color: colorScheme.onPrimary,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'SOLEA Chat',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Semantics(
          button: true,
          label: 'Pengaturan Privasi DM dan Daftar Blokir',
          child: IconButton(
            tooltip: 'Pengaturan Privasi DM & Daftar Blokir',
            constraints: const BoxConstraints(
              minWidth: ChatLayoutTokens.minTapTarget,
              minHeight: ChatLayoutTokens.minTapTarget,
            ),
            onPressed: onOpenPrivacySettings,
            icon: Icon(
              Icons.lock_outline_rounded,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const HomeButton(),
        const SizedBox(width: 6),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
          height: 1,
          color: colorScheme.outline,
        ),
      ),
    );
  }
}

/// Header satu baris bergaya WhatsApp untuk ruang percakapan (`ChatRoomPage` / panel kanan):
/// Tombol kembali (di mobile), avatar, nama, status satu baris,
/// tombol Mode Admin (khusus Admin di ruang Admin), dan menu ⋮ (khusus grup & DM).
class ChatRoomHeader extends StatelessWidget {
  final ChatConversationItem conversation;
  final ChatKindConfig config;
  final ChatController controller;
  final bool showBackButton;
  final VoidCallback? onBack;
  final VoidCallback onOpenPeerProfile;
  final VoidCallback onReportPeer;
  final VoidCallback onToggleBlockPeer;
  final VoidCallback onOpenPrivacySettings;

  const ChatRoomHeader({
    super.key,
    required this.conversation,
    required this.config,
    required this.controller,
    required this.showBackButton,
    this.onBack,
    required this.onOpenPeerProfile,
    required this.onReportPeer,
    required this.onToggleBlockPeer,
    required this.onOpenPrivacySettings,
  });

  IconData get _fallbackIcon {
    switch (config.kind) {
      case ChatKind.bot:
        return Icons.smart_toy_outlined;
      case ChatKind.admin:
        return Icons.support_agent_rounded;
      case ChatKind.group:
        return Icons.groups_rounded;
      case ChatKind.direct:
        return Icons.person_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final status =
        config.statusText(controller, conversation.id);
    final isBlocked = config.kind == ChatKind.direct &&
        controller.isUserBlocked(conversation.id);
    final hasAvatar = conversation.avatarUrl != null &&
        conversation.avatarUrl!.trim().isNotEmpty;

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 58,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outline,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            showBackButton ? 4 : 16,
            6,
            8,
            6,
          ),
          child: Row(
            children: [
              if (showBackButton)
                Semantics(
                  button: true,
                  label: 'Kembali ke daftar percakapan',
                  child: IconButton(
                    tooltip: 'Kembali ke daftar percakapan',
                    constraints: const BoxConstraints(
                      minWidth:
                          ChatLayoutTokens.minTapTarget,
                      minHeight:
                          ChatLayoutTokens.minTapTarget,
                    ),
                    onPressed: onBack ??
                        () => Navigator.of(context)
                            .maybePop(),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              GestureDetector(
                onTap: config.kind == ChatKind.direct
                    ? onOpenPeerProfile
                    : null,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: ChatLayoutTokens
                          .avatarRadiusHeader,
                      backgroundColor: colorScheme.primary
                          .withValues(alpha: 0.14),
                      backgroundImage: hasAvatar
                          ? NetworkImage(
                              conversation.avatarUrl!,
                            )
                          : null,
                      child: !hasAvatar
                          ? Icon(
                              _fallbackIcon,
                              size: 19,
                              color: colorScheme.primary,
                            )
                          : null,
                    ),
                    if (!isBlocked)
                      Positioned(
                        right: -1,
                        bottom: -1,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: conversation.isOnline
                                ? colorScheme.primary
                                : colorScheme
                                    .onSurfaceVariant,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.surface,
                              width: 1.8,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: config.kind == ChatKind.direct
                      ? onOpenPeerProfile
                      : null,
                  borderRadius: BorderRadius.circular(8),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        conversation.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(
                          fontSize:
                              ChatLayoutTokens.fontBody,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        status,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(
                          fontSize:
                              ChatLayoutTokens.fontCaption,
                          fontWeight: FontWeight.w600,
                          color: isBlocked
                              ? colorScheme.error
                              : colorScheme
                                  .onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tombol Mode Admin HANYA tampil jika di ruang Admin & user adalah Admin
              if (config.kind == ChatKind.admin &&
                  controller.isCurrentUserAdmin) ...[
                const SizedBox(width: 6),
                Semantics(
                  button: true,
                  label: controller.replyAsAdminMode
                      ? 'Ganti ke mode pengguna biasa'
                      : 'Aktifkan Mode Admin',
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth:
                          ChatLayoutTokens.minTapTarget,
                      minHeight:
                          ChatLayoutTokens.minTapTarget,
                    ),
                    child: OutlinedButton.icon(
                      onPressed: controller
                          .toggleReplyAsAdminMode,
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            controller.replyAsAdminMode
                                ? colorScheme.onPrimary
                                : colorScheme.primary,
                        backgroundColor:
                            controller.replyAsAdminMode
                                ? colorScheme.primary
                                : Colors.transparent,
                        side: BorderSide(
                          color: colorScheme.primary,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                      ),
                      icon: Icon(
                        controller.replyAsAdminMode
                            ? Icons.person_outline_rounded
                            : Icons
                                .admin_panel_settings_outlined,
                        size: 16,
                      ),
                      label: Text(
                        controller.replyAsAdminMode
                            ? 'Mode User'
                            : 'Mode Admin',
                        style: const TextStyle(
                          fontSize:
                              ChatLayoutTokens.fontCaption,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              // Menu ⋮ untuk laporkan/blokir HANYA di grup dan DM (bukan di Bot/Admin)
              if (config.canModerate)
                Semantics(
                  button: true,
                  label: 'Menu opsi percakapan dan moderasi',
                  child: PopupMenuButton<String>(
                    tooltip: 'Opsi moderasi & privasi',
                    constraints: const BoxConstraints(
                      minWidth:
                          ChatLayoutTokens.minTapTarget,
                      minHeight:
                          ChatLayoutTokens.minTapTarget,
                    ),
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: colorScheme.onSurface,
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'profile':
                          onOpenPeerProfile();
                          break;
                        case 'report':
                          onReportPeer();
                          break;
                        case 'block':
                          onToggleBlockPeer();
                          break;
                        case 'privacy':
                          onOpenPrivacySettings();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      if (config.kind ==
                          ChatKind.direct) ...[
                        const PopupMenuItem<String>(
                          value: 'profile',
                          child: Text('Lihat profil pengguna'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'report',
                          child: Text('Laporkan pengguna'),
                        ),
                        PopupMenuItem<String>(
                          value: 'block',
                          child: Text(
                            isBlocked
                                ? 'Buka blokir pengguna'
                                : 'Blokir pengguna',
                          ),
                        ),
                        const PopupMenuDivider(),
                      ],
                      const PopupMenuItem<String>(
                        value: 'privacy',
                        child: Text(
                          'Pengaturan privasi DM & daftar blokir',
                        ),
                      ),
                    ],
                  ),
                ),

              if (showBackButton) const HomeButton(),
            ],
          ),
        ),
      ),
    );
  }
}
