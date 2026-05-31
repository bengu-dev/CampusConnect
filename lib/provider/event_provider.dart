import 'dart:convert';

import 'package:campus_project/models/event_model.dart';
import 'package:campus_project/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────
// EVENT PROVIDER
// Tüm etkinlik state'ini yönetir.
// Hem EventsScreen hem CalendarScreen bu
// provider'ı dinler → gerçek zamanlı senkron.
// ─────────────────────────────────────────────

enum EventLoadState { idle, loading, error, loaded }

const _kPersonalEventsKey = 'personal_events_v1';

class EventProvider extends ChangeNotifier {
  // ── State ─────────────────────────────────────────────────────────────────

  final List<EventModel> _events = [];
  EventLoadState _loadState      = EventLoadState.idle;
  String?        _errorMessage;

  final Map<String, Map<String, dynamic>> _schoolEventMeta = {};

  // ── Getters ───────────────────────────────────────────────────────────────

  EventLoadState get loadState    => _loadState;
  String?        get errorMessage => _errorMessage;

  bool get isInitialLoading =>
      _loadState == EventLoadState.loading && _events.isEmpty;

  bool get isRefreshing =>
      _loadState == EventLoadState.loading && _events.isNotEmpty;

  bool get isLoading => _loadState == EventLoadState.loading;
  bool get hasError  => _loadState == EventLoadState.error;

  List<EventModel> get allEvents {
    final now  = DateTime.now();
    final upcoming = _events
        .where((e) => !e.date.isBefore(
            DateTime(now.year, now.month, now.day)))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final past = _events
        .where((e) => e.date.isBefore(
            DateTime(now.year, now.month, now.day)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return [...upcoming, ...past];
  }

  List<EventModel> get personalEvents =>
      allEvents.where((e) => e.isPersonal).toList();

  List<EventModel> get schoolEvents =>
      allEvents.where((e) => !e.isPersonal).toList();

  List<EventModel> eventsForDay(DateTime day) =>
      allEvents.where((e) => e.isSameDay(day)).toList();

  List<EventCategory> categoriesForDay(DateTime day) =>
      eventsForDay(day).map((e) => e.category).toSet().toList();

  Map<String, dynamic>? schoolMeta(String eventId) => _schoolEventMeta[eventId];

  // ── Kalıcı Kayıt (SharedPreferences) ─────────────────────────────────────

  Future<void> _savePersonalEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _events
          .where((e) => e.isPersonal)
          .map((e) => {
                'id':          e.id,
                'title':       e.title,
                'description': e.description,
                'date':        e.date.toIso8601String(),
                'category':    e.category.name,
              })
          .toList();
      await prefs.setString(_kPersonalEventsKey, jsonEncode(list));
    } catch (e) {
      debugPrint('Kisisel etkinlikler kaydedilemedi: $e');
    }
  }

  Future<void> loadPersonalEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw   = prefs.getString(_kPersonalEventsKey);
      if (raw == null || raw.isEmpty) return;

      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      for (final map in list) {
        final id = map['id']?.toString() ?? '';
        if (_events.any((e) => e.id == id)) continue;

        _events.add(EventModel.personal(
          id:          id,
          title:       map['title']?.toString() ?? '',
          description: map['description']?.toString() ?? '',
          date:        DateTime.tryParse(map['date']?.toString() ?? '') ??
                       DateTime.now(),
          category:    EventCategory.values.firstWhere(
            (c) => c.name == map['category'],
            orElse: () => EventCategory.personal,
          ),
        ));
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Kisisel etkinlikler yuklenemedi: $e');
    }
  }

  // ── Veri Yükleme ──────────────────────────────────────────────────────────

  Future<void> loadFromBackend() async {
    _loadState    = EventLoadState.loading;
    _errorMessage = null;
    notifyListeners();

    // Kişisel etkinlikleri önce yükle (henüz yüklenmemişse)
    if (_events.where((e) => e.isPersonal).isEmpty) {
      await loadPersonalEvents();
    }

    final result = await ApiService.getEvents();

    if (result['success'] != true) {
      _loadState    = EventLoadState.error;
      _errorMessage = result['message']?.toString() ?? 'Baglanti hatasi!';
      notifyListeners();
      return;
    }

    final raw = (result['events'] as List? ?? []);

    _events.removeWhere((e) => !e.isPersonal);
    _schoolEventMeta.clear();

    for (final item in raw) {
      final map   = Map<String, dynamic>.from(item);
      final model = EventModel.fromSchoolMap(map);
      _events.add(model);

      _schoolEventMeta[model.id] = {
        'isJoined':         map['isJoined'] as bool? ?? map['is_joined'] as bool? ?? false,
        'participantCount': (map['participantCount'] ?? map['participant_count'] ?? 0) as int,
        'capacity':         (map['capacity'] ?? 100) as int,
        'eventType':        map['eventType']?.toString() ?? map['event_type']?.toString() ?? 'GENERAL',
        'location':         map['location']?.toString() ?? '',
        'organizerName':    map['organizerName']?.toString() ?? map['organizer_name']?.toString() ?? '',
        'endDatetime':      map['endDatetime']?.toString() ?? map['end_datetime']?.toString(),
        'rawMap':           map,
      };
    }

    _loadState = EventLoadState.loaded;
    notifyListeners();
  }

  // ── Kişisel Etkinlik ──────────────────────────────────────────────────────

  Future<void> addPersonalEvent({
    required String        title,
    required String        description,
    required DateTime      date,
    required EventCategory category,
  }) async {
    final event = EventModel.personal(
      id:          'personal_${DateTime.now().millisecondsSinceEpoch}',
      title:       title,
      description: description,
      date:        date,
      category:    category,
    );
    _events.add(event);
    notifyListeners();
    await _savePersonalEvents();
  }

  Future<void> removePersonalEvent(String id) async {
    _events.removeWhere((e) => e.id == id && e.isPersonal);
    notifyListeners();
    await _savePersonalEvents();
  }

  // ── Kampüs Etkinliği Katılım ──────────────────────────────────────────────

  Future<bool> joinEvent(String eventId) async {
    final idInt = int.tryParse(eventId);
    if (idInt == null) return false;
    final result = await ApiService.joinEvent(idInt);
    if (result['success'] == true) {
      final meta = _schoolEventMeta[eventId];
      if (meta != null) {
        meta['isJoined']         = true;
        meta['participantCount'] = (meta['participantCount'] as int) + 1;
        notifyListeners();
      }
      return true;
    }
    return false;
  }

  Future<bool> leaveEvent(String eventId) async {
    final idInt = int.tryParse(eventId);
    if (idInt == null) return false;
    final result = await ApiService.leaveEvent(idInt);
    if (result['success'] == true) {
      final meta = _schoolEventMeta[eventId];
      if (meta != null) {
        meta['isJoined']         = false;
        meta['participantCount'] = ((meta['participantCount'] as int) - 1).clamp(0, 9999);
        notifyListeners();
      }
      return true;
    }
    return false;
  }

  Future<bool> createSchoolEvent(Map<String, dynamic> data) async {
    final result = await ApiService.createEvent(data);
    if (result['success'] == true) {
      await loadFromBackend();
      return true;
    }
    return false;
  }
}
