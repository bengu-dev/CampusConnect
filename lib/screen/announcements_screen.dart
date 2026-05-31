import 'dart:convert';

import 'package:campus_project/core/app_theme.dart';
import 'package:campus_project/screen/create_announcement_screen.dart';
import 'package:campus_project/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

const _wsUrl = 'ws://10.0.2.2:8080/ws';

// targetRole → Türkçe etiket
const _roleLabels = {
  'ALL':     'Herkese',
  'STUDENT': 'Öğrencilere',
  'TEACHER': 'Öğretim Üyelerine',
  'OFFICE':  'Ofis Personeline',
};

// targetRole → renk
const _roleColors = {
  'ALL':     Color(0xFF4F46E5),
  'STUDENT': Color(0xFF059669),
  'TEACHER': Color(0xFF0D9488),
  'OFFICE':  Color(0xFFD97706),
};

// targetRole → ikon
const _roleIcons = {
  'ALL':     Icons.public_rounded,
  'STUDENT': Icons.school_rounded,
  'TEACHER': Icons.cast_for_education_rounded,
  'OFFICE':  Icons.business_center_rounded,
};

// ─── Hem snake_case (REST) hem camelCase (WS) destekle ───────────────────────
String _field(Map<String, dynamic> m, String camel, String snake,
    [String fallback = '']) =>
    ((m[camel] ?? m[snake] ?? fallback) as Object).toString();

class AnnouncementsScreen extends StatefulWidget {
  final String displayRole;
  final Color  accentColor;

  const AnnouncementsScreen({
    super.key,
    required this.displayRole,
    required this.accentColor,
  });

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final List<Map<String, dynamic>> _announcements = [];
  bool    _isLoading   = true;
  String? _errorMsg;
  bool    _wsConnected = false;
  StompClient? _stomp;

  bool get _canCreate =>
      widget.displayRole == 'Öğretim Üyesi' ||
      widget.displayRole == 'Ofis Personeli';

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
    _connectStomp();
  }

  @override
  void dispose() {
    _stomp?.deactivate();
    super.dispose();
  }

  Future<void> _loadAnnouncements() async {
    setState(() { _isLoading = true; _errorMsg = null; });
    final result = await ApiService.getAnnouncements();
    if (!mounted) return;
    if (result['success'] == true) {
      final List<dynamic> raw = result['announcements'] ?? [];
      setState(() {
        _announcements
          ..clear()
          ..addAll(raw.map((e) => Map<String, dynamic>.from(e as Map)));
        _isLoading = false;
      });
    } else {
      setState(() { _errorMsg = result['message'] as String?; _isLoading = false; });
    }
  }

  void _connectStomp() {
    _stomp = StompClient(
      config: StompConfig(
        url: _wsUrl,
        onConnect: _onConnected,
        onDisconnect: (_) {
          if (mounted) setState(() => _wsConnected = false);
        },
        onStompError:     (f) => debugPrint('STOMP error: ${f.body}'),
        onWebSocketError: (e) => debugPrint('WS error: $e'),
        heartbeatIncoming: const Duration(seconds: 10),
        heartbeatOutgoing: const Duration(seconds: 10),
        reconnectDelay: const Duration(seconds: 5),
      ),
    );
    _stomp!.activate();
  }

  void _onConnected(StompFrame frame) {
    if (mounted) setState(() => _wsConnected = true);
    _stomp!.subscribe(
      destination: '/topic/announcements',
      callback: (frame) {
        if (frame.body == null || !mounted) return;
        final newItem = Map<String, dynamic>.from(
            jsonDecode(frame.body!) as Map);
        final target = _field(newItem, 'targetRole', 'target_role', 'ALL');
        if (!_isRelevant(target)) return;
        setState(() => _announcements.insert(0, newItem));
        final author = _field(newItem, 'authorName', 'author_name', 'Bilinmiyor');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.campaign_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text('$author yeni duyuru paylaştı')),
          ]),
          backgroundColor: widget.accentColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      },
    );
  }

  bool _isRelevant(String targetRole) {
    if (targetRole == 'ALL') return true;
    const map = {
      'Öğrenci':       'STUDENT',
      'Öğretim Üyesi': 'TEACHER',
      'Ofis Personeli':'OFFICE',
    };
    return targetRole == (map[widget.displayRole] ?? '');
  }

  Future<void> _openCreateScreen() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (_) =>
              CreateAnnouncementScreen(accentColor: widget.accentColor)),
    );
    if (created == true) _loadAnnouncements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Duyurular',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            Row(children: [
              Container(
                width: 7, height: 7,
                margin: const EdgeInsets.only(right: 5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _wsConnected ? AppColors.success : AppColors.textMuted,
                ),
              ),
              Text(
                _wsConnected ? 'Canlı' : 'Bağlanıyor…',
                style: TextStyle(
                  color: _wsConnected ? AppColors.success : AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ]),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
            onPressed: _loadAnnouncements,
          ),
        ],
      ),
      floatingActionButton: _canCreate
          ? FloatingActionButton.extended(
              onPressed: _openCreateScreen,
              backgroundColor: widget.accentColor,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text('Duyuru Oluştur',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            )
          : null,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _errorMsg != null
              ? _buildError()
              : _announcements.isEmpty
                  ? _buildEmpty()
                  : _buildList(),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      color: widget.accentColor,
      onRefresh: _loadAnnouncements,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16, 12, 16, _canCreate ? 80 : 16),
        itemCount: _announcements.length,
        itemBuilder: (ctx, i) => _AnnouncementCard(
          item: _announcements[i],
          accentColor: widget.accentColor,
        ),
      ),
    );
  }

  Widget _buildError() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.wifi_off_rounded, color: AppColors.textMuted, size: 52),
      const SizedBox(height: 16),
      Text(_errorMsg!,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
          textAlign: TextAlign.center),
      const SizedBox(height: 20),
      TextButton(
        onPressed: _loadAnnouncements,
        child: Text('Tekrar Dene',
            style: TextStyle(color: widget.accentColor))),
    ]),
  );

  Widget _buildEmpty() => const Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.campaign_outlined, color: AppColors.textHint, size: 64),
      SizedBox(height: 16),
      Text('Henüz duyuru yok.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
    ]),
  );
}

// ─────────────────────────────────────────────
// DUYURU KARTI
// ─────────────────────────────────────────────

class _AnnouncementCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final Color accentColor;

  const _AnnouncementCard({required this.item, required this.accentColor});

  // Hem snake_case hem camelCase için yardımcı
  String _f(String camel, String snake, [String fallback = '']) =>
      _field(item, camel, snake, fallback);

  String _formatDate(String? raw) {
    if (raw == null) return '';
    try {
      final dt   = DateTime.parse(raw);
      final now  = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1)  return 'Az önce';
      if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
      if (diff.inHours   < 24) return '${diff.inHours} sa önce';
      if (diff.inDays    < 7)  return '${diff.inDays} gün önce';
      return '${dt.day}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    } catch (_) { return raw; }
  }

  @override
  Widget build(BuildContext context) {
    final title      = _f('title',      'title');
    final content    = _f('content',    'content');
    final targetRole = _f('targetRole', 'target_role', 'ALL');
    final authorName = _f('authorName', 'author_name', 'Sistem');
    final createdAt  = item['createdAt'] as String? ?? item['created_at'] as String?;
    final isPinned   = item['isPinned'] as bool? ?? item['is_pinned'] as bool? ?? false;

    final badgeColor = _roleColors[targetRole] ?? accentColor;
    final badgeLabel = _roleLabels[targetRole] ?? targetRole;
    final badgeIcon  = _roleIcons[targetRole] ?? Icons.campaign_rounded;

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.bgCard,
          border: Border.all(
            color: isPinned ? badgeColor.withAlpha(80) : AppColors.border,
            width: isPinned ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: badgeColor.withAlpha(isPinned ? 25 : 10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Üst Bant: Kim gönderdi + hedef + zaman ──────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: badgeColor.withAlpha(18),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(children: [
                // Gönderen kişi avatarı
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: badgeColor.withAlpha(40),
                  ),
                  child: Center(
                    child: Text(
                      authorName.isNotEmpty ? authorName[0].toUpperCase() : 'S',
                      style: TextStyle(
                        color: badgeColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Gönderen ismi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authorName.isEmpty ? 'Sistem' : authorName,
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Row(children: [
                        Icon(badgeIcon, size: 10, color: badgeColor.withAlpha(180)),
                        const SizedBox(width: 3),
                        Text(
                          badgeLabel,
                          style: TextStyle(
                            color: badgeColor.withAlpha(180),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),

                // Sabitlenmiş pin + tarih
                if (isPinned) ...[
                  Icon(Icons.push_pin_rounded, size: 13, color: badgeColor),
                  const SizedBox(width: 6),
                ],
                Text(
                  _formatDate(createdAt),
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
              ]),
            ),

            // ── İçerik ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(children: [
                    // Okuma işareti
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor.withAlpha(15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(badgeIcon, size: 11, color: badgeColor),
                        const SizedBox(width: 4),
                        Text(
                          badgeLabel,
                          style: TextStyle(
                            color: badgeColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ]),
                    ),
                    const Spacer(),
                    Text(
                      'Detayı gör →',
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    final title      = _f('title',      'title');
    final content    = _f('content',    'content');
    final targetRole = _f('targetRole', 'target_role', 'ALL');
    final authorName = _f('authorName', 'author_name', 'Sistem');
    final createdAt  = item['createdAt'] as String? ?? item['created_at'] as String?;
    final isPinned   = item['isPinned'] as bool? ?? item['is_pinned'] as bool? ?? false;

    final badgeColor = _roleColors[targetRole] ?? accentColor;
    final badgeLabel = _roleLabels[targetRole] ?? targetRole;
    final badgeIcon  = _roleIcons[targetRole] ?? Icons.campaign_rounded;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, sc) => Container(
          decoration: const BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),

            Expanded(
              child: ListView(
                controller: sc,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                children: [
                  // ── Gönderen bilgi kartı ────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: badgeColor.withAlpha(15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: badgeColor.withAlpha(50)),
                    ),
                    child: Row(children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: badgeColor.withAlpha(40),
                        ),
                        child: Center(
                          child: Text(
                            authorName.isNotEmpty
                                ? authorName[0].toUpperCase()
                                : 'S',
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authorName.isEmpty ? 'Sistem' : authorName,
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(children: [
                            Icon(badgeIcon, size: 12, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              '$badgeLabel gönderildi',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ]),
                        ],
                      )),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (isPinned)
                            Icon(Icons.push_pin_rounded,
                                size: 14, color: badgeColor),
                          Text(
                            _formatDate(createdAt),
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ]),
                  ),
                  const SizedBox(height: 18),

                  // ── Başlık ──────────────────────────────────────────────
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 14),

                  // ── İçerik (tam metin) ───────────────────────────────────
                  Text(
                    content,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      height: 1.8,
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
