import 'package:campus_project/screen/home_screen.dart';
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
    return MaterialApp(
      title: 'Campus Connect',
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          Theme.of(context).textTheme,
        ),
        useMaterial3: true,
      ),

      initialRoute: '/',

      routes: {
        '/': (context) => const WelcomeScreen(),
        '/student_login': (context) => const StudentLoginScreen(),
        '/teacher_login': (context) => const TeacherLoginScreen(),
        '/office_login': (context) => const OfficeLoginScreen(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final args = settings.arguments as Map<String, String>;
          return MaterialPageRoute(
            builder: (context) => HomeScreen(
              userName: args['userName'] ?? 'User',
              displayRole: args['displayRole'] ?? 'Guest',
            ),
          );
        }
        return null;
      },
    );
  }
}