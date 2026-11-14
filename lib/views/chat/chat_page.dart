import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart'
    as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

import '../../controllers/chat_controller.dart';
import '../../controllers/product_controller.dart';
import '../../core/app_helpers.dart';
import '../../core/app_theme.dart';
import '../../core/home_button.dart';

class ChatPage extends StatefulWidget {
  final SoleaChatChannel initialChannel;

  const ChatPage({
    super.key,
    this.initialChannel = SoleaChatChannel.bot,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late SoleaChatChannel _selectedChannel;
  final ChatController _controller =
      ChatController.instance;

  @override
  void initState() {
    super.initState();
    _selectedChannel = widget.initialChannel;
    _controller.connectRealtimeStreams();
  }

  List<types.Message> get _currentMessages {
    switch (_selectedChannel) {
      case SoleaChatChannel.bot:
        return _controller.botMessages;
      case SoleaChatChannel.admin:
        return _controller.adminMessages;
      case SoleaChatChannel.user:
        return _controller.activeUserMessages;
    }
  }

  types.User get _activeSenderUser {
    if (_selectedChannel == SoleaChatChannel.admin &&
        _controller.replyAsAdminMode) {
      return ChatController.adminUser;
    }
    return _controller.currentUser;
  }

  List<types.User> get _typingUsers {
    switch (_selectedChannel) {
      case SoleaChatChannel.bot:
        return _controller.isBotTyping
            ? [ChatController.botUser]
            : const [];
      case SoleaChatChannel.admin:
        return _controller.isAdminTyping
            ? [ChatController.adminUser]
            : const [];
      case SoleaChatChannel.user:
        if (!_controller.isPeerTyping) return const [];
        final contact = _controller.activePeerContact;
        return [
          types.User(
            id: contact.id,
            firstName: contact.name.split(' ').first,
          ),
        ];
    }
  }

  List<String> get _quickPrompts {
    switch (_selectedChannel) {
      case SoleaChatChannel.bot:
        return const [
          'Rekomendasi sepatu populer',
          'Sepatu di bawah 1 juta',
          'Panduan ukuran sepatu',
          'Koleksi Running',
          'Cek status pesanan saya',
          'Info pembayaran & pengiriman',
        ];
      case SoleaChatChannel.admin:
        return const [
          'Apakah ukuran 42 masih ready stock?',
          'Bagaimana prosedur tukar ukuran?',
          'Kendala verifikasi pembayaran',
          'Berapa lama pengiriman reguler?',
        ];
      case SoleaChatChannel.user:
        return const [
          'Rekomendasi sepatu running terbaik?',
          'Ada yang sudah coba Court Vision?',
          'Info ukuran SOLEA true to size?',
          'Sneaker favorit kalian minggu ini?',
        ];
    }
  }

  void _handleSendPressed(types.PartialText partialText) {
    final text = partialText.text.trim();
    if (text.isEmpty) return;

    switch (_selectedChannel) {
      case SoleaChatChannel.bot:
        _controller.sendBotMessage(text);
        break;
      case SoleaChatChannel.admin:
        _controller.sendAdminChannelMessage(text);
        break;
      case SoleaChatChannel.user:
        _controller.sendUserChannelMessage(text);
        break;
    }
  }

  void _openShareProductModal() {
    final products = ProductController.products;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
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
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      color: AppColors.forest,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Kirim Produk ke Ruang Chat',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Pilih sepatu dari katalog SOLEA untuk ditanyakan atau dibagikan:',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: products.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1),
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
                                (_, _, _) =>
                                    Container(
                              width: 50,
                              height: 50,
                              color: AppColors.sand,
                              child: const Icon(
                                Icons
                                    .directions_run_rounded,
                                color: AppColors.forest,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        subtitle: Text(
                          '${product.category} · ${formatRupiah(product.price)}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.muted,
                          ),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            _controller
                                .shareProductToChannel(
                              _selectedChannel,
                              product,
                            );
                          },
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColors.forest,
                            foregroundColor:
                                Colors.white,
                            minimumSize:
                                const Size(76, 36),
                            padding: const EdgeInsets
                                .symmetric(
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.sand,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            titleSpacing: 0,
            title: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.forest,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.forum_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SOLEA Chat Hub',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      'Chat Bot · Admin Support · Komunitas User',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: const [
              HomeButton(),
              SizedBox(width: 6),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                height: 1,
                color: AppColors.line,
              ),
            ),
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1120,
                ),
                child: Column(
                  children: [
                    // 1. TAB PEMILIH MODE CHAT (BOT / ADMIN / USER)
                    _buildChannelSelector(),

                    // 2. HEADER KONTEKS CHANNEL (SUB-INFO / PILIH USER / MODE ADMIN)
                    _buildChannelContextBanner(),

                    // 3. WIDGET UTAMA FLUTTER_CHAT_UI
                    Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: Chat(
                            key: ValueKey<String>(
                              '${_selectedChannel.name}_${_controller.activeUserRoomId}',
                            ),
                            messages: _currentMessages,
                            onSendPressed:
                                _handleSendPressed,
                            onAttachmentPressed:
                                _openShareProductModal,
                            user: _activeSenderUser,
                            showUserAvatars: true,
                            showUserNames: true,
                            typingIndicatorOptions:
                                TypingIndicatorOptions(
                              typingUsers: _typingUsers,
                            ),
                            inputOptions:
                                const InputOptions(
                              sendButtonVisibilityMode:
                                  SendButtonVisibilityMode
                                      .always,
                            ),
                            listBottomWidget:
                                _buildQuickPromptBar(),
                            l10n: const ChatL10nEn(
                              inputPlaceholder:
                                  'Tulis pesan atau pertanyaanmu di sini...',
                              emptyChatPlaceholder:
                                  'Belum ada percakapan. Mulai kirim pesan sekarang!',
                            ),
                            theme: DefaultChatTheme(
                              backgroundColor:
                                  Colors.white,
                              primaryColor:
                                  AppColors.forest,
                              secondaryColor:
                                  const Color(0xFFF2F0EA),
                              inputBackgroundColor:
                                  const Color(0xFF14201B),
                              inputTextColor:
                                  AppColors.ink,
                              inputTextCursorColor:
                                  AppColors.forest,
                              inputPadding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 10,
                                vertical: 12,
                              ),
                              inputTextStyle:
                                  const TextStyle(
                                color: AppColors.ink,
                                fontSize: 14.5,
                                fontWeight:
                                    FontWeight.w500,
                                height: 1.35,
                              ),
                              inputTextDecoration:
                                  InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                isCollapsed: false,
                                contentPadding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 18,
                                  vertical: 16,
                                ),
                                border:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(14),
                                  borderSide:
                                      BorderSide.none,
                                ),
                                enabledBorder:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(14),
                                  borderSide:
                                      BorderSide.none,
                                ),
                                focusedBorder:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(14),
                                  borderSide:
                                      const BorderSide(
                                    color:
                                        AppColors.forest,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              attachmentButtonIcon:
                                  const Icon(
                                Icons
                                    .add_circle_outline_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                              sendButtonIcon: const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              inputBorderRadius:
                                  const BorderRadius
                                      .vertical(
                                top: Radius.circular(18),
                              ),
                              messageBorderRadius: 16,
                              sentMessageBodyTextStyle:
                                  const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1.45,
                                fontWeight:
                                    FontWeight.w500,
                              ),
                              receivedMessageBodyTextStyle:
                                  const TextStyle(
                                color: AppColors.ink,
                                fontSize: 14,
                                height: 1.45,
                                fontWeight:
                                    FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // PEMILIH 3 CHANNEL: CHAT BOT / CHAT ADMIN / CHAT USER

  Widget _buildChannelSelector() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ChannelTabButton(
              icon: Icons.smart_toy_outlined,
              label: 'Chat Bot',
              subtitle: 'AI Assistant',
              selected: _selectedChannel ==
                  SoleaChatChannel.bot,
              onTap: () {
                setState(() {
                  _selectedChannel =
                      SoleaChatChannel.bot;
                });
              },
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _ChannelTabButton(
              icon: Icons.support_agent_rounded,
              label: 'Chat Admin',
              subtitle: 'Live Support',
              selected: _selectedChannel ==
                  SoleaChatChannel.admin,
              onTap: () {
                setState(() {
                  _selectedChannel =
                      SoleaChatChannel.admin;
                });
              },
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _ChannelTabButton(
              icon: Icons.people_alt_outlined,
              label: 'Chat User',
              subtitle: 'Komunitas & DM',
              selected: _selectedChannel ==
                  SoleaChatChannel.user,
              onTap: () {
                setState(() {
                  _selectedChannel =
                      SoleaChatChannel.user;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // BANNER KONTEKS TIAP CHANNEL

  Widget _buildChannelContextBanner() {
    if (_selectedChannel == SoleaChatChannel.bot) {
      return Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F0EC),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              size: 18,
              color: AppColors.forest,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'SOLEA AI Bot aktif 24/7 — Tanyakan rekomendasi sepatu, ukuran, atau status pesananmu.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.forestDeep,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: _openShareProductModal,
              icon: const Icon(
                Icons.add_shopping_cart_rounded,
                size: 16,
              ),
              label: const Text(
                'Tanya Produk',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    if (_selectedChannel == SoleaChatChannel.admin) {
      final isAdminMode = _controller.replyAsAdminMode;
      return Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isAdminMode
              ? const Color(0xFF14201B)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isAdminMode
                ? AppColors.forest
                : AppColors.line,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isAdminMode
                  ? Icons.verified_user_rounded
                  : Icons.support_agent_rounded,
              size: 18,
              color: isAdminMode
                  ? const Color(0xFFB9BEA0)
                  : AppColors.forest,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isAdminMode
                    ? 'Mode Admin Aktif: Pesan yang kamu ketik akan dikirim sebagai Admin SOLEA.'
                    : 'Terhubung dengan Admin Customer Support SOLEA (Tersinkronisasi Cloud Firestore).',
                style: TextStyle(
                  fontSize: 12.5,
                  color: isAdminMode
                      ? Colors.white
                      : AppColors.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
             OutlinedButton.icon(
              onPressed:
                  _controller.toggleReplyAsAdminMode,
              style: OutlinedButton.styleFrom(
                foregroundColor: isAdminMode
                    ? const Color(0xFFF3EFE5)
                    : AppColors.forest,
                side: BorderSide(
                  color: isAdminMode
                      ? const Color(0xFFB9BEA0)
                      : AppColors.forest,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                minimumSize: const Size(0, 32),
              ),
              icon: Icon(
                isAdminMode
                    ? Icons.person_outline_rounded
                    : Icons.admin_panel_settings_outlined,
                size: 15,
              ),
              label: Text(
                isAdminMode
                    ? 'Ganti ke User'
                    : 'Mode Admin',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Channel User: pemilih grup komunitas atau DM user lain
    return Container(
      height: 50,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ChatController.peerContacts.length,
        separatorBuilder: (_, _) =>
            const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final contact =
              ChatController.peerContacts[index];
          final active = contact.id ==
              _controller.activeUserRoomId;

          return ChoiceChip(
            selected: active,
            onSelected: (_) {
              _controller.selectUserRoom(contact.id);
            },
            avatar: CircleAvatar(
              backgroundImage:
                  NetworkImage(contact.avatarUrl),
              backgroundColor: AppColors.sand,
            ),
            label: Text(contact.name),
            selectedColor: AppColors.forest,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: active
                  ? Colors.white
                  : AppColors.ink,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
            side: BorderSide(
              color: active
                  ? AppColors.forest
                  : AppColors.line,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          );
        },
      ),
    );
  }

  // BAR TOMBOL CEPAT (QUICK PROMPTS) DI ATAS INPUT

  Widget _buildQuickPromptBar() {
    final prompts = _quickPrompts;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.line),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final prompt in prompts)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  onPressed: () {
                    _handleSendPressed(
                      types.PartialText(text: prompt),
                    );
                  },
                  backgroundColor: AppColors.sand,
                  side: const BorderSide(
                    color: AppColors.line,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(999),
                  ),
                  label: Text(
                    prompt,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// TOMBOL TAB CHANNEL CHAT

class _ChannelTabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ChannelTabButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.forest
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 19,
                color: selected
                    ? Colors.white
                    : AppColors.ink,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: selected
                            ? Colors.white
                            : AppColors.ink,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: selected
                            ? Colors.white
                                .withValues(alpha: 0.82)
                            : AppColors.muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
