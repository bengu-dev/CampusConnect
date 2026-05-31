import 'package:campus_project/core/app_lang.dart';
import 'package:campus_project/core/app_theme.dart';
import 'package:campus_project/provider/event_provider.dart';
import 'package:campus_project/screen/home_screen.dart';
import 'package:campus_project/screen/welcome_screen.dart';
import 'package:campus_project/services/api_service.dart';
import 'package:campus_project/users/office_login_screen.dart';
import 'package:campus_project/users/student_login_screen.dart';
import 'package:campus_project/users/teacher_login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart'; // ← EKLENDI
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // table_calendar locale hatası için — TR tarih formatını başlat
  await initializeDateFormatting('tr_TR', null); // ← EKLENDI

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor:          Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness:     Brightness.light,
  ));

  await AppLang.load();

  runApp(
    ChangeNotifierProvider(
      create: (_) {
        final provider = EventProvider();
        provider.loadPersonalEvents(); // uygulama açılışında kişisel etkinlikleri yükle
        return provider;
      },
      child: const CampusConnectApp(),
    ),
  );
}

class CampusConnectApp extends StatelessWidget {
  const CampusConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLang.notifier,
      builder: (context, lang, child) => MaterialApp(
        title: 'Campus Connect',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const _SplashRouter(),
        routes: {
          '/welcome':       (ctx) => const WelcomeScreen(),
          '/student_login': (ctx) => const StudentLoginScreen(),
          '/teacher_login': (ctx) => const TeacherLoginScreen(),
          '/office_login':  (ctx) => const OfficeLoginScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/home') {
            final args = settings.arguments as Map<String, String>;
            return MaterialPageRoute(
              builder: (ctx) => HomeScreen(
                userName:    args['userName']    ?? AppLang.t('Kullanıcı', 'User'),
                displayRole: args['displayRole'] ?? AppLang.t('Kullanıcı', 'User'),
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SPLASH ROUTER
// ─────────────────────────────────────────────

class _SplashRouter extends StatefulWidget {
  const _SplashRouter();

  @override
  State<_SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<_SplashRouter> {
  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final token = await ApiService.getToken();
    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      final userInfo = await ApiService.getUserInfo();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            userName:    userInfo['userName']    ?? AppLang.t('Kullanıcı', 'User'),
            displayRole: userInfo['displayRole'] ?? AppLang.t('Kullanıcı', 'User'),
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: AppGradients.brand,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(80),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.school_rounded, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              'Campus Connect',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 28, height: 28,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
