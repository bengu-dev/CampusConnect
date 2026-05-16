import 'package:campus_project/l10n/app_locale.dart';
import 'package:flutter/material.dart';

class TermsCheckbox extends StatelessWidget {
  final Color accent;
  final bool agreed;
  final void Function(bool) onChanged;

  const TermsCheckbox({
    super.key,
    required this.accent,
    required this.agreed,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!agreed),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: agreed ? accent : const Color(0xFFF1F5F9),
              border: Border.all(
                color: agreed ? accent : const Color(0xFFCBD5E1),
                width: 1.5,
              ),
            ),
            child: agreed
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 13)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: S.termsText,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                children: [
                  TextSpan(
                    text: S.termsAccept,
                    style: TextStyle(color: accent, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SubmitButton extends StatelessWidget {
  final Color accent;
  final bool isLoading;
  final String label;
  final VoidCallback onPressed;

  const SubmitButton({
    super.key,
    required this.accent,
    required this.isLoading,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
          disabledBackgroundColor: accent.withValues(alpha: 0.5),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white))
            : Text(label,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
