import 'package:campus_project/l10n/app_locale.dart';
import 'package:campus_project/services/api_service.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String get _roleLabel {
    switch (widget.role) {
      case 'teacher': return S.teacherRole;
      case 'office':  return S.officeRole;
      default:        return S.studentRole;
    }
  }

  void _handleSendLink() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final result =
        await ApiService.forgotPassword(_emailController.text.trim());
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result['success'] == true) {
      setState(() => _emailSent = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] ?? 'Hata oluştu'),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenBase(
      role: _roleLabel,
      roleEmoji: '',
      roleIcon: widget.roleIcon,
      gradient: widget.gradient,
      accentColor: widget.accentColor,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 28),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: widget.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.lock_reset_rounded,
                  color: widget.accentColor, size: 26),
            ),
            const SizedBox(height: 20),
            Text(S.forgotTitle,
                style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 26,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(S.forgotSubtitle,
                style: const TextStyle(
                    color: Color(0xFF64748B), fontSize: 14, height: 1.5)),
            const SizedBox(height: 32),
            if (!_emailSent) ...[
              CustomTextField(
                label: S.emailAddressLabel,
                hint: S.emailAddressHint,
                icon: Icons.email_outlined,
                controller: _emailController,
                accentColor: widget.accentColor,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return S.enterEmail;
                  if (!v.contains('@')) return S.invalidEmail;
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSendLink,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.accentColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13)),
                    disabledBackgroundColor:
                        widget.accentColor.withValues(alpha: 0.5),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white))
                      : Text(S.sendLink,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFF059669).withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF059669).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mark_email_read_rounded,
                          color: Color(0xFF059669), size: 28),
                    ),
                    const SizedBox(height: 14),
                    Text(S.emailSentTitle,
                        style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 17,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(
                      S.emailSentBody(_emailController.text),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                          height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _emailSent = false;
                    _emailController.clear();
                  }),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: widget.accentColor.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13)),
                  ),
                  child: Text(S.tryDifferentEmail,
                      style: TextStyle(
                          color: widget.accentColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Center(
              child: TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded,
                    color: Color(0xFF94A3B8), size: 16),
                label: Text(S.backToLogin,
                    style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
