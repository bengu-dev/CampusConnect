import 'package:campus_project/core/app_theme.dart';
import 'package:campus_project/models/note_model.dart';
import 'package:campus_project/services/api_service.dart';
import 'package:flutter/material.dart';

class NotesScreen extends StatefulWidget {
  final Color accentColor;

  const NotesScreen({super.key, required this.accentColor});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<NoteModel> _notes     = [];
  bool            _isLoading = true;
  String?         _errorMsg;
  NoteCategory?   _filterCat; // null = tümü

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _errorMsg = null; });
    final res = await ApiService.getNotes();
    if (!mounted) return;
    if (res['success'] == true) {
      final raw = (res['notes'] as List? ?? []);
      setState(() {
        _notes     = raw.map((e) => NoteModel.fromMap(Map<String, dynamic>.from(e))).toList();
        _isLoading = false;
      });
    } else {
      setState(() { _errorMsg = res['message']; _isLoading = false; });
    }
  }

  List<NoteModel> get _filtered {
    if (_filterCat == null) return _notes;
    return _notes.where((n) => n.category == _filterCat).toList();
  }

  // ── Add / Edit sheet ─────────────────────────────────────────────────────

  Future<void> _openForm({NoteModel? note}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NoteFormSheet(
        existing:    note,
        accentColor: widget.accentColor,
        onSaved:     _load,
      ),
    );
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> _delete(NoteModel note) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Notu Sil',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        content: Text('"${note.title}" notunu silmek istiyor musun?',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('İptal', style: TextStyle(color: AppColors.textMuted))),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sil', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    final res = await ApiService.deleteNote(note.id);
    if (!mounted) return;
    if (res['success'] == true) {
      _load();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Not silindi'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        title: const Text('Notlarım',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
            onPressed: _load,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: widget.accentColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Not Ekle',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_errorMsg != null)
            _buildError()
          else if (_filtered.isEmpty)
            _buildEmpty()
          else
            Expanded(child: _buildList()),
        ],
      ),
    );
  }

  // ── Kategori filtre barı ──────────────────────────────────────────────────

  Widget _buildCategoryFilter() {
    final cats = [null, NoteCategory.personal, NoteCategory.work, NoteCategory.social];
    return Container(
      height: 52,
      color: AppColors.bgLight,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: cats.map((cat) {
          final isSelected = _filterCat == cat;
          final label      = cat?.label ?? 'Tümü';
          final color      = cat?.color ?? widget.accentColor;
          return GestureDetector(
            onTap: () => setState(() => _filterCat = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isSelected ? color : Colors.transparent,
                border: Border.all(color: isSelected ? color : AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (cat != null) ...[
                    Icon(cat.icon, size: 13,
                        color: isSelected ? Colors.white : color),
                    const SizedBox(width: 5),
                  ],
                  Text(label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      )),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Notlar listesi ────────────────────────────────────────────────────────

  Widget _buildList() {
    return RefreshIndicator(
      color: widget.accentColor,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
        itemCount: _filtered.length,
        itemBuilder: (ctx, i) {
          final note = _filtered[i];
          return _NoteCard(
            note: note,
            onEdit:   () => _openForm(note: note),
            onDelete: () => _delete(note),
          );
        },
      ),
    );
  }

  Widget _buildError() => Expanded(
    child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.wifi_off_rounded, color: AppColors.textMuted, size: 52),
      const SizedBox(height: 16),
      Text(_errorMsg!, style: const TextStyle(color: AppColors.textSecondary),
          textAlign: TextAlign.center),
      const SizedBox(height: 20),
      TextButton(onPressed: _load,
          child: Text('Tekrar Dene', style: TextStyle(color: widget.accentColor))),
    ])),
  );

  Widget _buildEmpty() => Expanded(
    child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.note_alt_outlined, color: AppColors.textHint, size: 64),
      const SizedBox(height: 16),
      Text(
        _filterCat != null ? '${_filterCat!.label} notun yok.' : 'Henüz not eklemedin.',
        style: const TextStyle(color: AppColors.textMuted, fontSize: 16),
      ),
    ])),
  );
}

// ─────────────────────────────────────────────
// NOT KARTI
// ─────────────────────────────────────────────

class _NoteCard extends StatelessWidget {
  final NoteModel    note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _NoteCard({required this.note, required this.onEdit, required this.onDelete});

  String _formatDate(DateTime dt) {
    final now  = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Az önce';
    if (diff.inHours   < 1) return '${diff.inMinutes}dk önce';
    if (diff.inDays    < 1) return '${diff.inHours}sa önce';
    if (diff.inDays    < 7) return '${diff.inDays}g önce';
    return '${dt.day}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cat = note.category;
    return GestureDetector(
      onTap: onEdit,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.bgCard,
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(color: note.color.withAlpha(18), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Renk bandı
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: note.color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: cat.bgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(cat.icon, size: 11, color: cat.color),
                            const SizedBox(width: 4),
                            Text(cat.label,
                                style: TextStyle(color: cat.color, fontSize: 11, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(_formatDate(note.updatedAt),
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onDelete,
                        child: const Icon(Icons.delete_outline_rounded,
                            size: 18, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(note.title,
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (note.content.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(note.content,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13, height: 1.5),
                        maxLines: 3, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// NOT FORMU — BottomSheet
// ─────────────────────────────────────────────

class _NoteFormSheet extends StatefulWidget {
  final NoteModel? existing;
  final Color      accentColor;
  final VoidCallback onSaved;

  const _NoteFormSheet({this.existing, required this.accentColor, required this.onSaved});

  @override
  State<_NoteFormSheet> createState() => _NoteFormSheetState();
}

class _NoteFormSheetState extends State<_NoteFormSheet> {
  final _titleCtrl   = TextEditingController();
  final _contentCtrl = TextEditingController();
  NoteCategory _category = NoteCategory.personal;
  Color        _color    = kNoteColors[0];
  bool         _isSaving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _titleCtrl.text   = e.title;
      _contentCtrl.text = e.content;
      _category         = e.category;
      _color            = e.color;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  String _colorToHex(Color c) {
    final r = c.r.round().toRadixString(16).padLeft(2, '0');
    final g = c.g.round().toRadixString(16).padLeft(2, '0');
    final b = c.b.round().toRadixString(16).padLeft(2, '0');
    return '#$r$g$b';
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Başlık boş bırakılamaz!'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _isSaving = true);

    final Map<String, dynamic> res;
    final colorHex = _colorToHex(_color);

    if (widget.existing != null) {
      res = await ApiService.updateNote(
        id:       widget.existing!.id,
        title:    _titleCtrl.text.trim(),
        content:  _contentCtrl.text.trim(),
        category: _category.apiValue,
        color:    colorHex,
      );
    } else {
      res = await ApiService.createNote(
        title:    _titleCtrl.text.trim(),
        content:  _contentCtrl.text.trim(),
        category: _category.apiValue,
        color:    colorHex,
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (res['success'] == true) {
      Navigator.pop(context);
      widget.onSaved();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res['message'] ?? 'Hata oluştu!'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize:     0.5,
      maxChildSize:     0.95,
      expand: false,
      builder: (_, sc) => Container(
        decoration: const BoxDecoration(
          color: AppColors.bgLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Text(isEdit ? 'Notu Düzenle' : 'Yeni Not',
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  TextButton(
                    onPressed: _isSaving ? null : _save,
                    style: TextButton.styleFrom(
                      backgroundColor: widget.accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: _isSaving
                        ? const SizedBox(width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(isEdit ? 'Kaydet' : 'Ekle',
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),

            // Scrollable form
            Expanded(
              child: ListView(
                controller: sc,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  // Başlık
                  _label('Başlık'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleCtrl,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                    decoration: _inputDecoration('Not başlığı…'),
                  ),
                  const SizedBox(height: 16),

                  // İçerik
                  _label('İçerik'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _contentCtrl,
                    maxLines: 5,
                    minLines: 3,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.5),
                    decoration: _inputDecoration('Notunu buraya yaz…'),
                  ),
                  const SizedBox(height: 16),

                  // Kategori
                  _label('Kategori'),
                  const SizedBox(height: 10),
                  _categorySelector(),
                  const SizedBox(height: 16),

                  // Renk
                  _label('Not Rengi'),
                  const SizedBox(height: 10),
                  _colorPicker(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600));

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
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
        borderSide: BorderSide(color: widget.accentColor, width: 1.5)),
    contentPadding: const EdgeInsets.all(14),
  );

  Widget _categorySelector() {
    final cats = NoteCategory.values;
    return Row(
      children: cats.map((cat) {
        final selected = _category == cat;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _category = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: EdgeInsets.only(right: cat != cats.last ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: selected ? cat.color.withAlpha(25) : AppColors.bgSurface,
                border: Border.all(
                    color: selected ? cat.color : AppColors.border,
                    width: selected ? 1.5 : 1),
              ),
              child: Column(
                children: [
                  Icon(cat.icon, size: 18, color: selected ? cat.color : AppColors.textMuted),
                  const SizedBox(height: 4),
                  Text(cat.label,
                      style: TextStyle(
                        color: selected ? cat.color : AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                      )),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _colorPicker() => Wrap(
    spacing: 10,
    runSpacing: 10,
    children: kNoteColors.map((c) {
      final isSelected = _color.value == c.value;
      return GestureDetector(
        onTap: () => setState(() => _color = c),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 36, height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: c,
            border: Border.all(
              color: isSelected ? AppColors.textPrimary : Colors.transparent,
              width: 2.5,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: c.withAlpha(80), blurRadius: 8, spreadRadius: 2)]
                : [],
          ),
          child: isSelected
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
              : null,
        ),
      );
    }).toList(),
  );
}
