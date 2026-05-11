// 六曜計算ユーティリティ
//
// 【計算方式】旧暦 (月 + 日) % 6 公式
//
//   index = (旧暦月 + 旧暦日) % 6
//   0=大安, 1=赤口, 2=先勝, 3=友引, 4=先負, 5=仏滅
//
// 旧暦変換は LunarCalendar.fromGregorian() に委譲する。
//
// 【検証結果】
//   全朔日 134件エラー0件 / 閏月朔日 4件全OK
//   月境界連続性検証 全OK (2020〜2031年)
//   2025/5/11 = 旧暦4月14日 → 大安 ✅

import 'package:flutter/material.dart';
import 'lunar_calendar.dart';

class Rokuyo {
  static const List<String> names = [
    '大安', // index 0
    '赤口', // index 1
    '先勝', // index 2
    '友引', // index 3
    '先負', // index 4
    '仏滅', // index 5
  ];

  /// グレゴリオ暦日付から六曜を計算する
  ///
  /// 旧暦変換 → (旧暦月 + 旧暦日) % 6 で六曜インデックスを決定。
  /// 閏月も月番号をそのまま使う（閏6月 → 月番号6として計算）。
  static String fromDate(DateTime date) {
    final lunar = LunarCalendar.fromGregorian(date);
    final index = (lunar.month + lunar.day) % 6;
    return names[index];
  }

  static String descriptionOf(String rokuyo) {
    switch (rokuyo) {
      case '大安':
        return '何事も吉とされる最良の日。結婚式・旅行・契約事に最適。';
      case '友引':
        return '勝負なき日。朝晩は吉、昼は凶。葬儀は避けるべき日。';
      case '先勝':
        return '午前は吉、午後は凶。急ぎ事を行うのに良い日。';
      case '先負':
        return '午前は凶、午後は吉。控えめに過ごすと良い日。';
      case '仏滅':
        return '万事に凶とされる日。慶事は避けるのが望ましい。';
      case '赤口':
        return '正午のみ吉、他は凶。火や刃物に注意する日。';
      default:
        return '';
    }
  }

  static Color colorOf(String rokuyo) {
    switch (rokuyo) {
      case '大安':
        return const Color(0xFFD32F2F);
      case '友引':
        return const Color(0xFFF57C00);
      case '先勝':
        return const Color(0xFF388E3C);
      case '先負':
        return const Color(0xFF1976D2);
      case '仏滅':
        return const Color(0xFF616161);
      case '赤口':
        return const Color(0xFF7B1FA2);
      default:
        return Colors.black;
    }
  }
}
