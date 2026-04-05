import 'package:campus_project/screen/home_screen.dart';
import 'package:campus_project/widgets/custom_text_filed.dart';
import 'package:flutter/material.dart';
import '../../widgets/auth_screen_base.dart';

class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({super.key});

  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  static const Color _accent = Color(0xFF4F46E5);
  static const LinearGradient _gradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      // Backend Simülasyonu
      await Future.delayed(const Duration(milliseconds: 1500));
      
      if (_emailController.text == 'sude' && _passwordController.text == '1234') {
        setState(() => _isLoading = false);
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const HomeScreen(
                userName: 'Sude',
                displayRole: 'Student',
              ),
            ),
            (route) => false,
          );
        }
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hatalı giriş! (Dene: sude / 1234)'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenBase(
      role: 'Student',
      roleEmoji: '🎓',
      roleIcon: Icons.person_rounded,
      gradient: _gradient,
      accentColor: _accent,
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 32),
            const Text('Student Login', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 36),
            CustomTextField(
              label: 'Student Email',
              hint: 'sude',
              icon: Icons.email_rounded,
              controller: _emailController,
              accentColor: _accent,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Password',
              hint: '1234',
              icon: Icons.lock_rounded,
              controller: _passwordController,
              accentColor: _accent,
              isPassword: true,
            ),
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