import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart'
    as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:intl/intl.dart';

import '../../controllers/chat_controller.dart';
import '../../controllers/product_controller.dart';
import '../../core/app_helpers.dart';
import '../../core/app_routes.dart';
import 'chat_theme.dart';
import 'widgets/chat_header.dart';
import 'widgets/conversation_list.dart';
import 'widgets/moderation_sheet.dart';
import 'widgets/quick_prompt_bar.dart';

export 'chat_theme.dart' show senderNameColor;

/// Entry point SOLEA Chat dengan pola navigasi mirip WhatsApp:
/// - Rute `/chat` (`conversationId == null`):
///   - Layar sempit (< 840 dp): menampilkan `ChatListPage` (daftar percakapan).
///     Ketuk item -> `Navigator.pushNamed('/chat/$id')`.
///   - Layar lebar (>= 840 dp): master-detail (daftar kiri 320 dp + ruang chat kanan maks 720 dp).
/// - Rute `/chat/:id` (`conversationId != null`):
///   - Layar sempit (< 840 dp): menampilkan `ChatRoomPage` penuh dengan tombol kembali ke daftar.
///   - Layar lebar (>= 840 dp): master-detail dengan percakapan `:id` terpilih.
class ChatPage extends StatefulWidget {
  final SoleaChatChannel initialChannel;
  final String? conversationId;

  const ChatPage({
    super.key,
    this.initialChannel = SoleaChatChannel.bot,
    this.conversationId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatController _controller =
      ChatController.instance;

  @override
  void initState() {
    super.initState();

    final initialConvId = widget.conversationId?.trim();
    if (initialConvId != null && initialConvId.isNotEmpty) {
      _controller.selectConversation(initialConvId);
    } else if (widget.initialChannel !=
        SoleaChatChannel.bot) {
      final targetId =
          widget.initialChannel == SoleaChatChannel.admin
              ? 'admin'
              : _controller.activeUserRoomId;
      _controller.selectConversation(targetId);
    }

    _controller.connectRealtimeStreams();
  }

  @override
  void didUpdateWidget(covariant ChatPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newId = widget.conversationId?.trim();
    if (newId != null &&
        newId.isNotEmpty &&
        newId != oldWidget.conversationId) {
      _controller.selectConversation(newId);
    }
  }

  void _handleSelectConversation(
    String conversationId, {
    required bool isWide,
  }) {
    _controller.selectConversation(conversationId);
    if (!isWide) {
      Navigator.of(context).pushNamed(
        AppRoutes.chatConversation(conversationId),
      );
    }
  }

  void _openPrivacySettings() {
    showCommunityPrivacyAndBlockedSheet(
      context: context,
      controller: _controller,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >=
                ChatLayoutTokens.wideBreakpoint;
            final hasExplicitRoomRoute =
                widget.conversationId != null &&
                    widget.conversationId!
                        .trim()
                        .isNotEmpty;

            // 1. Layar lebar (>= 840 dp): Master-Detail tanpa tab
            if (isWide) {
              return Scaffold(
                backgroundColor:
                    theme.scaffoldBackgroundColor,
                appBar: ChatListAppBar(
                  onOpenPrivacySettings:
                      _openPrivacySettings,
                ),
                body: SafeArea(
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width:
                            ChatLayoutTokens.sidebarWidth,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            border: Border(
                              right: BorderSide(
                                color: colorScheme.outline,
                              ),
                            ),
                          ),
                          child: ConversationList(
                            controller: _controller,
                            selectedConversationId:
                                _controller
                                    .activeConversationId,
                            onSelectConversation: (id) =>
                                _handleSelectConversation(
                              id,
                              isWide: true,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ChatRoomView(
                          controller: _controller,
                          conversationId: _controller
                              .activeConversationId,
                          showBackButton: false,
                          isWideLayout: true,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // 2. Layar sempit (< 840 dp) pada rute /chat/:id -> ChatRoomPage
            if (hasExplicitRoomRoute) {
              return Scaffold(
                backgroundColor:
                    theme.scaffoldBackgroundColor,
                body: SafeArea(
                  child: ChatRoomView(
                    controller: _controller,
                    conversationId:
                        _controller.activeConversationId,
                    showBackButton: true,
                    isWideLayout: false,
                  ),
                ),
              );
            }

            // 3. Layar sempit (< 840 dp) pada rute /chat -> ChatListPage
            return Scaffold(
              backgroundColor: colorScheme.surface,
              appBar: ChatListAppBar(
                onOpenPrivacySettings: _openPrivacySettings,
              ),
              body: SafeArea(
                child: ConversationList(
                  controller: _controller,
                  selectedConversationId: null,
                  onSelectConversation: (id) =>
                      _handleSelectConversation(
                    id,
                    isWide: false,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Ruang percakapan tunggal (`ChatRoomPage` / panel kanan Master-Detail).
class ChatRoomView extends StatelessWidget {
  final ChatController controller;
  final String conversationId;
  final bool showBackButton;
  final bool isWideLayout;

  const ChatRoomView({
    super.key,
    required this.controller,
    required this.conversationId,
    required this.showBackButton,
    required this.isWideLayout,
  });

  List<types.Message> get _messages {
    if (conversationId == 'bot') {
      return controller.botMessages;
    }
    if (conversationId == 'admin') {
      return controller.adminMessages;
    }
    return controller.activeUserMessages;
  }

  types.User get _activeSenderUser {
    if (conversationId == 'admin' &&
        controller.replyAsAdminMode) {
      return ChatController.adminUser;
    }
    return controller.currentUser;
  }

  List<types.User> _typingUsers(ChatKind kind) {
    switch (kind) {
      case ChatKind.bot:
        return controller.isBotTyping
            ? [ChatController.botUser]
            : const [];
      case ChatKind.admin:
        return controller.isAdminTyping
            ? [ChatController.adminUser]
            : const [];
      case ChatKind.group:
      case ChatKind.direct:
        if (!controller.isPeerTyping) return const [];
        final contact = controller.activePeerContact;
        return [
          types.User(
            id: contact.id,
            firstName: contact.name.split(' ').first,
          ),
        ];
    }
  }

  void _handleSend(ChatKind kind, String rawText) {
    final text = rawText.trim();
    if (text.isEmpty) return;

    switch (kind) {
      case ChatKind.bot:
        controller.sendBotMessage(text);
        break;
      case ChatKind.admin:
        controller.sendAdminChannelMessage(text);
        break;
      case ChatKind.group:
      case ChatKind.direct:
        controller.sendUserChannelMessage(text);
        break;
    }
  }

  void _handleEscalateBotToAdmin(BuildContext context) {
    final lastQuery =
        controller.lastEscalatableQuery.trim();
    controller.clearBotEscalation();

    // C.4: Format teks eskalasi yang natural (tidak robotik untuk query pendek)
    final escalationMessage = lastQuery.length < 8
        ? 'Halo Admin, saya butuh bantuan dengan pesanan/produk saya.'
        : 'Halo Admin, saya butuh bantuan: "$lastQuery"';

    controller.selectConversation('admin');
    controller.sendAdminChannelMessage(escalationMessage);

    if (!isWideLayout) {
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.chatConversation('admin'),
      );
    }
  }

  types.User _peerUserForDirectRoom() {
    final contact = controller.activePeerContact;
    final parts = contact.name.split(' ');
    return types.User(
      id: contact.id,
      firstName: parts.first,
      lastName:
          parts.length > 1 ? parts.sublist(1).join(' ') : '',
      imageUrl: contact.avatarUrl,
    );
  }

  bool _canModerateAuthor(
    ChatKindConfig config,
    types.User author,
  ) {
    if (!config.canModerate) return false;
    if (author.id == 'solea_bot' ||
        author.id == 'solea_admin' ||
        author.id == controller.currentUser.id) {
      return false;
    }
    return true;
  }

  void _onMessageLongPress(
    BuildContext context,
    ChatKindConfig config,
    types.Message message,
  ) {
    if (!_canModerateAuthor(config, message.author)) {
      return;
    }
    final msgText = message is types.TextMessage
        ? message.text
        : (message is types.ImageMessage
            ? message.name
            : '');

    showUserProfileModerationSheet(
      context: context,
      controller: controller,
      author: message.author,
      messageId: message.id,
      messageText: msgText,
    );
  }

  void _onAvatarTap(
    BuildContext context,
    ChatKindConfig config,
    types.User author,
  ) {
    if (!_canModerateAuthor(config, author)) return;
    showUserProfileModerationSheet(
      context: context,
      controller: controller,
      author: author,
    );
  }

  void _openShareProductModal(
    BuildContext context,
    ChatKind kind,
  ) {
    final products = ProductController.products;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final targetChannel = kind == ChatKind.bot
        ? SoleaChatChannel.bot
        : kind == ChatKind.admin
            ? SoleaChatChannel.admin
            : SoleaChatChannel.user;

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
              18,
              20,
              16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Kirim Produk ke Ruang Chat',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: 'Tutup daftar produk',
                      child: IconButton(
                        tooltip: 'Tutup daftar produk',
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
                const SizedBox(height: 6),
                Text(
                  'Pilih sepatu dari katalog SOLEA untuk ditanyakan atau dibagikan:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: ChatLayoutTokens.fontLabel,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(
                          vertical: 4,
                        ),
                        leading: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(10),
                          child: Image.network(
                            product.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, _, _) => Container(
                              width: 50,
                              height: 50,
                              color: theme
                                  .scaffoldBackgroundColor,
                              child: Icon(
                                Icons.directions_run_rounded,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          product.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          '${product.category} · ${formatRupiah(product.price)}',
                          style: TextStyle(
                            fontSize:
                                ChatLayoutTokens.fontCaption,
                            color:
                                colorScheme.onSurfaceVariant,
                          ),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            controller.shareProductToChannel(
                              targetChannel,
                              product,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                colorScheme.primary,
                            foregroundColor:
                                colorScheme.onPrimary,
                            minimumSize: const Size(
                              76,
                              ChatLayoutTokens.minTapTarget,
                            ),
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 14,
                            ),
                          ),
                          child: const Text('Kirim'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Custom bubble builder:
  /// - Memisahkan bubble pesan diterima (#FFFFFF + border tipis outline) dari latar krem (#F7F5F0)
  /// - Menampilkan nama pengirim secara konsisten di setiap pesan grup (D.5),
  ///   dan menyembunyikan nama pengirim di chat 1-lawan-1 (bot/admin/DM)
  /// - Menampilkan jam kecil "HH:mm" berbahasa Indonesia di tiap pesan (D.1).
  Widget _buildCustomBubble(
    BuildContext context,
    Widget child, {
    required types.Message message,
    required bool nextMessageInGroup,
    required ChatKindConfig config,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSentByMe =
        message.author.id == _activeSenderUser.id;
    final showAuthorHeader =
        config.showSenderNames && !isSentByMe;

    final authorName = [
      message.author.firstName ?? '',
      message.author.lastName ?? '',
    ].where((s) => s.trim().isNotEmpty).join(' ').trim();

    final createdAtMs = message.createdAt;
    final timeStr = createdAtMs != null
        ? DateFormat('HH:mm', 'id_ID').format(
            DateTime.fromMillisecondsSinceEpoch(
              createdAtMs,
            ),
          )
        : '';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isSentByMe
            ? colorScheme.primary
            : colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(
            ChatLayoutTokens.bubbleRadius,
          ),
          topRight: const Radius.circular(
            ChatLayoutTokens.bubbleRadius,
          ),
          bottomLeft: Radius.circular(
            isSentByMe ? ChatLayoutTokens.bubbleRadius : 4,
          ),
          bottomRight: Radius.circular(
            isSentByMe ? 4 : ChatLayoutTokens.bubbleRadius,
          ),
        ),
        border: isSentByMe
            ? null
            : Border.all(
                color: colorScheme.outline,
                width: 1,
              ),
      ),
      child: Column(
        crossAxisAlignment: isSentByMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showAuthorHeader &&
              authorName.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                14,
                10,
                14,
                0,
              ),
              child: Text(
                authorName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontSize: ChatLayoutTokens.fontCaption,
                  fontWeight: FontWeight.w800,
                  color: senderNameColor(
                    message.author.id,
                    brightness: theme.brightness,
                  ),
                ),
              ),
            ),
          ],
          child,
          if (timeStr.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                0,
                12,
                6,
              ),
              child: Text(
                timeStr,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: ChatLayoutTokens.fontCaption,
                  color: isSentByMe
                      ? colorScheme.onPrimary
                          .withValues(alpha: 0.82)
                      : colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget? _buildListBottomWidget(
    BuildContext context,
    ChatKindConfig config,
    List<types.Message> messages,
    bool isBlocked,
  ) {
    if (isBlocked) return null;

    // A.6: Kartu eskalasi tunggal "Hubungi Admin" di bawah balasan Bot
    final showEscalationCard =
        config.kind == ChatKind.bot &&
            controller.showBotEscalateToAdmin &&
            controller.lastEscalatableQuery
                .trim()
                .isNotEmpty;

    // C.3: Quick-prompt chip tampil HANYA saat percakapan baru dimulai (<= 2 pesan)
    // dan HANYA untuk Bot/Admin (config.quickPrompts tidak kosong)
    final showQuickPrompts =
        config.quickPrompts.isNotEmpty &&
            messages.length <= 2;

    if (!showEscalationCard && !showQuickPrompts) {
      return null;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showEscalationCard)
          BotAdminEscalationCard(
            onContactAdmin: () =>
                _handleEscalateBotToAdmin(context),
          ),
        if (showQuickPrompts)
          QuickPromptBar(
            prompts: config.quickPrompts,
            onPromptSelected: (prompt) =>
                _handleSend(config.kind, prompt),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final conversation = controller.activeConversation;
    final config =
        ChatKindConfig.forConversationId(conversation.id);
    final messages = _messages;
    final isBlockedDirect =
        config.kind == ChatKind.direct &&
            controller.isUserBlocked(conversation.id);

    final emptyPlaceholder = isBlockedDirect
        ? 'Pesan dari pengguna ini disembunyikan.'
        : 'Belum ada pesan. Sapa dulu yuk!';

    return Column(
      children: [
        // 1. HEADER SATU BARIS (TANPA TAB & TANPA BANNER KOTAK)
        ChatRoomHeader(
          conversation: conversation,
          config: config,
          controller: controller,
          showBackButton: showBackButton,
          onOpenPeerProfile: () {
            if (config.kind == ChatKind.direct) {
              showUserProfileModerationSheet(
                context: context,
                controller: controller,
                author: _peerUserForDirectRoom(),
              );
            }
          },
          onReportPeer: () {
            if (config.kind == ChatKind.direct) {
              final peer = _peerUserForDirectRoom();
              showReportReasonDialog(
                context: context,
                controller: controller,
                targetUserId: peer.id,
                targetUserName: conversation.title,
              );
            }
          },
          onToggleBlockPeer: () async {
            if (config.kind != ChatKind.direct) return;
            final messenger = ScaffoldMessenger.of(context);
            if (isBlockedDirect) {
              await controller
                  .unblockUser(conversation.id);
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    'Blokir ${conversation.title} telah dibuka.',
                  ),
                ),
              );
            } else {
              await controller.blockUser(
                targetUserId: conversation.id,
                targetUserName: conversation.title,
                reason: 'Diblokir dari ruang DM SOLEA',
              );
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    '${conversation.title} telah diblokir. Pesannya disembunyikan.',
                  ),
                ),
              );
            }
          },
          onOpenPrivacySettings: () {
            showCommunityPrivacyAndBlockedSheet(
              context: context,
              controller: controller,
            );
          },
        ),

        // 2. AREA PESAN DATAR (TANPA CLIPRRECT & PADDING LUAR 12 DP)
        Expanded(
          child: Chat(
            key: ValueKey<String>(
              '${conversation.id}_$isBlockedDirect',
            ),
            messages: messages,
            onSendPressed: (partial) =>
                _handleSend(config.kind, partial.text),
            onAttachmentPressed: () =>
                _openShareProductModal(
              context,
              config.kind,
            ),
            // C.1: onMessageTap dihapus; hanya onMessageLongPress & onAvatarTap
            onMessageLongPress: (_, msg) =>
                _onMessageLongPress(
              context,
              config,
              msg,
            ),
            onAvatarTap: (author) => _onAvatarTap(
              context,
              config,
              author,
            ),
            user: _activeSenderUser,
            showUserAvatars:
                config.kind == ChatKind.group,
            showUserNames: false,
            bubbleBuilder: (
              child, {
              required message,
              required nextMessageInGroup,
            }) =>
                _buildCustomBubble(
              context,
              child,
              message: message,
              nextMessageInGroup: nextMessageInGroup,
              config: config,
            ),
            // D.1: Format tanggal & jam bahasa Indonesia ("21 November", "HH:mm")
            dateLocale: 'id_ID',
            dateFormat: DateFormat('d MMMM', 'id_ID'),
            timeFormat: DateFormat('HH:mm', 'id_ID'),
            typingIndicatorOptions:
                TypingIndicatorOptions(
              typingUsers: _typingUsers(config.kind),
            ),
            inputOptions: const InputOptions(
              sendButtonVisibilityMode:
                  SendButtonVisibilityMode.always,
            ),
            customBottomWidget: isBlockedDirect
                ? BlockedUserBottomNotice(
                    userName: conversation.title,
                    onUnblock: () => controller
                        .unblockUser(conversation.id),
                  )
                : null,
            listBottomWidget: _buildListBottomWidget(
              context,
              config,
              messages,
              isBlockedDirect,
            ),
            l10n: ChatL10nEn(
              attachmentButtonAccessibilityLabel:
                  'Bagikan produk dari katalog',
              sendButtonAccessibilityLabel: 'Kirim pesan',
              inputPlaceholder:
                  'Tulis pesan atau pertanyaanmu di sini...',
              emptyChatPlaceholder: emptyPlaceholder,
            ),
            theme: buildSoleaChatTheme(theme),
          ),
        ),
      ],
    );
  }
}
