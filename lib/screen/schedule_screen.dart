import 'package:campus_project/core/app_theme.dart';
import 'package:campus_project/services/api_service.dart';
import 'package:campus_project/widgets/error_view.dart';
import 'package:campus_project/widgets/skeleton_widget.dart';
import 'package:flutter/material.dart';

/// day_of_week tamsayısını Türkçe gün adına çevirir (1=Pazartesi)
const _dayNames = {
  1: 'Pazartesi',
  2: 'Salı',
  3: 'Çarşamba',
  4: 'Perşembe',
  5: 'Cuma',
  6: 'Cumartesi',
  7: 'Pazar',
};

/// Saat string'ini "09:00:00" → "09:00" formatına kısaltır
String _shortTime(String? raw) {
  if (raw == null || raw.length < 5) return raw ?? '--:--';
  return raw.substring(0, 5);
}

/// Ders Programı ekranı.
/// GET /api/schedule/my → öğrenci için günlere göre gruplandırılmış program,
/// öğretim üyesi için ders listesi.
/// Tüm veriler PostgreSQL'den gelir — hardcode veri YOKTUR.
class ScheduleScreen extends StatefulWidget {
  final String displayRole;
  final Color  accentColor;

  const ScheduleScreen({
    super.key,
    required this.displayRole,
    required this.accentColor,
  });

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  // Öğrenci: gün sırası → ders listesi
  final Map<int, List<Map<String, dynamic>>> _scheduleByDay = {};
  // Öğretim üyesi: ders listesi
  final List<Map<String, dynamic>> _teacherCourses = [];

  String? _errorMsg;
  bool    _isNetworkError = false;
  bool    _isLoading      = true;
  bool    _isListView     = false; // öğrenci için toggle: haftalık ↔ liste
  int     _selectedDay    = -1;   // -1 = tümü, 1-5 = gün

  late TabController _tabController;

  bool get _isStudent  => widget.displayRole == 'Öğrenci';
  bool get _isTeacher  => widget.displayRole == 'Öğretim Üyesi';

  /// Bugün hangi gün? (1=Pazartesi … 5=Cuma, hafta sonu → 1)
  int get _todayDay {
    final wd = DateTime.now().weekday;
    return (wd >= 1 && wd <= 5) ? wd : 1;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _selectedDay = _todayDay;
    _tabController.index = _todayDay - 1;
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Veri yükleme ───────────────────────────────────────────────────────────

  Future<void> _load() async {
    setState(() { _isLoading = true; _isNetworkError = false; _errorMsg = null; });

    final result = await ApiService.getMySchedule();
    if (!mounted) return;

    if (result['success'] != true) {
      setState(() {
        _isNetworkError = result['isNetworkError'] == true;
        _errorMsg  = result['message'] as String?;
        _isLoading = false;
      });
      return;
    }

    if (_isStudent) {
      // Ders programını gün numarasına göre grupla
      final raw = result['schedule'] as List? ?? [];
      final grouped = <int, List<Map<String, dynamic>>>{};
      for (int d = 1; d <= 7; d++) {
        grouped[d] = [];
      }
      for (final item in raw) {
        final day = item['day_of_week'];
        final dayInt = day is int ? day : int.tryParse(day.toString()) ?? 1;
        grouped.putIfAbsent(dayInt, () => []).add(Map<String, dynamic>.from(item));
      }
      // Her günü saat sırasına göre sırala
      for (final list in grouped.values) {
        list.sort((a, b) =>
            (a['start_time'] as String? ?? '').compareTo(b['start_time'] as String? ?? ''));
      }
      setState(() {
        _scheduleByDay
          ..clear()
          ..addAll(grouped);
        _isLoading = false;
      });
    } else if (_isTeacher) {
      // Önce schedule (gün bazlı) verisini dene — ScheduleController artık bunu da dönüyor
      final scheduleRaw = result['schedule'] as List? ?? [];
      if (scheduleRaw.isNotEmpty) {
        final grouped = <int, List<Map<String, dynamic>>>{};
        for (int d = 1; d <= 7; d++) { grouped[d] = []; }
        for (final item in scheduleRaw) {
          final day    = item['day_of_week'];
          final dayInt = day is int ? day : int.tryParse(day.toString()) ?? 1;
          grouped.putIfAbsent(dayInt, () => []).add(Map<String, dynamic>.from(item));
        }
        for (final list in grouped.values) {
          list.sort((a, b) =>
              (a['start_time'] as String? ?? '').compareTo(b['start_time'] as String? ?? ''));
        }
        setState(() {
          _scheduleByDay..clear()..addAll(grouped);
          _isLoading = false;
        });
      } else {
        // Fallback: ders listesi görünümü
        final raw = result['courses'] as List? ?? [];
        setState(() {
          _teacherCourses..clear()..addAll(raw.map((e) => Map<String, dynamic>.from(e)));
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        title: Text(
          _isTeacher ? 'Ders Programım' : 'Ders Programım',
          style: const TextStyle(
              color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Öğrenci için görünüm toggle
          if (_isStudent && !_isLoading && _errorMsg == null)
            IconButton(
              icon: Icon(
                _isListView ? Icons.view_week_rounded : Icons.view_list_rounded,
                color: AppColors.textSecondary,
              ),
              tooltip: _isListView ? 'Haftalık Görünüm' : 'Liste Görünümü',
              onPressed: () => setState(() => _isListView = !_isListView),
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
            onPressed: _load,
          ),
        ],
        // Öğrenci ve Öğretmen (gün bazlı verisi varsa) için gün tab'ları
        bottom: ((_isStudent || (_isTeacher && _scheduleByDay.values.any((l) => l.isNotEmpty)))
                && !_isLoading && _errorMsg == null)
            ? TabBar(
                controller: _tabController,
                onTap: (i) => setState(() => _selectedDay = i + 1),
                isScrollable: false,
                indicatorColor: widget.accentColor,
                indicatorWeight: 3,
                labelColor: widget.accentColor,
                unselectedLabelColor: AppColors.textMuted,
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                unselectedLabelStyle: const TextStyle(fontSize: 12),
                tabs: [
                  for (int d = 1; d <= 5; d++)
                    _DayTab(
                      dayName:  _dayNames[d]!.substring(0, 3),
                      count:    _scheduleByDay[d]?.length ?? 0,
                      isToday:  d == _todayDay,
                      accent:   widget.accentColor,
                    ),
                ],
              )
            : null,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Yükleniyor
    if (_isLoading) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SkeletonCard(height: 120),
          SkeletonCard(height: 120),
          SkeletonCard(height: 120),
        ],
      );
    }

    // Hata
    if (_errorMsg != null) {
      return ErrorView(
        isNetworkError: _isNetworkError,
        message: _errorMsg,
        accentColor: widget.accentColor,
        onRetry: _load,
      );
    }

    if (_isStudent) return _buildStudentView();
    if (_isTeacher) {
      // Gün bazlı veri varsa → tab görünümü; yoksa → ders listesi
      if (_scheduleByDay.values.any((l) => l.isNotEmpty)) {
        return _buildStudentView();
      }
      return _buildTeacherView();
    }
    return const EmptyView(
      icon: Icons.calendar_today_outlined,
      message: 'Ders programı yok.',
    );
  }

  // ── Öğrenci görünümü ──────────────────────────────────────────────────────

  Widget _buildStudentView() {
    if (_isListView) return _buildStudentList();
    return _buildStudentTabContent();
  }

  /// Seçili gün tab'ı içeriği
  Widget _buildStudentTabContent() {
    final courses = _scheduleByDay[_selectedDay] ?? [];
    if (courses.isEmpty) {
      return EmptyView(
        icon: Icons.free_breakfast_rounded,
        message: '${_dayNames[_selectedDay] ?? 'Bu gün'} dersi yok.',
        subtitle: 'Bu gün için programda ders bulunmuyor.',
        accentColor: widget.accentColor,
      );
    }
    return RefreshIndicator(
      color: widget.accentColor,
      backgroundColor: AppColors.surface,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: courses.length,
        itemBuilder: (_, i) => _CourseCard(course: courses[i], accent: widget.accentColor),
      ),
    );
  }

  /// Tüm haftayı liste görünümünde göster
  Widget _buildStudentList() {
    final hasAny = _scheduleByDay.values.any((list) => list.isNotEmpty);
    if (!hasAny) {
      return EmptyView(
        icon: Icons.school_outlined,
        message: 'Kayıtlı ders bulunamadı.',
        subtitle: 'Hiçbir derse kayıt yapılmamış.',
        accentColor: widget.accentColor,
      );
    }
    return RefreshIndicator(
      color: widget.accentColor,
      backgroundColor: AppColors.surface,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          for (int d = 1; d <= 5; d++)
            if ((_scheduleByDay[d] ?? []).isNotEmpty) ...[
              // Gün başlığı
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 10),
                child: Row(children: [
                  Container(width: 4, height: 18,
                      decoration: BoxDecoration(
                          color: widget.accentColor,
                          borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 10),
                  Text(_dayNames[d] ?? 'Gün $d',
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
                  if (d == _todayDay) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: widget.accentColor.withAlpha(51),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Bugün',
                          style: TextStyle(
                              color: widget.accentColor, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ]),
              ),
              for (final course in _scheduleByDay[d]!)
                _CourseCard(course: course, accent: widget.accentColor),
            ],
        ],
      ),
    );
  }

  // ── Öğretim Üyesi görünümü ────────────────────────────────────────────────

  Widget _buildTeacherView() {
    if (_teacherCourses.isEmpty) {
      return EmptyView(
        icon: Icons.school_outlined,
        message: 'Henüz ders atanmamış.',
        subtitle: 'Size atanan dersler burada görünecek.',
        accentColor: widget.accentColor,
      );
    }
    return RefreshIndicator(
      color: widget.accentColor,
      backgroundColor: AppColors.surface,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _teacherCourses.length,
        itemBuilder: (_, i) => _TeacherCourseCard(
          course: _teacherCourses[i],
          accent: widget.accentColor,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB BAŞLIĞI
// ─────────────────────────────────────────────

class _DayTab extends StatelessWidget {
  final String dayName;
  final int    count;
  final bool   isToday;
  final Color  accent;

  const _DayTab({
    required this.dayName,
    required this.count,
    required this.isToday,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(dayName),
          if (count > 0)
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 6, height: 6,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: accent),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ÖĞRENCİ DERS KARTI
// ─────────────────────────────────────────────

class _CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final Color                accent;

  const _CourseCard({required this.course, required this.accent});

  @override
  Widget build(BuildContext context) {
    final code        = course['course_code']  as String? ?? '';
    final name        = course['course_name']  as String? ?? '';
    final teacher     = course['teacher_name'] as String? ?? '';
    final startTime   = _shortTime(course['start_time'] as String?);
    final endTime     = _shortTime(course['end_time']   as String?);
    final classroom   = course['classroom']    as String? ?? '—';
    final building    = course['building']     as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: accent.withAlpha(18),
        border: Border.all(color: accent.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Saat bandı + kod
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: accent.withAlpha(38),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$startTime – $endTime',
                style: TextStyle(
                    color: accent, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
            const Spacer(),
            Text(code,
                style: TextStyle(
                    color: accent.withAlpha(180), fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 8),
          // Ders adı
          Text(name,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          // Derslik
          Row(children: [
            const Icon(Icons.meeting_room_rounded, size: 13, color: AppColors.textMuted),
            const SizedBox(width: 5),
            Text(
              building.isNotEmpty ? '$classroom · $building' : classroom,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ]),
          const SizedBox(height: 4),
          // Öğretim üyesi
          if (teacher.isNotEmpty)
            Row(children: [
              const Icon(Icons.person_outline_rounded, size: 13, color: AppColors.textMuted),
              const SizedBox(width: 5),
              Text(teacher,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ]),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ÖĞRETİM ÜYESİ DERS KARTI
// ─────────────────────────────────────────────

class _TeacherCourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final Color                accent;

  const _TeacherCourseCard({required this.course, required this.accent});

  @override
  Widget build(BuildContext context) {
    final code      = course['course_code']   as String? ?? '';
    final name      = course['course_name']   as String? ?? '';
    final dept      = course['department']    as String? ?? '';
    final credits   = course['credits']       ?? 0;
    final enrolled  = course['enrolled_count']  ?? 0;
    final capacity  = course['capacity']        ?? 0;
    final semester  = course['semester']      as String? ?? '';
    final year      = course['academic_year'] as String? ?? '';

    final cap       = (capacity as num?)?.toInt()  ?? 0;
    final enr       = (enrolled as num?)?.toInt()  ?? 0;
    final fillRatio = cap > 0 ? enr / cap : 0.0;
    final fillColor = fillRatio > 0.85 ? AppColors.error
        : fillRatio > 0.6 ? AppColors.warning
        : AppColors.success;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: accent.withAlpha(13),
        border: Border.all(color: accent.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: accent.withAlpha(38), borderRadius: BorderRadius.circular(8)),
              child: Text(code,
                  style: TextStyle(
                      color: accent, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(name,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.domain_rounded, size: 13, color: AppColors.textMuted),
            const SizedBox(width: 5),
            Expanded(child: Text(dept,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
            Text('$credits kredi',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ]),
          if (semester.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.textMuted),
              const SizedBox(width: 5),
              Text('$semester / $year',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ]),
          ],
          const SizedBox(height: 10),
          // Doluluk barı
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Kayıtlı öğrenci',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                Text('$enrolled / $capacity',
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: fillRatio.clamp(0.0, 1.0),
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation(fillColor),
                  minHeight: 5,
                ),
              ),
            ])),
          ]),
        ],
      ),
    );
  }
}
