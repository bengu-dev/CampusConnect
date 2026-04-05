import 'package:campus_project/screen/home_screen.dart';
import 'package:campus_project/widgets/custom_text_filed.dart';
import 'package:flutter/material.dart';
import '../../widgets/auth_screen_base.dart';

class TeacherLoginScreen extends StatefulWidget {
  const TeacherLoginScreen({super.key});

  @override
  State<TeacherLoginScreen> createState() => _TeacherLoginScreenState();
}

class _TeacherLoginScreenState extends State<TeacherLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  static const Color _accent = Color(0xFF059669);
  static const LinearGradient _gradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF0D9488)],
  );

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 1500));
      
      if (_emailController.text == 'sude' && _passwordController.text == '1234') {
        setState(() => _isLoading = false);
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const HomeScreen(userName: 'Sude', displayRole: 'Teacher'),
            ),
            (route) => false,
          );
        }
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hatalı giriş!')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenBase(
      role: 'Teacher',
      roleEmoji: '📚',
      roleIcon: Icons.cast_for_education_rounded,
      gradient: _gradient,
      accentColor: _accent,
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 32),
            const Text('Teacher Login', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 36),
            CustomTextField(label: 'Faculty Email', hint: 'sude', icon: Icons.email_rounded, controller: _emailController, accentColor: _accent),
            const SizedBox(height: 20),
            CustomTextField(label: 'Password', hint: '1234', icon: Icons.lock_rounded, controller: _passwordController, accentColor: _accent, isPassword: true),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(backgroundColor: _accent),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Sign In'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}