import 'package:intl/intl.dart';

extension DateTimeExt on DateTime {
  static DateTime fromSecondsSinceEpoch(int seconds) => DateTime.fromMillisecondsSinceEpoch(seconds * 1000);

  int get secondsSinceEpoch => millisecondsSinceEpoch ~/ 1000;

  int get daysSinceEpoch => millisecondsSinceEpoch ~/ (1000 * 3600 * 24);

  bool isSameDayAs(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isYesterdayOf(DateTime other) {
    return year == other.year && month == other.month && day == other.day - 1;
  }

  // 是否在最近七天内
  bool isWithinLastSevenDays(DateTime other) {
    return difference(other).inDays.abs() < 7;
  }

  bool isSameYearAs(DateTime other) {
    return year == other.year;
  }

  // 时间转换逻辑：
  // 目标时间和今天是同一个自然日，只展示几点几分，例如「13:58」
  // 目标时间自然日==今天-1，展示「昨天」+几点几分，例如「昨天 07:32」
  // 今天 - 7 < 目标时间自然日 < 今天 - 1，展示星期几，例如「星期六」
  // 目标时间自然日 < 今天 - 7，展示几月几号，例如「06/18」
  // 目标时间自然日在去年或更早，展示年月日，例如「2022/12/31」
  // 举例：今天2023/06/26 星期一，那么：
  // 2023/06/26 12:30展示为「12:30」
  // 2023/06/25 12:30展示为「昨天 12:30」
  // 2023/06/24展示为「星期六」
  // 2023/06/20展示为「星期二」
  // 2023/06/19展示为「06/19」
  // 2023/01/01展示为「01/01」
  // 2022/12/31展示为「2022/12/31」
  // 需要多语言的应该是「昨天」和七个「星期x」，月日年需要注意根据locale调整格式，几点几分需要根据系统24小时制切换
  String toDescription({DateTime? comparedTo, required String yesterday}) {
    comparedTo ??= DateTime.now();
    if (isSameDayAs(comparedTo)) {
      // 跟当前的时间为同一天
      return DateFormat("HH:mm").format(this); // 时分
    } else if (isYesterdayOf(comparedTo)) {
      return "$yesterday ${DateFormat("HH:mm").format(this)}"; // 昨天
    } else if (isWithinLastSevenDays(comparedTo)) {
      return DateFormat("EEEE").format(this); // 星期几
    } else if (isSameYearAs(comparedTo)) {
      return DateFormat("MM/dd").format(this); // 月日
    } else {
      return DateFormat.yMd().format(this); // 默认情况：年月日
    }
  }

  String toYmd() => DateFormat.yMd().format(this);
}
