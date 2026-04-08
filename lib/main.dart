import 'package:campus_project/l10n/app_locale.dart';
import 'package:campus_project/screen/home_screen.dart';
import 'package:campus_project/screen/splash_screen.dart';
import 'package:campus_project/screen/welcome_screen.dart';
import 'package:campus_project/users/office_login_screen.dart';
import 'package:campus_project/users/student_login_screen.dart';
import 'package:campus_project/users/teacher_login_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const CampusConnectApp());
}

class CampusConnectApp extends StatelessWidget {
  const CampusConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Dil değişince tüm uygulama yeniden çizilir
    return ValueListenableBuilder<String>(
      valueListenable: appLocale,
      builder: (context, locale, _) {
        return MaterialApp(
          title: 'Campus Connect',
          debugShowCheckedModeBanner: false,
          locale: Locale(locale),
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4F46E5),
              brightness: Brightness.light,
              surface: Colors.white,
            ),
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            textTheme: GoogleFonts.plusJakartaSansTextTheme(
              ThemeData.light().textTheme,
            ).apply(
              bodyColor: const Color(0xFF1E293B),
              displayColor: const Color(0xFF1E293B),
            ),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFF8FAFC),
              elevation: 0,
              foregroundColor: Color(0xFF1E293B),
            ),
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/welcome': (context) => const WelcomeScreen(),
            '/student_login': (context) => const StudentLoginScreen(),
            '/teacher_login': (context) => const TeacherLoginScreen(),
            '/office_login': (context) => const OfficeLoginScreen(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/home') {
              final args = settings.arguments as Map<String, String>;
              return MaterialPageRoute(
                builder: (context) => HomeScreen(
                  userName: args['userName'] ?? '',
                  displayRole: args['displayRole'] ?? '',
                  userEmail: args['userEmail'] ?? '',
                ),
              );
            }
            return null;
          },
        );
      },
    );
  }
}
