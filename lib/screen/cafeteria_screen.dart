import 'package:campus_project/core/app_theme.dart';
import 'package:flutter/material.dart';

const _weekdays = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
const _months   = [
  '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
  'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
];

// Referans tarihi — menü döngüsünün başladığı gün
final _refDate = DateTime(2025, 1, 1);

// 20 günlük döngüsel yemekhane menüsü
const List<Map<String, String>> _menuCycle = [
  // 1. Gün
  {
    'corba':  'Mercimek Çorbası',
    'ana':    'Tavuk Sote',
    'ara':    'Bulgur Pilavı',
    'salata': 'Mevsim Salatası',
    'tatli':  'Sütlaç',
  },
  // 2. Gün
  {
    'corba':  'Domates Çorbası',
    'ana':    'Kıymalı Bezelye',
    'ara':    'Pirinç Pilavı',
    'salata': 'Coleslaw',
    'tatli':  'Muhallebi',
  },
  // 3. Gün
  {
    'corba':  'Ezogelin Çorbası',
    'ana':    'Izgara Köfte',
    'ara':    'Kuru Fasulye',
    'salata': 'Çoban Salatası',
    'tatli':  'Şekerpare',
  },
  // 4. Gün
  {
    'corba':  'Sebze Çorbası',
    'ana':    'Tavuk Güveç',
    'ara':    'Bulgur Pilavı',
    'salata': 'Havuçlu Yoğurt',
    'tatli':  'Revani',
  },
  // 5. Gün
  {
    'corba':  'Kremalı Mantar Çorbası',
    'ana':    'Balık Tava',
    'ara':    'Patates Yemeği',
    'salata': 'Yeşil Salata',
    'tatli':  'Kadayıf',
  },
  // 6. Gün
  {
    'corba':  'Arpa Şehriye Çorbası',
    'ana':    'İzmir Köfte',
    'ara':    'Nohut',
    'salata': 'Patlıcan Salatası',
    'tatli':  'Fırın Sütlaç',
  },
  // 7. Gün
  {
    'corba':  'Tavuk Çorbası',
    'ana':    'Kuzu Güveç',
    'ara':    'Pirinç Pilavı',
    'salata': 'Mevsim Salatası',
    'tatli':  'Baklava',
  },
  // 8. Gün
  {
    'corba':  'Ezogelin Çorbası',
    'ana':    'Fırın Tavuk',
    'ara':    'İmam Bayıldı',
    'salata': 'Coleslaw',
    'tatli':  'Ayva Tatlısı',
  },
  // 9. Gün
  {
    'corba':  'Domates Çorbası',
    'ana':    'Şiş Köfte',
    'ara':    'Mercimekli Pilav',
    'salata': 'Çoban Salatası',
    'tatli':  'Komposto',
  },
  // 10. Gün
  {
    'corba':  'Sebze Çorbası',
    'ana':    'Et Kavurma',
    'ara':    'Nohutlu Makarna',
    'salata': 'Yeşil Salata',
    'tatli':  'Tavuk Göğsü',
  },
  // 11. Gün
  {
    'corba':  'Mercimek Çorbası',
    'ana':    'Tavuklu Güveç',
    'ara':    'Patates Oturtması',
    'salata': 'Mevsim Salatası',
    'tatli':  'Sütlaç',
  },
  // 12. Gün
  {
    'corba':  'Kremalı Domates Çorbası',
    'ana':    'Etli Taze Fasulye',
    'ara':    'Bulgur Pilavı',
    'salata': 'Semizotu Salatası',
    'tatli':  'Helva',
  },
  // 13. Gün
  {
    'corba':  'Arpa Şehriye Çorbası',
    'ana':    'Kıymalı Ispanak',
    'ara':    'Kuru Fasulye',
    'salata': 'Havuçlu Yoğurt',
    'tatli':  'Şekerpare',
  },
  // 14. Gün
  {
    'corba':  'Ezogelin Çorbası',
    'ana':    'Fırın Levrek',
    'ara':    'Zeytinyağlı Bezelye',
    'salata': 'Çoban Salatası',
    'tatli':  'Kaymaklı Kadayıf',
  },
  // 15. Gün
  {
    'corba':  'Domates Çorbası',
    'ana':    'Tas Kebabı',
    'ara':    'Pirinç Pilavı',
    'salata': 'Yeşil Salata',
    'tatli':  'Revani',
  },
  // 16. Gün
  {
    'corba':  'Sebze Çorbası',
    'ana':    'Tavuk Şiş',
    'ara':    'Patates Kızartması',
    'salata': 'Mevsim Salatası',
    'tatli':  'Muhallebi',
  },
  // 17. Gün
  {
    'corba':  'Mercimek Çorbası',
    'ana':    'Etli Nohut',
    'ara':    'Erişte',
    'salata': 'Patlıcan Salatası',
    'tatli':  'Baklava',
  },
  // 18. Gün
  {
    'corba':  'Tavuk Çorbası',
    'ana':    'Orman Kebabı',
    'ara':    'Bulgur Pilavı',
    'salata': 'Coleslaw',
    'tatli':  'Fırın Sütlaç',
  },
  // 19. Gün
  {
    'corba':  'Kremalı Mantar Çorbası',
    'ana':    'Izgara Köfte',
    'ara':    'Nohut',
    'salata': 'Yeşil Salata',
    'tatli':  'Komposto',
  },
  // 20. Gün
  {
    'corba':  'Domates Çorbası',
    'ana':    'Kıymalı Biber Dolması',
    'ara':    'Pirinç Pilavı',
    'salata': 'Çoban Salatası',
    'tatli':  'Sütlaç',
  },
];

// Tarihe göre menü kaydını getir (20 günlük döngü)
Map<String, String> _menuForDate(DateTime date) {
  final daysSinceRef = date.difference(_refDate).inDays;
  final index = daysSinceRef % _menuCycle.length;
  return _menuCycle[index < 0 ? (index + _menuCycle.length) : index];
}

// Yemek kategorileri — ikon + renk + başlık
const _categories = [
  (key: 'corba',  label: 'Çorba',      icon: Icons.soup_kitchen_rounded,       color: Color(0xFFD97706)),
  (key: 'ana',    label: 'Ana Yemek',  icon: Icons.lunch_dining_rounded,        color: Color(0xFF059669)),
  (key: 'ara',    label: 'Ara Yemek',  icon: Icons.rice_bowl_rounded,           color: Color(0xFF2563EB)),
  (key: 'salata', label: 'Salata',     icon: Icons.eco_rounded,                 color: Color(0xFF16A34A)),
  (key: 'tatli',  label: 'Tatlı',      icon: Icons.cake_rounded,                color: Color(0xFFDB2777)),
];

class CafeteriaScreen extends StatefulWidget {
  final Color accentColor;
  const CafeteriaScreen({super.key, required this.accentColor});

  @override
  State<CafeteriaScreen> createState() => _CafeteriaScreenState();
}

class _CafeteriaScreenState extends State<CafeteriaScreen> {
  DateTime _selectedDate = DateTime.now();

  void _changeDay(int delta) =>
      setState(() => _selectedDate = _selectedDate.add(Duration(days: delta)));

  bool get _isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  String get _dateLabel {
    if (_isToday) return 'Bugün, ${_selectedDate.day} ${_months[_selectedDate.month]}';
    return '${_weekdays[_selectedDate.weekday - 1]}, '
        '${_selectedDate.day} ${_months[_selectedDate.month]} ${_selectedDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    final menu = _menuForDate(_selectedDate);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        title: const Text(
          'Yemek Menüsü',
          style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today_rounded, color: AppColors.textSecondary),
            tooltip: 'Bugüne Dön',
            onPressed: _isToday
                ? null
                : () => setState(() => _selectedDate = DateTime.now()),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateNav(context),
          Expanded(child: _buildMenu(menu)),
        ],
      ),
    );
  }

  // ── Tarih Navigasyonu ─────────────────────────────────────────────────────

  Widget _buildDateNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.bgSurface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          _NavBtn(
            icon: Icons.chevron_left_rounded,
            onTap: () => _changeDay(-1),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now().add(const Duration(days: 60)),
                  builder: (ctx, child) => Theme(
                    data: ThemeData.light().copyWith(
                      colorScheme: ColorScheme.light(primary: widget.accentColor),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
              child: Column(
                children: [
                  Text(
                    _dateLabel,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_isToday) ...[
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: widget.accentColor.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Bugün',
                        style: TextStyle(
                          color: widget.accentColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          _NavBtn(
            icon: Icons.chevron_right_rounded,
            onTap: () => _changeDay(1),
          ),
        ],
      ),
    );
  }

  // ── Menü İçeriği ─────────────────────────────────────────────────────────

  Widget _buildMenu(Map<String, String> menu) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Öğle Yemeği başlık kartı
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              gradient: LinearGradient(
                colors: [
                  widget.accentColor.withAlpha(40),
                  widget.accentColor.withAlpha(15),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              border: Border.all(color: widget.accentColor.withAlpha(60)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.accentColor.withAlpha(40),
                  ),
                  child: Icon(Icons.lunch_dining_rounded,
                      color: widget.accentColor, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Öğle Yemeği',
                      style: TextStyle(
                        color: widget.accentColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      'Yemekhane Günlük Menüsü',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Yemek kalemleri
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(16)),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: widget.accentColor.withAlpha(12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: _categories.map((cat) {
                final isLast = cat.key == _categories.last.key;
                return _MenuRow(
                  icon: cat.icon,
                  color: cat.color,
                  label: cat.label,
                  value: menu[cat.key] ?? '—',
                  showDivider: !isLast,
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // Bilgi notu
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 15, color: AppColors.textMuted),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Menü 20 günlük döngü ile hazırlanmaktadır. '
                    'Malzeme değişikliği durumunda güncelleme yapılabilir.',
                    style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Menü Satırı ──────────────────────────────────────────────────────────────

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final Color    color;
  final String   label;
  final String   value;
  final bool     showDivider;

  const _MenuRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: color.withAlpha(22),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 14),
              SizedBox(
                width: 80,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, indent: 66, color: AppColors.border),
      ],
    );
  }
}

// ── Navigasyon Butonu ─────────────────────────────────────────────────────────

class _NavBtn extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onTap;

  const _NavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColors.bgSurface,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 22),
      ),
    );
  }
}
