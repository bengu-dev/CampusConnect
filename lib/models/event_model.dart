import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// ETKİNLİK KATEGORİSİ ENUM
// Kişisel (pembe) · İş (mavi) · Sosyal (yeşil)
// ─────────────────────────────────────────────

enum EventCategory {
  personal,
  work,
  social;

  String get label {
    switch (this) {
      case EventCategory.personal: return 'Kişisel';
      case EventCategory.work:     return 'İş';
      case EventCategory.social:   return 'Sosyal';
    }
  }

  /// Soft/pastel ana renk
  Color get color {
    switch (this) {
      case EventCategory.personal: return const Color(0xFFEC4899); // pembe
      case EventCategory.work:     return const Color(0xFF3B82F6); // mavi
      case EventCategory.social:   return const Color(0xFF10B981); // yeşil
    }
  }

  /// Kart arka planı için çok hafif ton
  Color get bgColor => color.withAlpha(22);

  IconData get icon {
    switch (this) {
      case EventCategory.personal: return Icons.person_rounded;
      case EventCategory.work:     return Icons.work_rounded;
      case EventCategory.social:   return Icons.people_rounded;
    }
  }

  static EventCategory fromString(String? v) {
    switch (v?.toUpperCase()) {
      case 'WORK':   return EventCategory.work;
      case 'SOCIAL': return EventCategory.social;
      default:       return EventCategory.personal;
    }
  }

  String get apiValue => name.toUpperCase();
}

// ─────────────────────────────────────────────
// EVENT MODEL
// ─────────────────────────────────────────────

class EventModel {
  final String        id;
  final String        title;
  final String        description;
  final DateTime      date;
  final EventCategory category;

  /// Kişisel mi (kullanıcının eklediği) yoksa kampüs etkinliği mi
  final bool isPersonal;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.category,
    this.isPersonal = true,
  });

  /// Backend'den gelen kampüs etkinliği map'i → EventModel
  factory EventModel.fromSchoolMap(Map<String, dynamic> map) {
    // Kampüs etkinlikleri için eventType → category mapping
    final eventType = map['eventType']?.toString() ?? map['event_type']?.toString() ?? '';
    EventCategory cat;
    switch (eventType.toUpperCase()) {
      case 'CAREER':
      case 'TECH':
      case 'ACADEMIC':
        cat = EventCategory.work;
        break;
      case 'SPORTS':
      case 'CEREMONY':
        cat = EventCategory.social;
        break;
      default:
        cat = EventCategory.personal;
    }

    return EventModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      date: DateTime.tryParse(
            map['startDatetime']?.toString() ??
            map['start_datetime']?.toString() ?? '') ??
          DateTime.now(),
      category: cat,
      isPersonal: false,
    );
  }

  /// Kişisel etkinlik → EventModel
  factory EventModel.personal({
    required String id,
    required String title,
    required String description,
    required DateTime date,
    required EventCategory category,
  }) {
    return EventModel(
      id: id,
      title: title,
      description: description,
      date: date,
      category: category,
      isPersonal: true,
    );
  }

  /// Aynı gün mü kontrolü (takvim marker'ları için)
  bool isSameDay(DateTime other) =>
      date.year == other.year &&
      date.month == other.month &&
      date.day == other.day;
}
