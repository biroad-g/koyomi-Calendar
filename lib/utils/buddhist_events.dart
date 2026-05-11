// 仏教・お寺の年中行事データ
class BuddhistEvent {
  final String name;
  final String description;
  final bool isMajor;

  const BuddhistEvent({
    required this.name,
    required this.description,
    this.isMajor = false,
  });
}

class BuddhistEvents {
  static const Map<String, List<BuddhistEvent>> fixedEvents = {
    '01-01': [
      BuddhistEvent(name: '修正会（しゅしょうえ）', description: '元旦に行う新年の法要。一年の安泰を祈願します。', isMajor: true),
    ],
    '01-16': [
      BuddhistEvent(name: '閻魔賽日（えんまさいじつ）', description: '閻魔大王の縁日。地獄の蓋が開く日とされます。'),
    ],
    '02-03': [
      BuddhistEvent(name: '節分会（せつぶんえ）', description: '鬼を払い福を呼ぶ豆まきの行事。', isMajor: true),
    ],
    '02-15': [
      BuddhistEvent(name: '涅槃会（ねはんえ）', description: 'お釈迦様の入滅（命日）を偲ぶ法要。', isMajor: true),
    ],
    '03-21': [
      BuddhistEvent(name: '春彼岸（中日）', description: '春分の日。先祖供養を行う彼岸の中日。', isMajor: true),
    ],
    '04-08': [
      BuddhistEvent(name: '花まつり（灌仏会）', description: 'お釈迦様の誕生をお祝いする法要。甘茶をかけて祝います。', isMajor: true),
    ],
    '05-21': [
      BuddhistEvent(name: '弘法大師降誕会', description: '弘法大師空海の誕生を祝う法要（真言宗）。'),
    ],
    '07-15': [
      BuddhistEvent(name: '盂蘭盆会（うらぼんえ）', description: '先祖の霊を迎え供養する仏教行事。お盆。', isMajor: true),
    ],
    '08-13': [
      BuddhistEvent(name: '盆迎え火', description: 'ご先祖様を迎える迎え火を焚きます。', isMajor: true),
    ],
    '08-15': [
      BuddhistEvent(name: '月遅れ盂蘭盆会', description: '月遅れのお盆の中日。先祖供養を行います。', isMajor: true),
    ],
    '08-16': [
      BuddhistEvent(name: '送り火', description: 'ご先祖様を送る送り火を焚きます。京都の五山送り火など。', isMajor: true),
    ],
    '09-23': [
      BuddhistEvent(name: '秋彼岸（中日）', description: '秋分の日。先祖供養を行う彼岸の中日。', isMajor: true),
    ],
    '11-15': [
      BuddhistEvent(name: '七五三', description: '子どもの健やかな成長を祝う行事。神社・お寺で祈祷。'),
    ],
    '12-08': [
      BuddhistEvent(name: '成道会（じょうどうえ）', description: 'お釈迦様が悟りを開いた日を記念する法要。', isMajor: true),
    ],
    '12-31': [
      BuddhistEvent(name: '除夜会・除夜の鐘', description: '108の煩悩を払う除夜の鐘を撞きます。', isMajor: true),
    ],
  };

  static List<BuddhistEvent> getEventsForDate(DateTime date) {
    final key =
        '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final events = <BuddhistEvent>[];

    if (fixedEvents.containsKey(key)) {
      events.addAll(fixedEvents[key]!);
    }

    final higan = _getHiganEvents(date);
    if (higan != null) events.add(higan);

    return events;
  }

  static BuddhistEvent? _getHiganEvents(DateTime date) {
    final springEquinox = _springEquinox(date.year);
    final autumnEquinox = _autumnEquinox(date.year);

    final daysFromSpring = date.difference(springEquinox).inDays;
    final daysFromAutumn = date.difference(autumnEquinox).inDays;

    if (daysFromSpring.abs() <= 3 && daysFromSpring != 0) {
      if (daysFromSpring == -3) {
        return const BuddhistEvent(
            name: '春彼岸入り', description: '春彼岸の始まり。先祖供養の期間に入ります。');
      }
      if (daysFromSpring == 3) {
        return const BuddhistEvent(name: '春彼岸明け', description: '春彼岸の最終日。');
      }
    }

    if (daysFromAutumn.abs() <= 3 && daysFromAutumn != 0) {
      if (daysFromAutumn == -3) {
        return const BuddhistEvent(
            name: '秋彼岸入り', description: '秋彼岸の始まり。先祖供養の期間に入ります。');
      }
      if (daysFromAutumn == 3) {
        return const BuddhistEvent(name: '秋彼岸明け', description: '秋彼岸の最終日。');
      }
    }

    return null;
  }

  static DateTime _springEquinox(int year) {
    final day =
        (20.8431 + 0.242194 * (year - 1980) - ((year - 1980) / 4).floor())
            .floor();
    return DateTime(year, 3, day);
  }

  static DateTime _autumnEquinox(int year) {
    final day =
        (23.2488 + 0.242194 * (year - 1980) - ((year - 1980) / 4).floor())
            .floor();
    return DateTime(year, 9, day);
  }
}
