import 'package:flutter/services.dart';

class DateValidator extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    String inputText = newValue.text;
    String formattedText = _formatDate(inputText);

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }

  String _formatDate(String inputText) {
    inputText = inputText.replaceAll(RegExp(r'[^0.9]'), '');

    if (inputText.length > 8) {
      inputText = inputText.substring(0, 8);
    }

    if (inputText.isNotEmpty) {
      if(inputText.length > 4) inputText = (inputText.split('')..insert(4, '.')).join();
      if(inputText.length > 7) inputText = (inputText.split('')..insert(7, '.')).join();

    }

    final parts = inputText.split('.').toList();
    if(parts.length > 0 && int.parse(parts.first) > DateTime.now().year) {
      parts[0] = DateTime.now().year.toString();
    }
    if(parts.length > 1 && int.parse(parts[1][0]) > 1) {

      parts[1] = '0${parts[1]}';
    }
    if(parts.length > 1 && int.parse(parts[1]) > 12) {

      parts[1] = '12';
    }

    if(parts.length > 1 && parts[1] == '00') {

      parts[1] = '01';
    }
    if(parts.length > 2 && int.parse(parts[2][0]) > 3) {

      parts[2] = '0${parts[2]}';
    }
    if(parts.length > 2 && int.parse(parts.last) > DateTime(int.parse(parts.first), int.parse(parts[1]) + 1, 0).day) {
      parts[2] = DateTime(int.parse(parts.first), int.parse(parts[1]) + 1, 0).day.toString();
    }

    if(parts.length > 2 && parts[2] == '00') {

      parts[2] = '01';
    }

    inputText = parts.toList().join('.');


    return inputText;
  }
}