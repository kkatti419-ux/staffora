import 'package:flutter/widgets.dart';

class DeviceUtils {
  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;
}
