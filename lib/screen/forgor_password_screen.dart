import 'package:campus_project/core/app_theme.dart';
import 'package:campus_project/widgets/custom_text_filed.dart';
import 'package:flutter/material.dart';
import '../widgets/auth_screen_base.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String role;
  final LinearGradient gradient;
  final Color accentColor;
  final IconData roleIcon;

  const ForgotPasswordScreen({
    super.key,
    required this.role,
    required this.gradient,
    required this.accentColor,
    required this.roleIcon,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey        = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSendLink() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _emailSent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenBase(
      role:        widget.role,
      roleEmoji:   '',
      roleIcon:    widget.roleIcon,
      gradient:    widget.gradient,
      accentColor: widget.accentColor,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),

            // İkon
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: widget.gradient,
                boxShadow: [
                  BoxShadow(
                    color:      widget.accentColor.withAlpha(100),
                    blurRadius: 20,
                    offset:     const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.lock_reset_rounded, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 24),

            const Text(
              'Şifremi Unuttum',
              style: TextStyle(
                color:       AppColors.textPrimary,
                fontSize:    30,
                fontWeight:  FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Kayıtlı e-posta adresinizi girin,\nşifre sıfırlama bağlantısı gönderelim.',
              style: TextStyle(
                color:  AppColors.textSecondary,
                fontSize: 14,
                height:   1.6,
              ),
            ),
            const SizedBox(height: 40),

            if (!_emailSent) ...[
              // E-posta alanı
              CustomTextField(
                label:        'E-posta Adresi',
                hint:         'Kayıtlı e-postanızı girin',
                icon:         Icons.email_rounded,
                controller:   _emailController,
                accentColor:  widget.accentColor,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen e-posta adresinizi girin';
                  }
                  if (!value.contains('@')) {
                    return 'Geçerli bir e-posta adresi girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Gönder butonu
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSendLink,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor:     Colors.transparent,
                    padding:         EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: _isLoading
                          ? const LinearGradient(
                              colors: [Color(0xFF94A3B8), Color(0xFF94A3B8)])
                          : widget.gradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color:      widget.accentColor.withAlpha(80),
                          blurRadius: 16,
                          offset:     const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: _isLoading
                          ? const SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5, color: Colors.white))
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send_rounded,
                                    color: Colors.white, size: 18),
                                SizedBox(width: 10),
                                Text(
                                  'Bağlantı Gönder',
                                  style: TextStyle(
                                    color:      Colors.white,
                                    fontSize:   16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Başarı durumu
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color:  AppColors.bgSurface,
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success.withAlpha(26),
                      ),
                      child: const Icon(Icons.mark_email_read_rounded,
                          color: AppColors.success, size: 30),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'E-posta Gönderildi!',
                      style: TextStyle(
                        color:      AppColors.textPrimary,
                        fontSize:   20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_emailController.text} adresine\nşifre sıfırlama bağlantısı gönderdik.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color:  AppColors.textSecondary,
                        fontSize: 14,
                        height:   1.6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'E-posta gelmediyse spam klasörünü\nkontrol edin veya birkaç dakika bekleyin.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:  AppColors.textMuted,
                        fontSize: 12,
                        height:   1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tekrar dene butonu
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _emailSent = false;
                      _emailController.clear();
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side:  BorderSide(color: widget.accentColor.withAlpha(128), width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    'Farklı e-posta dene',
                    style: TextStyle(
                      color:      widget.accentColor,
                      fontSize:   15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 28),

            // Giriş ekranına dön
            Center(
              child: TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.textMuted, size: 16),
                label: const Text(
                  'Giriş ekranına dön',
                  style: TextStyle(
                    color:      AppColors.textMuted,
                    fontSize:   14,
                    fontWeight: FontWeight.w500,
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
