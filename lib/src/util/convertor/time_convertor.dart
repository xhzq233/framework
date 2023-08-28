dynamic string2millis(dynamic time) {
  if (time == null) return null;
  return DateTime.parse(time).millisecondsSinceEpoch;
}

dynamic millis2string(dynamic millis) {
  if (millis == null) return null;
  return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true).toIso8601String();
}
