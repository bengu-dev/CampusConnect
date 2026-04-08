import 'package:flutter/material.dart';

/// Global dil notifier'ı. 'tr' veya 'en' değeri alır.
final ValueNotifier<String> appLocale = ValueNotifier('tr');

/// Tüm UI string'leri. Dil değişince ValueNotifier trigger eder → full rebuild.
class S {
  static bool get _tr => appLocale.value == 'tr';

  // ── Genel ────────────────────────────────────────────────────────────────
  static String get appName => 'Campus Connect';
  static String get copyright => '© 2025 Campus Connect';

  // ── Rol adları ───────────────────────────────────────────────────────────
  static String get studentRole => _tr ? 'Öğrenci' : 'Student';
  static String get studentSubtitle =>
      _tr ? 'Dersler, program ve etkinlikler' : 'Courses, schedule & events';
  static String get teacherRole => _tr ? 'Öğretmen' : 'Teacher';
  static String get teacherSubtitle =>
      _tr ? 'Dersler, öğrenciler ve yönetim' : 'Courses, students & management';
  static String get officeRole => _tr ? 'Ofis' : 'Office';
  static String get officeSubtitle =>
      _tr ? 'İdari işler ve yönetim araçları' : 'Administrative tools & management';
  static String get selectRole =>
      _tr ? 'Rolünü seçerek devam et.' : 'Select your role to continue.';

  // ── Ortak form ───────────────────────────────────────────────────────────
  static String get emailLabel => _tr ? 'E-posta' : 'Email';
  static String get passwordLabel => _tr ? 'Şifre' : 'Password';
  static String get confirmPasswordLabel =>
      _tr ? 'Şifre Tekrar' : 'Confirm Password';
  static String get firstNameLabel => _tr ? 'Ad' : 'First Name';
  static String get lastNameLabel => _tr ? 'Soyad' : 'Last Name';
  static String get departmentLabel => _tr ? 'Bölüm' : 'Department';
  static String get universityEmailLabel =>
      _tr ? 'Üniversite E-postası' : 'University Email';
  static String get passwordHint => _tr ? 'Min. 8 karakter' : 'Min. 8 characters';
  static String get confirmPasswordHint =>
      _tr ? 'Şifrenizi tekrar girin' : 'Re-enter your password';
  static String get required => _tr ? 'Zorunlu' : 'Required';
  static String get enterEmail => _tr ? 'E-posta giriniz' : 'Enter your email';
  static String get invalidEmail =>
      _tr ? 'Geçerli e-posta giriniz' : 'Enter a valid email';
  static String get enterPassword => _tr ? 'Şifre giriniz' : 'Enter your password';
  static String get passwordMin =>
      _tr ? 'En az 8 karakter' : 'Min. 8 characters';
  static String get passwordMismatch =>
      _tr ? 'Şifreler eşleşmiyor' : 'Passwords do not match';
  static String get enterConfirm =>
      _tr ? 'Şifre tekrarı giriniz' : 'Confirm your password';
  static String get forgotPassword =>
      _tr ? 'Şifremi unuttum' : 'Forgot password';
  static String get signIn => _tr ? 'Giriş Yap' : 'Sign In';
  static String get registerBtn => _tr ? 'Kayıt Ol' : 'Register';
  static String get noAccount =>
      _tr ? 'Hesabın yok mu? ' : "Don't have an account? ";
  static String get haveAccount =>
      _tr ? 'Zaten hesabın var mı? ' : 'Already have an account? ';
  static String get termsText =>
      _tr ? 'Kullanım koşullarını ' : 'I agree to the ';
  static String get termsAccept =>
      _tr ? 'kabul ediyorum' : 'Terms & Conditions';
  static String get acceptTermsError =>
      _tr ? 'Koşulları kabul etmelisiniz' : 'You must accept the terms';
  static String get enterDepartment =>
      _tr ? 'Bölüm giriniz' : 'Enter your department';
  static String get departmentHint =>
      _tr ? 'ör. Bilgisayar Mühendisliği' : 'e.g. Computer Science';

  // ── Öğrenci login / register ──────────────────────────────────────────────
  static String get studentLoginTitle =>
      _tr ? 'Öğrenci Girişi' : 'Student Login';
  static String get studentLoginSub =>
      _tr ? 'Kampüs hesabınla giriş yap' : 'Sign in with your campus account';
  static String get studentEmailHint =>
      _tr ? 'ogrenci@universite.edu.tr' : 'student@university.edu';
  static String get createAccount => _tr ? 'Hesap Oluştur' : 'Create Account';
  static String get registerAsStudent =>
      _tr ? 'Öğrenci olarak kayıt ol' : 'Register as a student';
  static String get studentIdLabel => _tr ? 'Öğrenci No' : 'Student ID';
  static String get studentIdHint => _tr ? 'ör. 20210001' : 'e.g. 20210001';
  static String get enterStudentId =>
      _tr ? 'Öğrenci numarası giriniz' : 'Enter your student ID';

  // ── Öğretmen login / register ─────────────────────────────────────────────
  static String get teacherLoginTitle =>
      _tr ? 'Öğretmen Girişi' : 'Teacher Login';
  static String get teacherLoginSub =>
      _tr ? 'Fakülte hesabınla giriş yap' : 'Sign in with your faculty account';
  static String get teacherEmailHint =>
      _tr ? 'ogretmen@universite.edu.tr' : 'teacher@university.edu';
  static String get registerAsTeacher =>
      _tr ? 'Öğretmen olarak kayıt ol' : 'Register as a teacher';
  static String get staffIdLabel => _tr ? 'Personel No' : 'Staff ID';
  static String get staffIdHint =>
      _tr ? 'ör. FAC-2024-001' : 'e.g. FAC-2024-001';
  static String get enterStaffId =>
      _tr ? 'Personel numarası giriniz' : 'Enter your staff ID';

  // ── Ofis login / register ─────────────────────────────────────────────────
  static String get officeLoginTitle => _tr ? 'Ofis Girişi' : 'Office Login';
  static String get officeLoginSub =>
      _tr ? 'İdari hesabınla giriş yap' : 'Sign in with your admin account';
  static String get officeEmailHint =>
      _tr ? 'ofis@universite.edu.tr' : 'office@university.edu';
  static String get registerAsOffice =>
      _tr ? 'Ofis personeli olarak kayıt ol' : 'Register as office staff';
  static String get employeeIdLabel => _tr ? 'Çalışan No' : 'Employee ID';
  static String get employeeIdHint =>
      _tr ? 'ör. OFF-2024-001' : 'e.g. OFF-2024-001';
  static String get positionLabel => _tr ? 'Pozisyon' : 'Position';
  static String get positionHint =>
      _tr ? 'ör. İdari Personel' : 'e.g. Administrative Officer';
  static String get enterEmployeeId =>
      _tr ? 'Çalışan numarası giriniz' : 'Enter your employee ID';
  static String get enterPosition => _tr ? 'Pozisyon giriniz' : 'Enter your position';

  // ── Şifremi unuttum ───────────────────────────────────────────────────────
  static String get forgotTitle => _tr ? 'Şifremi Unuttum' : 'Forgot Password';
  static String get forgotSubtitle => _tr
      ? 'E-posta adresinize sıfırlama bağlantısı göndereceğiz.'
      : "We'll send a reset link to your email.";
  static String get emailAddressLabel =>
      _tr ? 'E-posta Adresi' : 'Email Address';
  static String get emailAddressHint =>
      _tr ? 'Kayıtlı e-postanızı girin' : 'Enter your registered email';
  static String get sendLink => _tr ? 'Bağlantı Gönder' : 'Send Reset Link';
  static String get emailSentTitle =>
      _tr ? 'E-posta Gönderildi!' : 'Email Sent!';
  static String emailSentBody(String email) => _tr
      ? '$email adresine sıfırlama bağlantısı gönderildi.'
      : 'A reset link was sent to $email.';
  static String get tryDifferentEmail =>
      _tr ? 'Farklı e-posta dene' : 'Try a different email';
  static String get backToLogin =>
      _tr ? 'Giriş ekranına dön' : 'Back to Sign In';

  // ── Ana sayfa / sekmeler ──────────────────────────────────────────────────
  static String greeting(String name) =>
      _tr ? 'Merhaba, $name 👋' : 'Hello, $name 👋';
  static String get homeTab => _tr ? 'Ana Sayfa' : 'Home';
  static String get scheduleTab => _tr ? 'Program' : 'Schedule';
  static String get eventsTab => _tr ? 'Etkinlikler' : 'Events';
  static String get cafeteriaTab => _tr ? 'Yemekhane' : 'Cafeteria';

  // Dashboard kartları
  static String get scheduleCardTitle => _tr ? 'Ders Programı' : 'Course Schedule';
  static String get scheduleCardSub =>
      _tr ? 'Bugünkü derslerini gör' : "View today's classes";
  static String get eventsCardTitle => _tr ? 'Etkinlikler' : 'Events';
  static String get eventsCardSub =>
      _tr ? 'Yaklaşan kampüs etkinlikleri' : 'Upcoming campus events';
  static String get cafeteriaCardTitle =>
      _tr ? 'Yemekhane Menüsü' : 'Cafeteria Menu';
  static String get cafeteriaCardSub =>
      _tr ? 'Bugün ne var?' : "What's for today?";

  // Program sekmesi
  static String get scheduleSectionTitle => _tr ? 'Ders Programı' : 'Schedule';
  /// TR gün adları (backend'e göre sabit)
  static const List<String> _trDays = [
    'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma'
  ];
  static const List<String> _enDays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'
  ];
  static List<String> get displayDays => _tr ? _trDays : _enDays;
  /// Backend her zaman Türkçe gün adı kullanır
  static String backendDay(int index) => _trDays[index];
  static String noLessons(String day) =>
      _tr ? '$day günü ders yok' : 'No classes on $day';

  // Etkinlikler sekmesi
  static String get eventsSectionTitle => _tr ? 'Etkinlikler' : 'Events';
  static String get noEvents =>
      _tr ? 'Yaklaşan etkinlik yok' : 'No upcoming events';

  // Yemekhane sekmesi
  static String get cafeteriaSectionTitle =>
      _tr ? 'Yemekhane Menüsü' : 'Cafeteria Menu';
  static String get noMenu =>
      _tr ? 'Menü bilgisi bulunamadı' : 'Menu not available';
  static String get soupLabel => _tr ? 'Çorba' : 'Soup';
  static String get mainDishLabel => _tr ? 'Ana Yemek' : 'Main Dish';
  static String get sideDishLabel => _tr ? 'Yan Yemek' : 'Side Dish';
  static String get saladLabel => _tr ? 'Salata' : 'Salad';
  static String get dessertLabel => _tr ? 'Tatlı' : 'Dessert';
  static String get drinksLabel => _tr ? 'İçecek' : 'Drinks';

  // ── Profil sekmesi ────────────────────────────────────────────────────────
  static String get profileTab => _tr ? 'Profil' : 'Profile';
  static String get profileSectionTitle => _tr ? 'Profilim' : 'My Profile';
  static String get profileFullName => _tr ? 'Ad Soyad' : 'Full Name';
  static String get profileEmail => _tr ? 'E-posta' : 'Email';
  static String get profileRole => _tr ? 'Rol' : 'Role';
  static String get profileDepartment => _tr ? 'Bölüm' : 'Department';
  static String get profileStudentId => _tr ? 'Öğrenci No' : 'Student ID';
  static String get profileStaffId => _tr ? 'Personel No' : 'Staff ID';
  static String get profileEmployeeId => _tr ? 'Çalışan No' : 'Employee ID';
  static String get profilePosition => _tr ? 'Pozisyon' : 'Position';
  static String get profileJoined => _tr ? 'Kayıt Tarihi' : 'Joined';
  static String get profileLoadError => _tr ? 'Profil yüklenemedi' : 'Could not load profile';
  static String get logoutLabel => _tr ? 'Çıkış Yap' : 'Sign Out';
  static String get logoutConfirm => _tr ? 'Çıkış yapmak istediğinize emin misiniz?' : 'Are you sure you want to sign out?';
  static String get cancel => _tr ? 'İptal' : 'Cancel';

  // ── Duyurular sekmesi ─────────────────────────────────────────────────────
  static String get announcementsTab => _tr ? 'Duyurular' : 'Notices';
  static String get announcementsSectionTitle => _tr ? 'Duyurular' : 'Announcements';
  static String get noAnnouncements => _tr ? 'Duyuru bulunmuyor' : 'No announcements';
  static String get importantBadge => _tr ? 'Önemli' : 'Important';

  // ── SnackBar mesajları ────────────────────────────────────────────────────
  static String get loginFailed => _tr ? 'Giriş başarısız' : 'Login failed';
  static String get registerSuccess => _tr
      ? 'Kayıt başarılı! Giriş yapabilirsiniz.'
      : 'Registration successful! You can now sign in.';
  static String get registerFailed =>
      _tr ? 'Kayıt başarısız' : 'Registration failed';
}
