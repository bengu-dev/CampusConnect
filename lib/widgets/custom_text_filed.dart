import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextEditingController controller;
  final Color accentColor;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    required this.accentColor,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscure = true;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: Color(0xFF374151),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 7),
        Focus(
          onFocusChange: (focused) => setState(() => _isFocused = focused),
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.isPassword && _obscure,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(
                color: Color(0xFFADB5BD),
                fontSize: 14,
              ),
              prefixIcon: Icon(
                widget.icon,
                color: _isFocused ? widget.accentColor : const Color(0xFF94A3B8),
                size: 19,
              ),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF94A3B8),
                        size: 19,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    )
                  : null,
              filled: true,
              fillColor: _isFocused ? Colors.white : const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: widget.accentColor, width: 1.8),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.8),
              ),
              errorStyle: const TextStyle(color: Color(0xFFEF4444), fontSize: 11.5),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            ),
          ),
        ),
      ],
    );
  }
}
