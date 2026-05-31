import 'package:campus_project/core/app_theme.dart';
import 'package:campus_project/services/api_service.dart';
import 'package:campus_project/widgets/error_view.dart';
import 'package:campus_project/widgets/skeleton_widget.dart';
import 'package:flutter/material.dart';

const _gradeColors = {
  'AA': Color(0xFF10B981), // yeşil
  'BA': Color(0xFF34D399),
  'BB': Color(0xFF3B82F6), // mavi
  'CB': Color(0xFF60A5FA),
  'CC': Color(0xFFF59E0B), // sarı
  'DC': Color(0xFFF97316), // turuncu
  'DD': Color(0xFFEF4444), // kırmızı
  'FF': Color(0xFFDC2626),
};

Color _gradeColor(String? g) =>
    _gradeColors[g?.toUpperCase()] ?? AppColors.textMuted;

class TranscriptScreen extends StatefulWidget {
  final Color accentColor;
  const TranscriptScreen({super.key, required this.accentColor});

  @override
  State<TranscriptScreen> createState() => _TranscriptScreenState();
}

class _TranscriptScreenState extends State<TranscriptScreen> {
  List<Map<String, dynamic>> _transcript = [];
  double  _gpa        = 0.0;
  int     _total      = 0;
  bool    _isLoading  = true;
  bool    _isNetErr   = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _isNetErr = false; _errorMsg = null; });
    final result = await ApiService.getTranscript();
    if (!mounted) return;
    if (result['success'] == true) {
      final raw = (result['transcript'] as List? ?? []);
      setState(() {
        _transcript = raw.map((e) => Map<String, dynamic>.from(e)).toList();
        _gpa        = (result['gpa'] as num?)?.toDouble() ?? 0.0;
        _total      = result['totalCourses'] as int? ?? _transcript.length;
        _isLoading  = false;
      });
    } else {
      setState(() {
        _isNetErr  = result['isNetworkError'] == true;
        _errorMsg  = result['message'] as String?;
        _isLoading = false;
      });
    }
  }

  // Dersleri dönem+yıl'a göre grupla
  Map<String, List<Map<String, dynamic>>> get _grouped {
    final groups = <String, List<Map<String, dynamic>>>{};
    for (final item in _transcript) {
      final sem  = item['semester']      as String? ?? 'Bilinmiyor';
      final year = item['academic_year'] as String? ?? '';
      final key  = year.isNotEmpty ? '$sem / $year' : sem;
      groups.putIfAbsent(key, () => []).add(item);
    }
    return groups;
  }

  int get _completedCount =>
      _transcript.where((e) => e['enrollment_status'] == 'COMPLETED').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        title: const Text('Transkript',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
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
    if (_isLoading) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SkeletonCard(height: 110),
          SkeletonCard(height: 80),
          SkeletonCard(height: 80),
          SkeletonCard(height: 80),
        ],
      );
    }
    if (_errorMsg != null) {
      return ErrorView(
        isNetworkError: _isNetErr,
        message: _errorMsg,
        accentColor: widget.accentColor,
        onRetry: _load,
      );
    }
    if (_transcript.isEmpty) {
      return const EmptyView(
        icon: Icons.description_outlined,
        message: 'Henüz ders kaydı bulunamadı.',
      );
    }
    return RefreshIndicator(
      color: widget.accentColor,
      backgroundColor: AppColors.surface,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _buildGpaCard(),
          const SizedBox(height: 16),
          ..._buildSemesters(),
        ],
      ),
    );
  }

  // ── GPA kartı ──────────────────────────────────────────────────────────────

  Widget _buildGpaCard() {
    final gpaColor = _gpa >= 3.0
        ? const Color(0xFF10B981)
        : _gpa >= 2.0
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [widget.accentColor.withAlpha(50), widget.accentColor.withAlpha(20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: widget.accentColor.withAlpha(80)),
      ),
      child: Row(
        children: [
          // GPA dairesi
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: gpaColor.withAlpha(30),
              border: Border.all(color: gpaColor.withAlpha(120), width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _gpa.toStringAsFixed(2),
                  style: TextStyle(
                      color: gpaColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w800),
                ),
                Text('GPA', style: TextStyle(color: gpaColor, fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // İstatistikler
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Akademik Transkript',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                _stat(Icons.book_outlined, 'Toplam ders', '$_total'),
                const SizedBox(height: 6),
                _stat(Icons.check_circle_outline_rounded, 'Tamamlanan', '$_completedCount'),
                const SizedBox(height: 6),
                _stat(Icons.pending_outlined, 'Devam eden', '${_total - _completedCount}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String label, String value) => Row(
    children: [
      Icon(icon, size: 13, color: AppColors.textSecondary),
      const SizedBox(width: 6),
      Text(label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      const Spacer(),
      Text(value,
          style: const TextStyle(
              color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
    ],
  );

  // ── Dönemlere göre listele ─────────────────────────────────────────────────

  List<Widget> _buildSemesters() {
    final widgets = <Widget>[];
    final groups  = _grouped;
    for (final key in groups.keys) {
      widgets.add(_SemesterHeader(label: key, accent: widget.accentColor));
      widgets.add(const SizedBox(height: 8));
      for (final course in groups[key]!) {
        widgets.add(_CourseRow(course: course));
        widgets.add(const SizedBox(height: 8));
      }
      widgets.add(const SizedBox(height: 8));
    }
    return widgets;
  }
}

// ─────────────────────────────────────────────
// DÖNEM BAŞLIĞI
// ─────────────────────────────────────────────

class _SemesterHeader extends StatelessWidget {
  final String label;
  final Color  accent;
  const _SemesterHeader({required this.label, required this.accent});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 4, height: 18,
        decoration: BoxDecoration(
            color: accent, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 10),
    Text(label,
        style: const TextStyle(
            color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
  ]);
}

// ─────────────────────────────────────────────
// DERS SATIRI
// ─────────────────────────────────────────────

class _CourseRow extends StatelessWidget {
  final Map<String, dynamic> course;
  const _CourseRow({required this.course});

  @override
  Widget build(BuildContext context) {
    final code    = course['course_code']       as String? ?? '';
    final name    = course['course_name']       as String? ?? '';
    final credits = course['credits']           ?? 0;
    final grade   = course['letter_grade'] as String? ?? course['grade'] as String?;
    final status  = course['enrollment_status'] as String? ?? '';
    final isActive = status == 'ACTIVE';
    final gc = _gradeColor(grade);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.bgCard,
        border: Border.all(
          color: isActive
              ? AppColors.border
              : gc.withAlpha(40),
        ),
      ),
      child: Row(
        children: [
          // Kod
          SizedBox(
            width: 70,
            child: Text(code,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ),
          // Ders adı
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text('${credits} kredi',
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Not / Durum
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Devam',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            )
          else
            Container(
              width: 44, height: 36,
              decoration: BoxDecoration(
                color: gc.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: gc.withAlpha(80)),
              ),
              alignment: Alignment.center,
              child: Text(
                grade ?? '--',
                style: TextStyle(
                    color: gc,
                    fontSize: 14,
                    fontWeight: FontWeight.w800),
              ),
            ),
        ],
      ),
    );
  }
}
