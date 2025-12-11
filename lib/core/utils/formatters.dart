class Formatters {
  static String currency(double value) {
    return "₹ ${value.toStringAsFixed(2)}";
  }

  static String formatDate(DateTime? date) {
    if (date == null) return "N/A";
    return "${date.day}/${date.month}/${date.year}";
  }
}



/*
For formatting:
dates
currency
numbers
names
strings
*/