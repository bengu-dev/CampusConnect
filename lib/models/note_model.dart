import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// NOT KATEGORİSİ (EventCategory ile aynı enum)
// ─────────────────────────────────────────────

enum NoteCategory {
  personal,
  work,
  social;

  String get label {
    switch (this) {
      case NoteCategory.personal: return 'Kişisel';
      case NoteCategory.work:     return 'İş';
      case NoteCategory.social:   return 'Sosyal';
    }
  }

  Color get color {
    switch (this) {
      case NoteCategory.personal: return const Color(0xFFEC4899);
      case NoteCategory.work:     return const Color(0xFF3B82F6);
      case NoteCategory.social:   return const Color(0xFF10B981);
    }
  }

  Color get bgColor => color.withAlpha(25);

  IconData get icon {
    switch (this) {
      case NoteCategory.personal: return Icons.person_rounded;
      case NoteCategory.work:     return Icons.work_rounded;
      case NoteCategory.social:   return Icons.people_rounded;
    }
  }

  static NoteCategory fromString(String? v) {
    switch (v?.toUpperCase()) {
      case 'WORK':   return NoteCategory.work;
      case 'SOCIAL': return NoteCategory.social;
      default:       return NoteCategory.personal;
    }
  }

  String get apiValue => name.toUpperCase();
}

// ─────────────────────────────────────────────
// NOTE MODEL
// ─────────────────────────────────────────────

class NoteModel {
  final int          id;
  final String       title;
  final String       content;
  final NoteCategory category;
  final Color        color;
  final DateTime     createdAt;
  final DateTime     updatedAt;

  const NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id:        (map['id'] as num?)?.toInt() ?? 0,
      title:     map['title']?.toString() ?? '',
      content:   map['content']?.toString() ?? '',
      category:  NoteCategory.fromString(map['category']?.toString()),
      color:     _hexToColor(map['color']?.toString()),
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  NoteModel copyWith({
    String?       title,
    String?       content,
    NoteCategory? category,
    Color?        color,
  }) {
    return NoteModel(
      id:        id,
      title:     title     ?? this.title,
      content:   content   ?? this.content,
      category:  category  ?? this.category,
      color:     color     ?? this.color,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  String get colorHex {
    final r = color.r.round().toRadixString(16).padLeft(2, '0');
    final g = color.g.round().toRadixString(16).padLeft(2, '0');
    final b = color.b.round().toRadixString(16).padLeft(2, '0');
    return '#$r$g$b';
  }

  static Color _hexToColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFF6366F1);
    final clean = hex.replaceAll('#', '');
    if (clean.length == 6) {
      return Color(int.parse('FF$clean', radix: 16));
    }
    return const Color(0xFF6366F1);
  }
}

// Seçilebilir not renkleri
const List<Color> kNoteColors = [
  Color(0xFF6366F1), // indigo
  Color(0xFFEC4899), // pembe
  Color(0xFF3B82F6), // mavi
  Color(0xFF10B981), // yeşil
  Color(0xFFF59E0B), // sarı
  Color(0xFFEF4444), // kırmızı
  Color(0xFF8B5CF6), // mor
  Color(0xFF06B6D4), // cyan
  Color(0xFF64748B), // gri
];
