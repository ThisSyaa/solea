import 'package:flutter/material.dart';

import '../../../controllers/chat_controller.dart';
import '../../../core/app_theme.dart';
import '../chat_theme.dart';

/// Item daftar percakapan bergaya WhatsApp (tanpa border kotak per item,
/// highlight latar saat aktif, jam di kanan, badge unread, dan badge Resmi/Pin).
class ConversationTile extends StatelessWidget {
  final ChatConversationItem item;
  final String previewText;
  final String timeLabel;
  final int unreadCount;
  final bool selected;
  final bool isPinnedOfficial;
  final bool isBlocked;
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.item,
    required this.previewText,
    required this.timeLabel,
    required this.unreadCount,
    required this.selected,
    required this.isPinnedOfficial,
    this.isBlocked = false,
    required this.onTap,
  });

  IconData get _fallbackIcon {
    if (item.id == 'bot') {
      return Icons.smart_toy_outlined;
    }
    if (item.id == 'admin') {
      return Icons.support_agent_rounded;
    }
    if (item.isGroup) {
      return Icons.groups_rounded;
    }
    return Icons.person_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Warna teks pratinjau dengan kontras >= 4.5:1 di atas surface putih
    final previewColor = unreadCount > 0
        ? colorScheme.onSurface
        : AppColors.ink.withValues(alpha: 0.78);

    final unreadSemantics = unreadCount > 0
        ? ', $unreadCount pesan belum dibaca'
        : '';

    return Semantics(
      button: true,
      selected: selected,
      label:
          'Percakapan ${item.title}, $previewText, pukul $timeLabel$unreadSemantics',
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 68,
          minWidth: ChatLayoutTokens.minTapTarget,
        ),
        child: Material(
          color: selected
              ? colorScheme.primary.withValues(alpha: 0.10)
              : Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.center,
                children: [
                  _buildAvatar(colorScheme),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Wrap(
                                crossAxisAlignment:
                                    WrapCrossAlignment
                                        .center,
                                spacing: 6,
                                runSpacing: 2,
                                children: [
                                  Text(
                                    item.title,
                                    maxLines: 1,
                                    overflow: TextOverflow
                                        .ellipsis,
                                    style: theme.textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                      fontSize:
                                          ChatLayoutTokens
                                              .fontBody,
                                      fontWeight:
                                          FontWeight.w800,
                                      color: colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                  if (isPinnedOfficial)
                                    const _OfficialBadge(),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              timeLabel,
                              style: theme
                                  .textTheme.bodySmall
                                  ?.copyWith(
                                fontSize: ChatLayoutTokens
                                    .fontCaption,
                                fontWeight: unreadCount > 0
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: unreadCount > 0
                                    ? colorScheme.primary
                                    : AppColors.ink
                                        .withValues(
                                            alpha: 0.72),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (isPinnedOfficial) ...[
                              Icon(
                                Icons.push_pin_rounded,
                                size: 14,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Expanded(
                              child: Text(
                                isBlocked
                                    ? 'Pengguna diblokir'
                                    : previewText,
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: theme
                                    .textTheme.bodySmall
                                    ?.copyWith(
                                  fontSize: ChatLayoutTokens
                                      .fontLabel,
                                  fontWeight:
                                      unreadCount > 0
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                  color: isBlocked
                                      ? colorScheme.error
                                      : previewColor,
                                ),
                              ),
                            ),
                            if (unreadCount > 0) ...[
                              const SizedBox(width: 8),
                              UnreadCountBadge(
                                count: unreadCount,
                              ),
                            ],
                          ],
                        ),
                      ],
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

  Widget _buildAvatar(ColorScheme colorScheme) {
    final hasAvatar = item.avatarUrl != null &&
        item.avatarUrl!.trim().isNotEmpty;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: ChatLayoutTokens.avatarRadiusList,
          backgroundColor:
              colorScheme.primary.withValues(alpha: 0.14),
          backgroundImage: hasAvatar
              ? NetworkImage(item.avatarUrl!)
              : null,
          child: !hasAvatar
              ? Icon(
                  _fallbackIcon,
                  size: 22,
                  color: colorScheme.primary,
                )
              : null,
        ),
        if (!isBlocked)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: ChatLayoutTokens.onlineDotSize,
              height: ChatLayoutTokens.onlineDotSize,
              decoration: BoxDecoration(
                color: item.isOnline
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.surface,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _OfficialBadge extends StatelessWidget {
  const _OfficialBadge();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Resmi',
        style: TextStyle(
          fontSize: ChatLayoutTokens.fontCaption,
          fontWeight: FontWeight.w700,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}

/// Badge jumlah pesan belum dibaca.
class UnreadCountBadge extends StatelessWidget {
  final int count;

  const UnreadCountBadge({
    super.key,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: '$count pesan belum dibaca',
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 22,
          minHeight: 22,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Text(
          count > 99 ? '99+' : '$count',
          style: TextStyle(
            fontSize: ChatLayoutTokens.fontCaption,
            fontWeight: FontWeight.w800,
            color: colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
