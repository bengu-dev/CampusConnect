import 'package:campus_project/l10n/app_locale.dart';
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
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
    appLocale.addListener(_onLocaleChange);
  }

  void _onLocaleChange() => setState(() {});

  @override
  void dispose() {
    appLocale.removeListener(_onLocaleChange);
    _controller.dispose();
    super.dispose();
  }

  void _navigate(String role) {
    Widget screen;
    switch (role) {
      case 'student':
        screen = const StudentLoginScreen();
        break;
      case 'teacher':
        screen = const TeacherLoginScreen();
        break;
      case 'office':
        screen = const OfficeLoginScreen();
        break;
      default:
        return;
    }
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) =>
                FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.04, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                        parent: animation, curve: Curves.easeOut)),
                    child: child,
                  ),
                ),
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // appLocale değiştiğinde bu widget de rebuild olur
    // (main.dart'taki ValueListenableBuilder tüm ağacı yeniden kuruyor)
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),

                  // ── Üst satır: logo + dil seçici ─────────────────────────
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                          ),
                        ),
                        child: const Icon(Icons.school_rounded,
                            color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Campus Connect',
                        style: TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      // ── Dil seçici ─────────────────────────────────────
                      _LanguageToggle(),
                    ],
                  ),
                  const SizedBox(height: 36),

                  // ── Başlık ────────────────────────────────────────────────
                  Text(
                    S.selectRole,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Rol kartları ──────────────────────────────────────────
                  RoleCard(
                    title: S.studentRole,
                    subtitle: S.studentSubtitle,
                    icon: Icons.person_rounded,
                    gradient: const LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]),
                    accentColor: const Color(0xFF4F46E5),
                    onTap: () => _navigate('student'),
                  ),
                  const SizedBox(height: 12),
                  RoleCard(
                    title: S.teacherRole,
                    subtitle: S.teacherSubtitle,
                    icon: Icons.cast_for_education_rounded,
                    gradient: const LinearGradient(
                        colors: [Color(0xFF059669), Color(0xFF0D9488)]),
                    accentColor: const Color(0xFF059669),
                    onTap: () => _navigate('teacher'),
                  ),
                  const SizedBox(height: 12),
                  RoleCard(
                    title: S.officeRole,
                    subtitle: S.officeSubtitle,
                    icon: Icons.business_center_rounded,
                    gradient: const LinearGradient(
                        colors: [Color(0xFFD97706), Color(0xFFB45309)]),
                    accentColor: const Color(0xFFD97706),
                    onTap: () => _navigate('office'),
                  ),

                  const Spacer(),
                  Center(
                    child: Text(
                      S.copyright,
                      style: const TextStyle(
                          color: Color(0xFFCBD5E1), fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Dil Seçici Widget ────────────────────────────────────────────────────────

class _LanguageToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLocale,
      builder: (context, locale, _) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LangBtn(
                flag: '🇹🇷',
                code: 'TR',
                selected: locale == 'tr',
                onTap: () => appLocale.value = 'tr',
                isLeft: true,
              ),
              Container(
                  width: 1,
                  height: 28,
                  color: const Color(0xFFE2E8F0)),
              _LangBtn(
                flag: '🇬🇧',
                code: 'EN',
                selected: locale == 'en',
                onTap: () => appLocale.value = 'en',
                isLeft: false,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LangBtn extends StatelessWidget {
  final String flag;
  final String code;
  final bool selected;
  final VoidCallback onTap;
  final bool isLeft;

  const _LangBtn({
    required this.flag,
    required this.code,
    required this.selected,
    required this.onTap,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4F46E5) : Colors.transparent,
          borderRadius: BorderRadius.horizontal(
            left: isLeft ? const Radius.circular(9) : Radius.zero,
            right: !isLeft ? const Radius.circular(9) : Radius.zero,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              code,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
