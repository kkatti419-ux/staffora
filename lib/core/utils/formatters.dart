class Formatters {
  static String currency(double value) {
    return "₹ ${value.toStringAsFixed(2)}";
  }

  static String date(DateTime value) {
    return "${value.day}/${value.month}/${value.year}";
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