import 'package:flutter/services.dart';

Color getColor(String? colorCode) {
  return Color(0xFF000000 | int.parse(colorCode ?? '000000', radix: 16));
}
