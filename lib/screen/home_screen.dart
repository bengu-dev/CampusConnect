import 'package:campus_project/l10n/app_locale.dart';
import 'package:campus_project/services/api_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String displayRole;
  final String userEmail;

  const HomeScreen({
    super.key,
    required this.userName,
    required this.displayRole,
    required this.userEmail,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    appLocale.addListener(_onLocaleChange);
  }

  void _onLocaleChange() => setState(() {});

  @override
  void dispose() {
    appLocale.removeListener(_onLocaleChange);
    super.dispose();
  }

  List<Widget> get _tabs => [
    _DashboardTab(
      userName: widget.userName,
      displayRole: widget.displayRole,
      onNavigate: (i) => setState(() => _currentIndex = i),
    ),
    const _ScheduleTab(),
    const _EventsTab(),
    const _CafeteriaTab(),
    const _AnnouncementsTab(),
    _ProfileTab(userName: widget.userName, userEmail: widget.userEmail),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _tabs[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF4F46E5),
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedLabelStyle: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home_rounded),
                label: S.homeTab),
            BottomNavigationBarItem(
                icon: const Icon(Icons.calendar_today_outlined),
                activeIcon: const Icon(Icons.calendar_today_rounded),
                label: S.scheduleTab),
            BottomNavigationBarItem(
                icon: const Icon(Icons.event_outlined),
                activeIcon: const Icon(Icons.event_rounded),
                label: S.eventsTab),
            BottomNavigationBarItem(
                icon: const Icon(Icons.restaurant_outlined),
                activeIcon: const Icon(Icons.restaurant_rounded),
                label: S.cafeteriaTab),
            BottomNavigationBarItem(
                icon: const Icon(Icons.campaign_outlined),
                activeIcon: const Icon(Icons.campaign_rounded),
                label: S.announcementsTab),
            BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline_rounded),
                activeIcon: const Icon(Icons.person_rounded),
                label: S.profileTab),
          ],
        ),
      ),
    );
  }
}

// ─── Dashboard ───────────────────────────────────────────────────────────────

class _DashboardTab extends StatelessWidget {
  final String userName;
  final String displayRole;
  final void Function(int) onNavigate;

  const _DashboardTab({
    required this.userName,
    required this.displayRole,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.greeting(userName.split(' ').first),
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        displayRole,
                        style: const TextStyle(
                            color: Color(0xFF64748B), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _confirmLogout(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Icon(Icons.logout_rounded,
                        color: Color(0xFF64748B), size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _quickCard(
              icon: Icons.calendar_today_rounded,
              color: const Color(0xFF4F46E5),
              title: S.scheduleCardTitle,
              subtitle: S.scheduleCardSub,
              onTap: () => onNavigate(1),
            ),
            const SizedBox(height: 12),
            _quickCard(
              icon: Icons.event_rounded,
              color: const Color(0xFF059669),
              title: S.eventsCardTitle,
              subtitle: S.eventsCardSub,
              onTap: () => onNavigate(2),
            ),
            const SizedBox(height: 12),
            _quickCard(
              icon: Icons.restaurant_rounded,
              color: const Color(0xFFD97706),
              title: S.cafeteriaCardTitle,
              subtitle: S.cafeteriaCardSub,
              onTap: () => onNavigate(3),
            ),
            const SizedBox(height: 12),
            _quickCard(
              icon: Icons.campaign_rounded,
              color: const Color(0xFFDC2626),
              title: S.announcementsSectionTitle,
              subtitle: S.noAnnouncements,
              onTap: () => onNavigate(4),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(S.logoutLabel,
            style: const TextStyle(
                color: Color(0xFF1E293B), fontWeight: FontWeight.w700)),
        content: Text(S.logoutConfirm,
            style: const TextStyle(color: Color(0xFF64748B))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.cancel,
                style: const TextStyle(color: Color(0xFF64748B))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ApiService.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/welcome', (r) => false);
              }
            },
            child: Text(S.logoutLabel,
                style: const TextStyle(
                    color: Color(0xFFEF4444), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _quickCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Color(0xFF64748B), fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: color.withValues(alpha: 0.5), size: 14),
          ],
        ),
      ),
    );
  }
}

// ─── Schedule ─────────────────────────────────────────────────────────────────

class _ScheduleTab extends StatefulWidget {
  const _ScheduleTab();

  @override
  State<_ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<_ScheduleTab> {
  List<dynamic> _courses = [];
  bool _loading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ApiService.getSchedule();
    if (mounted) setState(() { _courses = data; _loading = false; });
  }

  List<dynamic> get _filtered =>
      _courses.where((c) => c['dayOfWeek'] == S.backendDay(_selectedIndex)).toList();

  @override
  Widget build(BuildContext context) {
    final days = S.displayDays;
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Text(S.scheduleSectionTitle,
                style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 22,
                    fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: days.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final selected = i == _selectedIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF4F46E5)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF4F46E5)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      days[i],
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : const Color(0xFF64748B),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF4F46E5)))
                : _filtered.isEmpty
                    ? _emptyState(
                        icon: Icons.calendar_today_outlined,
                        message: S.noLessons(days[_selectedIndex]))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 10),
                        itemBuilder: (_, i) =>
                            _courseCard(_filtered[i]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _courseCard(Map<String, dynamic> c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c['courseName'] ?? '',
                  style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 14,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  c['teacherName'] ?? '',
                  style: const TextStyle(
                      color: Color(0xFF64748B), fontSize: 12.5),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${c['startTime']} - ${c['endTime']}',
                style: const TextStyle(
                    color: Color(0xFF4F46E5),
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                c['room'] ?? '',
                style: const TextStyle(
                    color: Color(0xFF94A3B8), fontSize: 11.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Events ───────────────────────────────────────────────────────────────────

class _EventsTab extends StatefulWidget {
  const _EventsTab();

  @override
  State<_EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<_EventsTab> {
  List<dynamic> _events = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ApiService.getEvents();
    if (mounted) setState(() { _events = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Text(S.eventsSectionTitle,
                style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 22,
                    fontWeight: FontWeight.w800)),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF4F46E5)))
                : _events.isEmpty
                    ? _emptyState(
                        icon: Icons.event_outlined,
                        message: S.noEvents)
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: _events.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 12),
                        itemBuilder: (_, i) => _eventCard(_events[i]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _eventCard(Map<String, dynamic> e) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  e['eventDate'] ?? '',
                  style: const TextStyle(
                      color: Color(0xFF059669),
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
                ),
              ),
              const Spacer(),
              Text(
                e['eventTime'] ?? '',
                style: const TextStyle(
                    color: Color(0xFF94A3B8), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            e['title'] ?? '',
            style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 15,
                fontWeight: FontWeight.w700),
          ),
          if (e['description'] != null) ...[
            const SizedBox(height: 6),
            Text(
              e['description'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Color(0xFF64748B), fontSize: 13, height: 1.4),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  color: Color(0xFF94A3B8), size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  e['location'] ?? '',
                  style: const TextStyle(
                      color: Color(0xFF94A3B8), fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Cafeteria ────────────────────────────────────────────────────────────────

class _CafeteriaTab extends StatefulWidget {
  const _CafeteriaTab();

  @override
  State<_CafeteriaTab> createState() => _CafeteriaTabState();
}

class _CafeteriaTabState extends State<_CafeteriaTab> {
  List<dynamic> _menus = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ApiService.getCafeteriaMenu();
    if (mounted) setState(() { _menus = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Text(S.cafeteriaSectionTitle,
                style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 22,
                    fontWeight: FontWeight.w800)),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF4F46E5)))
                : _menus.isEmpty
                    ? _emptyState(
                        icon: Icons.restaurant_outlined,
                        message: S.noMenu)
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: _menus.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 12),
                        itemBuilder: (_, i) => _menuCard(_menus[i]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _menuCard(Map<String, dynamic> m) {
    final items = <Map<String, String>>[
      if (m['soup'] != null)
        {'label': S.soupLabel, 'value': m['soup']},
      if (m['mainDish'] != null)
        {'label': S.mainDishLabel, 'value': m['mainDish']},
      if (m['sideDish'] != null)
        {'label': S.sideDishLabel, 'value': m['sideDish']},
      if (m['salad'] != null)
        {'label': S.saladLabel, 'value': m['salad']},
      if (m['dessert'] != null)
        {'label': S.dessertLabel, 'value': m['dessert']},
      if (m['drinks'] != null)
        {'label': S.drinksLabel, 'value': m['drinks']},
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFD97706).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              m['menuDate'] ?? '',
              style: const TextStyle(
                  color: Color(0xFFD97706),
                  fontSize: 11,
                  fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 14),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(
                        item['label']!,
                        style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item['value']!,
                        style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ─── Announcements ────────────────────────────────────────────────────────────

class _AnnouncementsTab extends StatefulWidget {
  const _AnnouncementsTab();

  @override
  State<_AnnouncementsTab> createState() => _AnnouncementsTabState();
}

class _AnnouncementsTabState extends State<_AnnouncementsTab> {
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ApiService.getAnnouncements();
    if (mounted) setState(() { _items = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Text(S.announcementsSectionTitle,
                style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 22,
                    fontWeight: FontWeight.w800)),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF4F46E5)))
                : _items.isEmpty
                    ? _emptyState(
                        icon: Icons.campaign_outlined,
                        message: S.noAnnouncements)
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: _items.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 12),
                        itemBuilder: (_, i) =>
                            _announcementCard(_items[i]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _announcementCard(Map<String, dynamic> a) {
    final isImportant = a['important'] == true;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isImportant
              ? const Color(0xFFDC2626).withValues(alpha: 0.3)
              : const Color(0xFFE2E8F0),
          width: isImportant ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (a['category'] != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    a['category'],
                    style: const TextStyle(
                        color: Color(0xFF4F46E5),
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              const Spacer(),
              if (isImportant)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.priority_high_rounded,
                          color: Color(0xFFDC2626), size: 11),
                      const SizedBox(width: 2),
                      Text(S.importantBadge,
                          style: const TextStyle(
                              color: Color(0xFFDC2626),
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            a['title'] ?? '',
            style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 14,
                fontWeight: FontWeight.w700),
          ),
          if (a['content'] != null) ...[
            const SizedBox(height: 6),
            Text(
              a['content'],
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Color(0xFF64748B), fontSize: 13, height: 1.45),
            ),
          ],
          if (a['author'] != null || a['publishDate'] != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.person_outline_rounded,
                    color: Color(0xFFCBD5E1), size: 13),
                const SizedBox(width: 4),
                Text(a['author'] ?? '',
                    style: const TextStyle(
                        color: Color(0xFF94A3B8), fontSize: 11)),
                const Spacer(),
                Text(a['publishDate'] ?? '',
                    style: const TextStyle(
                        color: Color(0xFF94A3B8), fontSize: 11)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Profile ──────────────────────────────────────────────────────────────────

class _ProfileTab extends StatefulWidget {
  final String userName;
  final String userEmail;

  const _ProfileTab({required this.userName, required this.userEmail});

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  Map<String, dynamic> _profile = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ApiService.getUserProfile();
    if (mounted) setState(() { _profile = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
          : _profile.isEmpty
              ? _emptyState(
                  icon: Icons.person_outline_rounded,
                  message: S.profileLoadError)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(S.profileSectionTitle,
                          style: const TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 22,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 24),
                      // Avatar
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF4F46E5),
                                    Color(0xFF7C3AED)
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _initials(_profile['fullName'] ?? widget.userName),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _profile['fullName'] ?? widget.userName,
                              style: const TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _profile['email'] ?? widget.userEmail,
                              style: const TextStyle(
                                  color: Color(0xFF64748B), fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Info cards
                      _infoCard([
                        if (_profile['role'] != null)
                          _InfoRow(label: S.profileRole, value: _roleDisplay(_profile['role'])),
                        if (_profile['department'] != null)
                          _InfoRow(label: S.profileDepartment, value: _profile['department']),
                        if (_profile['studentId'] != null)
                          _InfoRow(label: S.profileStudentId, value: _profile['studentId']),
                        if (_profile['staffId'] != null)
                          _InfoRow(label: S.profileStaffId, value: _profile['staffId']),
                        if (_profile['employeeId'] != null)
                          _InfoRow(label: S.profileEmployeeId, value: _profile['employeeId']),
                        if (_profile['position'] != null)
                          _InfoRow(label: S.profilePosition, value: _profile['position']),
                      ]),
                      const SizedBox(height: 28),
                      // Logout button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () => _confirmLogout(context),
                          icon: const Icon(Icons.logout_rounded,
                              color: Color(0xFFEF4444), size: 18),
                          label: Text(S.logoutLabel,
                              style: const TextStyle(
                                  color: Color(0xFFEF4444),
                                  fontWeight: FontWeight.w700)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: const Color(0xFFEF4444)
                                    .withValues(alpha: 0.4)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String _roleDisplay(String role) {
    switch (role) {
      case 'TEACHER': return S.teacherRole;
      case 'OFFICE': return S.officeRole;
      default: return S.studentRole;
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(S.logoutLabel,
            style: const TextStyle(
                color: Color(0xFF1E293B), fontWeight: FontWeight.w700)),
        content: Text(S.logoutConfirm,
            style: const TextStyle(color: Color(0xFF64748B))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.cancel,
                style: const TextStyle(color: Color(0xFF64748B))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ApiService.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/welcome', (r) => false);
              }
            },
            child: Text(S.logoutLabel,
                style: const TextStyle(
                    color: Color(0xFFEF4444), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(List<_InfoRow> rows) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: rows
            .asMap()
            .entries
            .map((e) => Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 110,
                            child: Text(e.value.label,
                                style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 13)),
                          ),
                          Expanded(
                            child: Text(e.value.value,
                                style: const TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                    if (e.key < rows.length - 1)
                      const Divider(
                          height: 1,
                          indent: 18,
                          endIndent: 18,
                          color: Color(0xFFF1F5F9)),
                  ],
                ))
            .toList(),
      ),
    );
  }
}

class _InfoRow {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});
}

// ─── Shared ───────────────────────────────────────────────────────────────────

Widget _emptyState({required IconData icon, required String message}) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: const Color(0xFFCBD5E1), size: 36),
        ),
        const SizedBox(height: 16),
        Text(message,
            style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
                fontWeight: FontWeight.w500)),
      ],
    ),
  );
}
