import 'package:campus_project/core/app_theme.dart';
import 'package:flutter/material.dart';

/// Beyaz temaya uygun özel metin alanı.
class CustomTextField extends StatefulWidget {
  final String                    label;
  final String                    hint;
  final IconData                  icon;
  final bool                      isPassword;
  final TextEditingController     controller;
  final Color                     accentColor;
  final TextInputType             keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    required this.accentColor,
    this.isPassword   = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscure   = true;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etiket
        Text(
          widget.label,
          style: const TextStyle(
            color:       AppColors.textSecondary,
            fontSize:    13,
            fontWeight:  FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),

        // Giriş alanı
        Focus(
          onFocusChange: (focused) => setState(() => _isFocused = focused),
          child: TextFormField(
            controller:   widget.controller,
            obscureText:  widget.isPassword && _obscure,
            keyboardType: widget.keyboardType,
            validator:    widget.validator,
            style: const TextStyle(
              color:      AppColors.textPrimary,
              fontSize:   15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText:  widget.hint,
              hintStyle: const TextStyle(
                color:   AppColors.textHint,
                fontSize: 15,
              ),
              prefixIcon: Icon(
                widget.icon,
                color: _isFocused
                    ? widget.accentColor
                    : AppColors.textMuted,
                size: 20,
              ),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    )
                  : null,
              filled:    true,
              fillColor: AppColors.bgSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:   const BorderSide(
                    color: AppColors.border, width: 1.2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:   const BorderSide(
                    color: AppColors.border, width: 1.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:   BorderSide(
                    color: widget.accentColor, width: 1.8),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:   const BorderSide(
                    color: AppColors.error, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:   const BorderSide(
                    color: AppColors.error, width: 1.8),
              ),
              errorStyle: const TextStyle(
                  color: AppColors.error, fontSize: 12),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 15),
            ),
          ),
        ),
      ],
    );
  }
}
