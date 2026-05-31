import 'package:campus_project/core/app_theme.dart';
import 'package:campus_project/services/api_service.dart';
import 'package:campus_project/widgets/custom_text_filed.dart';
import 'package:flutter/material.dart';

// Hedef kitle seçenekleri
const _targets = [
  (value: 'STUDENT', label: 'Öğrencilerime',      icon: Icons.school_rounded,               desc: 'Tüm öğrencilere gönder'),
  (value: 'COURSE',  label: 'Derse Özel',           icon: Icons.menu_book_rounded,             desc: 'Belirli bir derse gönder'),
  (value: 'TEACHER', label: 'Öğretmenler',           icon: Icons.cast_for_education_rounded,    desc: 'Tüm öğretim üyelerine gönder'),
  (value: 'OFFICE',  label: 'Ofis Personeli',        icon: Icons.business_center_rounded,       desc: 'Ofis çalışanlarına gönder'),
  (value: 'ALL',     label: 'Herkese',               icon: Icons.public_rounded,                desc: 'Tüm kullanıcılara gönder'),
];

const _targetColors = {
  'STUDENT': Color(0xFF059669),
  'COURSE':  Color(0xFF2563EB),
  'TEACHER': Color(0xFF0D9488),
  'OFFICE':  Color(0xFFD97706),
  'ALL':     Color(0xFF4F46E5),
};

class CreateAnnouncementScreen extends StatefulWidget {
  final Color accentColor;
  const CreateAnnouncementScreen({super.key, required this.accentColor});

  @override
  State<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _formKey         = GlobalKey<FormState>();
  final _titleController   = TextEditingController();
  final _contentController = TextEditingController();

  String  _selectedTarget   = 'STUDENT';
  String? _selectedCourseId;
  bool    _isLoading        = false;

  // Öğretmenin kendi dersleri
  List<Map<String, dynamic>> _courses       = [];
  bool                       _coursesLoading = true;

  // Tüm öğretmen listesi
  List<Map<String, dynamic>> _teachers       = [];
  bool                       _teachersLoading = false;

  // Seçilen öğretmenler (görsel bilgi amaçlı, API TEACHER rolüne gönderir)
  final Set<dynamic> _selectedTeacherIds = {};

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    final result = await ApiService.getTeacherCourses();
    if (!mounted) return;
    if (result['success'] == true) {
      setState(() {
        _courses = (result['courses'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _coursesLoading = false;
      });
    } else {
      setState(() => _coursesLoading = false);
    }
  }

  Future<void> _loadTeachers() async {
    if (_teachers.isNotEmpty) return;
    setState(() => _teachersLoading = true);
    final result = await ApiService.getAllTeachers();
    if (!mounted) return;
    setState(() {
      if (result['success'] == true) {
        _teachers = (result['teachers'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
      _teachersLoading = false;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTarget == 'COURSE' && _selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text('Lütfen bir ders seçin!'),
        ]),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }

    setState(() => _isLoading = true);
    final result = await ApiService.createAnnouncement(
      title:      _titleController.text.trim(),
      content:    _contentController.text.trim(),
      targetRole: _selectedTarget == 'COURSE' ? 'STUDENT' : _selectedTarget,
      courseId:   _selectedTarget == 'COURSE' ? _selectedCourseId : null,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Row(children: [
          Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text('Duyuru oluşturuldu ve yayınlandı!'),
        ]),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] as String? ?? 'Duyuru oluşturulamadı!'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor;
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        title: const Text('Duyuru Oluştur',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded,
              color: AppColors.textPrimary, size: 22),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Başlık ────────────────────────────────────────────────
              _sectionLabel('Duyuru Başlığı'),
              const SizedBox(height: 8),
              CustomTextField(
                label: 'Başlık',
                hint: 'Kısa ve açıklayıcı bir başlık',
                icon: Icons.title_rounded,
                controller: _titleController,
                accentColor: accent,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Başlık boş olamaz';
                  if (v.trim().length < 5) return 'En az 5 karakter olmalı';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // ── İçerik ────────────────────────────────────────────────
              _sectionLabel('Duyuru İçeriği'),
              const SizedBox(height: 8),
              _contentField(accent),
              const SizedBox(height: 24),

              // ── Hedef Kitle Seçimi ────────────────────────────────────
              _sectionLabel('Kime Gönderilsin?'),
              const SizedBox(height: 12),
              _targetGrid(accent),

              // ── Derse Özel: Kurs dropdown ─────────────────────────────
              if (_selectedTarget == 'COURSE') ...[
                const SizedBox(height: 16),
                _courseDropdown(accent),
              ],

              // ── Öğretmen Seçimi (görsel) ──────────────────────────────
              if (_selectedTarget == 'TEACHER') ...[
                const SizedBox(height: 16),
                _teacherPicker(accent),
              ],

              // ── Öğrenci Özeti ─────────────────────────────────────────
              if (_selectedTarget == 'STUDENT') ...[
                const SizedBox(height: 16),
                _studentSummary(accent),
              ],

              const SizedBox(height: 32),

              // ── Gönder Butonu ─────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: _isLoading
                          ? AppGradients.loading
                          : LinearGradient(
                              colors: [accent, accent.withAlpha(220)]),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: _isLoading
                          ? const SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5, color: Colors.white))
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send_rounded,
                                    color: Colors.white, size: 18),
                                SizedBox(width: 10),
                                Text('Yayınla',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Duyuru anlık olarak ilgili kullanıcılara iletilecektir.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Hedef Izgara ──────────────────────────────────────────────────────────

  Widget _targetGrid(Color accent) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.2,
      children: _targets.map((t) {
        final selected  = _selectedTarget == t.value;
        final color     = _targetColors[t.value] ?? accent;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedTarget = t.value;
              _selectedCourseId = null;
              _selectedTeacherIds.clear();
            });
            if (t.value == 'TEACHER') _loadTeachers();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: selected ? color.withAlpha(20) : AppColors.bgSurface,
              border: Border.all(
                color: selected ? color : AppColors.border,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? color.withAlpha(30) : AppColors.border.withAlpha(60),
                  ),
                  child: Icon(t.icon,
                      size: 16,
                      color: selected ? color : AppColors.textMuted),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(t.label,
                          style: TextStyle(
                            color: selected ? color : AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text(t.desc,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 9,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Kurs Dropdown ─────────────────────────────────────────────────────────

  Widget _courseDropdown(Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Hangi Ders İçin?'),
        const SizedBox(height: 8),
        _coursesLoading
            ? const Center(child: CircularProgressIndicator())
            : _courses.isEmpty
                ? _infoBox(Icons.info_outline_rounded, 'Atanmış dersiniz bulunamadı.')
                : DropdownButtonFormField<String>(
                    dropdownColor: AppColors.bgCard,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Bir ders seçin…',
                      hintStyle: const TextStyle(
                          color: AppColors.textHint, fontSize: 14),
                      filled: true,
                      fillColor: AppColors.bgSurface,
                      prefixIcon: Icon(Icons.menu_book_rounded,
                          color: accent.withAlpha(200), size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: accent, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                    ),
                    initialValue: _selectedCourseId,
                    items: _courses.map((c) {
                      final id   = c['courseId']?.toString() ?? c['id']?.toString() ?? '';
                      final code = c['courseCode'] as String? ?? '';
                      final name = c['courseName'] as String? ?? '';
                      final cnt  = (c['enrolledCount'] as num?)?.toInt() ?? 0;
                      return DropdownMenuItem<String>(
                        value: id,
                        child: Text(
                          '$code — $name ($cnt öğrenci)',
                          style: const TextStyle(
                              color: AppColors.textPrimary, fontSize: 13),
                        ),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedCourseId = v),
                  ),
      ],
    );
  }

  // ── Öğretmen Seçici ───────────────────────────────────────────────────────

  Widget _teacherPicker(Color accent) {
    const color = Color(0xFF0D9488);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Öğretim Üyeleri'),
        const SizedBox(height: 4),
        const Text(
          'Duyuru tüm öğretim üyelerine gönderilecektir. '
          'Aşağıda kimlere ulaşacağını görebilirsin.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 10),
        _teachersLoading
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ))
            : _teachers.isEmpty
                ? _infoBox(Icons.people_outline_rounded, 'Öğretmen listesi yüklenemedi.')
                : Column(
                    children: _teachers.map((t) {
                      final id        = t['id'];
                      final firstName = t['first_name'] as String? ?? '';
                      final lastName  = t['last_name'] as String? ?? '';
                      final dept      = t['department'] as String? ?? '';
                      final fullName  = '$firstName $lastName'.trim();
                      final initials  =
                          '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}';
                      final isChecked = _selectedTeacherIds.contains(id);

                      return GestureDetector(
                        onTap: () => setState(() {
                          if (isChecked) {
                            _selectedTeacherIds.remove(id);
                          } else {
                            _selectedTeacherIds.add(id);
                          }
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: isChecked
                                ? color.withAlpha(15)
                                : AppColors.bgSurface,
                            border: Border.all(
                              color: isChecked ? color : AppColors.border,
                              width: isChecked ? 1.5 : 1,
                            ),
                          ),
                          child: Row(children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color.withAlpha(isChecked ? 40 : 20),
                              ),
                              child: Center(
                                child: Text(initials.toUpperCase(),
                                    style: TextStyle(
                                      color: color,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    )),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(fullName,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    )),
                                Text(dept,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    )),
                              ],
                            )),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 22, height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isChecked ? color : Colors.transparent,
                                border: Border.all(
                                  color: isChecked ? color : AppColors.border,
                                  width: 1.5,
                                ),
                              ),
                              child: isChecked
                                  ? const Icon(Icons.check_rounded,
                                      color: Colors.white, size: 13)
                                  : null,
                            ),
                          ]),
                        ),
                      );
                    }).toList(),
                  ),
        if (!_teachersLoading && _teachers.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _infoBox(
              Icons.info_outline_rounded,
              'İşaretleme görsel bilgi amaçlıdır. '
              'Duyuru tüm öğretim üyelerine gönderilir.',
            ),
          ),
      ],
    );
  }

  // ── Öğrenci Özeti ─────────────────────────────────────────────────────────

  Widget _studentSummary(Color accent) {
    const color = Color(0xFF059669);
    if (_coursesLoading) return const SizedBox();
    if (_courses.isEmpty) {
      return _infoBox(Icons.school_outlined,
          'Atanmış ders bulunamadı. Duyuru tüm öğrencilere gönderilecek.');
    }
    final total = _courses.fold<int>(
        0, (s, c) => s + ((c['enrolledCount'] as num?)?.toInt() ?? 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Ulaşacağı Öğrenciler'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withAlpha(12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withAlpha(50)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.people_rounded, color: color, size: 18),
                const SizedBox(width: 8),
                Text('$total öğrenci',
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    )),
                const Spacer(),
                Text('${_courses.length} ders',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ]),
              const SizedBox(height: 10),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 10),
              ..._courses.map((c) {
                final code = c['courseCode'] as String? ?? '';
                final name = c['courseName'] as String? ?? '';
                final cnt  = (c['enrolledCount'] as num?)?.toInt() ?? 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withAlpha(20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(code,
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          )),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(name,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis)),
                    Text('$cnt kişi',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        )),
                  ]),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // ── Yardımcı Widget'lar ───────────────────────────────────────────────────

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      color: AppColors.textSecondary,
      fontSize: 13,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
    ),
  );

  Widget _infoBox(IconData icon, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.bgSurface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(children: [
      Icon(icon, size: 15, color: AppColors.textMuted),
      const SizedBox(width: 8),
      Expanded(
        child: Text(text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.4,
            )),
      ),
    ]),
  );

  Widget _contentField(Color accent) => TextFormField(
    controller: _contentController,
    maxLines: 6,
    minLines: 4,
    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.6),
    decoration: InputDecoration(
      hintText: 'Duyuru içeriğini buraya yazın…',
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
      filled: true,
      fillColor: AppColors.bgSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.all(16),
    ),
    validator: (v) {
      if (v == null || v.trim().isEmpty) return 'İçerik boş olamaz';
      if (v.trim().length < 10) return 'En az 10 karakter olmalı';
      return null;
    },
  );
}
