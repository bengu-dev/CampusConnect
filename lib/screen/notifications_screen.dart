import 'package:campus_project/core/app_theme.dart';
import 'package:campus_project/services/api_service.dart';
import 'package:campus_project/widgets/error_view.dart';
import 'package:campus_project/widgets/skeleton_widget.dart';
import 'package:flutter/material.dart';

/// Bildirimler ekranı.
/// Tüm veriler GET /api/notifications/my endpoint'inden gelir.
/// Okunmamış bildirimler kalın yazıyla, okunmuşlar normal yazıyla gösterilir.
/// "Tümünü Okundu İşaretle" butonu PUT /api/notifications/read-all çağırır.
class NotificationsScreen extends StatefulWidget {
  final Color accentColor;
  const NotificationsScreen({super.key, required this.accentColor});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool    _isLoading      = true;
  bool    _isNetworkError = false;
  String? _errorMsg;
  int     _unreadCount    = 0;
  bool    _markingAll     = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ── Bildirimleri yükle ─────────────────────────────────────────────────────

  Future<void> _load() async {
    setState(() { _isLoading = true; _isNetworkError = false; _errorMsg = null; });

    final result = await ApiService.getNotifications();
    if (!mounted) return;

    if (result['success'] == true) {
      final raw = result['notifications'] as List? ?? [];
      setState(() {
        _notifications  = raw.map((e) => Map<String, dynamic>.from(e)).toList();
        _unreadCount    = result['unreadCount'] as int? ?? 0;
        _isLoading      = false;
      });
    } else {
      setState(() {
        _isNetworkError = result['isNetworkError'] == true;
        _errorMsg   = result['message'] as String?;
        _isLoading  = false;
      });
    }
  }

  // ── Tümünü okundu işaretle ─────────────────────────────────────────────────

  Future<void> _markAllRead() async {
    if (_unreadCount == 0 || _markingAll) return;
    setState(() => _markingAll = true);

    final result = await ApiService.markAllNotificationsRead();
    if (!mounted) return;
    setState(() => _markingAll = false);

    if (result['success'] == true) {
      // Yerel listeyi güncelle — backend'e tekrar istek atmaya gerek yok
      setState(() {
        for (final n in _notifications) {
          n['is_read'] = true;
        }
        _unreadCount = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] ?? 'Tüm bildirimler okundu işaretlendi.'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] ?? 'İşlem başarısız!'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  // ── Tek bildirim okundu ────────────────────────────────────────────────────

  Future<void> _markOneRead(Map<String, dynamic> notif) async {
    final isRead = notif['is_read'] as bool? ?? false;
    if (isRead) return;

    final id = notif['id'];
    if (id == null) return;

    await ApiService.markNotificationRead(id as int);
    if (!mounted) return;

    setState(() {
      notif['is_read'] = true;
      _unreadCount     = (_unreadCount - 1).clamp(0, 999);
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        title: Row(
          children: [
            const Text('Bildirimler',
                style: TextStyle(
                    color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Tümünü Okundu İşaretle butonu
          if (_unreadCount > 0)
            TextButton.icon(
              onPressed: _markingAll ? null : _markAllRead,
              icon: _markingAll
                  ? const SizedBox(
                      width: 14, height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textSecondary))
                  : Icon(Icons.done_all_rounded,
                      color: widget.accentColor, size: 18),
              label: Text(
                'Tümünü Oku',
                style: TextStyle(
                    color: widget.accentColor, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
            onPressed: _load,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Yükleniyor — skeleton göster
    if (_isLoading) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: List.generate(
          6,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: SkeletonListTile(),
          ),
        ),
      );
    }

    // Hata — internet yok veya sunucu hatası
    if (_errorMsg != null) {
      return ErrorView(
        isNetworkError: _isNetworkError,
        message: _errorMsg,
        accentColor: widget.accentColor,
        onRetry: _load,
      );
    }

    // Boş liste
    if (_notifications.isEmpty) {
      return EmptyView(
        icon: Icons.notifications_none_rounded,
        message: 'Henüz bildirim yok.',
        subtitle: 'Yeni bildirimler burada görünecek.',
        accentColor: widget.accentColor,
      );
    }

    // Bildirim listesi
    return RefreshIndicator(
      color: widget.accentColor,
      backgroundColor: AppColors.surface,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: _notifications.length,
        itemBuilder: (_, i) => _NotificationTile(
          notification: _notifications[i],
          accentColor: widget.accentColor,
          onTap: () => _markOneRead(_notifications[i]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BİLDİRİM SATIRISI
// ─────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  final Map<String, dynamic> notification;
  final Color                accentColor;
  final VoidCallback         onTap;

  const _NotificationTile({
    required this.notification,
    required this.accentColor,
    required this.onTap,
  });

  /// Bildirim tipine göre ikon
  IconData _typeIcon(String? type) {
    switch (type) {
      case 'ENROLLMENT':    return Icons.school_rounded;
      case 'ANNOUNCEMENT':  return Icons.campaign_rounded;
      case 'EVENT_JOIN':    return Icons.event_available_rounded;
      case 'GRADE':         return Icons.grade_rounded;
      default:              return Icons.notifications_rounded;
    }
  }

  /// Tarihi okunabilir formata çevir
  String _formatDate(String? raw) {
    if (raw == null) return '';
    try {
      final dt  = DateTime.parse(raw);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1)  return 'Az önce';
      if (diff.inMinutes < 60) return '${diff.inMinutes} dakika önce';
      if (diff.inHours < 24)   return '${diff.inHours} saat önce';
      if (diff.inDays < 7)     return '${diff.inDays} gün önce';
      return '${dt.day}.${dt.month.toString().padLeft(2,'0')}.${dt.year}';
    } catch (_) { return raw; }
  }

  @override
  Widget build(BuildContext context) {
    final isRead   = notification['is_read']    as bool?   ?? false;
    final title    = notification['title']      as String? ?? '';
    final body     = notification['body']       as String? ?? '';
    final type     = notification['type']       as String?;
    final dateStr  = notification['created_at'] as String?;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          // Okunmamış → hafif vurgulu arka plan
          color: isRead
              ? AppColors.bgCard
              : accentColor.withAlpha(18),
          border: Border.all(
            color: isRead
                ? AppColors.border
                : accentColor.withAlpha(64),
            width: isRead ? 1 : 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tip ikonu
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withAlpha(isRead ? 26 : 51),
              ),
              child: Icon(
                _typeIcon(type),
                color: isRead ? accentColor.withAlpha(128) : accentColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // İçerik
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: isRead
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                            fontSize: 14,
                            // Okunmamış → bold
                            fontWeight: isRead
                                ? FontWeight.w400
                                : FontWeight.w700,
                          ),
                        ),
                      ),
                      // Okunmamış noktası
                      if (!isRead)
                        Container(
                          width: 8, height: 8,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accentColor,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: TextStyle(
                      color: isRead
                          ? AppColors.textMuted
                          : AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatDate(dateStr),
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
