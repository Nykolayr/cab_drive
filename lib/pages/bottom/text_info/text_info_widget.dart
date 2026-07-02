import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'text_info_model.dart';
export 'text_info_model.dart';

class TextInfoWidget extends StatefulWidget {
  const TextInfoWidget({
    super.key,
    required this.tittle,
    this.pole,
  });

  final String? tittle;
  final String? pole;

  @override
  State<TextInfoWidget> createState() => _TextInfoWidgetState();
}

class _TextInfoWidgetState extends State<TextInfoWidget> {
  late TextInfoModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TextInfoModel());

    _model.inputTextController ??= TextEditingController(text: widget.pole);
    _model.inputFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 57.0,
      ),
      decoration: const BoxDecoration(),
      child: Stack(
        children: [
          TextFormField(
            controller: _model.inputTextController,
            focusNode: _model.inputFocusNode,
            autofocus: false,
            textCapitalization: TextCapitalization.none,
            readOnly: true,
            obscureText: false,
            decoration: InputDecoration(
              isDense: false,
              labelText: widget.tittle,
              labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                    fontFamily: 'SF',
                    color: const Color(0xFF8F8F8E),
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                  ),
              enabledBorder: UnderlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFFD0CFCE),
                  width: 0.3,
                ),
                borderRadius: BorderRadius.circular(0.0),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFFD0CFCE),
                  width: 0.3,
                ),
                borderRadius: BorderRadius.circular(0.0),
              ),
              errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).error,
                  width: 0.3,
                ),
                borderRadius: BorderRadius.circular(0.0),
              ),
              focusedErrorBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).error,
                  width: 0.3,
                ),
                borderRadius: BorderRadius.circular(0.0),
              ),
              contentPadding:
                  const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 16.0),
              hoverColor: Colors.transparent,
            ),
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'SF',
                  fontSize: 16.0,
                  letterSpacing: 0.0,
                ),
            maxLines: 30,
            minLines: 1,
            cursorColor: FlutterFlowTheme.of(context).primaryText,
            validator: _model.inputTextControllerValidator.asValidator(context),
            inputFormatters: [
              if (!isAndroid && !isiOS)
                TextInputFormatter.withFunction((oldValue, newValue) {
                  return TextEditingValue(
                    selection: newValue.selection,
                    text:
                        newValue.text.toCapitalization(TextCapitalization.none),
                  );
                }),
            ],
          ),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              minHeight: 57.0,
            ),
            decoration: const BoxDecoration(),
          ),
        ],
      ),
    );
  }
}
