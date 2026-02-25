class WeatherUtils {
  static String getAssetForCondition(String? main) {
    final v = (main ?? '').toLowerCase().trim();
    if (v.contains('thunder')) return 'assets/thunder.json';
    if (v.contains('snow')) return 'assets/snow.json';
    if (v.contains('rain') || v.contains('drizzle')) return 'assets/rain.json';
    if (v.contains('mist') ||
        v.contains('fog') ||
        v.contains('haze') ||
        v.contains('smoke')) {
      return 'assets/mist.json';
    }
    if (v.contains('cloud')) return 'assets/cloudy_day.json';
    return 'assets/clear_day.json';
  }

  static String getWeekday(int weekday) =>
      const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekday - 1];

  static String getMonth(int month) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][month - 1];

  static String formatDate(DateTime dateTime) {
    return '${getWeekday(dateTime.weekday)}, ${dateTime.day} ${getMonth(dateTime.month)}';
  }

  static String getRainChancePct(double? chance) {
    if (chance == null) return '--';
    return '${(chance * 100).round()}%';
  }
}
