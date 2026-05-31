import 'package:campus_project/core/app_lang.dart';
import 'package:campus_project/screen/home_screen.dart';
import 'package:campus_project/services/api_service.dart';
import 'package:campus_project/users/office_register_screen.dart';
import 'package:campus_project/widgets/custom_text_filed.dart';
import 'package:flutter/material.dart';
import '../../widgets/auth_screen_base.dart';

class OfficeLoginScreen extends StatefulWidget {
  const OfficeLoginScreen({super.key});
  @override
  State<OfficeLoginScreen> createState() => _OfficeLoginScreenState();
}

class _OfficeLoginScreenState extends State<OfficeLoginScreen> {
  final _formKey         = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController  = TextEditingController();
  bool _isLoading = false;

  static const Color _accent = Color(0xFFD97706);
  static const LinearGradient _gradient =
      LinearGradient(colors: [Color(0xFFD97706), Color(0xFFDC2626)]);

  void _onLangChange() { if (mounted) setState(() {}); }

  @override
  void initState() {
    super.initState();
    AppLang.notifier.addListener(_onLangChange);
  }

  @override
  void dispose() {
    AppLang.notifier.removeListener(_onLangChange);
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final result = await ApiService.login(
      _emailController.text.trim(),
      _passController.text,
      'OFFICE',
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      final name        = result['name'] as String? ?? AppLang.t('Ofis Personeli', 'Office Staff');
      final displayRole = AppLang.t('Ofis Personeli', 'Office Staff');
      await ApiService.saveUserInfo(name, displayRole);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(userName: name, displayRole: displayRole)),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            result['message'] ?? AppLang.t('Giriş başarısız!', 'Login failed!')),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLang.isTr;
    return AuthScreenBase(
      role:        AppLang.t('Ofis Personeli', 'Office Staff'),
      roleEmoji:   '🏢',
      roleIcon:    Icons.business_center_rounded,
      gradient:    _gradient,
      accentColor: _accent,
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 32),
            Text(
              tr ? 'Ofis Personeli Girişi' : 'Office Staff Login',
              style: const TextStyle(
                  color: Color(0xFF1E293B), fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 36),

            CustomTextField(
              label: tr ? 'E-posta' : 'Email',
              hint: 'office@university.edu',
              icon: Icons.email_rounded,
              controller: _emailController,
              accentColor: _accent,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) { return tr ? 'E-posta boş olamaz' : 'Email cannot be empty'; }
                if (!v.contains('@')) { return tr ? 'Geçerli e-posta girin' : 'Enter a valid email'; }
                return null;
              },
            ),
            const SizedBox(height: 20),

            CustomTextField(
              label: tr ? 'Şifre' : 'Password',
              hint: tr ? 'Şifrenizi girin' : 'Enter your password',
              icon: Icons.lock_rounded,
              controller: _passController,
              accentColor: _accent,
              isPassword: true,
              validator: (v) {
                if (v == null || v.isEmpty) { return tr ? 'Şifre boş olamaz' : 'Password cannot be empty'; }
                if (v.length < 6) { return tr ? 'En az 6 karakter' : 'At least 6 characters'; }
                return null;
              },
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: _isLoading
                        ? const LinearGradient(
                            colors: [Color(0xFF6B7280), Color(0xFF6B7280)])
                        : _gradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.white))
                        : Text(
                            tr ? 'Giriş Yap' : 'Sign In',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const OfficeRegisterScreen()),
              ),
              child: RichText(
                text: TextSpan(
                  text: tr ? 'Hesabınız yok mu? ' : "Don't have an account? ",
                  style: const TextStyle(
                      color: Color(0xFF64748B), fontSize: 14),
                  children: [
                    TextSpan(
                      text: tr ? 'Kayıt Olun' : 'Sign Up',
                      style: const TextStyle(
                          color: _accent, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
