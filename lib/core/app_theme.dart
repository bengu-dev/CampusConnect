import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// CampusConnect Design System — Açık Tema (Beyaz Arka Plan)

class AppColors {
  AppColors._();

  // Ana marka rengi — mavi
  static const Color primary     = Color(0xFF2563EB); // blue-600
  static const Color primaryDark = Color(0xFF1D4ED8); // blue-700
  static const Color primaryLight = Color(0xFFEFF6FF); // blue-50
  static const Color secondary   = Color(0xFF0EA5E9); // sky-500

  // Rol renkleri — gradient başlangıç/bitiş
  static const Color student    = Color(0xFF2563EB); // mavi
  static const Color studentEnd = Color(0xFF4F46E5); // indigo
  static const Color teacher    = Color(0xFF059669); // yeşil
  static const Color teacherEnd = Color(0xFF0D9488); // turkuaz
  static const Color office     = Color(0xFFD97706); // turuncu
  static const Color officeEnd  = Color(0xFFDC2626); // kırmızı

  // Arka plan — beyaz ve açık tonlar
  static const Color bgLight   = Color(0xFFFFFFFF); // saf beyaz
  static const Color bgSurface = Color(0xFFF0F4FF); // çok açık mavi-beyaz
  static const Color bgCard    = Color(0xFFFFFFFF); // kart arka planı
  static const Color surface   = Color(0xFFF1F5F9); // açık gri-mavi

  // Kenarlık
  static const Color border      = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);

  // Semantik
  static const Color error   = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);

  // Metin — koyu (beyaz arka planda okunabilir)
  static const Color textPrimary   = Color(0xFF1E293B); // slate-800
  static const Color textSecondary = Color(0xFF64748B); // slate-500
  static const Color textMuted     = Color(0xFF94A3B8); // slate-400
  static const Color textHint      = Color(0xFFCBD5E1); // slate-300

  // Geriye dönük uyumluluk için aliases
  static const Color bgDark  = bgLight;
  static const Color bgMid   = bgSurface;
  static const Color bgDeep  = bgCard;
}

class AppGradients {
  AppGradients._();

  // Ekran arka planı — çok hafif mavi tonlu beyaz
  static const LinearGradient background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEFF6FF), Color(0xFFFFFFFF)],
  );

  // Marka gradient'ı — mavi
  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2563EB), Color(0xFF0EA5E9)],
  );

  // Rol gradient'ları
  static const LinearGradient student = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
  );
  static const LinearGradient teacher = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF0D9488)],
  );
  static const LinearGradient office = LinearGradient(
    colors: [Color(0xFFD97706), Color(0xFFDC2626)],
  );
  static const LinearGradient loading = LinearGradient(
    colors: [Color(0xFF94A3B8), Color(0xFF94A3B8)],
  );
}

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get heading1 => GoogleFonts.plusJakartaSans(
    fontSize: 42, fontWeight: FontWeight.w800, height: 1.15,
    letterSpacing: -1, color: AppColors.textPrimary,
  );

  static TextStyle get heading2 => GoogleFonts.plusJakartaSans(
    fontSize: 30, fontWeight: FontWeight.w700, letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static TextStyle get subtitle => GoogleFonts.plusJakartaSans(
    fontSize: 16, fontWeight: FontWeight.w400, height: 1.6,
    color: AppColors.textSecondary,
  );

  static TextStyle get cardTitle => GoogleFonts.plusJakartaSans(
    fontSize: 16, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get cardSubtitle => GoogleFonts.plusJakartaSans(
    fontSize: 13, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle get label => GoogleFonts.plusJakartaSans(
    fontSize: 13, fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle get body => GoogleFonts.plusJakartaSans(
    fontSize: 15, fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle get button => GoogleFonts.plusJakartaSans(
    fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white,
  );

  static TextStyle get appBarTitle => GoogleFonts.plusJakartaSans(
    fontSize: 20, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get caption => GoogleFonts.plusJakartaSans(
    fontSize: 12, fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );
}

class AppTheme {
  AppTheme._();

  // Artık light theme kullanılıyor
  static ThemeData get dark => light;

  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.bgLight,
    colorScheme: const ColorScheme.light(
      primary:   AppColors.primary,
      secondary: AppColors.secondary,
      surface:   AppColors.surface,
      error:     AppColors.error,
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(
      ThemeData.light().textTheme,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor:  AppColors.bgLight,
      foregroundColor:  AppColors.textPrimary,
      elevation:        0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color:       AppColors.bgCard,
      elevation:   0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    dividerColor:        AppColors.border,
    dividerTheme: const DividerThemeData(color: AppColors.border),
    useMaterial3:        true,
  );
}
