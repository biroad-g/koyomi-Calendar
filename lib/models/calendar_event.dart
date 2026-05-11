import 'dart:convert';

class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final EventType type;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.type = EventType.user,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'date': date.toIso8601String(),
        'type': type.index,
      };

  factory CalendarEvent.fromJson(Map<String, dynamic> json) => CalendarEvent(
        id: json['id'],
        title: json['title'],
        description: json['description'] ?? '',
        date: DateTime.parse(json['date']),
        type: EventType.values[json['type'] ?? 0],
      );

  static String encodeList(List<CalendarEvent> events) =>
      jsonEncode(events.map((e) => e.toJson()).toList());

  static List<CalendarEvent> decodeList(String source) =>
      (jsonDecode(source) as List)
          .map((e) => CalendarEvent.fromJson(e))
          .toList();
}

enum EventType {
  user,       // ユーザー追加の予定
  buddhist,   // 仏教行事
  rokuyo,     // 六曜
  sekki,      // 二十四節気
}
