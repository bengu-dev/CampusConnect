import 'package:campus_project/core/app_theme.dart';
import 'package:flutter/material.dart';

/// Beyaz temaya uygun rol kartı.
/// Sol tarafta renkli gradient ikon, sağda ok.
class RoleCard extends StatefulWidget {
  final String         title;
  final String         subtitle;
  final IconData       icon;
  final LinearGradient gradient;
  final Color          accentColor;
  final VoidCallback   onTap;
  final int            delay;

  const RoleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.accentColor,
    required this.onTap,
    this.delay = 0,
  });

  @override
  State<RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<RoleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:  (_) => setState(() => _pressed = true),
      onTapUp:    (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale:    _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: AppColors.bgCard,
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color:      widget.accentColor.withAlpha(30),
                blurRadius: 16,
                offset:     const Offset(0, 4),
              ),
              const BoxShadow(
                color:      Color(0x0A000000),
                blurRadius: 8,
                offset:     Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Renkli gradient ikon kutusu
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: widget.gradient,
                  boxShadow: [
                    BoxShadow(
                      color:      widget.accentColor.withAlpha(70),
                      blurRadius: 10,
                      offset:     const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(widget.icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),

              // Başlık ve açıklama
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color:       AppColors.textPrimary,
                        fontSize:    16,
                        fontWeight:  FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        color:      AppColors.textSecondary,
                        fontSize:   12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // Ok ikonu
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.accentColor.withAlpha(18),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: widget.accentColor,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
