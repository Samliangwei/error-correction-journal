import 'package:flutter_test/flutter_test.dart';
import 'package:clock/clock.dart';
import 'package:error_journal/core/scheduling/learning_date.dart';

void main() {
  group('LearningDate - UTC+8 固定时区', () {
    test('解析日期字符串', () {
      final date = LearningDate.parse('2026-11-20');
      expect(date.value, '2026-11-20');
    });

    test('无效格式抛异常', () {
      expect(() => LearningDate.parse('20261120'), throwsFormatException);
      expect(() => LearningDate.parse('2026/11/20'), throwsFormatException);
    });

    test('加天数', () {
      final date = LearningDate.parse('2026-11-20');
      expect(date.addDays(1).value, '2026-11-21');
      expect(date.addDays(3).value, '2026-11-23');
      expect(date.addDays(7).value, '2026-11-27');
      expect(date.addDays(14).value, '2026-12-04');
    });

    test('跨月份加天数', () {
      final date = LearningDate.parse('2026-11-30');
      expect(date.addDays(1).value, '2026-12-01');
      expect(date.addDays(15).value, '2026-12-15');
    });

    test('日期比较', () {
      final date1 = LearningDate.parse('2026-11-20');
      final date2 = LearningDate.parse('2026-11-21');
      final date3 = LearningDate.parse('2026-11-20');

      expect(date1 < date2, true);
      expect(date1 > date2, false);
      expect(date1 == date3, true);
      expect(date1 <= date3, true);
    });

    test('注入clock获取今日（UTC+8）', () {
      // 模拟UTC时间：2026-11-20 00:00:00 UTC
      // UTC+8应该是 2026-11-20 08:00:00
      final fakeClock = Clock.fixed(DateTime.utc(2026, 11, 20, 0, 0, 0));

      final today =
          withClock(fakeClock, () => LearningDate.today(clock: fakeClock));

      expect(today.value, '2026-11-20');
    });

    test('UTC+8跨日（UTC 23:00 = UTC+8 次日07:00）', () {
      // UTC: 2026-11-20 23:00:00
      // UTC+8: 2026-11-21 07:00:00
      final fakeClock = Clock.fixed(DateTime.utc(2026, 11, 20, 23, 0, 0));

      final today =
          withClock(fakeClock, () => LearningDate.today(clock: fakeClock));

      expect(today.value, '2026-11-21'); // 次日
    });

    test('UTC+8边界（UTC 16:00 = UTC+8 当日00:00）', () {
      // UTC: 2026-11-19 16:00:00
      // UTC+8: 2026-11-20 00:00:00
      final fakeClock = Clock.fixed(DateTime.utc(2026, 11, 19, 16, 0, 0));

      final today =
          withClock(fakeClock, () => LearningDate.today(clock: fakeClock));

      expect(today.value, '2026-11-20');
    });
  });
}
