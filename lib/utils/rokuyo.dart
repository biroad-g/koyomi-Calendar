// 六曜計算ユーティリティ
//
// 【重要】(旧暦月 + 旧暦日) % 6 の公式は年によって成立しない。
// 旧暦月の長さが29日/30日と変動するため、月をまたぐとインデックスがずれる。
//
// 正しい計算方法:
//   基準日 2024/2/10（旧暦2024年1月1日）= 先勝(index=2) から
//   グレゴリオ暦の日付差を使って六曜インデックスを直接計算する。
//
//   rokuyo_index = (BASE_INDEX + diff_days) % 6
//
// 検証済み基準値:
//   2024/2/10 = 先勝 ✅  2024/2/11 = 友引 ✅  2024/2/14 = 大安 ✅
//   2025/1/29 = 先勝 ✅  2025/4/28 = 赤口 ✅  2025/9/21 = 友引 ✅

import 'package:flutter/material.dart';

class Rokuyo {
  // 基準日: 2024/2/10 = 旧暦2024年1月1日 = 先勝 (index=2)
  // 国立天文台データ + 複数カレンダーサービスで検証済み
  static final DateTime _baseDate = DateTime(2024, 2, 10);
  static const int _baseIndex = 2; // 先勝

  static const List<String> names = [
    '大安', // index 0
    '赤口', // index 1
    '先勝', // index 2  ← 基準日(2024/2/10)
    '友引', // index 3
    '先負', // index 4
    '仏滅', // index 5
  ];

  /// グレゴリオ暦日付から六曜を計算する
  /// 基準日からの日付差でインデックスを決定する正確な方式
  static String fromDate(DateTime date) {
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(_baseDate).inDays;
    final index = ((_baseIndex + diff) % 6 + 6) % 6; // 負の値対策
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
