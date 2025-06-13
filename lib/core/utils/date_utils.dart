class DateUtils {
  static DateTime parseBackendDate(String dateString) {
    final initialParse = DateTime.parse(dateString);
    if (initialParse.isUtc) {
      return initialParse;
    } else {
      return DateTime.utc(
        initialParse.year,
        initialParse.month,
        initialParse.day,
        initialParse.hour,
        initialParse.minute,
        initialParse.second,
        initialParse.millisecond,
        initialParse.microsecond,
      );
    }
  }
}
