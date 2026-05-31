import 'package:campus_project/core/app_theme.dart';
import 'package:campus_project/models/event_model.dart';
import 'package:campus_project/provider/event_provider.dart';
import 'package:campus_project/screen/create_event_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const _schoolTypeLabels = {
  'CAREER':   'Kariyer',
  'SPORTS':   'Spor',
  'ACADEMIC': 'Akademik',
  'CEREMONY': 'Tören',
  'TECH':     'Teknoloji',
  'GENERAL':  'Genel',
};

// ─────────────────────────────────────────────
// EVENTS SCREEN
// ─────────────────────────────────────────────

class EventsScreen extends StatefulWidget {
  final String displayRole;
  final Color  accentColor;

  const EventsScreen({
    super.key,
    required this.displayRole,
    required this.accentColor,
  });

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  bool get _isOffice => widget.displayRole == 'Ofis Personeli';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<EventProvider>();
      // Sadece hiç yüklenmemişse yükle; loaded ise mevcut listeyi göster
      if (!provider.isLoading) {
        provider.loadFromBackend();
      }
    });
  }

  Future<void> _showAddPersonalForm() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PersonalEventForm(accentColor: widget.accentColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: _buildAppBar(),
      floatingActionButton: _buildFab(),
      body: Consumer<EventProvider>(
        builder: (context, provider, _) {
          // İlk yükleme — henüz hiç veri yok
          if (provider.isInitialLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }

          final events = provider.allEvents;

          // Hiç veri yok ve hata var
          if (events.isEmpty && provider.hasError) {
            return _ErrorView(
              message:     provider.errorMessage ?? 'Bağlantı hatası',
              accentColor: widget.accentColor,
              onRetry:     () => provider.loadFromBackend(),
            );
          }

          // Hiç veri yok (boş liste)
          if (events.isEmpty) {
            return _EmptyView(accentColor: widget.accentColor);
          }

          // Veri var — listeyi göster, üstte opsiyonel ince banner
          return Column(
            children: [
              // Arka planda yenileniyor
              if (provider.isRefreshing)
                LinearProgressIndicator(
                  color: widget.accentColor,
                  backgroundColor: widget.accentColor.withAlpha(30),
                  minHeight: 2,
                ),

              Expanded(child: _buildList(provider, events)),
            ],
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() => AppBar(
    backgroundColor: AppColors.bgLight,
    elevation: 0,
    scrolledUnderElevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded,
          color: AppColors.textPrimary, size: 20),
      onPressed: () => Navigator.pop(context),
    ),
    title: const Text('Etkinlikler',
        style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700)),
    actions: [
      IconButton(
        icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
        onPressed: () => context.read<EventProvider>().loadFromBackend(),
      ),
    ],
  );

  Widget _buildFab() {
    if (_isOffice) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'personal_fab',
            onPressed: _showAddPersonalForm,
            backgroundColor: widget.accentColor.withAlpha(200),
            tooltip: 'Kişisel Etkinlik',
            child: const Icon(Icons.person_add_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'school_fab',
            onPressed: () async {
              final ok = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      CreateEventScreen(accentColor: widget.accentColor),
                ),
              );
              if (ok == true && mounted) {
                context.read<EventProvider>().loadFromBackend();
              }
            },
            backgroundColor: widget.accentColor,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text('Etkinlik Ekle',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      );
    }
    return FloatingActionButton.extended(
      heroTag: 'personal_fab',
      onPressed: _showAddPersonalForm,
      backgroundColor: widget.accentColor,
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: const Text('Kişisel Ekle',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600)),
    );
  }

  // ── Liste ─────────────────────────────────────────────────────────────────

  Widget _buildList(EventProvider provider, List<EventModel> events) {
    return RefreshIndicator(
      color: widget.accentColor,
      onRefresh: () => provider.loadFromBackend(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: events.length,
        itemBuilder: (ctx, i) {
          final event = events[i];
          final showHeader =
              i == 0 || !_isSameDay(event.date, events[i - 1].date);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showHeader) _DateHeader(date: event.date),
              if (event.isPersonal)
                _PersonalEventCard(
                  event: event,
                  onDelete: () => _confirmDeletePersonal(context, provider, event),
                )
              else
                _SchoolEventCard(
                  event: event,
                  meta: provider.schoolMeta(event.id) ?? {},
                  accentColor: widget.accentColor,
                  onJoin:  () => provider.joinEvent(event.id),
                  onLeave: () => provider.leaveEvent(event.id),
                ),
            ],
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _confirmDeletePersonal(
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
}

// ─────────────────────────────────────────────
// TARİH GRUP BAŞLIĞI
// ─────────────────────────────────────────────

class _DateHeader extends StatelessWidget {
  final DateTime date;
  const _DateHeader({required this.date});

  static const _months = [
    '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
  ];

  @override
  Widget build(BuildContext context) {
    final now     = DateTime.now();
    final today   = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(date.year, date.month, date.day);
    final isPast  = dateDay.isBefore(today);

    final bool isToday    = dateDay == today;
    final bool isTomorrow = dateDay == today.add(const Duration(days: 1));

    final String label = isToday
        ? 'Bugün'
        : isTomorrow
            ? 'Yarın'
            : '${date.day} ${_months[date.month]}';

    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Row(children: [
        Text(label,
            style: TextStyle(
              color: isPast
                  ? AppColors.textMuted
                  : AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            )),
        const SizedBox(width: 8),
        Expanded(child: Container(height: 1, color: AppColors.border)),
        if (isPast) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.textHint.withAlpha(40),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('geçmiş',
                style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
          ),
        ],
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// KİŞİSEL ETKİNLİK KARTI
// ─────────────────────────────────────────────

class _PersonalEventCard extends StatelessWidget {
  final EventModel   event;
  final VoidCallback onDelete;

  const _PersonalEventCard({required this.event, required this.onDelete});

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
                  _CategoryBadge(category: cat),
                  const Spacer(),
                  Text(
                    '${event.date.day}.${event.date.month.toString().padLeft(2, '0')}.${event.date.year}',
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 11),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onDelete,
                    child: const Icon(Icons.close_rounded,
                        size: 16, color: AppColors.textMuted),
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
                if (event.description.isNotEmpty)
                  Text(event.description,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  DateTime get date => event.date;
}

// ─────────────────────────────────────────────
// KAMPÜS ETKİNLİĞİ KARTI
// ─────────────────────────────────────────────

class _SchoolEventCard extends StatelessWidget {
  final EventModel           event;
  final Map<String, dynamic> meta;
  final Color                accentColor;
  final Future<bool> Function() onJoin;
  final Future<bool> Function() onLeave;

  const _SchoolEventCard({
    required this.event,
    required this.meta,
    required this.accentColor,
    required this.onJoin,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    final cat       = event.category;
    final isJoined  = meta['isJoined'] as bool? ?? false;
    final pCount    = (meta['participantCount'] as num?)?.toInt() ?? 0;
    final capacity  = (meta['capacity'] as num?)?.toInt() ?? 100;
    final location  = meta['location'] as String? ?? '';
    final eventType = meta['eventType'] as String? ?? 'GENERAL';
    final typeLabel = _schoolTypeLabels[eventType] ?? eventType;
    final isFull    = pCount >= capacity;
    final fillRatio = capacity > 0 ? pCount / capacity : 0.0;

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
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
                    _SchoolTypeBadge(label: typeLabel, color: cat.color),
                    const Spacer(),
                    Text(_formatTime(event.date),
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 11)),
                  ]),
                  const SizedBox(height: 6),
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
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$pCount/$capacity',
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 10)),
                        const SizedBox(height: 3),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: fillRatio.clamp(0.0, 1.0),
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation(
                                fillRatio > 0.9
                                    ? AppColors.error
                                    : AppColors.success),
                            minHeight: 3,
                          ),
                        ),
                      ],
                    )),
                    const SizedBox(width: 12),
                    _JoinButton(
                      isJoined: isJoined,
                      isFull:   isFull,
                      color:    cat.color,
                      onTap: () async {
                        final ok = isJoined
                            ? await onLeave()
                            : await onJoin();
                        if (!ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('İşlem başarısız!'),
                              backgroundColor: AppColors.error,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        }
                      },
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    final cat       = event.category;
    final isJoined  = meta['isJoined'] as bool? ?? false;
    final pCount    = (meta['participantCount'] as num?)?.toInt() ?? 0;
    final capacity  = (meta['capacity'] as num?)?.toInt() ?? 100;
    final location  = meta['location'] as String? ?? '';
    final organizer = meta['organizerName'] as String? ?? '';
    final eventType = meta['eventType'] as String? ?? 'GENERAL';
    final typeLabel = _schoolTypeLabels[eventType] ?? eventType;
    final isFull    = pCount >= capacity;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize:     0.4,
        maxChildSize:     0.9,
        expand: false,
        builder: (_, sc) => Container(
          decoration: const BoxDecoration(
            color: AppColors.bgLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Container(height: 3, color: cat.color),
            Expanded(
              child: ListView(
                controller: sc,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                children: [
                  _SchoolTypeBadge(label: typeLabel, color: cat.color),
                  const SizedBox(height: 12),
                  Text(event.title,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                  if (event.description.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(event.description,
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            height: 1.6)),
                  ],
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 12),
                  if (location.isNotEmpty)
                    _DetailRow(Icons.location_on_rounded, location),
                  if (organizer.isNotEmpty)
                    _DetailRow(Icons.person_rounded, organizer),
                  _DetailRow(Icons.people_rounded,
                      '$pCount / $capacity katılımcı${isFull ? " (Dolu)" : ""}'),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: isFull && !isJoined
                        ? null
                        : () {
                            Navigator.pop(context);
                            isJoined ? onLeave() : onJoin();
                          },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: isJoined
                            ? Colors.redAccent.withAlpha(20)
                            : cat.color.withAlpha(22),
                        border: Border.all(
                            color: isJoined
                                ? Colors.redAccent
                                : cat.color),
                      ),
                      child: Center(child: Text(
                        isJoined
                            ? 'Katılımı İptal Et'
                            : isFull
                                ? 'Kontenjan Dolu'
                                : 'Etkinliğe Katıl',
                        style: TextStyle(
                          color: isJoined
                              ? Colors.redAccent
                              : cat.color,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      )),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  String _formatTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

// ─────────────────────────────────────────────
// YARDIMCI WIDGET'LAR
// ─────────────────────────────────────────────

class _CategoryBadge extends StatelessWidget {
  final EventCategory category;
  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
        color: category.bgColor,
        borderRadius: BorderRadius.circular(8)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(category.icon, size: 10, color: category.color),
      const SizedBox(width: 4),
      Text(category.label,
          style: TextStyle(
              color: category.color,
              fontSize: 10,
              fontWeight: FontWeight.w700)),
    ]),
  );
}

class _SchoolTypeBadge extends StatelessWidget {
  final String label;
  final Color  color;
  const _SchoolTypeBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
        color: color.withAlpha(22),
        borderRadius: BorderRadius.circular(8)),
    child: Text(label,
        style: TextStyle(
            color: color, fontSize: 10, fontWeight: FontWeight.w700)),
  );
}

class _JoinButton extends StatelessWidget {
  final bool         isJoined;
  final bool         isFull;
  final Color        color;
  final VoidCallback onTap;
  const _JoinButton({
    required this.isJoined,
    required this.isFull,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = isJoined || !isFull;
    return GestureDetector(
      onTap: active ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isJoined
              ? Colors.redAccent.withAlpha(18)
              : isFull
                  ? AppColors.border
                  : color.withAlpha(22),
          border: Border.all(
              color: isJoined
                  ? Colors.redAccent
                  : isFull
                      ? AppColors.textMuted
                      : color),
        ),
        child: Text(
          isJoined ? 'Ayrıl' : isFull ? 'Dolu' : 'Katıl',
          style: TextStyle(
            color: isJoined
                ? Colors.redAccent
                : isFull
                    ? AppColors.textMuted
                    : color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String   text;
  const _DetailRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Icon(icon, size: 15, color: AppColors.textMuted),
      const SizedBox(width: 10),
      Expanded(child: Text(text,
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 13))),
    ]),
  );
}

class _ErrorView extends StatelessWidget {
  final String       message;
  final Color        accentColor;
  final VoidCallback onRetry;
  const _ErrorView({
    required this.message,
    required this.accentColor,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.wifi_off_rounded,
            color: AppColors.textMuted, size: 52),
        const SizedBox(height: 16),
        Text(message,
            style: const TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center),
        const SizedBox(height: 20),
        TextButton(
          onPressed: onRetry,
          child: Text('Tekrar Dene',
              style: TextStyle(
                  color: accentColor, fontWeight: FontWeight.w600)),
        ),
      ]),
    ),
  );
}

class _EmptyView extends StatelessWidget {
  final Color accentColor;
  const _EmptyView({required this.accentColor});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.event_outlined,
          color: AppColors.textHint, size: 64),
      const SizedBox(height: 16),
      const Text('Henüz etkinlik yok.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
      const SizedBox(height: 8),
      const Text('FAB butonuna basarak\nkişisel etkinlik ekleyebilirsin.',
          style: TextStyle(color: AppColors.textHint, fontSize: 13),
          textAlign: TextAlign.center),
    ]),
  );
}

// ─────────────────────────────────────────────
// KİŞİSEL ETKİNLİK EKLEME FORMU
// ─────────────────────────────────────────────

class _PersonalEventForm extends StatefulWidget {
  final Color accentColor;
  const _PersonalEventForm({required this.accentColor});

  @override
  State<_PersonalEventForm> createState() => _PersonalEventFormState();
}

class _PersonalEventFormState extends State<_PersonalEventForm> {
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  EventCategory _category = EventCategory.personal;
  DateTime?     _date;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate:  DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(primary: widget.accentColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    if (_titleCtrl.text.trim().isEmpty) {
      _snack('Başlık boş bırakılamaz!');
      return;
    }
    if (_date == null) {
      _snack('Lütfen bir tarih seç!');
      return;
    }
    // Provider'a ekle → hem EventsScreen hem CalendarScreen anında güncellenir
    context.read<EventProvider>().addPersonalEvent(
      title:       _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      date:        _date!,
      category:    _category,
    );
    Navigator.pop(context);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              const Text('Kişisel Etkinlik',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              TextButton(
                onPressed: _save,
                style: TextButton.styleFrom(
                  backgroundColor: widget.accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 9),
                ),
                child: const Text('Kaydet',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 18),

            _label('Başlık'),
            const SizedBox(height: 6),
            _field(_titleCtrl, 'Etkinlik adı…'),
            const SizedBox(height: 14),

            _label('Açıklama (opsiyonel)'),
            const SizedBox(height: 6),
            _field(_descCtrl, 'Yer, not, detay…', maxLines: 3),
            const SizedBox(height: 14),

            _label('Kategori'),
            const SizedBox(height: 8),
            Row(
              children: EventCategory.values.map((cat) {
                final sel = _category == cat;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _category = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: EdgeInsets.only(
                          right: cat != EventCategory.values.last ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: sel
                            ? cat.color.withAlpha(22)
                            : AppColors.bgSurface,
                        border: Border.all(
                            color: sel ? cat.color : AppColors.border,
                            width: sel ? 1.5 : 1),
                      ),
                      child: Column(children: [
                        Icon(cat.icon, size: 17,
                            color: sel ? cat.color : AppColors.textMuted),
                        const SizedBox(height: 4),
                        Text(cat.label,
                            style: TextStyle(
                              color:
                                  sel ? cat.color : AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: sel
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            )),
                      ]),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            _label('Tarih'),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.bgSurface,
                  border: Border.all(
                    color: _date != null
                        ? widget.accentColor.withAlpha(150)
                        : AppColors.border,
                  ),
                ),
                child: Row(children: [
                  Icon(Icons.calendar_today_rounded,
                      size: 17,
                      color: _date != null
                          ? widget.accentColor
                          : AppColors.textMuted),
                  const SizedBox(width: 12),
                  Text(
                    _date != null
                        ? '${_date!.day}.${_date!.month.toString().padLeft(2, '0')}.${_date!.year}'
                        : 'Tarih seç',
                    style: TextStyle(
                      color: _date != null
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textMuted, size: 18),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Text(t,
      style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600));

  Widget _field(TextEditingController ctrl, String hint,
      {int maxLines = 1}) =>
      TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              const TextStyle(color: AppColors.textHint, fontSize: 14),
          filled: true,
          fillColor: AppColors.bgSurface,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: widget.accentColor, width: 1.5)),
          contentPadding: const EdgeInsets.all(14),
        ),
      );
}
