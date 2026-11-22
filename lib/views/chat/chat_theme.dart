import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

import '../../controllers/chat_controller.dart';
import '../../core/app_theme.dart';

/// Konstanta layout dan tipografi bernama untuk fitur Chat SOLEA (tanpa magic numbers).
abstract final class ChatLayoutTokens {
  static const double wideBreakpoint = 840.0;
  static const double sidebarWidth = 320.0;
  static const double maxChatPanelWidth = 720.0;

  static const double minTapTarget = 48.0;
  static const double sendButtonCircleSize = 40.0;
  static const double avatarRadiusList = 22.0;
  static const double avatarRadiusHeader = 18.0;
  static const double onlineDotSize = 11.0;

  static const double inputPillRadius = 24.0;
  static const double bubbleRadius = 16.0;
  static const double cardRadius = 14.0;

  static const double fontBody = 14.0;
  static const double fontInput = 14.5;
  static const double fontLabel = 13.0;
  static const double fontCaption = 12.0;
}

/// Jenis percakapan untuk menentukan perilaku UI tanpa tab.
enum ChatKind {
  bot,
  admin,
  group,
  direct,
}

/// Konfigurasi deklaratif per jenis percakapan.
class ChatKindConfig {
  final ChatKind kind;
  final List<String> quickPrompts;
  final bool canModerate;
  final bool showSenderNames;
  final bool isPinnedOfficial;

  const ChatKindConfig({
    required this.kind,
    required this.quickPrompts,
    required this.canModerate,
    required this.showSenderNames,
    this.isPinnedOfficial = false,
  });

  static ChatKindConfig forConversationId(
    String conversationId,
  ) {
    if (conversationId == 'bot') {
      return const ChatKindConfig(
        kind: ChatKind.bot,
        isPinnedOfficial: true,
        canModerate: false,
        showSenderNames: false,
        quickPrompts: [
          'Rekomendasi sepatu populer',
          'Sepatu di bawah 1 juta',
          'Panduan ukuran sepatu',
          'Koleksi Running',
          'Cek status pesanan saya',
          'Info pembayaran & pengiriman',
        ],
      );
    }

    if (conversationId == 'admin') {
      return const ChatKindConfig(
        kind: ChatKind.admin,
        isPinnedOfficial: true,
        canModerate: false,
        showSenderNames: false,
        quickPrompts: [
          'Apakah ukuran 42 masih ready stock?',
          'Bagaimana prosedur tukar ukuran?',
          'Kendala verifikasi pembayaran',
          'Berapa lama pengiriman reguler?',
        ],
      );
    }

    final isGroup = conversationId == 'community_global';
    return ChatKindConfig(
      kind: isGroup ? ChatKind.group : ChatKind.direct,
      isPinnedOfficial: false,
      canModerate: true,
      showSenderNames: isGroup,
      quickPrompts: const [],
    );
  }

  String statusText(
    ChatController controller,
    String conversationId,
  ) {
    switch (kind) {
      case ChatKind.bot:
        return 'Online · Asisten AI 24/7';
      case ChatKind.admin:
        if (controller.replyAsAdminMode) {
          return 'Mode Admin aktif · Membalas sebagai Admin';
        }
        final status =
            controller.isAdminOnline ? 'Online' : 'Offline';
        return '$status · membalas ±10 menit';
      case ChatKind.group:
        return '${controller.onlineCommunityCount} anggota online';
      case ChatKind.direct:
        if (controller.isUserBlocked(conversationId)) {
          return 'Pengguna ini kamu blokir';
        }
        final peer = ChatController.peerContacts.firstWhere(
          (c) => c.id == conversationId,
          orElse: () => ChatController.peerContacts.first,
        );
        return peer.subtitle;
    }
  }
}

/// Menghasilkan warna nama pengirim dengan rasio kontras WCAG AA (>= 4.5:1).
Color senderNameColor(String userId) =>
    AppColors.senderNameColor(userId);

/// Membangun tema `flutter_chat_ui` v1.6.15 dengan input bar terang,
/// kolom teks berbentuk pill, dan tipografi yang konsisten dengan ThemeData.
DefaultChatTheme buildSoleaChatTheme(ThemeData theme) {
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  final baseBodyStyle = textTheme.bodyMedium ??
      const TextStyle(
        fontSize: ChatLayoutTokens.fontBody,
      );

  final inputStyle = baseBodyStyle.copyWith(
    color: colorScheme.onSurface,
    fontSize: ChatLayoutTokens.fontInput,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  final hintStyle = baseBodyStyle.copyWith(
    color: colorScheme.onSurfaceVariant,
    fontSize: ChatLayoutTokens.fontInput,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );

  return DefaultChatTheme(
    // Latar area pesan lembut agar bubble putih diterima tampak terpisah tegas
    backgroundColor: theme.scaffoldBackgroundColor,
    primaryColor: colorScheme.primary,
    secondaryColor: colorScheme.surface,

    // Input bar terang dengan garis atas tipis outlineVariant
    inputBackgroundColor: colorScheme.surface,
    inputSurfaceTintColor: Colors.transparent,
    inputElevation: 0,
    inputMargin: EdgeInsets.zero,
    inputPadding: const EdgeInsets.symmetric(
      horizontal: 6,
      vertical: 8,
    ),
    inputBorderRadius: BorderRadius.zero,
    inputContainerDecoration: BoxDecoration(
      color: colorScheme.surface,
      border: Border(
        top: BorderSide(
          color: colorScheme.outline,
          width: 1,
        ),
      ),
    ),

    // Kolom teks berbentuk pill (radius 24) dengan fill surfaceContainerHighest
    inputTextColor: colorScheme.onSurface,
    inputTextCursorColor: colorScheme.primary,
    inputTextStyle: inputStyle,
    inputTextDecoration: InputDecoration(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest,
      isCollapsed: false,
      hintStyle: hintStyle,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          ChatLayoutTokens.inputPillRadius,
        ),
        borderSide: BorderSide(
          color: colorScheme.outline,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          ChatLayoutTokens.inputPillRadius,
        ),
        borderSide: BorderSide(
          color: colorScheme.outline,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          ChatLayoutTokens.inputPillRadius,
        ),
        borderSide: BorderSide(
          color: colorScheme.primary,
          width: 1.5,
        ),
      ),
    ),

    // Tombol lampiran (48x48 dp tap target, warna onSurfaceVariant)
    attachmentButtonMargin: EdgeInsets.zero,
    attachmentButtonIcon: Semantics(
      button: true,
      label: 'Bagikan produk dari katalog',
      child: Tooltip(
        message: 'Bagikan produk dari katalog',
        child: SizedBox(
          width: ChatLayoutTokens.minTapTarget,
          height: ChatLayoutTokens.minTapTarget,
          child: Center(
            child: Icon(
              Icons.add_circle_outline_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 24,
            ),
          ),
        ),
      ),
    ),

    // Tombol kirim bulat berwarna primary dalam area 48x48 dp
    sendButtonMargin: EdgeInsets.zero,
    sendButtonIcon: Semantics(
      button: true,
      label: 'Kirim pesan',
      child: Tooltip(
        message: 'Kirim pesan',
        child: SizedBox(
          width: ChatLayoutTokens.minTapTarget,
          height: ChatLayoutTokens.minTapTarget,
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width:
                    ChatLayoutTokens.sendButtonCircleSize,
                height:
                    ChatLayoutTokens.sendButtonCircleSize,
                child: Icon(
                  Icons.send_rounded,
                  color: colorScheme.onPrimary,
                  size: 19,
                ),
              ),
            ),
          ),
        ),
      ),
    ),

    // Tipografi pesan & tanggal konsisten dengan Theme.textTheme
    messageBorderRadius: ChatLayoutTokens.bubbleRadius,
    messageInsetsHorizontal: 14,
    messageInsetsVertical: 10,
    sentMessageBodyTextStyle: baseBodyStyle.copyWith(
      color: colorScheme.onPrimary,
      fontSize: ChatLayoutTokens.fontBody,
      height: 1.45,
      fontWeight: FontWeight.w500,
    ),
    receivedMessageBodyTextStyle: baseBodyStyle.copyWith(
      color: colorScheme.onSurface,
      fontSize: ChatLayoutTokens.fontBody,
      height: 1.45,
      fontWeight: FontWeight.w500,
    ),
    dateDividerMargin: const EdgeInsets.symmetric(
      vertical: 14,
    ),
    dateDividerTextStyle:
        (textTheme.labelMedium ?? baseBodyStyle).copyWith(
      color: colorScheme.onSurface,
      fontSize: ChatLayoutTokens.fontCaption,
      fontWeight: FontWeight.w700,
    ),
    emptyChatPlaceholderTextStyle: baseBodyStyle.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontSize: ChatLayoutTokens.fontBody,
      fontWeight: FontWeight.w600,
    ),
    userNameTextStyle:
        (textTheme.labelMedium ?? baseBodyStyle).copyWith(
      fontSize: ChatLayoutTokens.fontCaption,
      fontWeight: FontWeight.w800,
    ),
  );
}
