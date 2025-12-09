import 'package:flutter/widgets.dart';

extension StringExtensions on String {
  bool get isEmail => RegExp(r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(this);
}

extension WidgetExt on Widget {
  Widget paddingAll(double value) => Padding(
        padding: EdgeInsets.all(value),
        child: this,
      );
}
