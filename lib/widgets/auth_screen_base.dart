import 'package:campus_project/core/app_lang.dart';
import 'package:campus_project/core/app_theme.dart';
import 'package:flutter/material.dart';

/// Tüm giriş/kayıt ekranlarının beyaz temalı ortak iskeleti.
class AuthScreenBase extends StatelessWidget {
  final String         role;
  final String         roleEmoji;
  final IconData       roleIcon;
  final LinearGradient gradient;
  final Color          accentColor;
  final Widget         body;

  const AuthScreenBase({
    super.key,
    required this.role,
    required this.roleEmoji,
    required this.roleIcon,
    required this.gradient,
    required this.accentColor,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLang.notifier,
      builder: (context, lang, child) => Scaffold(
        backgroundColor: AppColors.bgLight,
        body: SafeArea(
          child: Column(
            children: [
              // ── Üst Bar ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    // Geri butonu
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.bgSurface,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            color: AppColors.textPrimary, size: 18),
                      ),
                    ),

                    const Spacer(),

                    // TR / EN toggle
                    _LangToggle(accent: accentColor),

                    const SizedBox(width: 10),

                    // Rol rozeti
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: gradient,
                      ),
                      child: Text(
                        role,
                        style: const TextStyle(
                          color:      Colors.white,
                          fontSize:   12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── İçerik ─────────────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: body,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TR / EN Toggle — beyaz temaya uygun
// ─────────────────────────────────────────────

class _LangToggle extends StatelessWidget {
  final Color accent;
  const _LangToggle({required this.accent});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppLang.toggle(),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: AppColors.bgSurface,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Chip(label: 'TR', active: AppLang.isTr, accent: accent),
            const SizedBox(width: 2),
            _Chip(label: 'EN', active: AppLang.isEn, accent: accent),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool   active;
  final Color  accent;
  const _Chip({required this.label, required this.active, required this.accent});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: active ? accent : Colors.transparent,
      ),
      child: Text(
        label,
        style: TextStyle(
          color:      active ? Colors.white : AppColors.textMuted,
          fontSize:   11,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}
