class DateHelper {
  static const List<String> months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];

  static String getMonth(int index) {
    if (index < 1 || index > 12) return "";
    return months[index - 1];
  }
}
