import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/core/utils/formatters/phone_mask_input_formatter.dart';
import '/core/utils/formatters/ru_phone.dart';
import '/flutter_flow/flutter_flow_theme.dart';

/// Переиспользуемое поле телефона с маской как в авторизации / знакомстве.
///
/// Хранит в [controller] отображаемую маску `+7 (___) ___-__-__`.
/// Для API берите [RuPhone.digits11](controller.text).
class PhoneMaskedField extends StatefulWidget {
  const PhoneMaskedField({
    super.key,
    required this.controller,
    this.focusNode,
    this.labelText = 'Номер телефона',
    this.hintText = RuPhone.maskHint,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.autofillHints = const [AutofillHints.telephoneNumber],
    this.textInputAction = TextInputAction.done,
    this.style,
    this.decoration,
    this.underlineStyle = true,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? labelText;
  final String? hintText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final Iterable<String>? autofillHints;
  final TextInputAction textInputAction;
  final TextStyle? style;
  final InputDecoration? decoration;

  /// Стиль как у sender/recipient (underline). `false` — как Verif (толстая линия primary).
  final bool underlineStyle;

  /// Проставить в контроллер маску из сырого номера (switch «это я» и т.п.).
  static void setMaskedText(TextEditingController controller, String? raw) {
    final masked = RuPhone.mask(raw);
    controller.value = TextEditingValue(
      text: masked,
      selection: TextSelection.collapsed(offset: masked.length),
    );
  }

  @override
  State<PhoneMaskedField> createState() => _PhoneMaskedFieldState();
}

class _PhoneMaskedFieldState extends State<PhoneMaskedField> {
  late final PhoneMaskInputFormatter _formatter;

  @override
  void initState() {
    super.initState();
    _formatter = PhoneMaskInputFormatter(mask: RuPhone.inputMask);
    final raw = widget.controller.text;
    if (raw.trim().isNotEmpty) {
      final masked = RuPhone.mask(raw);
      if (masked != raw) {
        widget.controller.value = TextEditingValue(
          text: masked,
          selection: TextSelection.collapsed(offset: masked.length),
        );
      }
      // Синхронизация внутреннего состояния форматтера.
      _formatter.formatEditUpdate(
        const TextEditingValue(),
        TextEditingValue(
          text: widget.controller.text,
          selection: TextSelection.collapsed(
            offset: widget.controller.text.length,
          ),
        ),
      );
    }
  }

  InputDecoration _defaultDecoration(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    if (widget.underlineStyle) {
      return InputDecoration(
        isDense: false,
        labelText: widget.labelText,
        labelStyle: theme.labelMedium.override(
          fontFamily: 'SF',
          color: const Color(0xFF8F8F8E),
          fontSize: 16.0,
          letterSpacing: 0.0,
        ),
        hintText: widget.hintText,
        hintStyle: theme.labelMedium.override(
          fontFamily: 'SF',
          color: theme.secondaryText,
          fontSize: 16.0,
          letterSpacing: 0.0,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFD0CFCE), width: 0.3),
          borderRadius: BorderRadius.circular(0.0),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFD0CFCE), width: 0.3),
          borderRadius: BorderRadius.circular(0.0),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: theme.error, width: 0.3),
          borderRadius: BorderRadius.circular(0.0),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: theme.error, width: 0.3),
          borderRadius: BorderRadius.circular(0.0),
        ),
        contentPadding:
            const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 16.0),
        hoverColor: Colors.transparent,
      );
    }
    return InputDecoration(
      isDense: false,
      hintText: widget.hintText,
      hintStyle: theme.labelMedium.override(
        fontFamily: 'SF',
        color: theme.secondaryText,
        fontSize: 20.0,
        letterSpacing: 0.0,
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: theme.primary, width: 3.0),
        borderRadius: BorderRadius.circular(0.0),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: theme.primary, width: 3.0),
        borderRadius: BorderRadius.circular(0.0),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: theme.error, width: 3.0),
        borderRadius: BorderRadius.circular(0.0),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: theme.error, width: 3.0),
        borderRadius: BorderRadius.circular(0.0),
      ),
      filled: true,
      fillColor: Colors.transparent,
      contentPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
      hoverColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      autofillHints: widget.autofillHints,
      keyboardType: TextInputType.phone,
      textInputAction: widget.textInputAction,
      obscureText: false,
      decoration: widget.decoration ?? _defaultDecoration(context),
      style: widget.style ??
          theme.bodyMedium.override(
            fontFamily: 'SF',
            fontSize: 16.0,
            letterSpacing: 0.0,
          ),
      cursorColor: theme.primaryText,
      validator: widget.validator ??
          (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Обязательно для заполнения';
            }
            if (!RuPhone.isComplete(val)) {
              return 'Введите номер полностью';
            }
            return null;
          },
      inputFormatters: <TextInputFormatter>[_formatter],
      onChanged: widget.onChanged,
    );
  }
}
