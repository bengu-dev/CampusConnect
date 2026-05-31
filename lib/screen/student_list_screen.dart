import 'package:campus_project/core/app_theme.dart';
import 'package:campus_project/services/api_service.dart';
import 'package:campus_project/widgets/error_view.dart';
import 'package:campus_project/widgets/skeleton_widget.dart';
import 'package:flutter/material.dart';

// Geçerli not seçenekleri
const _gradeOptions = ['AA', 'BA', 'BB', 'CB', 'CC', 'DC', 'DD', 'FF', 'MUAF', 'DEV'];

class StudentListScreen extends StatefulWidget {
  final int    courseId;
  final String courseName;
  final String courseCode;
  final Color  accentColor;

  const StudentListScreen({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    required this.accentColor,
  });

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  List<Map<String, dynamic>> _students = [];
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
    final result = await ApiService.getCourseStudents(widget.courseId);
    if (!mounted) return;
    if (result['success'] == true) {
      final raw = result['students'] as List? ?? [];
      setState(() {
        _students = raw.map((e) => Map<String, dynamic>.from(e)).toList();
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

  // ── Not girişi dialog'u ───────────────────────────────────────────────────

  Future<void> _showGradeDialog(Map<String, dynamic> student) async {
    final name         = '${student['firstName']} ${student['lastName']}';
    final enrollmentId = student['enrollmentId'] as int? ?? 0;
    String? selected   = student['grade'] as String?;

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: AppColors.bgCard,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Not Girişi',
                  style: TextStyle(
                      color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(name,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _gradeOptions.map((g) {
                  final isSelected = selected == g;
                  return GestureDetector(
                    onTap: () => setLocal(() => selected = g),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: isSelected
                            ? widget.accentColor.withAlpha(51)
                            : AppColors.bgSurface,
                        border: Border.all(
                          color: isSelected
                              ? widget.accentColor
                              : AppColors.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(g,
                          style: TextStyle(
                            color: isSelected ? widget.accentColor : AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                          )),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal',
                  style: TextStyle(color: AppColors.textMuted)),
            ),
            TextButton(
              onPressed: selected == null
                  ? null
                  : () => Navigator.pop(ctx, selected),
              child: Text('Kaydet',
                  style: TextStyle(
                      color: selected == null
                          ? AppColors.textHint
                          : widget.accentColor,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );

    if (result == null || !mounted) return;

    // API'ye gönder
    final apiResult = await ApiService.setStudentGrade(
      courseId:     widget.courseId,
      enrollmentId: enrollmentId,
      grade:        result,
    );
    if (!mounted) return;

    if (apiResult['success'] == true) {
      setState(() => student['grade'] = result);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$name → $result notu kaydedildi.'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(apiResult['message'] ?? 'Not kaydedilemedi!'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.courseName,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis),
            Text(widget.courseCode,
                style: TextStyle(
                    color: widget.accentColor, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.accentColor.withAlpha(38),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_students.length} öğrenci',
                  style: TextStyle(
                      color: widget.accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
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
        children: List.generate(5, (_) => const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: SkeletonListTile(),
        )),
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
    if (_students.isEmpty) {
      return EmptyView(
        icon: Icons.people_outlined,
        message: 'Bu derse kayıtlı öğrenci yok.',
        accentColor: widget.accentColor,
      );
    }
    return RefreshIndicator(
      color: widget.accentColor,
      backgroundColor: AppColors.surface,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _students.length,
        itemBuilder: (_, i) {
          final s          = _students[i];
          final firstName  = s['firstName']     as String? ?? '';
          final lastName   = s['lastName']      as String? ?? '';
          final studentNum = s['studentNumber'] as String? ?? '';
          final initials   = '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}';

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.bgCard,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                // Sıra numarası
                SizedBox(
                  width: 28,
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 10),
                // Avatar
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.accentColor.withAlpha(30),
                  ),
                  child: Center(
                    child: Text(initials.toUpperCase(),
                        style: TextStyle(
                            color: widget.accentColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                // Ad soyad + öğrenci no
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$firstName $lastName',
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(studentNum,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                // Not girişi ikonu (sağda küçük)
                GestureDetector(
                  onTap: () => _showGradeDialog(s),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.bgSurface,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Icon(Icons.edit_note_rounded,
                        size: 18, color: widget.accentColor.withAlpha(180)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
