import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/calendar_event.dart';
import '../services/event_storage.dart';
import '../utils/rokuyo.dart';
import '../utils/lunar_calendar.dart';
import 'add_event_screen.dart';

class EventDetailScreen extends StatelessWidget {
  final CalendarEvent event;
  const EventDetailScreen({super.key, required this.event});

  Future<void> _delete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('予定を削除'),
        content: const Text('この予定を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await EventStorage.deleteEvent(event.id);
      if (context.mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rokuyo = Rokuyo.fromDate(event.date);
    final lunar = LunarCalendar.fromGregorian(event.date);

    return Scaffold(
      appBar: AppBar(
        title: const Text('予定の詳細'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEventScreen(
                    initialDate: event.date,
                    existingEvent: event,
                  ),
                ),
              );
              if (result == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _delete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 日付カード
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5A2B), Color(0xFFA67C52)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('yyyy年 M月 d日 (E)', 'ja_JP').format(event.date),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '旧暦 ${lunar.month}月${lunar.day}日${lunar.isLeap ? '(閏)' : ''}  ・  六曜：$rokuyo',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // タイトル
            const Text('タイトル',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF8B5A2B))),
            const SizedBox(height: 6),
            Text(event.title,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4037))),
            const SizedBox(height: 20),
            // メモ
            if (event.description.isNotEmpty) ...[
              const Text('メモ',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF8B5A2B))),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  event.description,
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
