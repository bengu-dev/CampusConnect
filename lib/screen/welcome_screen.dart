import 'package:campus_project/core/app_lang.dart';
import 'package:campus_project/core/app_theme.dart';
import 'package:campus_project/users/office_login_screen.dart';
import 'package:campus_project/users/student_login_screen.dart';
import 'package:campus_project/users/teacher_login_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/role_card.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        duration: const Duration(milliseconds: 700), vsync: this);
    _slideCtrl = AnimationController(
        duration: const Duration(milliseconds: 650), vsync: this);

    _fadeAnim  = CurvedAnimation(parent: _fadeCtrl,  curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));

    _fadeCtrl.forward();
    Future.delayed(const Duration(milliseconds: 100),
        () { if (mounted) _slideCtrl.forward(); });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  void _navigate(String role) {
    final Widget screen;
    switch (role) {
      case 'student': screen = const StudentLoginScreen(); break;
      case 'teacher': screen = const TeacherLoginScreen(); break;
      case 'office':  screen = const OfficeLoginScreen();  break;
      default: return;
    }
    Navigator.push(context, PageRouteBuilder(
      pageBuilder:       (ctx, anim, sec) => screen,
      transitionsBuilder:(ctx, anim, sec, child) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0), end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
      transitionDuration: const Duration(milliseconds: 320),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return ValueListenableBuilder<String>(
      valueListenable: AppLang.notifier,
      builder: (context, lang, child) => Scaffold(
        backgroundColor: AppColors.bgLight,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          // Beyaz arka plan, üstte çok hafif mavi ton
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFEFF6FF), Color(0xFFFFFFFF)],
            ),
          ),
          child: Stack(
            children: [
              // Dekoratif mavi daireler (hafif)
              Positioned(
                top: -60, right: -50,
                child: Container(
                  width: 220, height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withAlpha(18),
                  ),
                ),
              ),
              Positioned(
                top: 80, right: 60,
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondary.withAlpha(25),
                  ),
                ),
              ),
              Positioned(
                bottom: -80, left: -60,
                child: Container(
                  width: 260, height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withAlpha(12),
                  ),
                ),
              ),

              // İçerik
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // ── Üst Bar ──────────────────────────────────────────
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: Row(
                          children: [
                            // Logo
                            Container(
                              width: 46, height: 46,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(13),
                                gradient: AppGradients.brand,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withAlpha(60),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.school_rounded,
                                  color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Text('Campus Connect',
                                style: GoogleFontsHelper.appTitle),
                            const Spacer(),

                            // TR / EN toggle
                            _LangToggle(),
                          ],
                        ),
                      ),

                      SizedBox(height: size.height * 0.07),

                      // ── Başlık ────────────────────────────────────────────
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLang.t('Hoş Geldiniz', 'Welcome Back'),
                              style: AppTextStyles.heading1,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              AppLang.t(
                                'Kampüse erişmek için\nrolünüzü seçin.',
                                'Choose your role to\naccess the campus.',
                              ),
                              style: AppTextStyles.subtitle,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: size.height * 0.055),

                      // ── Rol Kartları ──────────────────────────────────────
                      SlideTransition(
                        position: _slideAnim,
                        child: FadeTransition(
                          opacity: _fadeAnim,
                          child: Column(
                            children: [
                              RoleCard(
                                title:       AppLang.t('Öğrenci', 'Student'),
                                subtitle:    AppLang.t(
                                  'Derslerine, notlarına ve programına eriş',
                                  'Access courses, grades & schedule',
                                ),
                                icon:        Icons.person_rounded,
                                gradient:    AppGradients.student,
                                accentColor: AppColors.student,
                                onTap:       () => _navigate('student'),
                                delay:       0,
                              ),
                              const SizedBox(height: 14),
                              RoleCard(
                                title:       AppLang.t('Öğretim Üyesi', 'Faculty'),
                                subtitle:    AppLang.t(
                                  'Dersleri, notları ve öğrencileri yönet',
                                  'Manage classes, grades & students',
                                ),
                                icon:        Icons.cast_for_education_rounded,
                                gradient:    AppGradients.teacher,
                                accentColor: AppColors.teacher,
                                onTap:       () => _navigate('teacher'),
                                delay:       60,
                              ),
                              const SizedBox(height: 14),
                              RoleCard(
                                title:       AppLang.t('Ofis Personeli', 'Office Staff'),
                                subtitle:    AppLang.t(
                                  'Yönetim ve idari araçlara eriş',
                                  'Administration & management tools',
                                ),
                                icon:        Icons.business_center_rounded,
                                gradient:    AppGradients.office,
                                accentColor: AppColors.office,
                                onTap:       () => _navigate('office'),
                                delay:       120,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(),

                      Center(
                        child: Text(
                          '© 2025 Campus Connect',
                          style: AppTextStyles.caption,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Google Fonts yardımcısı
class GoogleFontsHelper {
  static TextStyle get appTitle => const TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );
}

// ─────────────────────────────────────────────
// TR / EN TOGGLE
// ─────────────────────────────────────────────

class _LangToggle extends StatelessWidget {
  const _LangToggle();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppLang.toggle(),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.bgSurface,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Chip(label: 'TR', active: AppLang.isTr),
            const SizedBox(width: 2),
            _Chip(label: 'EN', active: AppLang.isEn),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool   active;
  const _Chip({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: active ? AppColors.primary : Colors.transparent,
        boxShadow: active
            ? [BoxShadow(
                color: AppColors.primary.withAlpha(50),
                blurRadius: 6, offset: const Offset(0, 2))]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color:      active ? Colors.white : AppColors.textMuted,
          fontSize:   12,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}
