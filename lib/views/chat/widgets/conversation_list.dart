import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../controllers/chat_controller.dart';
import '../../../core/app_theme.dart';
import '../chat_theme.dart';
import 'conversation_tile.dart';

/// Daftar percakapan satu kolom bergaya WhatsApp dengan 3 bagian:
/// - "Disematkan" (SOLEA Assistant, Admin Support)
/// - "Komunitas" (Grup Sneakerheads Lounge)
/// - "Pesan langsung" (DM antar pengguna)
class ConversationList extends StatelessWidget {
  final ChatController controller;
  final String? selectedConversationId;
  final ValueChanged<String> onSelectConversation;

  const ConversationList({
    super.key,
    required this.controller,
    required this.selectedConversationId,
    required this.onSelectConversation,
  });

  String _formatTimeLabel(String conversationId) {
    int? timestampMs;
    if (conversationId == 'bot' &&
        controller.botMessages.isNotEmpty) {
      timestampMs = controller.botMessages.first.createdAt;
    } else if (conversationId == 'admin' &&
        controller.adminMessages.isNotEmpty) {
      timestampMs =
          controller.adminMessages.first.createdAt;
    } else if (conversationId ==
            controller.activeUserRoomId &&
        controller.activeUserMessages.isNotEmpty) {
      timestampMs =
          controller.activeUserMessages.first.createdAt;
    }

    final dt = timestampMs != null
        ? DateTime.fromMillisecondsSinceEpoch(timestampMs)
        : DateTime.now().subtract(
            Duration(
              minutes: conversationId == 'community_global'
                  ? 2
                  : conversationId == 'peer_raka'
                      ? 5
                      : 12,
            ),
          );

    return DateFormat('HH:mm', 'id_ID').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final all = controller.allConversations;

    final pinnedList = all
        .where(
          (c) =>
              c.section ==
              ChatConversationSection.bantuan,
        )
        .toList();
    final groupList = all
        .where(
          (c) =>
              c.section ==
                  ChatConversationSection.komunitas &&
              c.isGroup,
        )
        .toList();
    final directList = all
        .where(
          (c) =>
              c.section ==
                  ChatConversationSection.komunitas &&
              !c.isGroup,
        )
        .toList();

    final entries = <Object>[
      if (pinnedList.isNotEmpty) ...[
        'Disematkan',
        ...pinnedList,
      ],
      if (groupList.isNotEmpty) ...[
        'Komunitas',
        ...groupList,
      ],
      if (directList.isNotEmpty) ...[
        'Pesan langsung',
        ...directList,
      ],
    ];

    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colorScheme.surface,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          if (entry is String) {
            return _SectionHeader(
              title: entry,
              isFirst: index == 0,
            );
          }

          final item = entry as ChatConversationItem;
          final isSelected =
              selectedConversationId != null &&
                  item.id == selectedConversationId;
          final unreadCount = controller
              .unreadCountForConversation(item.id);
          final preview =
              controller.lastMessagePreview(item.id);
          final timeLabel = _formatTimeLabel(item.id);
          final isPinned = item.section ==
              ChatConversationSection.bantuan;
          final isBlocked = !item.isGroup &&
              item.section ==
                  ChatConversationSection.komunitas &&
              controller.isUserBlocked(item.id);

          return ConversationTile(
            item: item,
            previewText: preview,
            timeLabel: timeLabel,
            unreadCount: unreadCount,
            selected: isSelected,
            isPinnedOfficial: isPinned,
            isBlocked: isBlocked,
            onTap: () => onSelectConversation(item.id),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isFirst;

  const _SectionHeader({
    required this.title,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        isFirst ? 8 : 16,
        16,
        6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isFirst) ...[
            Divider(
              height: 1,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 12),
          ],
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              // Kontras >= 4.5:1 dengan ukuran >= 12 sp
              fontSize: ChatLayoutTokens.fontCaption,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: AppColors.forestDeep,
            ),
          ),
        ],
      ),
    );
  }
}
