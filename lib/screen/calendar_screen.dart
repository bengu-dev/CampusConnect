import 'package:campus_project/core/app_theme.dart';
import 'package:campus_project/models/event_model.dart';
import 'package:campus_project/provider/event_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

// ─────────────────────────────────────────────
// TAKVİM SAYFASI
// ─────────────────────────────────────────────

class CalendarScreen extends StatefulWidget {
  final Color accentColor;
  const CalendarScreen({super.key, required this.accentColor});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay  = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<EventProvider>();
      if (provider.loadState == EventLoadState.idle) {
        provider.loadFromBackend();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textPrimary, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text('Takvim',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.today_rounded, color: AppColors.textSecondary),
            tooltip: 'Bugüne git',
            onPressed: () => setState(() {
              _focusedDay  = DateTime.now();
              _selectedDay = DateTime.now();
            }),
          ),
        ],
      ),
      body: Consumer<EventProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              _buildCalendar(provider),
              const Divider(height: 1, color: AppColors.border),
              Expanded(child: _buildDayEvents(provider)),
            ],
          );
        },
      ),
    );
  }

  // ── TableCalendar ─────────────────────────────────────────────────────────

  Widget _buildCalendar(EventProvider provider) {
    return TableCalendar<EventModel>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay:  DateTime.utc(2030, 12, 31),
      focusedDay:  _focusedDay,
      selectedDayPredicate: (day) => isSameDay(day, _selectedDay),

      // locale KALDIRILDI — initializeDateFormatting olmadan hata fırlatır.
      // Türkçe görünüm için daysOfWeekStyle'da manuel yazdık.

      eventLoader: (day) => provider.eventsForDay(day),

      onDaySelected: (selected, focused) {
        setState(() {
          _selectedDay = selected;
          _focusedDay  = focused;
        });
      },

      onPageChanged: (focused) => _focusedDay = focused,

      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: 'Ay'},
      startingDayOfWeek: StartingDayOfWeek.monday,

      // ── Header ───────────────────────────────────────────────────────────
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700),
        leftChevronIcon: const Icon(Icons.chevron_left_rounded,
            color: AppColors.textSecondary),
        rightChevronIcon: const Icon(Icons.chevron_right_rounded,
            color: AppColors.textSecondary),
        headerPadding: const EdgeInsets.symmetric(vertical: 8),
        // Ay adını Türkçe göster
        titleTextFormatter: (date, locale) => _turkishMonthYear(date),
      ),

      // ── Gün başlıkları — Türkçe manuel ───────────────────────────────────
      calendarBuilders: CalendarBuilders(
        // Haftanın günleri başlığı (Pt, Sa, Ça …)
        dowBuilder: (context, day) {
          const labels = ['Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct', 'Pz'];
          final label  = labels[day.weekday - 1];
          final isWeekend = day.weekday == 6 || day.weekday == 7;
          return Center(
            child: Text(label,
                style: TextStyle(
                    color: isWeekend
                        ? AppColors.textMuted
                        : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          );
        },

        // Kategori renkli marker noktaları
        markerBuilder: (context, day, events) {
          if (events.isEmpty) return const SizedBox();
          final categories = events
              .map((e) => e.category)
              .toSet()
              .take(3)
              .toList();
          return Positioned(
            bottom: 4,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: categories.map((cat) => Container(
                width: 5, height: 5,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                    color: cat.color, shape: BoxShape.circle),
              )).toList(),
            ),
          );
        },
      ),

      // ── Stil ─────────────────────────────────────────────────────────────
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        defaultTextStyle: const TextStyle(
            color: AppColors.textPrimary, fontSize: 13),
        weekendTextStyle: const TextStyle(
            color: AppColors.textSecondary, fontSize: 13),
        todayDecoration: BoxDecoration(
          color: widget.accentColor.withAlpha(30),
          shape: BoxShape.circle,
        ),
        todayTextStyle: TextStyle(
            color: widget.accentColor,
            fontSize: 13,
            fontWeight: FontWeight.w800),
        selectedDecoration: BoxDecoration(
          color: widget.accentColor,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: const TextStyle(
            color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
        markersMaxCount: 3,
        markerDecoration: const BoxDecoration(color: Colors.transparent),
      ),
    );
  }

  // ── Seçili gün etkinlikleri ───────────────────────────────────────────────

  Widget _buildDayEvents(EventProvider provider) {
    final events = provider.eventsForDay(_selectedDay);

    if (events.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.event_available_rounded,
              color: AppColors.textHint, size: 48),
          const SizedBox(height: 12),
          Text(
            _isSameDay(_selectedDay, DateTime.now())
                ? 'Bugün için etkinlik yok.'
                : '${_selectedDay.day} ${_turkishMonth(_selectedDay.month)} için etkinlik yok.',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        ]),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: events.length,
      itemBuilder: (ctx, i) {
        final event = events[i];
        return event.isPersonal
            ? _CalendarPersonalCard(
                event: event,
                onDelete: () => _confirmDelete(context, provider, event),
              )
            : _CalendarSchoolCard(
                event: event,
                meta: provider.schoolMeta(event.id) ?? {},
              );
      },
    );
  }

  // ── Yardımcılar ───────────────────────────────────────────────────────────

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _confirmDelete(
      BuildContext context, EventProvider provider, EventModel event) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Etkinliği Sil',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        content: Text('"${event.title}" etkinliğini silmek istiyor musun?',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (ok == true) provider.removePersonalEvent(event.id);
  }

  String _turkishMonthYear(DateTime date) {
    const months = [
      '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
    ];
    return '${months[date.month]} ${date.year}';
  }

  String _turkishMonth(int m) {
    const months = [
      '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
    ];
    return months[m];
  }
}

// ─────────────────────────────────────────────
// KİŞİSEL ETKİNLİK KARTI
// ─────────────────────────────────────────────

class _CalendarPersonalCard extends StatelessWidget {
  final EventModel   event;
  final VoidCallback onDelete;

  const _CalendarPersonalCard({
    required this.event,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cat = event.category;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: cat.color.withAlpha(15),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(children: [
        // Sol renk şeridi
        Container(
          width: 4,
          height: 68,
          decoration: BoxDecoration(
            color: cat.color,
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(14)),
          ),
        ),
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CategoryChip(category: cat),
                    const SizedBox(height: 5),
                    Text(event.title,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    if (event.description.isNotEmpty)
                      Text(event.description,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.close_rounded,
                    size: 16, color: AppColors.textMuted),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// KAMPÜS ETKİNLİĞİ KARTI
// ─────────────────────────────────────────────

class _CalendarSchoolCard extends StatelessWidget {
  final EventModel           event;
  final Map<String, dynamic> meta;

  const _CalendarSchoolCard({
    required this.event,
    required this.meta,
  });

  @override
  Widget build(BuildContext context) {
    final cat      = event.category;
    final location = meta['location'] as String? ?? '';
    final pCount   = (meta['participantCount'] as num?)?.toInt() ?? 0;
    final capacity = (meta['capacity'] as num?)?.toInt() ?? 100;
    final isJoined = meta['isJoined'] as bool? ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: cat.color.withAlpha(15),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(children: [
        Container(
          width: 4,
          height: 72,
          decoration: BoxDecoration(
            color: cat.color,
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(14)),
          ),
        ),
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  _CategoryChip(category: cat),
                  const Spacer(),
                  if (isJoined)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success.withAlpha(22),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Kayıtlısın',
                          style: TextStyle(
                              color: AppColors.success,
                              fontSize: 10,
                              fontWeight: FontWeight.w700)),
                    ),
                ]),
                const SizedBox(height: 5),
                Text(event.title,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                if (location.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Row(children: [
                    const Icon(Icons.location_on_rounded,
                        size: 11, color: AppColors.textMuted),
                    const SizedBox(width: 3),
                    Expanded(child: Text(location,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis)),
                  ]),
                ],
                const SizedBox(height: 4),
                Text('$pCount / $capacity katılımcı',
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// KATEGORİ ETİKETİ
// ─────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final EventCategory category;
  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: category.bgColor,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(category.icon, size: 10, color: category.color),
      const SizedBox(width: 3),
      Text(category.label,
          style: TextStyle(
              color: category.color,
              fontSize: 10,
              fontWeight: FontWeight.w700)),
    ]),
  );
}
