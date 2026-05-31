/// FCM stub — Firebase kurulmadan önce bu dosya aktif değildir.
library;
///
/// Firebase kurulumu için:
///   1. https://console.firebase.google.com → Proje oluştur
///   2. Android uygulaması ekle (com.example.campus_project)
///   3. google-services.json dosyasını android/app/ klasörüne koy
///   4. pubspec.yaml'da firebase_core ve firebase_messaging yorumunu kaldır
///   5. Bu dosyadaki kodları aktif et
///
/// Şu an Firebase kurulmadığından bu dosya stub olarak çalışır.

class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  /// Uygulamanın başlangıcında çağrılır — Firebase yoksa hiçbir şey yapmaz.
  Future<void> initialize() async {
    // Firebase kurulunca buraya gerçek kod gelecek
  }

  Future<void> setForegroundNotificationPresentation() async {
    // Firebase kurulunca aktif edilecek
  }
}
