import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart'
    as types;

import '../../../controllers/chat_controller.dart';
import '../chat_theme.dart';

/// Notice di bagian bawah ruang chat ketika pengguna saat ini memblokir lawan bicara DM.
class BlockedUserBottomNotice extends StatelessWidget {
  final String userName;
  final VoidCallback onUnblock;

  const BlockedUserBottomNotice({
    super.key,
    required this.userName,
    required this.onUnblock,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline,
          ),
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.block_rounded,
                size: 18,
                color: colorScheme.error,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Kamu memblokir pengguna ini. Buka blokir untuk mengirim pesan.',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(
                    fontSize: ChatLayoutTokens.fontLabel,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Semantics(
            button: true,
            label: 'Buka blokir $userName',
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: ChatLayoutTokens.minTapTarget,
                minHeight: ChatLayoutTokens.minTapTarget,
              ),
              child: OutlinedButton(
                onPressed: onUnblock,
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  side: BorderSide(
                    color: colorScheme.primary,
                  ),
                  minimumSize: const Size(
                    ChatLayoutTokens.minTapTarget,
                    ChatLayoutTokens.minTapTarget,
                  ),
                ),
                child: const Text('Buka blokir'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Menampilkan bottom sheet profil pengguna beserta aksi Laporkan & Blokir/Buka Blokir.
void showUserProfileModerationSheet({
  required BuildContext context,
  required ChatController controller,
  required types.User author,
  String? messageId,
  String? messageText,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final authorName = [
    author.firstName ?? '',
    author.lastName ?? '',
  ].where((s) => s.trim().isNotEmpty).join(' ').trim();
  final displayName =
      authorName.isEmpty ? 'Pengguna SOLEA' : authorName;
  final isBlocked = controller.isUserBlocked(author.id);

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            18,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: colorScheme.primary
                        .withValues(alpha: 0.14),
                    backgroundImage:
                        author.imageUrl != null &&
                                author.imageUrl!.isNotEmpty
                            ? NetworkImage(author.imageUrl!)
                            : null,
                    child: author.imageUrl == null ||
                            author.imageUrl!.isEmpty
                        ? Icon(
                            Icons.person_rounded,
                            color: colorScheme.primary,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          isBlocked
                              ? 'Status: Diblokir'
                              : 'Anggota Komunitas SOLEA',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(
                            fontSize:
                                ChatLayoutTokens.fontCaption,
                            color: isBlocked
                                ? colorScheme.error
                                : colorScheme
                                    .onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: 'Tutup profil pengguna',
                    child: IconButton(
                      tooltip: 'Tutup profil pengguna',
                      constraints: const BoxConstraints(
                        minWidth:
                            ChatLayoutTokens.minTapTarget,
                        minHeight:
                            ChatLayoutTokens.minTapTarget,
                      ),
                      onPressed: () =>
                          Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ],
              ),
              if (messageText != null &&
                  messageText.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outline,
                    ),
                  ),
                  child: Text(
                    '"$messageText"',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style:
                        theme.textTheme.bodySmall?.copyWith(
                      fontSize: ChatLayoutTokens.fontLabel,
                      fontStyle: FontStyle.italic,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                minVerticalPadding: 12,
                leading: Icon(
                  Icons.flag_outlined,
                  color: colorScheme.onSurface,
                ),
                title: Text(
                  messageId != null
                      ? 'Laporkan pesan & pengguna'
                      : 'Laporkan pengguna ini',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Kirim laporan pelanggaran komunitas ke Admin SOLEA',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: ChatLayoutTokens.fontCaption,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  showReportReasonDialog(
                    context: context,
                    controller: controller,
                    targetUserId: author.id,
                    targetUserName: displayName,
                    messageId: messageId,
                    messageText: messageText,
                  );
                },
              ),
              Divider(
                height: 1,
                color: colorScheme.outline,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                minVerticalPadding: 12,
                leading: Icon(
                  isBlocked
                      ? Icons.lock_open_rounded
                      : Icons.block_rounded,
                  color: isBlocked
                      ? colorScheme.primary
                      : colorScheme.error,
                ),
                title: Text(
                  isBlocked
                      ? 'Buka blokir $displayName'
                      : 'Blokir $displayName',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isBlocked
                        ? colorScheme.primary
                        : colorScheme.error,
                  ),
                ),
                subtitle: Text(
                  isBlocked
                      ? 'Tampilkan kembali pesan dari pengguna ini'
                      : 'Sembunyikan semua pesan & cegah DM dari pengguna ini',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: ChatLayoutTokens.fontCaption,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                onTap: () async {
                  final messenger =
                      ScaffoldMessenger.of(context);
                  Navigator.pop(sheetContext);
                  if (isBlocked) {
                    await controller.unblockUser(author.id);
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          'Blokir $displayName telah dibuka.',
                        ),
                      ),
                    );
                  } else {
                    await controller.blockUser(
                      targetUserId: author.id,
                      targetUserName: displayName,
                      reason:
                          'Diblokir dari Komunitas SOLEA',
                    );
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          '$displayName telah diblokir. Pesannya disembunyikan.',
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Dialog laporan dengan RadioListTile polos tanpa ikon merah berulang,
/// teks petunjuk 13.5 sp berwarna onSurfaceVariant, dan tombol "Kirim laporan"
/// yang hanya aktif setelah pengguna memilih alasan.
void showReportReasonDialog({
  required BuildContext context,
  required ChatController controller,
  required String targetUserId,
  required String targetUserName,
  String? messageId,
  String? messageText,
}) {
  const reasons = [
    'Spam atau promosi tidak relevan',
    'Kata-kata kasar atau pelecehan',
    'Indikasi penipuan / scam transaksi',
    'Konten tidak pantas di komunitas',
  ];

  String? selectedReason;

  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

          return AlertDialog(
            backgroundColor: colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Laporkan $targetUserName',
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pilih alasan laporan untuk ditinjau tim Admin SOLEA:',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(
                      fontSize: 13.5,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final reason in reasons)
                    _ReportReasonRadioTile(
                      reason: reason,
                      selected: selectedReason == reason,
                      onSelect: () {
                        setDialogState(() {
                          selectedReason = reason;
                        });
                      },
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(dialogContext),
                style: TextButton.styleFrom(
                  minimumSize: const Size(
                    ChatLayoutTokens.minTapTarget,
                    ChatLayoutTokens.minTapTarget,
                  ),
                ),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: selectedReason == null
                    ? null
                    : () async {
                        final chosen = selectedReason!;
                        final messenger =
                            ScaffoldMessenger.of(context);
                        Navigator.pop(dialogContext);
                        await controller.reportContent(
                          targetUserId: targetUserId,
                          targetUserName: targetUserName,
                          messageId: messageId,
                          messageText: messageText,
                          reason: chosen,
                        );
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Laporan terhadap $targetUserName telah dikirim ke Admin SOLEA.',
                            ),
                          ),
                        );
                      },
                style: FilledButton.styleFrom(
                  minimumSize: const Size(
                    ChatLayoutTokens.minTapTarget,
                    ChatLayoutTokens.minTapTarget,
                  ),
                ),
                child: const Text('Kirim laporan'),
              ),
            ],
          );
        },
      );
    },
  );
}

/// Bottom sheet untuk mengatur "Siapa yang boleh mengirim DM kepada saya"
/// dan mengelola daftar pengguna yang diblokir.
void showCommunityPrivacyAndBlockedSheet({
  required BuildContext context,
  required ChatController controller,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;
          final currentPrivacy = controller.dmPrivacy;
          final blockedIds =
              controller.blockedUserIds.toList();

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                18,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Privasi DM & Pengguna Diblokir',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Semantics(
                        button: true,
                        label: 'Tutup pengaturan privasi',
                        child: IconButton(
                          tooltip:
                              'Tutup pengaturan privasi',
                          constraints: const BoxConstraints(
                            minWidth: ChatLayoutTokens
                                .minTapTarget,
                            minHeight: ChatLayoutTokens
                                .minTapTarget,
                          ),
                          onPressed: () =>
                              Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Siapa yang boleh mengirim DM kepada saya:',
                    style: theme.textTheme.labelLarge
                        ?.copyWith(
                      fontSize: ChatLayoutTokens.fontLabel,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _DmPrivacyChip(
                        label: 'Semua Pengguna',
                        selected: currentPrivacy ==
                            DmPrivacyPermission.everyone,
                        onSelected: () async {
                          await controller.updateDmPrivacy(
                            DmPrivacyPermission.everyone,
                          );
                          setModalState(() {});
                        },
                      ),
                      _DmPrivacyChip(
                        label: 'Hanya Anggota Komunitas',
                        selected: currentPrivacy ==
                            DmPrivacyPermission.community,
                        onSelected: () async {
                          await controller.updateDmPrivacy(
                            DmPrivacyPermission.community,
                          );
                          setModalState(() {});
                        },
                      ),
                      _DmPrivacyChip(
                        label: 'Tidak Siapa Pun',
                        selected: currentPrivacy ==
                            DmPrivacyPermission.none,
                        onSelected: () async {
                          await controller.updateDmPrivacy(
                            DmPrivacyPermission.none,
                          );
                          setModalState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(
                    height: 1,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Daftar Pengguna yang Diblokir (${blockedIds.length}):',
                    style: theme.textTheme.labelLarge
                        ?.copyWith(
                      fontSize: ChatLayoutTokens.fontLabel,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (blockedIds.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                      ),
                      child: Text(
                        'Belum ada pengguna yang diblokir. Tekan lama pada pesan atau ketuk menu ⋮ di ruang chat untuk melaporkan atau memblokir.',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(
                          fontSize:
                              ChatLayoutTokens.fontLabel,
                          color:
                              colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    for (final blockedId in blockedIds)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.person_off_outlined,
                          color: colorScheme.error,
                        ),
                        title: Text(
                          ChatController.peerContacts
                              .firstWhere(
                                (c) => c.id == blockedId,
                                orElse: () =>
                                    PeerUserContact(
                                  id: blockedId,
                                  name: blockedId,
                                  subtitle: '',
                                  avatarUrl: '',
                                ),
                              )
                              .name,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        trailing: OutlinedButton(
                          onPressed: () async {
                            await controller
                                .unblockUser(blockedId);
                            setModalState(() {});
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(
                              ChatLayoutTokens.minTapTarget,
                              ChatLayoutTokens.minTapTarget,
                            ),
                          ),
                          child: const Text('Buka blokir'),
                        ),
                      ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class _DmPrivacyChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _DmPrivacyChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: 'Opsi privasi DM: $label',
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: ChatLayoutTokens.minTapTarget,
          minHeight: ChatLayoutTokens.minTapTarget,
        ),
        child: ChoiceChip(
          materialTapTargetSize:
              MaterialTapTargetSize.padded,
          label: Text(label),
          selected: selected,
          onSelected: (_) => onSelected(),
          selectedColor: colorScheme.primary,
          backgroundColor: colorScheme.surface,
          labelStyle: TextStyle(
            color: selected
                ? colorScheme.onPrimary
                : colorScheme.onSurface,
            fontSize: ChatLayoutTokens.fontCaption,
            fontWeight: FontWeight.w700,
          ),
          side: BorderSide(
            color: selected
                ? colorScheme.primary
                : colorScheme.outline,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

class _ReportReasonRadioTile extends StatelessWidget {
  final String reason;
  final bool selected;
  final VoidCallback onSelect;

  const _ReportReasonRadioTile({
    required this.reason,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      button: true,
      inMutuallyExclusiveGroup: true,
      selected: selected,
      label: 'Alasan laporan: $reason',
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: ChatLayoutTokens.minTapTarget,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 8,
            ),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 22,
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    reason,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(
                      fontSize: ChatLayoutTokens.fontBody,
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: colorScheme.onSurface,
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
