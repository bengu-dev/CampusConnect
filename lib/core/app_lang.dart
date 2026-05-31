import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Uygulama dil yöneticisi.
/// Dil değişimi anlık gerçekleşir, SharedPreferences'a kaydedilir.
/// Kullanım: AppLang.t('Türkçe metin', 'English text')
class AppLang {
  AppLang._();

  static final ValueNotifier<String> notifier = ValueNotifier('tr');

  static bool get isTr => notifier.value == 'tr';
  static bool get isEn => notifier.value == 'en';

  /// Uygulamanın başlangıcında kaydedilmiş dili yükler.
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('app_lang') ?? 'tr';
    notifier.value = saved;
  }

  /// TR ↔ EN geçişi yapar.
  static Future<void> toggle() async {
    final next = isTr ? 'en' : 'tr';
    notifier.value = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_lang', next);
  }

  /// Dile göre doğru metni döner.
  static String t(String tr, String en) => isTr ? tr : en;
}
