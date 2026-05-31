import 'package:campus_project/services/api_service.dart';
import 'package:campus_project/widgets/custom_text_filed.dart';
import 'package:flutter/material.dart';
import '../../widgets/auth_screen_base.dart';

class OfficeRegisterScreen extends StatefulWidget {
  const OfficeRegisterScreen({super.key});

  @override
  State<OfficeRegisterScreen> createState() => _OfficeRegisterScreenState();
}

class _OfficeRegisterScreenState extends State<OfficeRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _departmentController = TextEditingController();
  final _positionController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _agreedToTerms = false;

  static const Color _accent = Color(0xFFD97706);
  static const LinearGradient _gradient = LinearGradient(
    colors: [Color(0xFFD97706), Color(0xFFDC2626)],
  );

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _employeeIdController.dispose();
    _departmentController.dispose();
    _positionController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.redAccent : Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _handleRegister() async {
    if (!_agreedToTerms) {
      _showSnackbar('Kullanım koşullarını kabul etmelisiniz.', isError: true);
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await ApiService.registerOffice(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      employeeId: _employeeIdController.text.trim(),
      department: _departmentController.text.trim(),
      position: _positionController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      _showSnackbar(result['message'] ?? 'Kayıt başarılı! Giriş yapabilirsiniz.');
      Navigator.pop(context);
    } else {
      _showSnackbar(result['message'] ?? 'Kayıt başarısız!', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenBase(
      role: 'Ofis Personeli',
      roleEmoji: '🏢',
      roleIcon: Icons.business_center_rounded,
      gradient: _gradient,
      accentColor: _accent,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: _gradient,
                boxShadow: [
                  BoxShadow(color: _accent.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 6)),
                ],
              ),
              child: const Icon(Icons.person_add_rounded, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 24),
            const Text(
              'Ofis Personeli Kaydı',
              style: TextStyle(color: Color(0xFF1E293B), fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Yönetim araçlarına erişmek için\nhesabınızı oluşturun.',
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 36),

            // Ad & Soyad
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Ad',
                    hint: 'Mehmet',
                    icon: Icons.badge_rounded,
                    controller: _firstNameController,
                    accentColor: _accent,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Zorunlu alan';
                      if (v.trim().length < 2) return 'En az 2 karakter';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: CustomTextField(
                    label: 'Soyad',
                    hint: 'Demir',
                    icon: Icons.badge_outlined,
                    controller: _lastNameController,
                    accentColor: _accent,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Zorunlu alan';
                      if (v.trim().length < 2) return 'En az 2 karakter';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Çalışan No
            CustomTextField(
              label: 'Çalışan Numarası',
              hint: 'ör. OFİS-2024-001',
              icon: Icons.badge_rounded,
              controller: _employeeIdController,
              accentColor: _accent,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Çalışan numarası zorunlu';
                if (v.trim().length < 3) return 'En az 3 karakter';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Departman
            CustomTextField(
              label: 'Departman',
              hint: 'ör. Öğrenci İşleri',
              icon: Icons.domain_rounded,
              controller: _departmentController,
              accentColor: _accent,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Departman zorunlu';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Pozisyon
            CustomTextField(
              label: 'Pozisyon / Unvan',
              hint: 'ör. İdari Uzman',
              icon: Icons.work_rounded,
              controller: _positionController,
              accentColor: _accent,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Pozisyon zorunlu';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // E-posta
            CustomTextField(
              label: 'E-posta',
              hint: 'ofis@universite.edu.tr',
              icon: Icons.email_rounded,
              controller: _emailController,
              accentColor: _accent,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'E-posta zorunlu';
                if (!v.contains('@') || !v.contains('.')) return 'Geçerli e-posta girin';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Şifre
            CustomTextField(
              label: 'Şifre',
              hint: 'En az 8 karakter',
              icon: Icons.lock_rounded,
              controller: _passwordController,
              accentColor: _accent,
              isPassword: true,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Şifre zorunlu';
                if (v.length < 8) return 'En az 8 karakter olmalı';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Şifre Tekrar
            CustomTextField(
              label: 'Şifre Tekrar',
              hint: 'Şifrenizi tekrar girin',
              icon: Icons.lock_outline_rounded,
              controller: _confirmPasswordController,
              accentColor: _accent,
              isPassword: true,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Şifre tekrarı zorunlu';
                if (v != _passwordController.text) return 'Şifreler eşleşmiyor';
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Koşullar Checkbox
            GestureDetector(
              onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: _agreedToTerms ? _accent : const Color(0xFFF1F5F9),
                      border: Border.all(
                        color: _agreedToTerms ? _accent : const Color(0xFFCBD5E1),
                        width: 1.5,
                      ),
                    ),
                    child: _agreedToTerms
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: 'Kabul ediyorum: ',
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.5),
                        children: [
                          TextSpan(text: 'Kullanım Koşulları', style: TextStyle(color: _accent, fontWeight: FontWeight.w600)),
                          const TextSpan(text: ' ve '),
                          TextSpan(text: 'Gizlilik Politikası', style: TextStyle(color: _accent, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Kayıt Ol Butonu
            SizedBox(
              width: double.infinity,
              height: 54,
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
                    gradient: _isLoading
                        ? const LinearGradient(colors: [Color(0xFF6B7280), Color(0xFF6B7280)])
                        : _gradient,
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
                              Text('Hesap Oluştur', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                            ],
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Giriş yap linki
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: RichText(
                  text: TextSpan(
                    text: 'Zaten hesabınız var mı? ',
                    style: TextStyle(color: const Color(0xFF64748B), fontSize: 14),
                    children: [
                      TextSpan(text: 'Giriş Yapın', style: TextStyle(color: _accent, fontWeight: FontWeight.w700)),
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
