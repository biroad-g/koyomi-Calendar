import 'package:shared_preferences/shared_preferences.dart';
import '../models/calendar_event.dart';

class EventStorage {
  static const String _key = 'temple_calendar_events';

  static Future<List<CalendarEvent>> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final source = prefs.getString(_key);
    if (source == null || source.isEmpty) return [];
    try {
      return CalendarEvent.decodeList(source);
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveEvents(List<CalendarEvent> events) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, CalendarEvent.encodeList(events));
  }

  static Future<void> addEvent(CalendarEvent event) async {
    final events = await loadEvents();
    events.add(event);
    await saveEvents(events);
  }

  static Future<void> updateEvent(CalendarEvent event) async {
    final events = await loadEvents();
    final index = events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      events[index] = event;
      await saveEvents(events);
    }
  }

  static Future<void> deleteEvent(String id) async {
    final events = await loadEvents();
    events.removeWhere((e) => e.id == id);
    await saveEvents(events);
  }
}
