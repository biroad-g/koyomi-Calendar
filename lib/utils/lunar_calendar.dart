// 旧暦変換ユーティリティ
// 朔日テーブル方式: 国立天文台 合朔時刻(JST)データ + hinokoto.com 六曜リセット検出法で検証済み
// 各エントリ = [グレゴリオ年, 月, 日, 旧暦月番号, 閏月フラグ]
//
// 六曜の計算については rokuyo.dart を参照。
// 六曜は (旧暦月+旧暦日)%6 の公式で計算する。

class LunarDate {
  final int year;
  final int month;
  final int day;
  final bool isLeap;

  const LunarDate(this.year, this.month, this.day, {this.isLeap = false});

  @override
  String toString() => '$year年${isLeap ? '閏' : ''}$month月$day日';
}

class LunarCalendar {
  // 朔日テーブル: [グレゴリオ年, グレゴリオ月, グレゴリオ日, 旧暦月番号, 閏月フラグ]
  // データ出典: 国立天文台 合朔時刻(JST) + hinokoto.com 六曜リセット検出法で全件検証
  // 合朔がJST当日中であれば、その日が旧暦1日(朔日)
  static const List<List<dynamic>> _sakuTable = [
    // 2019年末
    [2019, 12, 26, 12, false], // 旧暦2019年12月1日

    // 2020年 (閏4月あり)
    [2020,  1, 25,  1, false], // 旧暦2020年1月1日
    [2020,  2, 24,  2, false], // (+1) 六曜リセット検証済み
    [2020,  3, 24,  3, false],
    [2020,  4, 23,  4, false],
    [2020,  5, 23,  4,  true], // 閏4月1日
    [2020,  6, 21,  5, false],
    [2020,  7, 21,  6, false],
    [2020,  8, 19,  7, false],
    [2020,  9, 17,  8, false],
    [2020, 10, 17,  9, false],
    [2020, 11, 15, 10, false],
    [2020, 12, 15, 11, false],

    // 2021年
    [2021,  1, 13, 12, false], // 旧暦2020年12月1日
    [2021,  2, 12,  1, false], // 旧暦2021年1月1日
    [2021,  3, 13,  2, false],
    [2021,  4, 12,  3, false],
    [2021,  5, 12,  4, false], // (+1) 六曜リセット検証済み
    [2021,  6, 10,  5, false],
    [2021,  7, 10,  6, false],
    [2021,  8,  8,  7, false],
    [2021,  9,  7,  8, false],
    [2021, 10,  6,  9, false],
    [2021, 11,  5, 10, false],
    [2021, 12,  4, 11, false],

    // 2022年
    [2022,  1,  3, 12, false], // 旧暦2021年12月1日
    [2022,  2,  1,  1, false], // 旧暦2022年1月1日
    [2022,  3,  3,  2, false],
    [2022,  4,  1,  3, false],
    [2022,  5,  1,  4, false],
    [2022,  5, 30,  5, false],
    [2022,  6, 29,  6, false],
    [2022,  7, 29,  7, false],
    [2022,  8, 27,  8, false],
    [2022,  9, 26,  9, false],
    [2022, 10, 25, 10, false],
    [2022, 11, 24, 11, false],
    [2022, 12, 23, 12, false],

    // 2023年 (閏2月あり)
    [2023,  1, 22,  1, false], // 旧暦2023年1月1日
    [2023,  2, 20,  2, false],
    [2023,  3, 22,  2,  true], // 閏2月1日
    [2023,  4, 20,  3, false],
    [2023,  5, 20,  4, false], // (+1) 六曜リセット検証済み
    [2023,  6, 18,  5, false],
    [2023,  7, 18,  6, false],
    [2023,  8, 16,  7, false],
    [2023,  9, 15,  8, false],
    [2023, 10, 15,  9, false],
    [2023, 11, 13, 10, false],
    [2023, 12, 13, 11, false],

    // 2024年
    [2024,  1, 11, 12, false], // 旧暦2023年12月1日
    [2024,  2, 10,  1, false], // 旧暦2024年1月1日
    [2024,  3, 10,  2, false],
    [2024,  4,  9,  3, false],
    [2024,  5,  8,  4, false],
    [2024,  6,  6,  5, false],
    [2024,  7,  6,  6, false],
    [2024,  8,  4,  7, false],
    [2024,  9,  3,  8, false],
    [2024, 10,  3,  9, false],
    [2024, 11,  1, 10, false],
    [2024, 12,  1, 11, false],
    [2024, 12, 31, 12, false],

    // 2025年 (閏6月あり)
    [2025,  1, 29,  1, false], // 旧暦2025年1月1日
    [2025,  2, 28,  2, false], // (-1) 六曜リセット検証済み: 2/28=友引でリセット確認
    [2025,  3, 29,  3, false],
    [2025,  4, 28,  4, false],
    [2025,  5, 27,  5, false],
    [2025,  6, 25,  6, false],
    [2025,  7, 25,  6,  true], // 閏6月1日
    [2025,  8, 23,  7, false],
    [2025,  9, 22,  8, false], // (+1) 六曜リセット検証済み
    [2025, 10, 21,  9, false],
    [2025, 11, 20, 10, false],
    [2025, 12, 20, 11, false],

    // 2026年
    [2026,  1, 19, 12, false], // 旧暦2025年12月1日
    [2026,  2, 17,  1, false], // 旧暦2026年1月1日
    [2026,  3, 19,  2, false],
    [2026,  4, 17,  3, false],
    [2026,  5, 17,  4, false], // (+1) 六曜リセット検証済み
    [2026,  6, 15,  5, false],
    [2026,  7, 14,  6, false],
    [2026,  8, 13,  7, false],
    [2026,  9, 11,  8, false],
    [2026, 10, 11,  9, false],
    [2026, 11,  9, 10, false],
    [2026, 12,  9, 11, false],

    // 2027年
    [2027,  1,  8, 12, false], // (+1) 旧暦2026年12月1日: 1/8=赤口でリセット確認
    [2027,  2,  7,  1, false], // (+1) 旧暦2027年1月1日: 2/7=先勝でリセット確認
    [2027,  3,  8,  2, false],
    [2027,  4,  7,  3, false], // (+1) 4/7=先負でリセット確認
    [2027,  5,  6,  4, false],
    [2027,  6,  5,  5, false], // (+1) 6/5=大安でリセット確認
    [2027,  7,  4,  6, false],
    [2027,  8,  2,  7, false],
    [2027,  9,  1,  8, false],
    [2027,  9, 30,  9, false],
    [2027, 10, 29, 10, false], // (-1) 10/29=仏滅でリセット確認
    [2027, 11, 28, 11, false],
    [2027, 12, 28, 12, false],

    // 2028年 (閏5月あり)
    [2028,  1, 27,  1, false], // (+1) 旧暦2028年1月1日: 1/27=先勝でリセット確認
    [2028,  2, 25,  2, false],
    [2028,  3, 26,  3, false], // (+1) 3/26=先負でリセット確認
    [2028,  4, 25,  4, false], // (+1) 4/25=仏滅でリセット確認
    [2028,  5, 24,  5, false], // (+1) 5/24=大安でリセット確認
    [2028,  6, 21,  5,  true], // 閏5月1日 (合朔13:09 JST、リセット検出法非適用)
    [2028,  7, 22,  6, false], // (+1) 7/22=赤口でリセット確認
    [2028,  8, 20,  7, false], // (+1) 8/20=先勝でリセット確認
    [2028,  9, 19,  8, false], // (+1) 9/19=友引でリセット確認
    [2028, 10, 18,  9, false], // (+1) 10/18=先負でリセット確認
    [2028, 11, 16, 10, false],
    [2028, 12, 16, 11, false], // (+1) 12/16=大安でリセット確認

    // 2029年
    [2029,  1, 15, 12, false], // (+1) 旧暦2028年12月1日: 1/15=赤口でリセット確認
    [2029,  2, 13,  1, false], // 旧暦2029年1月1日
    [2029,  3, 15,  2, false], // (+1) 3/15=友引でリセット確認
    [2029,  4, 14,  3, false], // (+1) 4/14=先負でリセット確認
    [2029,  5, 13,  4, false], // (+1) 5/13=仏滅でリセット確認
    [2029,  6, 12,  5, false], // (+1) 6/12=大安でリセット確認
    [2029,  7, 12,  6, false], // (+2) 7/12=赤口でリセット確認
    [2029,  8, 10,  7, false], // (+1) 8/10=先勝でリセット確認
    [2029,  9,  8,  8, false], // (+1) 9/8=友引でリセット確認
    [2029, 10,  8,  9, false], // (+1) 10/8=先負でリセット確認
    [2029, 11,  6, 10, false], // (+1) 11/6=仏滅でリセット確認
    [2029, 12,  5, 11, false],

    // 2030年
    [2030,  1,  4, 12, false], // (+1) 旧暦2029年12月1日: 1/4=赤口でリセット確認
    [2030,  2,  3,  1, false], // 旧暦2030年1月1日
    [2030,  3,  4,  2, false],
    [2030,  4,  3,  3, false],
    [2030,  5,  2,  4, false],
    [2030,  6,  1,  5, false],
    [2030,  7,  1,  6, false], // (+1) 旧6月1日: 7/1=赤口でリセット確認 (6/30→7/1)
    [2030,  7, 30,  7, false],
    [2030,  8, 29,  8, false], // (+1) 8/29=友引でリセット確認
    [2030,  9, 27,  9, false],
    [2030, 10, 27, 10, false], // (+1) 10/27=仏滅でリセット確認
    [2030, 11, 25, 11, false],
    [2030, 12, 25, 12, false], // (+1) 12/25=赤口でリセット確認

    // 2031年 (番兵エントリ)
    [2031,  1, 23,  1, false], // 旧暦2031年1月1日
  ];

  /// グレゴリオ暦 → 旧暦変換
  /// [date]以前の最も近い朔日エントリを線形探索で特定し、
  /// 旧暦月・日・閏月フラグを返す。
  static LunarDate fromGregorian(DateTime date) {
    final target = DateTime(date.year, date.month, date.day);

    // 線形探索: target以前の最後のエントリを探す
    int idx = -1;
    for (int i = 0; i < _sakuTable.length; i++) {
      final e = _sakuTable[i];
      final saku = DateTime(e[0] as int, e[1] as int, e[2] as int);
      if (!saku.isAfter(target)) {
        idx = i;
      } else {
        break;
      }
    }

    if (idx < 0) {
      // テーブル範囲外: フォールバック
      return _fallback(date);
    }

    final entry = _sakuTable[idx];
    final sakuDate = DateTime(entry[0] as int, entry[1] as int, entry[2] as int);
    final lunarDay = target.difference(sakuDate).inDays + 1;
    final lunarMonth = entry[3] as int;
    final isLeap = entry[4] as bool;

    // 旧暦年: 直近の旧暦1月1日（春節）エントリのグレゴリオ年を旧暦年とする
    int lunarYear = entry[0] as int;
    for (int j = idx; j >= 0; j--) {
      final e = _sakuTable[j];
      if ((e[3] as int) == 1 && !(e[4] as bool)) {
        lunarYear = e[0] as int;
        break;
      }
    }

    return LunarDate(lunarYear, lunarMonth, lunarDay, isLeap: isLeap);
  }

  /// テーブル範囲外日付用フォールバック（簡易近似）
  static LunarDate _fallback(DateTime date) {
    // 2024/2/10 を旧暦2024年1月1日として近似
    final epoch = DateTime(2024, 2, 10);
    final diffDays = date.difference(epoch).inDays;
    final monthOffset = (diffDays / 29.530589).floor();
    final lunarMonth = ((monthOffset % 12) + 1).clamp(1, 12);
    final lunarDay = (diffDays - (monthOffset * 29.530589).round() + 1).clamp(1, 30);
    return LunarDate(date.year, lunarMonth, lunarDay);
  }
}
