import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/calendar_event.dart';
import '../services/event_storage.dart';

class AddEventScreen extends StatefulWidget {
  final DateTime initialDate;
  final CalendarEvent? existingEvent;

  const AddEventScreen({
    super.key,
    required this.initialDate,
    this.existingEvent,
  });

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.existingEvent?.date ?? widget.initialDate;
    if (widget.existingEvent != null) {
      _titleController.text = widget.existingEvent!.title;
      _descController.text = widget.existingEvent!.description;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('ja', 'JP'),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('タイトルを入力してください')),
      );
      return;
    }

    if (widget.existingEvent != null) {
      final updated = CalendarEvent(
        id: widget.existingEvent!.id,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        date: _selectedDate,
        type: EventType.user,
      );
      await EventStorage.updateEvent(updated);
    } else {
      final newEvent = CalendarEvent(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        date: _selectedDate,
        type: EventType.user,
      );
      await EventStorage.addEvent(newEvent);
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingEvent != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '予定を編集' : '予定を追加'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('日付',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF5D4037))),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF8B5A2B)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        color: Color(0xFF8B5A2B)),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('yyyy年 M月 d日 (E)', 'ja_JP')
                          .format(_selectedDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('タイトル',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF5D4037))),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: '例：法要、お墓参り、お寺参拝...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF8B5A2B)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                      color: Color(0xFF8B5A2B), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('メモ',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF5D4037))),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: '詳細やメモを入力',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF8B5A2B)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                      color: Color(0xFF8B5A2B), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: Icon(isEditing ? Icons.save : Icons.add),
                label: Text(isEditing ? '更新する' : '追加する'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5A2B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
