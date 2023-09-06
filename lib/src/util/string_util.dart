class StringUtil {
  StringUtil._();

  static bool containsHyperLink(String content) {
    final regex = RegExp(r'\[.*\]\(.*\)');
    return regex.hasMatch(content);
  }
}

extension MoneyStringExt on double {
  String get removeTrailingZeros {
    // return if complies to int
    if (this % 1 == 0) return toInt().toString();
    // remove trailing zeroes
    String str = '$this'.replaceAll(RegExp(r'0*$'), '');
    return str;
  }
}
