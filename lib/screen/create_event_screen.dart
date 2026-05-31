import 'package:campus_project/core/app_theme.dart';
import 'package:campus_project/services/api_service.dart';
import 'package:campus_project/widgets/custom_text_filed.dart';
import 'package:flutter/material.dart';

// Etkinlik tipleri
const _eventTypes = [
  ('CAREER',   'Kariyer',    Icons.work_rounded),
  ('ACADEMIC', 'Akademik',   Icons.school_rounded),
  ('SPORTS',   'Spor',       Icons.sports_soccer_rounded),
  ('TECH',     'Teknoloji',  Icons.computer_rounded),
  ('CEREMONY', 'Tören',      Icons.celebration_rounded),
  ('GENERAL',  'Genel',      Icons.event_rounded),
];

class CreateEventScreen extends StatefulWidget {
  final Color accentColor;
  const CreateEventScreen({super.key, required this.accentColor});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey          = GlobalKey<FormState>();
  final _titleCtrl        = TextEditingController();
  final _descCtrl         = TextEditingController();
  final _locationCtrl     = TextEditingController();
  final _capacityCtrl     = TextEditingController(text: '100');

  String    _eventType  = 'GENERAL';
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  bool      _isLoading  = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  // ── Tarih-saat seçici ─────────────────────────────────────────────────────

  Future<void> _pickStart() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => _datePickerTheme(ctx, child),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: _startTime ?? const TimeOfDay(hour: 10, minute: 0),
      builder: (ctx, child) => _datePickerTheme(ctx, child),
    );
    if (!mounted) return;
    setState(() { _startDate = date; _startTime = time; });
  }

  Future<void> _pickEnd() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? (_startDate ?? DateTime.now().add(const Duration(days: 1))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => _datePickerTheme(ctx, child),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: _endTime ?? const TimeOfDay(hour: 17, minute: 0),
      builder: (ctx, child) => _datePickerTheme(ctx, child),
    );
    if (!mounted) return;
    setState(() { _endDate = date; _endTime = time; });
  }

  Widget _datePickerTheme(BuildContext ctx, Widget? child) => Theme(
    data: ThemeData.light().copyWith(
      colorScheme: ColorScheme.light(
        primary: widget.accentColor,
      ),
    ),
    child: child!,
  );

  String _formatDt(DateTime d, TimeOfDay? t) {
    final h = t?.hour   ?? 0;
    final m = t?.minute ?? 0;
    return '${d.day.toString().padLeft(2,'0')}.${d.month.toString().padLeft(2,'0')}.${d.year}  '
        '${h.toString().padLeft(2,'0')}:${m.toString().padLeft(2,'0')}';
  }

  String _toIso(DateTime d, TimeOfDay t) =>
      DateTime(d.year, d.month, d.day, t.hour, t.minute).toIso8601String();

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _startTime == null) {
      _snack('Başlangıç tarihi ve saati seçin!', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      'title':         _titleCtrl.text.trim(),
      'description':   _descCtrl.text.trim(),
      'location':      _locationCtrl.text.trim(),
      'eventType':     _eventType,
      'capacity':      int.tryParse(_capacityCtrl.text) ?? 100,
      'startDatetime': _toIso(_startDate!, _startTime!),
      if (_endDate != null && _endTime != null)
        'endDatetime': _toIso(_endDate!, _endTime!),
    };

    final result = await ApiService.createEvent(data);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      _snack('Etkinlik oluşturuldu!');
      Navigator.pop(context, true);
    } else {
      _snack(result['message'] ?? 'Oluşturulamadı!', isError: true);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.error : AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        title: const Text('Etkinlik Ekle',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary, size: 22),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Başlık
              _label('Başlık'),
              const SizedBox(height: 8),
              CustomTextField(
                label: 'Etkinlik Başlığı',
                hint: 'Kariyer Günleri 2025',
                icon: Icons.title_rounded,
                controller: _titleCtrl,
                accentColor: widget.accentColor,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Başlık zorunlu';
                  if (v.trim().length < 5) return 'En az 5 karakter';
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ── Açıklama
              _label('Açıklama'),
              const SizedBox(height: 8),
              _multilineField(_descCtrl, 'Etkinlik hakkında kısa bilgi…'),

              const SizedBox(height: 20),

              // ── Konum
              _label('Konum'),
              const SizedBox(height: 8),
              CustomTextField(
                label: 'Yer / Salon',
                hint: 'Kongre Merkezi — Salon A',
                icon: Icons.location_on_rounded,
                controller: _locationCtrl,
                accentColor: widget.accentColor,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Konum zorunlu' : null,
              ),

              const SizedBox(height: 20),

              // ── Etkinlik tipi
              _label('Etkinlik Türü'),
              const SizedBox(height: 10),
              _typeSelector(),

              const SizedBox(height: 20),

              // ── Tarihler
              _label('Başlangıç Tarihi ve Saati'),
              const SizedBox(height: 8),
              _dateTile(
                label: _startDate != null
                    ? _formatDt(_startDate!, _startTime)
                    : 'Tarih ve saat seçin',
                hasValue: _startDate != null,
                onTap: _pickStart,
              ),

              const SizedBox(height: 14),
              _label('Bitiş Tarihi ve Saati (opsiyonel)'),
              const SizedBox(height: 8),
              _dateTile(
                label: _endDate != null
                    ? _formatDt(_endDate!, _endTime)
                    : 'Tarih ve saat seçin',
                hasValue: _endDate != null,
                onTap: _pickEnd,
              ),

              const SizedBox(height: 20),

              // ── Kontenjan
              _label('Kontenjan'),
              const SizedBox(height: 8),
              CustomTextField(
                label: 'Maksimum Katılımcı',
                hint: '100',
                icon: Icons.people_rounded,
                controller: _capacityCtrl,
                accentColor: widget.accentColor,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Kontenjan zorunlu';
                  final n = int.tryParse(v);
                  if (n == null || n < 1) return 'Geçerli bir sayı girin';
                  return null;
                },
              ),

              const SizedBox(height: 36),

              // ── Oluştur
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: _isLoading
                          ? AppGradients.loading
                          : LinearGradient(
                              colors: [widget.accentColor, widget.accentColor.withAlpha(200)]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: _isLoading
                          ? const SizedBox(width: 22, height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.event_available_rounded, color: Colors.white, size: 20),
                                SizedBox(width: 10),
                                Text('Etkinliği Oluştur',
                                    style: TextStyle(color: Colors.white, fontSize: 16,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Yardımcı widget'lar ───────────────────────────────────────────────────

  Widget _label(String text) => Text(text,
      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13,
          fontWeight: FontWeight.w600, letterSpacing: 0.4));

  Widget _multilineField(TextEditingController ctrl, String hint) => TextFormField(
    controller: ctrl,
    maxLines: 4,
    minLines: 3,
    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.5),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
      filled: true,
      fillColor: AppColors.bgSurface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: widget.accentColor, width: 1.5)),
      contentPadding: const EdgeInsets.all(14),
    ),
  );

  Widget _dateTile({required String label, required bool hasValue, required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: AppColors.bgSurface,
            border: Border.all(
              color: hasValue ? widget.accentColor.withAlpha(128) : AppColors.border),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: 18, color: hasValue ? widget.accentColor : AppColors.textMuted),
              const SizedBox(width: 12),
              Expanded(child: Text(label,
                  style: TextStyle(
                    color: hasValue ? AppColors.textPrimary : AppColors.textHint,
                    fontSize: 14,
                  ))),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted, size: 20),
            ],
          ),
        ),
      );

  Widget _typeSelector() => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: _eventTypes.map((t) {
      final (value, label, icon) = t;
      final selected = _eventType == value;
      return GestureDetector(
        onTap: () => setState(() => _eventType = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: selected ? widget.accentColor.withAlpha(51) : AppColors.bgSurface,
            border: Border.all(
              color: selected ? widget.accentColor : AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14,
                  color: selected ? widget.accentColor : AppColors.textMuted),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                    color: selected ? widget.accentColor : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  )),
            ],
          ),
        ),
      );
    }).toList(),
  );
}
