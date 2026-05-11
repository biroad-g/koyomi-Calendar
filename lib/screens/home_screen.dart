import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/calendar_event.dart';
import '../services/event_storage.dart';
import '../utils/rokuyo.dart';
import '../utils/lunar_calendar.dart';
import '../utils/buddhist_events.dart';
import '../utils/sekki.dart';
import 'add_event_screen.dart';
import 'event_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<CalendarEvent> _userEvents = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await EventStorage.loadEvents();
    setState(() {
      _userEvents = events;
    });
  }

  List<CalendarEvent> _getEventsForDay(DateTime day) {
    return _userEvents
        .where((e) =>
            e.date.year == day.year &&
            e.date.month == day.month &&
            e.date.day == day.day)
        .toList();
  }

  bool _hasBuddhistEvent(DateTime day) {
    return BuddhistEvents.getEventsForDate(day).isNotEmpty;
  }

  bool _hasSekki(DateTime day) {
    return Sekki.getSekkiForDate(day) != null;
  }

  @override
  Widget build(BuildContext context) {
    final selectedDay = _selectedDay ?? DateTime.now();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'こよみ Calendar',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: '今日',
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCalendar(),
          const Divider(height: 1),
          Expanded(child: _buildDayInfo(selectedDay)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF8B5A2B),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('予定追加'),
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => AddEventScreen(initialDate: selectedDay),
            ),
          );
          if (result == true) {
            _loadEvents();
          }
        },
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar<CalendarEvent>(
        locale: 'ja_JP',
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        eventLoader: _getEventsForDay,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekendStyle: TextStyle(color: Color(0xFFD32F2F)),
        ),
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5D4037),
          ),
          leftChevronIcon:
              const Icon(Icons.chevron_left, color: Color(0xFF8B5A2B)),
          rightChevronIcon:
              const Icon(Icons.chevron_right, color: Color(0xFF8B5A2B)),
          titleTextFormatter: (date, locale) =>
              DateFormat('yyyy年 M月', locale).format(date),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: const TextStyle(color: Color(0xFFD32F2F)),
          selectedDecoration: const BoxDecoration(
            color: Color(0xFF8B5A2B),
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: const Color(0xFF8B5A2B).withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: Color(0xFFD4A574),
            shape: BoxShape.circle,
          ),
        ),
        onDaySelected: (selected, focused) {
          setState(() {
            _selectedDay = selected;
            _focusedDay = focused;
          });
        },
        onPageChanged: (focused) {
          _focusedDay = focused;
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            return _buildCalendarCell(day,
                isSelected: false, isToday: false);
          },
          selectedBuilder: (context, day, focusedDay) {
            return _buildCalendarCell(day,
                isSelected: true, isToday: false);
          },
          todayBuilder: (context, day, focusedDay) {
            return _buildCalendarCell(day,
                isSelected: false, isToday: true);
          },
        ),
      ),
    );
  }

  Widget _buildCalendarCell(DateTime day,
      {required bool isSelected, required bool isToday}) {
    final rokuyo = Rokuyo.fromDate(day);
    final isBuddhist = _hasBuddhistEvent(day);
    final isSekki = _hasSekki(day);

    Color textColor = Colors.black87;
    if (day.weekday == DateTime.sunday) textColor = const Color(0xFFD32F2F);
    if (day.weekday == DateTime.saturday) textColor = const Color(0xFF1976D2);
    if (isSelected) textColor = Colors.white;

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF8B5A2B)
            : isToday
                ? const Color(0xFF8B5A2B).withValues(alpha: 0.15)
                : null,
        borderRadius: BorderRadius.circular(8),
        border: isBuddhist
            ? Border.all(color: const Color(0xFFD4A574), width: 1.5)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 14,
              fontWeight:
                  isBuddhist || isToday ? FontWeight.bold : FontWeight.normal,
              color: textColor,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            rokuyo,
            style: TextStyle(
              fontSize: 9,
              color: isSelected
                  ? Colors.white70
                  : Rokuyo.colorOf(rokuyo).withValues(alpha: 0.85),
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isSekki)
            Text(
              Sekki.getSekkiForDate(day)!,
              style: TextStyle(
                fontSize: 8,
                color: isSelected
                    ? Colors.amberAccent
                    : const Color(0xFF6D4C41),
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDayInfo(DateTime day) {
    final rokuyo = Rokuyo.fromDate(day);
    final lunar = LunarCalendar.fromGregorian(day);
    final buddhistEvents = BuddhistEvents.getEventsForDate(day);
    final sekki = Sekki.getSekkiForDate(day);
    final userEvents = _getEventsForDay(day);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 日付ヘッダー
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5A2B), Color(0xFFA67C52)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('yyyy年 M月 d日 (E)', 'ja_JP').format(day),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '旧暦 ${lunar.month}月${lunar.day}日${lunar.isLeap ? '(閏)' : ''}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    rokuyo,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Rokuyo.colorOf(rokuyo),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 六曜の説明
          _infoCard(
            icon: Icons.brightness_5,
            iconColor: Rokuyo.colorOf(rokuyo),
            title: '六曜：$rokuyo',
            content: Rokuyo.descriptionOf(rokuyo),
          ),
          // 二十四節気
          if (sekki != null)
            _infoCard(
              icon: Icons.local_florist,
              iconColor: const Color(0xFF6D4C41),
              title: '二十四節気：$sekki',
              content: Sekki.descriptions[sekki] ?? '',
            ),
          // お寺の年中行事
          ...buddhistEvents.map(
            (e) => _infoCard(
              icon: e.isMajor ? Icons.temple_buddhist : Icons.spa,
              iconColor: const Color(0xFFD4A574),
              title: e.name,
              content: e.description,
              isMajor: e.isMajor,
            ),
          ),
          // ユーザー予定
          if (userEvents.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.event_note, color: Color(0xFF8B5A2B)),
                  SizedBox(width: 8),
                  Text(
                    'マイ予定',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                ],
              ),
            ),
            ...userEvents.map((e) => _userEventCard(e)),
          ],
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    bool isMajor = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isMajor ? const Color(0xFFD4A574) : Colors.grey.shade300,
          width: isMajor ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4037),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _userEventCard(CalendarEvent event) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => EventDetailScreen(event: event),
          ),
        );
        if (result == true) {
          _loadEvents();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF8B5A2B), width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.event, color: Color(0xFF8B5A2B), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  if (event.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      event.description,
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF8B5A2B)),
          ],
        ),
      ),
    );
  }
}
