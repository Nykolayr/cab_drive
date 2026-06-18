
import 'package:flutter/material.dart';
extension TextStyleExtension on TextStyle {

  TextStyle copyParams (TextStyle fromDifferent) {
    return copyWith(color: fromDifferent.color, fontWeight: fromDifferent.fontWeight, fontSize: fromDifferent.fontSize);
  }
}
