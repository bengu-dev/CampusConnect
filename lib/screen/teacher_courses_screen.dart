import 'package:campus_project/core/app_theme.dart';
import 'package:campus_project/screen/student_list_screen.dart';
import 'package:campus_project/services/api_service.dart';
import 'package:campus_project/widgets/error_view.dart';
import 'package:campus_project/widgets/skeleton_widget.dart';
import 'package:flutter/material.dart';

class TeacherCoursesScreen extends StatefulWidget {
  final Color accentColor;
  const TeacherCoursesScreen({super.key, required this.accentColor});

  @override
  State<TeacherCoursesScreen> createState() => _TeacherCoursesScreenState();
}

class _TeacherCoursesScreenState extends State<TeacherCoursesScreen> {
  List<Map<String, dynamic>> _courses = [];
  bool    _isLoading      = true;
  bool    _isNetworkError = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _isNetworkError = false; _errorMsg = null; });
    final result = await ApiService.getTeacherCourses();
    if (!mounted) return;
    if (result['success'] == true) {
      final raw = result['courses'] as List? ?? [];
      setState(() {
        _courses = raw.map((e) => Map<String, dynamic>.from(e)).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isNetworkError = result['isNetworkError'] == true;
        _errorMsg  = result['message'];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        title: const Text('Derslerim',
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
          SkeletonCard(height: 160),
          SkeletonCard(height: 160),
          SkeletonCard(height: 160),
        ],
      );
    }
    if (_errorMsg != null) {
      return ErrorView(
        isNetworkError: _isNetworkError,
        message: _errorMsg,
        accentColor: widget.accentColor,
        onRetry: _load,
      );
    }
    if (_courses.isEmpty) {
      return const EmptyView(
        icon: Icons.school_outlined,
        message: 'Henüz ders atanmamış.',
        subtitle: 'Size atanan dersler burada görünecek.',
      );
    }
    return RefreshIndicator(
      color: widget.accentColor,
      backgroundColor: AppColors.surface,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _courses.length,
        itemBuilder: (_, i) => _CourseCard(
          course: _courses[i],
          accentColor: widget.accentColor,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StudentListScreen(
                courseId:   _courses[i]['courseId'] as int? ?? 0,
                courseName: _courses[i]['courseName'] as String? ?? '',
                courseCode: _courses[i]['courseCode'] as String? ?? '',
                accentColor: widget.accentColor,
              ),
            ),
          ).then((_) => _load()),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DERS KARTI
// ─────────────────────────────────────────────

class _CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final Color  accentColor;
  final VoidCallback onTap;

  const _CourseCard({required this.course, required this.accentColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final code      = course['courseCode']   as String? ?? '';
    final name      = course['courseName']   as String? ?? '';
    final dept      = course['department']   as String? ?? '';
    final credits   = course['credits']      as int?    ?? 0;
    final enrolled  = course['enrolledCount']  as int?  ?? 0;
    final capacity  = course['capacity']       as int?  ?? 0;
    final available = course['availableSeats'] as int?  ?? 0;
    final semester  = course['semester']     as String? ?? '';
    final year      = course['academicYear'] as String? ?? '';

    final fillRatio = capacity > 0 ? enrolled / capacity : 0.0;
    final fillColor = fillRatio > 0.85
        ? AppColors.error
        : fillRatio > 0.6
            ? AppColors.warning
            : AppColors.success;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: accentColor.withAlpha(13),
          border: Border.all(color: accentColor.withAlpha(51)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kod + ad
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withAlpha(38),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(code,
                      style: TextStyle(
                          color: accentColor, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(name,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 10),
            // Bölüm + kredi + dönem
            Row(children: [
              const Icon(Icons.domain_rounded, size: 13, color: AppColors.textMuted),
              const SizedBox(width: 5),
              Expanded(child: Text(dept,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
              Text('$credits Kredi',
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
            const SizedBox(height: 14),
            // Doluluk
            Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Kayıtlı öğrenci',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                        Text('$enrolled / $capacity',
                            style: const TextStyle(
                                color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: fillRatio.clamp(0.0, 1.0),
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation(fillColor),
                        minHeight: 5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Column(children: [
                Text('$available',
                    style: TextStyle(color: fillColor, fontSize: 22, fontWeight: FontWeight.w800)),
                const Text('boş',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
              ]),
            ]),
            const SizedBox(height: 12),
            // Öğrenci listesi linki
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.people_rounded, size: 14, color: accentColor.withAlpha(180)),
                const SizedBox(width: 6),
                Text('Öğrenci Listesi & Not Girişi →',
                    style: TextStyle(
                        color: accentColor, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
