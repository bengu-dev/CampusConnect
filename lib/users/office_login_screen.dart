import 'package:campus_project/l10n/app_locale.dart';
import 'package:campus_project/screen/forgor_password_screen.dart';
import 'package:campus_project/screen/home_screen.dart';
import 'package:campus_project/services/api_service.dart';
import 'package:campus_project/users/office_register_screen.dart';
import 'package:campus_project/widgets/custom_text_filed.dart';
import 'package:flutter/material.dart';
import '../widgets/auth_screen_base.dart';

class OfficeLoginScreen extends StatefulWidget {
  const OfficeLoginScreen({super.key});

  @override
  State<OfficeLoginScreen> createState() => _OfficeLoginScreenState();
}

class _OfficeLoginScreenState extends State<OfficeLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  static const Color _accent = Color(0xFFD97706);
  static const LinearGradient _gradient =
      LinearGradient(colors: [Color(0xFFD97706), Color(0xFFB45309)]);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final result = await ApiService.login(
        _emailController.text.trim(), _passwordController.text, 'OFFICE');
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result['success'] == true) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            userName: result['name'] ?? '',
            displayRole: S.officeRole,
            userEmail: result['email'] ?? '',
          ),
        ),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] ?? S.loginFailed),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenBase(
      role: S.officeRole,
      roleEmoji: '🏢',
      roleIcon: Icons.business_center_rounded,
      gradient: _gradient,
      accentColor: _accent,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 28),
            Text(S.officeLoginTitle,
                style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 26,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(S.officeLoginSub,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
            const SizedBox(height: 32),
            CustomTextField(
              label: S.emailLabel,
              hint: S.officeEmailHint,
              icon: Icons.email_outlined,
              controller: _emailController,
              accentColor: _accent,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return S.enterEmail;
                if (!v.contains('@')) return S.invalidEmail;
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: S.passwordLabel,
              hint: '••••••••',
              icon: Icons.lock_outline_rounded,
              controller: _passwordController,
              accentColor: _accent,
              isPassword: true,
              validator: (v) =>
                  v == null || v.isEmpty ? S.enterPassword : null,
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ForgotPasswordScreen(
                      role: 'office',
                      gradient: _gradient,
                      accentColor: _accent,
                      roleIcon: Icons.business_center_rounded,
                    ),
                  ),
                ),
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: Text(S.forgotPassword,
                    style: const TextStyle(
                        color: _accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13)),
                  disabledBackgroundColor: _accent.withValues(alpha: 0.5),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white))
                    : Text(S.signIn,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const OfficeRegisterScreen())),
                child: RichText(
                  text: TextSpan(
                    text: S.noAccount,
                    style: const TextStyle(
                        color: Color(0xFF64748B), fontSize: 13),
                    children: [
                      TextSpan(
                          text: S.registerBtn,
                          style: const TextStyle(
                              color: _accent, fontWeight: FontWeight.w700))
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
