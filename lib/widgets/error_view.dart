import 'package:campus_project/core/app_theme.dart';
import 'package:flutter/material.dart';

/// İnternet yokken veya API hatasında gösterilen anlamlı hata ekranı.
/// isNetworkError=true → "İnternet yok" görseli
/// isNetworkError=false → generic hata görseli

class ErrorView extends StatelessWidget {
  final bool         isNetworkError;
  final String?      title;
  final String?      message;
  final VoidCallback? onRetry;
  final Color?       accentColor;

  const ErrorView({
    super.key,
    this.isNetworkError = false,
    this.title,
    this.message,
    this.onRetry,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color  = accentColor ?? AppColors.primary;
    final icon   = isNetworkError ? Icons.wifi_off_rounded : Icons.error_outline_rounded;
    final head   = title ?? (isNetworkError ? 'Bağlantı Yok' : 'Bir Hata Oluştu');
    final body   = message ?? (isNetworkError
        ? 'İnternet bağlantınızı kontrol edip\ntekrar deneyin.'
        : 'Beklenmedik bir hata oluştu.\nLütfen tekrar deneyin.');

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // İkon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withAlpha(26),
              ),
              child: Icon(icon, color: color.withAlpha(180), size: 38),
            ),
            const SizedBox(height: 24),

            // Başlık
            Text(
              head,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // Açıklama
            Text(
              body,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),

            // Tekrar Dene butonu
            if (onRetry != null) ...[
              const SizedBox(height: 28),
              GestureDetector(
                onTap: onRetry,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: color.withAlpha(38),
                    border: Border.all(color: color.withAlpha(128)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded, color: color, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Tekrar Dene',
                        style: TextStyle(
                          color: color,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Boş liste durumu
class EmptyView extends StatelessWidget {
  final IconData icon;
  final String   message;
  final String?  subtitle;
  final Color?   accentColor;

  const EmptyView({
    super.key,
    required this.icon,
    required this.message,
    this.subtitle,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color.withAlpha(76), size: 64),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
