// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
// Imports other custom widgets
// Imports custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!


class PhoneInputWidget extends StatefulWidget {
  const PhoneInputWidget({
    super.key,
    this.width,
    this.height,
    this.callback,
  });

  final double? width;
  final double? height;
  final Future Function(String phone)? callback;

  @override
  State<PhoneInputWidget> createState() => _PhoneInputWidgetState();
}

class _PhoneInputWidgetState extends State<PhoneInputWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _phone = '';
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();

    // Запрашиваем фокус после построения виджета
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isComplete && mounted) {
        _focusNode.requestFocus();
      }
    });

    // Следим за фокусом только если номер не заполне
    _focusNode.addListener(() {
      if (!_isComplete && mounted && !_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!_isComplete && mounted) {
            _focusNode.requestFocus();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Widget _buildDot() {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: const BoxDecoration(
        color: Color(0xFFA4A6B2),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildDisplayText() {
    List<Widget> elements = [
      const Text(
        '+7 ',
        style: TextStyle(
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w500,
          fontSize: 20,
          color: Color(0xFF181818),
        ),
      ),
    ];

    List<String> digits = _phone.split('');

    for (int i = 0; i < 10; i++) {
      if (i < digits.length) {
        elements.add(Text(
          digits[i],
          style: const TextStyle(
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w500,
            fontSize: 20,
            color: Color(0xFF181818),
          ),
        ));
      } else {
        elements.add(_buildDot());
      }

      if (i == 2 || i == 5 || i == 7) {
        elements.add(const SizedBox(width: 12));
      } else {
        elements.add(const SizedBox(width: 2));
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: elements,
    );
  }

  void _handleTextChanged(String value) {
    String digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length > 10) {
      digitsOnly = digitsOnly.substring(0, 10);
    }

    setState(() {
      _phone = digitsOnly;
    });

    if (digitsOnly.length == 10 && widget.callback != null) {
      setState(() {
        _isComplete = true;
      });
      _focusNode.unfocus();
      widget.callback!('7$digitsOnly');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildDisplayText(),
        Opacity(
          opacity: 0,
          child: SizedBox(
            width: widget.width ?? double.infinity,
            height: widget.height,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              enableInteractiveSelection: false,
              showCursor: false,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: _handleTextChanged,
            ),
          ),
        ),
      ],
    );
  }
}
