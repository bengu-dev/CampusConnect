import 'dart:convert';
import 'package:campus_project/core/app_theme.dart';
import 'package:campus_project/screen/announcements_screen.dart';
import 'package:campus_project/screen/cafeteria_screen.dart';
import 'package:campus_project/screen/calendar_screen.dart';
import 'package:campus_project/screen/events_screen.dart';
import 'package:campus_project/screen/notes_screen.dart';
import 'package:campus_project/screen/notifications_screen.dart';
import 'package:campus_project/screen/schedule_screen.dart';
import 'package:campus_project/screen/teacher_courses_screen.dart';
import 'package:campus_project/screen/transcript_screen.dart';
import 'package:campus_project/screen/welcome_screen.dart';
import 'package:campus_project/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String displayRole;

  const HomeScreen({
    super.key,
    required this.userName,
    required this.displayRole,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  bool get _isStudent => widget.displayRole == 'Öğrenci' ||
      widget.displayRole == 'Student';
  bool get _isTeacher => widget.displayRole == 'Öğretim Üyesi' ||
      widget.displayRole == 'Faculty';

  Color get _roleAccent {
    if (_isStudent) return AppColors.student;
    if (_isTeacher) return AppColors.teacher;
    return AppColors.office;
  }

  LinearGradient get _roleGradient {
    if (_isStudent) return AppGradients.student;
    if (_isTeacher) return AppGradients.teacher;
    return AppGradients.office;
  }

  // ── Çıkış ─────────────────────────────────────────────────────────────────

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Çıkış Yap',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        content: const Text(
          'Hesabınızdan çıkmak istediğinize emin misiniz?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Çıkış Yap',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ApiService.logout();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  // ── Hızlı Erişim Kartları ─────────────────────────────────────────────────

  List<_QuickCard> get _quickCards {
    if (_isStudent) {
      return [
        _QuickCard('Ders Programım', Icons.calendar_today_rounded,   AppColors.student),
        _QuickCard('Notlarım',       Icons.grade_rounded,            const Color(0xFF7C3AED)),
        _QuickCard('Transkript',     Icons.description_rounded,      AppColors.teacher),
        _QuickCard('Duyurular',      Icons.campaign_rounded,         const Color(0xFFD97706)),
        _QuickCard('Yemek Menüsü',   Icons.restaurant_rounded,       AppColors.teacher),
        _QuickCard('Etkinlikler',    Icons.event_rounded,            const Color(0xFFDC2626)),
      ];
    }
    if (_isTeacher) {
      return [
        _QuickCard('Derslerim',       Icons.school_rounded,         AppColors.teacher),
        _QuickCard('Öğrenci Listesi', Icons.people_rounded,         const Color(0xFF0D9488)),
        _QuickCard('Ders Programı',   Icons.calendar_today_rounded, AppColors.student),
        _QuickCard('Not Girişi',      Icons.edit_note_rounded,      const Color(0xFFD97706)),
        _QuickCard('Duyurular',       Icons.campaign_rounded,       const Color(0xFF7C3AED)),
        _QuickCard('Etkinlikler',     Icons.event_rounded,          const Color(0xFFDC2626)),
      ];
    }
    return [
      _QuickCard('Kullanıcı Yönetimi', Icons.manage_accounts_rounded, AppColors.office),
      _QuickCard('Ders Yönetimi',      Icons.book_rounded,            const Color(0xFF0D9488)),
      _QuickCard('Duyuru Oluştur',     Icons.add_alert_rounded,       AppColors.student),
      _QuickCard('Etkinlik Yönetimi',  Icons.event_available_rounded, const Color(0xFF7C3AED)),
      _QuickCard('Raporlar',           Icons.bar_chart_rounded,       AppColors.teacher),
      _QuickCard('Yemek Menüsü',       Icons.restaurant_menu_rounded, const Color(0xFFDC2626)),
    ];
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      // ── Alt navigasyon çubuğundaki Takvim sekmesi artık CalendarScreen'i kullanıyor
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _DashboardTab(
            userName:     widget.userName,
            displayRole:  widget.displayRole,
            roleAccent:   _roleAccent,
            roleGradient: _roleGradient,
            quickCards:   _quickCards,
          ),
          // ── TAKVİM: artık CalendarScreen (EventProvider'ı dinler)
          CalendarScreen(accentColor: _roleAccent),
          NotificationsScreen(accentColor: _roleAccent),
          _ProfileTab(
            userName:     widget.userName,
            displayRole:  widget.displayRole,
            roleAccent:   _roleAccent,
            roleGradient: _roleGradient,
            onLogout:     _handleLogout,
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (i) => setState(() => _selectedIndex = i),
      backgroundColor: AppColors.bgLight,
      indicatorColor: _roleAccent.withAlpha(30),
      destinations: [
        NavigationDestination(
          icon:         const Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded, color: _roleAccent),
          label: 'Ana Sayfa',
        ),
        NavigationDestination(
          icon:         const Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month_rounded, color: _roleAccent),
          label: 'Takvim',
        ),
        NavigationDestination(
          icon:         const Icon(Icons.notifications_outlined),
          selectedIcon: Icon(Icons.notifications_rounded, color: _roleAccent),
          label: 'Bildirimler',
        ),
        NavigationDestination(
          icon:         const Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded, color: _roleAccent),
          label: 'Profil',
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// DASHBOARD TAB (hızlı erişim + duyurular)
// ─────────────────────────────────────────────

class _DashboardTab extends StatefulWidget {
  final String         userName;
  final String         displayRole;
  final Color          roleAccent;
  final LinearGradient roleGradient;
  final List<_QuickCard> quickCards;

  const _DashboardTab({
    required this.userName,
    required this.displayRole,
    required this.roleAccent,
    required this.roleGradient,
    required this.quickCards,
  });

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  final List<Map<String, dynamic>> _announcements = [];
  bool _announcementsLoaded = false;

  // Teacher-specific fields
  List<Map<String, dynamic>> _teacherCourses = [];
  int _totalStudents = 0;
  bool _teacherStatsLoaded = false;
  StompClient? _stomp;

  bool get _isTeacher =>
      widget.displayRole == 'Öğretim Üyesi' || widget.displayRole == 'Faculty';

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
    if (_isTeacher) {
      _loadTeacherStats();
    }
    _connectAnnouncementWs();
  }

  @override
  void dispose() {
    _stomp?.deactivate();
    super.dispose();
  }

  Future<void> _loadAnnouncements() async {
    final result = await ApiService.getAnnouncements();
    if (!mounted) return;
    if (result['success'] == true) {
      final raw = (result['announcements'] as List? ?? []);
      setState(() {
        _announcements
          ..clear()
          ..addAll(raw
              .take(3)
              .map((e) => Map<String, dynamic>.from(e)));
        _announcementsLoaded = true;
      });
    } else {
      setState(() => _announcementsLoaded = true);
    }
  }

  Future<void> _loadTeacherStats() async {
    final result = await ApiService.getTeacherCourses();
    if (!mounted) return;
    if (result['success'] == true) {
      final raw = (result['courses'] as List? ?? []);
      final courses =
          raw.map((e) => Map<String, dynamic>.from(e)).toList();
      int total = 0;
      for (final c in courses) {
        total += (c['enrolledCount'] as num? ?? 0).toInt();
      }
      setState(() {
        _teacherCourses = courses;
        _totalStudents = total;
        _teacherStatsLoaded = true;
      });
    } else {
      setState(() => _teacherStatsLoaded = true);
    }
  }

  void _connectAnnouncementWs() {
    _stomp = StompClient(
      config: StompConfig(
        url: 'ws://10.0.2.2:8080/ws',
        onConnect: (frame) {
          _stomp?.subscribe(
            destination: '/topic/announcements',
            callback: (frame) {
              if (!mounted) return;
              try {
                final body = frame.body;
                if (body == null || body.isEmpty) return;
                final data = Map<String, dynamic>.from(
                    jsonDecode(body) as Map);
                setState(() {
                  if (_announcements.length < 3) {
                    _announcements.insert(0, data);
                  } else {
                    _announcements.insert(0, data);
                    if (_announcements.length > 3) {
                      _announcements.removeLast();
                    }
                  }
                });
              } catch (e) {
                debugPrint('WS announcement parse error: $e');
              }
            },
          );
        },
        onWebSocketError: (dynamic error) {
          debugPrint('WS error: $error');
        },
        onStompError: (frame) {
          debugPrint('STOMP error: ${frame.body}');
        },
      ),
    );
    _stomp?.activate();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ── Renkli header ─────────────────────────────────────────────────
        SliverToBoxAdapter(child: _buildHeader(context)),

        // ── Teacher stats (yalnızca öğretim üyesi için) ───────────────────
        if (_isTeacher && _teacherStatsLoaded)
          SliverToBoxAdapter(child: _buildTeacherStats()),

        // ── Teacher courses overview (yalnızca öğretim üyesi için) ────────
        if (_isTeacher && _teacherCourses.isNotEmpty)
          SliverToBoxAdapter(child: _buildTeacherCoursesOverview()),

        // ── Hızlı Erişim başlığı ─────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Row(children: [
              const Text('Hızlı Erişim',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700)),
            ]),
          ),
        ),

        // ── Hızlı Erişim grid ────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final card = widget.quickCards[index];
                VoidCallback? onTapOverride;
                switch (card.label) {
                  case 'Ders Programım':
                  case 'Ders Programı':
                    onTapOverride = () => Navigator.push(context,
                        MaterialPageRoute(
                          builder: (_) => ScheduleScreen(
                              displayRole: widget.displayRole,
                              accentColor: widget.roleAccent),
                        ));
                  case 'Transkript':
                    onTapOverride = () => Navigator.push(context,
                        MaterialPageRoute(
                          builder: (_) => TranscriptScreen(
                              accentColor: widget.roleAccent),
                        ));
                  case 'Duyurular':
                  case 'Duyuru Oluştur':
                    onTapOverride = () => Navigator.push(context,
                        MaterialPageRoute(
                          builder: (_) => AnnouncementsScreen(
                              displayRole: widget.displayRole,
                              accentColor: widget.roleAccent),
                        ));
                  case 'Etkinlikler':
                  case 'Etkinlik Yönetimi':
                    onTapOverride = () => Navigator.push(context,
                        MaterialPageRoute(
                          builder: (_) => EventsScreen(
                              displayRole: widget.displayRole,
                              accentColor: widget.roleAccent),
                        ));
                  case 'Yemek Menüsü':
                    onTapOverride = () => Navigator.push(context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CafeteriaScreen(accentColor: widget.roleAccent),
                        ));
                  case 'Derslerim':
                  case 'Öğrenci Listesi':
                  case 'Not Girişi':
                    onTapOverride = () => Navigator.push(context,
                        MaterialPageRoute(
                          builder: (_) => TeacherCoursesScreen(
                              accentColor: widget.roleAccent),
                        ));
                  case 'Notlarım':
                    onTapOverride = () => Navigator.push(context,
                        MaterialPageRoute(
                          builder: (_) =>
                              NotesScreen(accentColor: widget.roleAccent),
                        ));
                }
                return _QuickCardWidget(
                    card: card, onTapOverride: onTapOverride);
              },
              childCount: widget.quickCards.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:  2,
              crossAxisSpacing: 12,
              mainAxisSpacing:  12,
              childAspectRatio: 1.2,
            ),
          ),
        ),

        // ── Son Duyurular ─────────────────────────────────────────────────
        if (_announcementsLoaded && _announcements.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(children: [
                const Text('Son Duyurular',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => AnnouncementsScreen(
                        displayRole: widget.displayRole,
                        accentColor: widget.roleAccent),
                  )),
                  child: Text('Tümü',
                      style: TextStyle(
                          color: widget.roleAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
              ]),
            ),
          ),
        if (_announcementsLoaded && _announcements.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final ann  = _announcements[i];
                  final title   = ann['title']   as String? ?? '';
                  final content = ann['content'] as String? ?? '';
                  final date    = ann['created_at'] as String? ?? '';
                  final role    = ann['target_role'] as String? ?? 'ALL';

                  const roleColors = {
                    'ALL':     AppColors.student,
                    'STUDENT': AppColors.teacher,
                    'TEACHER': Color(0xFF0D9488),
                    'OFFICE':  AppColors.office,
                  };
                  final c = roleColors[role] ?? widget.roleAccent;

                  return GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => AnnouncementsScreen(
                          displayRole: widget.displayRole,
                          accentColor: widget.roleAccent),
                    )),
                    child: Container(
                      margin:  const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color:  AppColors.bgCard,
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                              color:      c.withAlpha(20),
                              blurRadius: 8,
                              offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Row(children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: c.withAlpha(22),
                          ),
                          child: Icon(Icons.campaign_rounded, color: c, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title,
                                  style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Text(content,
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(_age(date),
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 10)),
                      ]),
                    ),
                  );
                },
                childCount: _announcements.length,
              ),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  // ── Teacher Stats Row ─────────────────────────────────────────────────────

  Widget _buildTeacherStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: _StatBox(
              label: 'Derslerim',
              value: '${_teacherCourses.length}',
              icon: Icons.school_rounded,
              color: AppColors.teacher,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatBox(
              label: 'Öğrencilerim',
              value: '$_totalStudents',
              icon: Icons.people_rounded,
              color: const Color(0xFF0D9488),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatBox(
              label: 'Bu Hafta',
              value: '${_teacherCourses.length * 3}',
              icon: Icons.calendar_today_rounded,
              color: AppColors.student,
            ),
          ),
        ],
      ),
    );
  }

  // ── Teacher Courses Overview ──────────────────────────────────────────────

  Widget _buildTeacherCoursesOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(children: [
            const Text('Derslerim Özeti',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700)),
          ]),
        ),
        SizedBox(
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: _teacherCourses.take(4).map((course) {
              final code = course['courseCode'] as String? ?? '';
              final name = course['courseName'] as String? ?? '';
              final enrolled = (course['enrolledCount'] as num? ?? 0).toInt();
              return Container(
                width: 160,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.teacher.withAlpha(18),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.teacher.withAlpha(22),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        code,
                        style: const TextStyle(
                          color: AppColors.teacher,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.people_rounded,
                            color: AppColors.textMuted, size: 13),
                        const SizedBox(width: 4),
                        Text(
                          '$enrolled öğrenci',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          24, MediaQuery.of(context).padding.top + 24, 24, 28),
      decoration: BoxDecoration(gradient: widget.roleGradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(50),
                border: Border.all(color: Colors.white.withAlpha(80)),
              ),
              child: const Icon(Icons.person_rounded,
                  color: Colors.white, size: 24),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(widget.displayRole,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 16),
          const Text('İyi günler,',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          Text(widget.userName.toLowerCase(),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5)),
        ],
      ),
    );
  }

  String _age(String? raw) {
    if (raw == null) return '';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}dk';
    if (diff.inHours   < 24) return '${diff.inHours}sa';
    return '${diff.inDays}g';
  }
}

// ─────────────────────────────────────────────
// STAT BOX
// ─────────────────────────────────────────────

class _StatBox extends StatelessWidget {
  final String   label;
  final String   value;
  final IconData icon;
  final Color    color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withAlpha(30),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// QUICK CARD
// ─────────────────────────────────────────────

class _QuickCard {
  final String   label;
  final IconData icon;
  final Color    color;
  const _QuickCard(this.label, this.icon, this.color);
}

class _QuickCardWidget extends StatefulWidget {
  final _QuickCard     card;
  final VoidCallback?  onTapOverride;
  const _QuickCardWidget({required this.card, this.onTapOverride});

  @override
  State<_QuickCardWidget> createState() => _QuickCardWidgetState();
}

class _QuickCardWidgetState extends State<_QuickCardWidget> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) => setState(() => _pressed = true),
      onTapUp:     (_) => setState(() => _pressed = false),
      onTapCancel: ()  => setState(() => _pressed = false),
      onTap: () {
        if (widget.onTapOverride != null) {
          widget.onTapOverride!();
        }
      },
      child: AnimatedScale(
        scale:    _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:        AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border:       Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                  color:      widget.card.color.withAlpha(20),
                  blurRadius: 10,
                  offset:     const Offset(0, 4)),
            ],
          ),
          child: Column(
            mainAxisAlignment:  MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color:        widget.card.color.withAlpha(22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.card.icon,
                    color: widget.card.color, size: 22),
              ),
              const SizedBox(height: 10),
              Text(widget.card.label,
                  style: const TextStyle(
                      color:      AppColors.textPrimary,
                      fontSize:   13,
                      fontWeight: FontWeight.w700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PROFİL TAB
// ─────────────────────────────────────────────

class _ProfileTab extends StatelessWidget {
  final String         userName;
  final String         displayRole;
  final Color          roleAccent;
  final LinearGradient roleGradient;
  final VoidCallback   onLogout;

  const _ProfileTab({
    required this.userName,
    required this.displayRole,
    required this.roleAccent,
    required this.roleGradient,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SingleChildScrollView(
        child: Column(children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
                24, MediaQuery.of(context).padding.top + 32, 24, 36),
            decoration: BoxDecoration(gradient: roleGradient),
            child: Column(children: [
              Container(
                width: 88, height: 88,
                decoration: BoxDecoration(
                  shape:  BoxShape.circle,
                  color:  Colors.white.withAlpha(50),
                  border: Border.all(
                      color: Colors.white.withAlpha(100), width: 2),
                ),
                child: const Icon(Icons.person_rounded,
                    color: Colors.white, size: 44),
              ),
              const SizedBox(height: 14),
              Text(userName,
                  style: const TextStyle(
                      color:      Colors.white,
                      fontSize:   22,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color:        Colors.white.withAlpha(50),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(displayRole,
                    style: const TextStyle(
                        color:      Colors.white,
                        fontSize:   13,
                        fontWeight: FontWeight.w600)),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(children: [
              _item(Icons.person_outline_rounded,  'Profil Bilgileri',  roleAccent),
              _item(Icons.notifications_outlined,  'Bildirim Ayarları', roleAccent),
              _item(Icons.lock_outline_rounded,    'Şifre Değiştir',    roleAccent),
              _item(Icons.help_outline_rounded,    'Yardım & Destek',   roleAccent),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: onLogout,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color:  Colors.red.withAlpha(15),
                    border: Border.all(color: Colors.red.withAlpha(60)),
                  ),
                  child: const Row(children: [
                    Icon(Icons.logout_rounded,
                        color: Colors.redAccent, size: 22),
                    SizedBox(width: 14),
                    Text('Çıkış Yap',
                        style: TextStyle(
                            color:      Colors.redAccent,
                            fontSize:   15,
                            fontWeight: FontWeight.w600)),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.redAccent, size: 14),
                  ]),
                ),
              ),
              const SizedBox(height: 28),
              const Text('Campus Connect v1.0.0',
                  style: TextStyle(
                      color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(height: 20),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _item(IconData icon, String label, Color accent) => Container(
    margin:  const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      color:  AppColors.bgCard,
      border: Border.all(color: AppColors.border),
    ),
    child: Row(children: [
      Icon(icon, color: accent, size: 22),
      const SizedBox(width: 14),
      Text(label,
          style: const TextStyle(
              color:      AppColors.textPrimary,
              fontSize:   15,
              fontWeight: FontWeight.w500)),
      const Spacer(),
      const Icon(Icons.arrow_forward_ios_rounded,
          color: AppColors.textMuted, size: 14),
    ]),
  );
}
