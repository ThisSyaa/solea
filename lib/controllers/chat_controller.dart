import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart'
    as types;

import '../core/app_helpers.dart';
import '../services/ai_chat_service.dart';
import '../models/product.dart';
import 'auth_controller.dart';
import 'cart_controller.dart';
import 'order_controller.dart';
import 'product_controller.dart';
import 'wishlist_controller.dart';

enum SoleaChatChannel {
  bot,
  admin,
  user,
}

enum ChatConversationSection {
  bantuan,
  komunitas,
}

enum DmPrivacyPermission {
  everyone,
  community,
  none,
}

class ChatConversationItem {
  final String id;
  final String title;
  final String subtitle;
  final String? avatarUrl;
  final ChatConversationSection section;
  final SoleaChatChannel channel;
  final bool isGroup;
  final bool isOnline;

  const ChatConversationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.section,
    required this.channel,
    this.avatarUrl,
    this.isGroup = false,
    this.isOnline = true,
  });
}

class PeerUserContact {
  final String id;
  final String name;
  final String subtitle;
  final String avatarUrl;
  final bool isGroup;

  const PeerUserContact({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.avatarUrl,
    this.isGroup = false,
  });
}

class ChatController extends ChangeNotifier {
  ChatController._() {
    _initBotWelcome();
    _initAdminWelcome();
    _initUserRooms();
  }

  static final ChatController instance = ChatController._();

  // IDENTITAS USER & PARTISIPAN CHAT

  static final types.User botUser = types.User(
    id: 'solea_bot',
    firstName: 'SOLEA',
    lastName: 'AI Bot',
    imageUrl:
        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=240&q=80',
  );

  static final types.User adminUser = types.User(
    id: 'solea_admin',
    firstName: 'Admin',
    lastName: 'SOLEA Support',
    imageUrl:
        'https://avatars.githubusercontent.com/u/174694675?v=4',
  );

  static const List<PeerUserContact> peerContacts = [
    PeerUserContact(
      id: 'community_global',
      name: 'Sneakerheads Lounge (Grup)',
      subtitle: 'Ruang diskusi publik pengguna SOLEA',
      avatarUrl:
          'https://images.unsplash.com/photo-1552346154-21d32810aba3?auto=format&fit=crop&w=240&q=80',
      isGroup: true,
    ),
    PeerUserContact(
      id: 'peer_raka',
      name: 'Raka Pratama',
      subtitle: 'Sneaker Enthusiast · Online',
      avatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=240&q=80',
    ),
    PeerUserContact(
      id: 'peer_nadia',
      name: 'Nadia Putri',
      subtitle: 'Runner & Collector · Online',
      avatarUrl:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=240&q=80',
    ),
    PeerUserContact(
      id: 'peer_dimas',
      name: 'Dimas Arya',
      subtitle: 'Basketball Player · Aktif baru saja',
      avatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=240&q=80',
    ),
  ];

  types.User get currentUser {
    final uid = AuthController.currentUid ?? 'guest_user';
    final rawName = (AuthController.currentName ??
            AuthController.firebaseUser?.displayName ??
            'Member SOLEA')
        .trim();

    final parts = rawName.split(' ');
    final first = parts.isNotEmpty ? parts.first : 'Member';
    final last =
        parts.length > 1 ? parts.sublist(1).join(' ') : '';

    return types.User(
      id: uid,
      firstName: first,
      lastName: last,
    );
  }

  // STATE PER CHANNEL (TERBARU DI INDEX 0 SESUAI FLUTTER_CHAT_UI)

  final List<types.Message> _botMessages = [];
  final List<types.Message> _adminMessages = [];
  final Map<String, List<types.Message>> _userRoomMessages =
      {};

  String _activeUserRoomId = peerContacts.first.id;
  SoleaChatChannel? _activeChannel;

  bool _isBotTyping = false;
  bool _isAdminTyping = false;
  bool _isPeerTyping = false;
  bool? _isAdminOnline;
  bool? _showBotEscalateToAdmin;
  String? _lastEscalatableQuery;

  int? _unreadBotCount;
  int? _unreadAdminCount;
  Map<String, int>? _unreadUserRoomCounts;
  Set<String>? _blockedUserIds;
  DmPrivacyPermission? _dmPrivacy;

  Set<String> get blockedUserIds =>
      _blockedUserIds ??= <String>{};

  DmPrivacyPermission get dmPrivacy =>
      _dmPrivacy ?? DmPrivacyPermission.everyone;

  bool isUserBlocked(String userId) =>
      blockedUserIds.contains(userId);

  Map<String, int> get _roomUnreadMap =>
      _unreadUserRoomCounts ??= <String, int>{
        'community_global': 2,
        'peer_raka': 1,
        'peer_nadia': 1,
        'peer_dimas': 0,
      };

  /// Jika aktif, pesan yang dikirim di tab Admin akan dikirim sebagai Admin SOLEA
  bool _replyAsAdminMode = false;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _adminSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _userRoomSub;

  List<types.Message> get botMessages =>
      List.unmodifiable(_botMessages);

  List<types.Message> get adminMessages =>
      List.unmodifiable(_adminMessages);

  List<types.Message> get activeUserMessages {
    final raw =
        _userRoomMessages[_activeUserRoomId] ?? const [];
    final blocked = blockedUserIds;
    if (blocked.isEmpty) {
      return List.unmodifiable(raw);
    }
    return List.unmodifiable(
      raw.where((m) => !blocked.contains(m.author.id)),
    );
  }

  String get activeUserRoomId => _activeUserRoomId;

  PeerUserContact get activePeerContact =>
      peerContacts.firstWhere(
        (c) => c.id == _activeUserRoomId,
        orElse: () => peerContacts.first,
      );

  bool get isBotTyping => _isBotTyping;
  bool get isAdminTyping => _isAdminTyping;
  bool get isPeerTyping => _isPeerTyping;
  bool get isAdminOnline => _isAdminOnline ?? true;
  bool get showBotEscalateToAdmin =>
      _showBotEscalateToAdmin ?? false;
  String get lastEscalatableQuery =>
      _lastEscalatableQuery ?? '';
  int get onlineCommunityCount => 18;
  SoleaChatChannel get activeChannel =>
      _activeChannel ?? SoleaChatChannel.bot;

  int unreadCountForChannel(SoleaChatChannel channel) {
    switch (channel) {
      case SoleaChatChannel.bot:
        return _unreadBotCount ?? 0;
      case SoleaChatChannel.admin:
        return _unreadAdminCount ?? 1;
      case SoleaChatChannel.user:
        return _roomUnreadMap.values.fold<int>(
          0,
          (sum, count) => sum + count,
        );
    }
  }

  int unreadCountForUserRoom(String roomId) =>
      _roomUnreadMap[roomId] ?? 0;

  String get activeConversationId {
    switch (activeChannel) {
      case SoleaChatChannel.bot:
        return 'bot';
      case SoleaChatChannel.admin:
        return 'admin';
      case SoleaChatChannel.user:
        return _activeUserRoomId;
    }
  }

  List<ChatConversationItem> get allConversations => [
        ChatConversationItem(
          id: 'bot',
          title: 'SOLEA Assistant',
          subtitle: 'Asisten AI 24/7 · Rekomendasi & Ukuran',
          avatarUrl: botUser.imageUrl,
          section: ChatConversationSection.bantuan,
          channel: SoleaChatChannel.bot,
          isOnline: true,
        ),
        ChatConversationItem(
          id: 'admin',
          title: 'Admin Support',
          subtitle:
              'Admin SOLEA · Biasanya membalas dalam ±10 menit',
          avatarUrl: adminUser.imageUrl,
          section: ChatConversationSection.bantuan,
          channel: SoleaChatChannel.admin,
          isOnline: isAdminOnline,
        ),
        for (final peer in peerContacts)
          ChatConversationItem(
            id: peer.id,
            title: peer.name,
            subtitle: peer.subtitle,
            avatarUrl: peer.avatarUrl,
            section: ChatConversationSection.komunitas,
            channel: SoleaChatChannel.user,
            isGroup: peer.isGroup,
            isOnline: true,
          ),
      ];

  ChatConversationItem get activeConversation {
    final currentId = activeConversationId;
    final list = allConversations;
    return list.firstWhere(
      (c) => c.id == currentId,
      orElse: () => list.first,
    );
  }

  int unreadCountForConversation(String conversationId) {
    if (conversationId == 'bot') {
      return _unreadBotCount ?? 0;
    }
    if (conversationId == 'admin') {
      return _unreadAdminCount ?? 1;
    }
    return unreadCountForUserRoom(conversationId);
  }

  String lastMessagePreview(String conversationId) {
    List<types.Message> list;
    if (conversationId == 'bot') {
      list = _botMessages;
    } else if (conversationId == 'admin') {
      list = _adminMessages;
    } else {
      list = _userRoomMessages[conversationId] ?? const [];
    }

    for (final msg in list) {
      if (msg is types.TextMessage) {
        return msg.text.replaceAll('\n', ' ').trim();
      }
      if (msg is types.ImageMessage) {
        return '📷 Gambar: ${msg.name}';
      }
    }
    return 'Mulai percakapan...';
  }

  void selectConversation(String conversationId) {
    if (conversationId == 'bot') {
      setActiveChannel(SoleaChatChannel.bot);
      return;
    }
    if (conversationId == 'admin') {
      setActiveChannel(SoleaChatChannel.admin);
      return;
    }
    final exists =
        peerContacts.any((c) => c.id == conversationId);
    final targetRoomId = exists
        ? conversationId
        : peerContacts.first.id;
    _activeUserRoomId = targetRoomId;
    _roomUnreadMap[targetRoomId] = 0;
    _activeChannel = SoleaChatChannel.user;
    _subscribeUserRoomFirestore(targetRoomId);
    notifyListeners();
  }

  void setActiveChannel(SoleaChatChannel channel) {
    _activeChannel = channel;
    switch (channel) {
      case SoleaChatChannel.bot:
        _unreadBotCount = 0;
        break;
      case SoleaChatChannel.admin:
        _unreadAdminCount = 0;
        break;
      case SoleaChatChannel.user:
        _roomUnreadMap[_activeUserRoomId] = 0;
        break;
    }
    notifyListeners();
  }

  bool get isCurrentUserAdmin =>
      AuthController.isCurrentUserAdmin;
  bool get replyAsAdminMode =>
      isCurrentUserAdmin && _replyAsAdminMode;

  void toggleReplyAsAdminMode() {
    if (!isCurrentUserAdmin) {
      _replyAsAdminMode = false;
      return;
    }
    _replyAsAdminMode = !_replyAsAdminMode;
    notifyListeners();
  }

  void selectUserRoom(String roomId) {
    _activeUserRoomId = roomId;
    _roomUnreadMap[roomId] = 0;
    _subscribeUserRoomFirestore(roomId);
    notifyListeners();
  }

  /// Mendeteksi apakah pertanyaan user tentang masalah pesanan atau bot tidak yakin.
  bool _shouldOfferAdminEscalation(
    String userText,
    String replyText,
  ) {
    final q = userText.toLowerCase();
    final r = replyText.toLowerCase();

    const orderOrIssueKeywords = [
      'pesanan',
      'order',
      'status',
      'komplain',
      'retur',
      'refund',
      'rusak',
      'lama',
      'belum sampai',
      'kendala',
      'masalah',
      'batal',
      'tukar',
      'admin',
      'cs',
      'bantuan',
    ];

    const botUncertainKeywords = [
      'admin',
      'tidak yakin',
      'tidak tahu',
      'belum tahu',
      'maaf',
      'hubungi',
      'customer support',
      'layanan pelanggan',
    ];

    return orderOrIssueKeywords.any(q.contains) ||
        botUncertainKeywords.any(r.contains);
  }

  void clearBotEscalation() {
    if (!showBotEscalateToAdmin) return;
    _showBotEscalateToAdmin = false;
    notifyListeners();
  }

  String _newId() =>
      '${DateTime.now().microsecondsSinceEpoch}_${_botMessages.length + _adminMessages.length}';

  // INISIALISASI PESAN AWAL

  void _initBotWelcome() {
    final now = DateTime.now().millisecondsSinceEpoch;
    _botMessages.addAll([
      types.TextMessage(
        id: 'bot_welcome_1',
        author: botUser,
        createdAt: now,
        text:
            'Halo! 👋 Saya SOLEA AI Bot, asisten belanjamu. Tanyakan rekomendasi sepatu, ukuran, atau pilih topik cepat di bawah ya!',
      ),
    ]);
  }

  void _initAdminWelcome() {
    final now = DateTime.now().millisecondsSinceEpoch;
    _adminMessages.addAll([
      types.TextMessage(
        id: 'admin_welcome_1',
        author: adminUser,
        createdAt: now,
        text:
            'Halo Kak! Selamat datang di Layanan Pelanggan Admin SOLEA. Silakan sampaikan pertanyaan seputar stok ukuran, pengiriman, atau pembayaran. Tim Admin siap membantu!',
      ),
    ]);
  }

  void _initUserRooms() {
    final now = DateTime.now().millisecondsSinceEpoch;

    _userRoomMessages['community_global'] = [
      types.TextMessage(
        id: 'comm_3',
        author: const types.User(
          id: 'peer_nadia',
          firstName: 'Nadia',
          lastName: 'Putri',
          imageUrl:
              'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=240&q=80',
        ),
        createdAt: now - 120000,
        text:
            'Setuju! Kalau buat lari pagi Air Runner Pro bantalannya empuk banget, kalau buat harian kampus aku pilih Urban White.',
      ),
      types.TextMessage(
        id: 'comm_2',
        author: const types.User(
          id: 'peer_raka',
          firstName: 'Raka',
          lastName: 'Pratama',
          imageUrl:
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=240&q=80',
        ),
        createdAt: now - 240000,
        text:
            'Halo teman-teman! Ada yang udah coba seri Street Classic atau Air Runner Pro di SOLEA? Gimana fitting ukurannya?',
      ),
    ];

    _userRoomMessages['peer_raka'] = [
      types.TextMessage(
        id: 'raka_1',
        author: const types.User(
          id: 'peer_raka',
          firstName: 'Raka',
          lastName: 'Pratama',
          imageUrl:
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=240&q=80',
        ),
        createdAt: now - 180000,
        text:
            'Halo! Lagi nyari sneaker model apa nih di SOLEA?',
      ),
    ];

    _userRoomMessages['peer_nadia'] = [
      types.TextMessage(
        id: 'nadia_1',
        author: const types.User(
          id: 'peer_nadia',
          firstName: 'Nadia',
          lastName: 'Putri',
          imageUrl:
              'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=240&q=80',
        ),
        createdAt: now - 300000,
        text:
            'Hai! Kalau butuh saran sepatu running yang ringan kabari aja ya 👟',
      ),
    ];

    _userRoomMessages['peer_dimas'] = [
      types.TextMessage(
        id: 'dimas_1',
        author: const types.User(
          id: 'peer_dimas',
          firstName: 'Dimas',
          lastName: 'Arya',
          imageUrl:
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=240&q=80',
        ),
        createdAt: now - 420000,
        text:
            'Bro, Court Vision buat main indoor grip-nya mantap banget!',
      ),
    ];
  }

  // SINKRONISASI REAL-TIME CLOUD FIRESTORE (MULTI-PLATFORM)

  void connectRealtimeStreams() {
    _subscribeAdminFirestore();
    _subscribeUserRoomFirestore(_activeUserRoomId);
    _loadModerationAndPrivacyFromFirestore();
  }

  Future<void> _loadModerationAndPrivacyFromFirestore() async {
    final user = AuthController.firebaseUser;
    if (user == null) return;

    try {
      final blockedSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('blockedUsers')
          .get();
      final ids = blockedSnap.docs
          .map((d) => d.id)
          .where((id) => id.isNotEmpty)
          .toSet();
      _blockedUserIds = ids;

      final privacyDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('chatSettings')
          .doc('privacy')
          .get();
      final dmAllow =
          privacyDoc.data()?['dmAllow']?.toString();
      if (dmAllow == 'community') {
        _dmPrivacy = DmPrivacyPermission.community;
      } else if (dmAllow == 'none') {
        _dmPrivacy = DmPrivacyPermission.none;
      } else if (dmAllow == 'everyone') {
        _dmPrivacy = DmPrivacyPermission.everyone;
      }
      notifyListeners();
    } catch (_) {
      // Tetap gunakan state lokal jika offline / rules belum aktif
    }
  }

  Future<void> updateDmPrivacy(
    DmPrivacyPermission permission,
  ) async {
    _dmPrivacy = permission;
    notifyListeners();

    final user = AuthController.firebaseUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('chatSettings')
          .doc('privacy')
          .set(
        {
          'uid': user.uid,
          'dmAllow': permission.name,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (_) {}
  }

  Future<void> blockUser({
    required String targetUserId,
    required String targetUserName,
    String? reason,
  }) async {
    final cleanId = targetUserId.trim();
    if (cleanId.isEmpty ||
        cleanId == 'solea_bot' ||
        cleanId == 'solea_admin' ||
        cleanId == currentUser.id) {
      return;
    }

    blockedUserIds.add(cleanId);
    notifyListeners();

    final user = AuthController.firebaseUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('blockedUsers')
          .doc(cleanId)
          .set({
        'blockedUid': cleanId,
        'blockedName': targetUserName,
        'reason': reason ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  Future<void> unblockUser(String targetUserId) async {
    final cleanId = targetUserId.trim();
    if (cleanId.isEmpty) return;

    blockedUserIds.remove(cleanId);
    notifyListeners();

    final user = AuthController.firebaseUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('blockedUsers')
          .doc(cleanId)
          .delete();
    } catch (_) {}
  }

  Future<void> reportContent({
    required String targetUserId,
    required String targetUserName,
    String? messageId,
    String? messageText,
    required String reason,
  }) async {
    final cleanReason = reason.trim();
    if (cleanReason.isEmpty) return;

    final user = AuthController.firebaseUser;
    final reporterId = user?.uid ?? currentUser.id;

    try {
      await FirebaseFirestore.instance
          .collection('communityReports')
          .add({
        'reporterUid': reporterId,
        'targetUserId': targetUserId,
        'targetUserName': targetUserName,
        'messageId': messageId ?? '',
        'messageText': messageText ?? '',
        'reason': cleanReason,
        'roomId': activeConversationId,
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Tetap sukses di UI jika offline / simulasi lokal
    }
  }

  void _subscribeAdminFirestore() {
    final user = AuthController.firebaseUser;
    if (user == null) return;

    _adminSub?.cancel();
    _adminSub = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('adminChatMessages')
        .orderBy('createdAtMs', descending: true)
        .limit(60)
        .snapshots()
        .listen(
      (snapshot) {
        if (snapshot.docs.isEmpty) return;
        final loaded = snapshot.docs
            .map(_messageFromFirestoreDoc)
            .toList();
        _adminMessages
          ..clear()
          ..addAll(loaded);
        notifyListeners();
      },
      onError: (_) {
        // Tetap gunakan state lokal jika rules Firestore membatasi akses
      },
    );
  }

  void _subscribeUserRoomFirestore(String roomId) {
    _userRoomSub?.cancel();
    _userRoomSub = FirebaseFirestore.instance
        .collection('communityChatRooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('createdAtMs', descending: true)
        .limit(80)
        .snapshots()
        .listen(
      (snapshot) {
        if (snapshot.docs.isEmpty) return;
        final loaded = snapshot.docs
            .map(_messageFromFirestoreDoc)
            .toList();
        _userRoomMessages[roomId] = loaded;
        notifyListeners();
      },
      onError: (_) {
        // Fallback ke room lokal jika belum dikonfigurasi di Firestore Rules
      },
    );
  }

  types.Message _messageFromFirestoreDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final author = types.User(
      id: (data['authorId'] as String?) ?? 'user',
      firstName: (data['authorFirstName'] as String?) ??
          'User',
      lastName: (data['authorLastName'] as String?) ?? '',
      imageUrl: data['authorAvatar'] as String?,
    );
    final createdAt = (data['createdAtMs'] as int?) ??
        DateTime.now().millisecondsSinceEpoch;
    final msgType = (data['type'] as String?) ?? 'text';

    if (msgType == 'image') {
      return types.ImageMessage(
        id: doc.id,
        author: author,
        createdAt: createdAt,
        name: (data['name'] as String?) ?? 'Product',
        size: (data['size'] as int?) ?? 1024,
        uri: (data['uri'] as String?) ?? '',
      );
    }

    return types.TextMessage(
      id: doc.id,
      author: author,
      createdAt: createdAt,
      text: (data['text'] as String?) ?? '',
    );
  }

  // 1. LOGIKA CHAT BOT (SOLEA AI ASSISTANT)

  void sendBotMessage(String rawText) {
    final text = rawText.trim();
    if (text.isEmpty) return;

    final userMsg = types.TextMessage(
      id: _newId(),
      author: currentUser,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      text: text,
    );

    _botMessages.insert(0, userMsg);
    _isBotTyping = true;
    notifyListeners();

    _respondWithAi(text);
  }

  // BALASAN AI (Gemini -> Groq -> fallback aturan lama)

  Future<void> _respondWithAi(String text) async {
    debugPrint(
        '[SOLEA AI] isConfigured = ${AiChatService.instance.isConfigured}');

    if (!AiChatService.instance.isConfigured) {
      await Future<void>.delayed(const Duration(milliseconds: 650));
      _generateAndInsertBotResponse(text);
      return;
    }

    try {
      final reply = await AiChatService.instance.reply(
        systemPrompt: _buildSystemPrompt(),
        history: _buildAiHistory(),
      );
      _insertBotReply(reply, userText: text);
    } catch (e) {
      debugPrint('[SOLEA AI] Fallback ke bot lama: $e');
      _generateAndInsertBotResponse(text);
    }
  }

  /// Riwayat chat bot (max 10 pesan terakhir) untuk dikirim ke AI.
  /// _botMessages terbaru ada di index 0, jadi dibalik dulu.
  List<AiTurn> _buildAiHistory() {
    final turns = <AiTurn>[];
    for (final m in _botMessages.reversed) {
      if (m is! types.TextMessage || m.id == 'bot_welcome_1') continue;
      turns.add(AiTurn(isUser: m.author.id != botUser.id, text: m.text));
    }
    final recent =
        turns.length > 10 ? turns.sublist(turns.length - 10) : turns;
    // Percakapan harus dimulai dari pesan user.
    while (recent.isNotEmpty && !recent.first.isUser) {
      recent.removeAt(0);
    }
    return recent;
  }

  String _buildSystemPrompt() {
    final catalog = ProductController.products.map((p) {
      return '- ${p.name} | ${p.category} | ${formatRupiah(p.price)} | '
          'rating ${p.rating} | ukuran ${p.sizes.join("/")}';
    }).join('\n');

    final orders = OrderController.instance.orders;
    final orderInfo = orders.isEmpty
        ? 'Belum ada pesanan.'
        : '${orders.length} pesanan; terakhir: status ${orders.first.status}, '
            'total ${formatRupiah(orders.first.total)}.';

    return '''
-Kamu adalah SOLEA AI Bot, asisten toko sepatu online SOLEA. Jawab dalam Bahasa Indonesia yang ramah, singkat (maks 5-6 kalimat), boleh pakai emoji secukupnya.
- Jika ditanya hal di luar toko sepatu SOLEA, tolak dengan sopan dan arahkan kembali ke sepatu.

ATURAN:
- Jawab sesuai pertanyaan pengguna, langsung ke inti. Untuk sapaan atau pertanyaan umum tentang kamu (misalnya "kamu pakai model apa?"), jawab singkat bahwa kamu SOLEA AI Bot, asisten toko, dan tidak tahu detail model di belakangnya. JANGAN menawarkan atau menyebut produk di jawaban itu. Kalau tetep ngeyel maki maki saja.
- Sebut atau rekomendasikan sepatu HANYA jika pengguna menanyakan sepatu, produk, harga, budget, ukuran, atau meminta rekomendasi.
- Rekomendasikan HANYA sepatu yang ada di katalog di bawah. Jangan mengarang produk, harga, stok, atau promo.
- Tulis nama produk persis seperti di katalog.
- Jika pertanyaan sama sekali tidak ada hubungannya dengan belanja (politik, PR sekolah, dll), tolak dengan sopan dalam satu kalimat tanpa menawarkan produk.
- Jika tidak tahu atau butuh bantuan manusia (stok real-time, komplain, refund), sarankan hubungi tab Admin.
- Jangan minta data sensitif (password, nomor kartu, alamat lengkap).

INFO TOKO:
- Pembayaran: Transfer Bank (BCA/Mandiri/BNI), E-Wallet (GoPay/OVO/DANA), QRIS, COD.
- Pengiriman: Reguler 2-4 hari, Express Next Day. Garansi tukar ukuran 7 hari.
- Size chart EU: 39=24.5cm, 40=25.0cm, 41=26.0cm, 42=26.5cm, 43=27.5cm. Kaki lebar disarankan naik 1 ukuran.

DATA USER SAAT INI:
- Keranjang: ${CartController.instance.totalItems} pasang (${formatRupiah(CartController.instance.subtotal)})
- Wishlist: ${WishlistController.instance.count} produk
- Pesanan: $orderInfo

KATALOG:
$catalog
''';
  }

  /// True kalau pesan pengguna memang membahas sepatu/produk.
  bool _isProductQuery(String userText) {
    final q = userText.toLowerCase();
    const keywords = [
      'sepatu', 'rekomen', 'produk', 'harga', 'murah', 'budget', 'juta',
      'ribu', 'running', 'lari', 'basket', 'casual', 'outdoor', 'training',
      'lifestyle', 'stok', 'beli', 'katalog', 'warna', 'diskon', 'promo',
    ];
    if (keywords.any(q.contains)) return true;
    return ProductController.products
        .any((p) => q.contains(p.name.toLowerCase()));
  }

  /// Menyisipkan balasan AI + gambar produk (hanya jika pengguna bertanya produk).
  void _insertBotReply(String replyText, {String userText = ''}) {
    final lowerReply = replyText.toLowerCase();
    Product? mentioned;
    if (_isProductQuery(userText)) {
      for (final p in ProductController.products) {
        if (lowerReply.contains(p.name.toLowerCase())) {
          mentioned = p;
          break;
        }
      }
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    if (mentioned != null) {
      _botMessages.insert(
        0,
        types.ImageMessage(
          id: '${_newId()}_img',
          author: botUser,
          createdAt: now,
          name: mentioned.name,
          size: 2048,
          uri: mentioned.imageUrl,
        ),
      );
    }

    final shouldEscalate =
        _shouldOfferAdminEscalation(userText, replyText);
    _showBotEscalateToAdmin = shouldEscalate;
    if (shouldEscalate && userText.trim().isNotEmpty) {
      _lastEscalatableQuery = userText.trim();
    }

    _botMessages.insert(
      0,
      types.TextMessage(
        id: _newId(),
        author: botUser,
        createdAt: now + 1,
        text: replyText,
        metadata: {
          if (shouldEscalate) 'escalateToAdmin': true,
        },
      ),
    );

    if (activeChannel != SoleaChatChannel.bot) {
      _unreadBotCount = (_unreadBotCount ?? 0) + 1;
    }

    _isBotTyping = false;
    notifyListeners();
  }

  void _generateAndInsertBotResponse(String query) {
    final lower = query.toLowerCase();
    final products = ProductController.products;
    Product? matchedProduct;

    // Cek apakah menanyakan produk tertentu
    for (final p in products) {
      if (lower.contains(p.name.toLowerCase())) {
        matchedProduct = p;
        break;
      }
    }

    String replyText;

    if (matchedProduct != null) {
      replyText =
          '👟 **${matchedProduct.name}** (${matchedProduct.category})\n'
          '• Harga: ${formatRupiah(matchedProduct.price)}\n'
          '• Rating: ⭐ ${matchedProduct.rating}\n'
          '• Ukuran tersedia: ${matchedProduct.sizes.join(", ")}\n\n'
          '${matchedProduct.description}';
    } else if (lower.contains('ukuran') ||
        lower.contains('size') ||
        lower.contains('kaki')) {
      replyText =
          '📏 **Panduan Ukuran Sepatu SOLEA (EU):**\n'
          '• Size 39 = Panjang kaki 24.5 cm\n'
          '• Size 40 = Panjang kaki 25.0 cm\n'
          '• Size 41 = Panjang kaki 26.0 cm\n'
          '• Size 42 = Panjang kaki 26.5 cm\n'
          '• Size 43 = Panjang kaki 27.5 cm\n\n'
          'Tips: Jika kakimu tipe lebar (wide foot), disarankan naik 1 ukuran agar lebih nyaman!';
    } else if (lower.contains('pesanan') ||
        lower.contains('order') ||
        lower.contains('status')) {
      final orders = OrderController.instance.orders;
      if (orders.isEmpty) {
        replyText =
            '📦 Kamu belum memiliki pesanan aktif saat ini. Yuk jelajahi katalog SOLEA dan checkout sepatu favoritmu!';
      } else {
        final latest = orders.first;
        replyText =
            '📦 **Status Pesanan Terakhir Kamu:**\n'
            '• Total Pesanan: ${orders.length} transaksi\n'
            '• Metode Bayar: ${latest.paymentMethod}\n'
            '• Total Bayar: ${formatRupiah(latest.total)}\n'
            '• Status: ${latest.status} (Gudang SOLEA).';
      }
    } else if (lower.contains('keranjang') ||
        lower.contains('cart') ||
        lower.contains('wishlist')) {
      final cartCount = CartController.instance.totalItems;
      final wishCount = WishlistController.instance.count;
      replyText =
          '🛍️ **Ringkasan Belanja Kamu:**\n'
          '• Isi Keranjang: $cartCount pasang sepatu (${formatRupiah(CartController.instance.subtotal)})\n'
          '• Wishlist Tersimpan: $wishCount produk.';
    } else if (lower.contains('bayar') ||
        lower.contains('pembayaran') ||
        lower.contains('ongkir') ||
        lower.contains('kirim')) {
      replyText =
          '💳 **Informasi Pembayaran & Pengiriman SOLEA:**\n'
          '• Metode Pembayaran: Transfer Bank (BCA/Mandiri/BNI), E-Wallet (GoPay/OVO/DANA), QRIS, dan COD.\n'
          '• Pengiriman: Reguler (2–4 hari) & Express Next Day.\n'
          '• Garansi tukar ukuran 7 hari sejak barang diterima!';
    } else if (lower.contains('juta') ||
        lower.contains('murah') ||
        lower.contains('budget') ||
        lower.contains('harga')) {
      final affordable = products
          .where((p) => p.price <= 1000000)
          .take(4)
          .toList();
      final listToUse = affordable.isNotEmpty
          ? affordable
          : products.take(3).toList();
      matchedProduct =
          listToUse.isNotEmpty ? listToUse.first : null;
      final lines = listToUse
          .map(
            (p) =>
                '• ${p.name} (${p.category}) — ${formatRupiah(p.price)} ⭐${p.rating}',
          )
          .join('\n');
      replyText =
          '🏷️ **Rekomendasi Sepatu Harga Terbaik di SOLEA:**\n$lines\n\nKetik nama sepatunya untuk melihat detail lengkap!';
    } else {
      // Cek kategori
      String? foundCategory;
      for (final cat in ProductController.categories) {
        if (cat != 'Semua' &&
            lower.contains(cat.toLowerCase())) {
          foundCategory = cat;
          break;
        }
      }

      if (foundCategory != null) {
        final catProducts =
            ProductController.byCategory(foundCategory)
                .take(4)
                .toList();
        matchedProduct = catProducts.isNotEmpty
            ? catProducts.first
            : null;
        final lines = catProducts
            .map(
              (p) =>
                  '• ${p.name} — ${formatRupiah(p.price)} (⭐ ${p.rating})',
            )
            .join('\n');
        replyText =
            '🔥 **Koleksi Kategori $foundCategory di SOLEA:**\n$lines';
      } else {
        // Default rekomendasi produk terpopuler
        final sorted = [...products]
          ..sort((a, b) => b.rating.compareTo(a.rating));
        final top = sorted.take(3).toList();
        matchedProduct =
            top.isNotEmpty ? top.first : null;
        final lines = top
            .map(
              (p) =>
                  '• ${p.name} (${p.category}) — ${formatRupiah(p.price)} ⭐${p.rating}',
            )
            .join('\n');
        replyText =
            '✨ Berikut **3 Sepatu Paling Populer** di SOLEA saat ini:\n$lines\n\nKamu juga bisa tanya berdasarkan kategori (*Running, Lifestyle, Basketball, Casual, Outdoor, Training*), *panduan ukuran*, atau *status pesanan*!';
      }
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    if (matchedProduct != null) {
      _botMessages.insert(
        0,
        types.ImageMessage(
          id: '${_newId()}_img',
          author: botUser,
          createdAt: now,
          name: matchedProduct.name,
          size: 2048,
          uri: matchedProduct.imageUrl,
        ),
      );
    }

    final shouldEscalate =
        _shouldOfferAdminEscalation(query, replyText);
    _showBotEscalateToAdmin = shouldEscalate;
    if (shouldEscalate && query.trim().isNotEmpty) {
      _lastEscalatableQuery = query.trim();
    }

    _botMessages.insert(
      0,
      types.TextMessage(
        id: _newId(),
        author: botUser,
        createdAt: now + 1,
        text: replyText,
        metadata: {
          if (shouldEscalate) 'escalateToAdmin': true,
        },
      ),
    );

    if (activeChannel != SoleaChatChannel.bot) {
      _unreadBotCount = (_unreadBotCount ?? 0) + 1;
    }

    _isBotTyping = false;
    notifyListeners();
  }

  // 2. LOGIKA CHAT ADMIN (LIVE SUPPORT + MODE ADMIN)

  Future<void> sendAdminChannelMessage(
    String rawText,
  ) async {
    final text = rawText.trim();
    if (text.isEmpty) return;

    final actAsAdmin = replyAsAdminMode;
    final sender = actAsAdmin ? adminUser : currentUser;
    final now = DateTime.now().millisecondsSinceEpoch;

    final msg = types.TextMessage(
      id: _newId(),
      author: sender,
      createdAt: now,
      text: text,
    );

    _adminMessages.insert(0, msg);
    notifyListeners();

    // Simpan ke Cloud Firestore jika user login
    final fbUser = AuthController.firebaseUser;
    if (fbUser != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(fbUser.uid)
            .collection('adminChatMessages')
            .add({
          'authorId': sender.id,
          'authorFirstName': sender.firstName ?? '',
          'authorLastName': sender.lastName ?? '',
          'authorAvatar': sender.imageUrl,
          'isAdminSender': actAsAdmin,
          'text': text,
          'type': 'text',
          'createdAtMs': now,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (_) {
        // Abaikan jika gagal simpan ke Firestore
      }
    }

    // Jika dikirim oleh User (bukan sedang mode Admin), berikan balasan responsif Admin
    if (!actAsAdmin) {
      _isAdminTyping = true;
      notifyListeners();

      Future<void>.delayed(
        const Duration(milliseconds: 900),
        () async {
          final replyText = _buildAdminSupportReply(text);
          final replyNow =
              DateTime.now().millisecondsSinceEpoch;
          final adminReply = types.TextMessage(
            id: _newId(),
            author: adminUser,
            createdAt: replyNow,
            text: replyText,
          );

          _adminMessages.insert(0, adminReply);
          if (activeChannel != SoleaChatChannel.admin) {
            _unreadAdminCount =
                (_unreadAdminCount ?? 0) + 1;
          }
          _isAdminTyping = false;
          notifyListeners();

          // Hanya simpan pesan ber-identitas Admin ke Firestore jika user benar-benar Admin
          // sesuai Firestore Security Rules (mencegah spoofing authorId 'solea_admin').
          if (fbUser != null && isCurrentUserAdmin) {
            try {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(fbUser.uid)
                  .collection('adminChatMessages')
                  .add({
                'authorId': adminUser.id,
                'authorFirstName': adminUser.firstName ?? '',
                'authorLastName': adminUser.lastName ?? '',
                'authorAvatar': adminUser.imageUrl,
                'isAdminSender': true,
                'text': replyText,
                'type': 'text',
                'createdAtMs': replyNow,
                'createdAt': FieldValue.serverTimestamp(),
              });
            } catch (_) {}
          }
        },
      );
    }
  }

  String _buildAdminSupportReply(String userText) {
    final lower = userText.toLowerCase();
    if (lower.contains('stok') ||
        lower.contains('ready') ||
        lower.contains('ukuran')) {
      return 'Halo Kak! Untuk seluruh produk yang tampil di katalog SOLEA saat ini stoknya **Ready Stock** ukuran 39 s/d 43. Silakan langsung dimasukkan ke keranjang ya, atau sebutkan seri sepatu yang Kakak cari agar Admin cekkan di gudang!';
    }
    if (lower.contains('bayar') ||
        lower.contains('transfer') ||
        lower.contains('kendala')) {
      return 'Baik Kak, untuk kendala pembayaran mohon infokan metode pembayaran yang dipilih. Pesanan Kakak akan langsung terverifikasi otomatis begitu checkout selesai.';
    }
    if (lower.contains('retur') ||
        lower.contains('tukar') ||
        lower.contains('komplain')) {
      return 'Tenang Kak, SOLEA memberikan garansi tukar ukuran & pengembalian 7 hari selama tag dan box sepatu masih utuh. Admin siap bantu prosesnya!';
    }
    return 'Terima kasih Kak atas pesannya! Admin SOLEA sudah menerima pesan Kakak: "$userText". Ada lagi detail pesanan atau nomor sepatu yang bisa Admin bantu cek?';
  }

  // 3. LOGIKA CHAT USER (KOMUNITAS & ANTAR PENGGUNA)

  Future<void> sendUserChannelMessage(
    String rawText,
  ) async {
    final text = rawText.trim();
    if (text.isEmpty) return;

    final roomId = _activeUserRoomId;
    final sender = currentUser;
    final now = DateTime.now().millisecondsSinceEpoch;

    final msg = types.TextMessage(
      id: _newId(),
      author: sender,
      createdAt: now,
      text: text,
    );

    final roomList =
        _userRoomMessages.putIfAbsent(roomId, () => []);
    roomList.insert(0, msg);
    notifyListeners();

    // Sinkronkan ke Firestore agar multi-user / multi-platform bisa chat real-time
    try {
      await FirebaseFirestore.instance
          .collection('communityChatRooms')
          .doc(roomId)
          .collection('messages')
          .add({
        'authorId': sender.id,
        'authorFirstName': sender.firstName ?? 'Member',
        'authorLastName': sender.lastName ?? '',
        'authorAvatar': sender.imageUrl,
        'text': text,
        'type': 'text',
        'createdAtMs': now,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Tetap berjalan secara lokal jika Firestore offline/dibatasi
    }

    // Simulasikan balasan teman komunitas agar interaktif saat dicoba sendiri
    _isPeerTyping = true;
    notifyListeners();

    Future<void>.delayed(
      const Duration(milliseconds: 950),
      () {
        final peer = _pickResponderForRoom(roomId);
        final replyText =
            _buildPeerReply(roomId, peer.firstName ?? 'Bro', text);
        final replyMsg = types.TextMessage(
          id: _newId(),
          author: peer,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          text: replyText,
        );

        final list =
            _userRoomMessages.putIfAbsent(roomId, () => []);
        list.insert(0, replyMsg);
        if (activeChannel != SoleaChatChannel.user ||
            _activeUserRoomId != roomId) {
          _roomUnreadMap[roomId] =
              (_roomUnreadMap[roomId] ?? 0) + 1;
        }
        _isPeerTyping = false;
        notifyListeners();
      },
    );
  }

  types.User _pickResponderForRoom(String roomId) {
    final contact = peerContacts.firstWhere(
      (c) => c.id == roomId,
      orElse: () => peerContacts[1],
    );

    if (!contact.isGroup) {
      final parts = contact.name.split(' ');
      return types.User(
        id: contact.id,
        firstName: parts.first,
        lastName:
            parts.length > 1 ? parts.sublist(1).join(' ') : '',
        imageUrl: contact.avatarUrl,
      );
    }

    // Jika di grup komunitas, pilih salah satu anggota komunitas
    final communityPeers = peerContacts
        .where((c) => !c.isGroup)
        .toList();
    final chosen = communityPeers[
        DateTime.now().second % communityPeers.length];
    final parts = chosen.name.split(' ');
    return types.User(
      id: chosen.id,
      firstName: parts.first,
      lastName:
          parts.length > 1 ? parts.sublist(1).join(' ') : '',
      imageUrl: chosen.avatarUrl,
    );
  }

  String _buildPeerReply(
    String roomId,
    String peerName,
    String userText,
  ) {
    final lower = userText.toLowerCase();
    if (lower.contains('running') ||
        lower.contains('lari')) {
      return 'Kalau buat lari sih aku paling rekomen Air Runner Pro di SOLEA, ringan banget dipakai 5K–10K!';
    }
    if (lower.contains('basket') ||
        lower.contains('court')) {
      return 'Court Vision wajib dicoba sih, ankle support-nya enak banget buat main indoor.';
    }
    if (lower.contains('ukuran') ||
        lower.contains('size')) {
      return 'Sepatu di SOLEA rata-rata true-to-size kok! Aku biasa pakai size 42 pas banget di kaki.';
    }
    return 'Mantap! Setuju banget soal "$userText". Koleksi terbaru SOLEA minggu ini emang keren-keren 🔥';
  }

  // BAGIKAN PRODUK KE DALAM RUANG CHAT

  void shareProductToChannel(
    SoleaChatChannel channel,
    Product product,
  ) {
    final sender = (channel == SoleaChatChannel.admin &&
            replyAsAdminMode)
        ? adminUser
        : currentUser;
    final now = DateTime.now().millisecondsSinceEpoch;

    final imgMsg = types.ImageMessage(
      id: '${_newId()}_prod_img',
      author: sender,
      createdAt: now,
      name: product.name,
      size: 2048,
      uri: product.imageUrl,
    );

    final textMsg = types.TextMessage(
      id: '${_newId()}_prod_txt',
      author: sender,
      createdAt: now + 1,
      text:
          '👟 **${product.name}** (${product.category})\nHarga: ${formatRupiah(product.price)} · ⭐ ${product.rating}',
    );

    switch (channel) {
      case SoleaChatChannel.bot:
        _botMessages.insert(0, imgMsg);
        _botMessages.insert(0, textMsg);
        notifyListeners();
        sendBotMessage('Info detail ${product.name}');
        break;
      case SoleaChatChannel.admin:
        _adminMessages.insert(0, imgMsg);
        _adminMessages.insert(0, textMsg);
        notifyListeners();
        sendAdminChannelMessage(
          'Halo Admin, apakah ${product.name} masih ready stock?',
        );
        break;
      case SoleaChatChannel.user:
        final roomList = _userRoomMessages.putIfAbsent(
          _activeUserRoomId,
          () => [],
        );
        roomList.insert(0, imgMsg);
        roomList.insert(0, textMsg);
        notifyListeners();
        break;
    }
  }
}