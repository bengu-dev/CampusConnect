import 'package:campus_project/widgets/custom_text_filed.dart';
import 'package:flutter/material.dart';
import '../../widgets/auth_screen_base.dart';

class TeacherRegisterScreen extends StatefulWidget {
  const TeacherRegisterScreen({super.key});

  @override
  State<TeacherRegisterScreen> createState() => _TeacherRegisterScreenState();
}

class _TeacherRegisterScreenState extends State<TeacherRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _staffIdController = TextEditingController();
  final _departmentController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _agreedToTerms = false;

  static const Color _accent = Color(0xFF059669);
  static const LinearGradient _gradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF0D9488)],
  );

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _staffIdController.dispose();
    _departmentController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please agree to the terms and conditions'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      // --- BACKEND SİMÜLASYONU ---
      await Future.delayed(const Duration(milliseconds: 2000));
      
      if (mounted) {
        setState(() => _isLoading = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Faculty account created! Please login to continue.'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: _gradient,
                boxShadow: [BoxShadow(color: _accent.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 6))],
              ),
              child: const Icon(Icons.person_add_rounded, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 24),
            const Text(
              'Faculty Registration',
              style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your faculty account to\nmanage your campus activities.',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 36),

            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'First Name',
                    hint: 'Jane',
                    icon: Icons.badge_rounded,
                    controller: _firstNameController,
                    accentColor: _accent,
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: CustomTextField(
                    label: 'Last Name',
                    hint: 'Smith',
                    icon: Icons.badge_outlined,
                    controller: _lastNameController,
                    accentColor: _accent,
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Staff ID',
              hint: 'e.g. FAC-2024-001',
              icon: Icons.badge_rounded,
              controller: _staffIdController,
              accentColor: _accent,
              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Department',
              hint: 'e.g. Computer Science',
              icon: Icons.domain_rounded,
              controller: _departmentController,
              accentColor: _accent,
              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Faculty Email',
              hint: 'teacher@university.edu',
              icon: Icons.email_rounded,
              controller: _emailController,
              accentColor: _accent,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required';
                if (!value.contains('@')) return 'Invalid email';
                return null;
              },
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Password',
              hint: 'Min. 8 characters',
              icon: Icons.lock_rounded,
              controller: _passwordController,
              accentColor: _accent,
              isPassword: true,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required';
                if (value.length < 8) return 'Min. 8 characters';
                return null;
              },
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Confirm Password',
              hint: 'Re-enter your password',
              icon: Icons.lock_outline_rounded,
              controller: _confirmPasswordController,
              accentColor: _accent,
              isPassword: true,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required';
                if (value != _passwordController.text) return 'Passwords do not match';
                return null;
              },
            ),
            const SizedBox(height: 24),

            GestureDetector(
              onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: _agreedToTerms ? _accent : Colors.white.withOpacity(0.1),
                      border: Border.all(color: _agreedToTerms ? _accent : Colors.white.withOpacity(0.25), width: 1.5),
                    ),
                    child: _agreedToTerms ? const Icon(Icons.check_rounded, color: Colors.white, size: 14) : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: 'I agree to the ',
                        style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 13, height: 1.5),
                        children: [
                          TextSpan(text: 'Terms of Service', style: TextStyle(color: _accent, fontWeight: FontWeight.w600)),
                          const TextSpan(text: ' and '),
                          TextSpan(text: 'Privacy Policy', style: TextStyle(color: _accent, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity, height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: _isLoading ? const LinearGradient(colors: [Color(0xFF6B7280), Color(0xFF6B7280)]) : _gradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: _accent.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: _isLoading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Create Account', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                            ],
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: RichText(
                  text: TextSpan(
                    text: 'Already have an account? ',
                    style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 14),
                    children: [
                      TextSpan(text: 'Sign In', style: TextStyle(color: _accent, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}