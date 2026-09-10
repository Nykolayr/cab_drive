import 'package:flutter/material.dart';

import '/core/widgets/phone_masked_field.dart';

/// Поле телефона на экране логина — обёртка над [PhoneMaskedField].
class PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;

  const PhoneField({
    super.key,
    required this.controller,
    this.focusNode,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PhoneMaskedField(
      controller: controller,
      focusNode: focusNode,
      labelText: null,
      underlineStyle: false,
      validator: validator ??
          (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Введите номер телефона';
            }
            return null;
          },
      onChanged: onChanged,
    );
  }
}
