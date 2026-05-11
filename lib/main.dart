import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ja_JP', null);
  runApp(const TempleCalendarApp());
}

class TempleCalendarApp extends StatelessWidget {
  const TempleCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'こよみ Calendar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5A2B),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF8E7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF8B5A2B),
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),
        fontFamily: 'sans-serif',
      ),
      home: const HomeScreen(),
    );
  }
}
