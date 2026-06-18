
import 'package:flutter/material.dart';

import '../../../../core/utils/formatters/phone_mask_input_formatter.dart';

class PhoneField extends StatelessWidget {
  final TextEditingController controller;

  const PhoneField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: '+7',
          ),
          inputFormatters: [PhoneMaskInputFormatter()],
        ))
      ],
    );
  }
}
