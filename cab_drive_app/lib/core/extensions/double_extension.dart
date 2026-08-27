import 'package:flutter/cupertino.dart';

extension DoubleExtension on num {
  double getAdaptiveHeight(BuildContext context) {
    final baseHeight = 812;
    final curHeight = MediaQuery.of(context).size.height;
    return this * (curHeight / baseHeight);
  }

  double getAdaptiveWidth(BuildContext context) {
    final baseHeight = 375;
    final curHeight = MediaQuery.of(context).size.width;
    return this * (curHeight / baseHeight);
  }

  double getFontSize(BuildContext context) {
    final baseWidth = 375;
    final baseHeight = 812;

    final curWidth = MediaQuery.of(context).size.width;
    final curHeight = MediaQuery.of(context).size.height;

    if (curWidth < curHeight) {
      return this * (curWidth / baseWidth);
    } else {
      return this * (curHeight / baseHeight);
    }
  }
}
