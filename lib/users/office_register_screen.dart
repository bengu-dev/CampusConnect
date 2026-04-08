import 'package:campus_project/l10n/app_locale.dart';
import 'package:campus_project/services/api_service.dart';
import 'package:campus_project/widgets/custom_text_filed.dart';
import 'package:campus_project/widgets/register_widgets.dart';
import 'package:flutter/material.dart';
import '../widgets/auth_screen_base.dart';

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
  static const LinearGradient _gradient =
      LinearGradient(colors: [Color(0xFFD97706), Color(0xFFB45309)]);

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

  void _handleRegister() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(S.acceptTermsError),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(S.registerSuccess),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] ?? S.registerFailed),
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
            Text(S.createAccount,
                style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 26,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(S.registerAsOffice,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
            const SizedBox(height: 28),
            Row(children: [
              Expanded(
                child: CustomTextField(
                  label: S.firstNameLabel, hint: 'Mehmet',
                  icon: Icons.badge_outlined,
                  controller: _firstNameController, accentColor: _accent,
                  validator: (v) => v == null || v.isEmpty ? S.required : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  label: S.lastNameLabel, hint: 'Demir',
                  icon: Icons.badge_outlined,
                  controller: _lastNameController, accentColor: _accent,
                  validator: (v) => v == null || v.isEmpty ? S.required : null,
                ),
              ),
            ]),
            const SizedBox(height: 14),
            CustomTextField(
              label: S.employeeIdLabel, hint: S.employeeIdHint,
              icon: Icons.badge_rounded,
              controller: _employeeIdController, accentColor: _accent,
              validator: (v) => v == null || v.isEmpty ? S.enterEmployeeId : null,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              label: S.departmentLabel, hint: S.departmentHint,
              icon: Icons.domain_rounded,
              controller: _departmentController, accentColor: _accent,
              validator: (v) => v == null || v.isEmpty ? S.enterDepartment : null,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              label: S.positionLabel, hint: S.positionHint,
              icon: Icons.work_outline_rounded,
              controller: _positionController, accentColor: _accent,
              validator: (v) => v == null || v.isEmpty ? S.enterPosition : null,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              label: S.universityEmailLabel, hint: S.officeEmailHint,
              icon: Icons.email_outlined,
              controller: _emailController, accentColor: _accent,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return S.enterEmail;
                if (!v.contains('@')) return S.invalidEmail;
                return null;
              },
            ),
            const SizedBox(height: 14),
            CustomTextField(
              label: S.passwordLabel, hint: S.passwordHint,
              icon: Icons.lock_outline_rounded,
              controller: _passwordController, accentColor: _accent,
              isPassword: true,
              validator: (v) {
                if (v == null || v.isEmpty) return S.enterPassword;
                if (v.length < 8) return S.passwordMin;
                return null;
              },
            ),
            const SizedBox(height: 14),
            CustomTextField(
              label: S.confirmPasswordLabel, hint: S.confirmPasswordHint,
              icon: Icons.lock_outline_rounded,
              controller: _confirmPasswordController, accentColor: _accent,
              isPassword: true,
              validator: (v) {
                if (v == null || v.isEmpty) return S.enterConfirm;
                if (v != _passwordController.text) return S.passwordMismatch;
                return null;
              },
            ),
            const SizedBox(height: 20),
            TermsCheckbox(
              accent: _accent,
              agreed: _agreedToTerms,
              onChanged: (v) => setState(() => _agreedToTerms = v),
            ),
            const SizedBox(height: 24),
            SubmitButton(
              accent: _accent,
              isLoading: _isLoading,
              label: S.registerBtn,
              onPressed: _handleRegister,
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: RichText(
                  text: TextSpan(
                    text: S.haveAccount,
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    children: [
                      TextSpan(text: S.signIn,
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
