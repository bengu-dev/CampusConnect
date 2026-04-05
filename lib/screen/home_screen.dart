import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String displayRole;

  const HomeScreen({
    super.key,
    required this.userName,
    required this.displayRole,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentSection = 'Dashboard';

  // Çıkış yapma fonksiyonu
  void _handleSignOut(BuildContext context) {
    // Navigator.pushNamedAndRemoveUntil kullanarak arkadaki tüm sayfaları sileriz
    // ve kullanıcıyı '/' rotasına (WelcomeScreen) göndeririz.
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    
    // Opsiyonel: Başarı mesajı
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Signed out successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(_currentSection, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF1A1A35),
        child: Column(
          children: [
            // Üst Kısım: Kullanıcı Bilgileri
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                ),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white, size: 40),
              ),
              accountName: Text(widget.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: Text(widget.displayRole),
            ),
            
            // Orta Kısım: Menü Öğeleri
            _drawerItem(Icons.calendar_today_rounded, 'Course Schedule'),
            _drawerItem(Icons.event_note_rounded, 'Events'),
            _drawerItem(Icons.restaurant_menu_rounded, 'Cafeteria Menu'),
            
            // spacer= aşağıdaki öğeleri en alta iter
            const Spacer(), 
            
            const Divider(color: Colors.white10, thickness: 1),
            
            // Alt Kısım: Sign Out Butonu
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
              ),
              onTap: () => _handleSignOut(context),
            ),
            const SizedBox(height: 20), // En altta biraz boşluk bırakalım
          ],
        ),
      ),
      body: Center(
        child: Text(
          'Welcome to $_currentSection',
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 18),
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4F46E5)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        setState(() => _currentSection = title);
        Navigator.pop(context); // Drawer'ı kapat
      },
    );
  }
}