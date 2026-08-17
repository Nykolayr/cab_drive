import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/backend/push_notifications/push_notifications_util.dart';
import '/driver/za_chto_plata/za_chto_plata_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'create_otklick_model.dart';
export 'create_otklick_model.dart';

class CreateOtklickWidget extends StatefulWidget {
  const CreateOtklickWidget({
    super.key,
    required this.order,
  });

  final OrderRecord? order;

  @override
  State<CreateOtklickWidget> createState() => _CreateOtklickWidgetState();
}

class _CreateOtklickWidgetState extends State<CreateOtklickWidget> {
  late CreateOtklickModel _model;

  LatLng? currentUserLocationValue;
  bool _isSending = false;

  int get _customerPrice {
    final cp = widget.order?.currentPrice ?? 0;
    if (cp > 0) return cp;
    return widget.order?.budget ?? 0;
  }

  int? get _proposedPrice {
    if (_model.priceMode == 1) return _customerPrice;
    if (_model.priceMode == 2) {
      return int.tryParse(_model.customPriceTextController?.text ?? '');
    }
    return null;
  }

  int get _commission {
    final price = _proposedPrice ?? 0;
    final pct = currentUserDocument?.commissionPercent ?? 0;
    if (price <= 0 || pct <= 0) return 0;
    return ((price / 100) * pct).round();
  }

  bool get _canSubmit {
    if (_isSending) return false;
    if (_model.priceMode == 0) return false;
    if (_model.priceMode == 2) {
      final raw = _model.customPriceTextController?.text ?? '';
      final parsed = int.tryParse(raw);
      if (parsed == null || parsed < _customerPrice) return false;
    }
    final comment = _model.commentBTextController?.text.trim() ?? '';
    if (comment.length < 3) return false;
    return true;
  }

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CreateOtklickModel());

    _model.commentBTextController ??= TextEditingController();
    _model.commentBFocusNode ??= FocusNode();
    _model.customPriceTextController ??= TextEditingController();
    _model.customPriceFocusNode ??= FocusNode();
    _model.etaTextController ??= TextEditingController();
    _model.etaFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    if (_model.formKey.currentState == null ||
        !_model.formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSending = true);
    try {
      currentUserLocationValue =
          await getCurrentUserLocation(defaultLocation: LatLng(0.0, 0.0));

      _model.adsd3 = await DistanceMatrixCall.call(
        destination:
            '${functions.extractLatLong(currentUserLocationValue!, true)},${functions.extractLatLong(currentUserLocationValue!, false)}',
        origin:
            '${functions.extractLatLong(widget.order!.pointA.latlng!, true)},${functions.extractLatLong(widget.order!.pointA.latlng!, false)}',
      );

      final etaText = _model.etaTextController?.text.trim() ?? '';
      final computedTime =
          DistanceMatrixCall.time(_model.adsd3?.jsonBody ?? '') ?? '';
      final timeValue = etaText.isNotEmpty ? etaText : computedTime;

      await ResponsesRecord.createDoc(widget.order!.reference)
          .set(createResponsesRecordData(
        userDriver: currentUserReference,
        viewed: false,
        text: _model.commentBTextController?.text ?? '',
        price: _proposedPrice,
        dateCreated: getCurrentTimestamp,
        time: timeValue,
        distance:
            DistanceMatrixCall.time(_model.adsd3?.jsonBody ?? '') ?? '',
      ));

      await widget.order!.reference.update({
        ...mapToFirestore(
          {
            'user_who_responced':
                FieldValue.arrayUnion([currentUserReference]),
            'count_resp': FieldValue.increment(1),
          },
        ),
      });

      triggerPushNotification(
        notificationTitle: 'Новый отклик',
        notificationText: 'На ваш заказ откликнулся водитель',
        notificationSound: 'default',
        userRefs: [widget.order!.userCustomer!],
        initialPageName: 'order_Page_Customer',
        parameterData: {
          'index': 1,
          'order': widget.order?.reference,
        },
      );

      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Widget _underlineInput({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    bool enabled = true,
    int? maxLines = 1,
    int? minLines,
    TextInputType? keyboardType,
    String? Function(BuildContext, String?)? validator,
  }) {
    final theme = FlutterFlowTheme.of(context);
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      maxLines: maxLines,
      minLines: minLines,
      keyboardType: keyboardType,
      onChanged: (_) => setState(() {}),
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        isDense: false,
        hintText: hint,
        hintStyle: theme.bodyMedium.override(
          fontFamily: 'SF',
          color: const Color(0xFF8F8F8E),
          fontSize: 16.0,
          letterSpacing: 0.0,
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFD0CFCE), width: 0.5),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFD0CFCE), width: 0.5),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: theme.error, width: 0.5),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: theme.error, width: 0.5),
        ),
        contentPadding:
            const EdgeInsetsDirectional.fromSTEB(0.0, 18.0, 0.0, 18.0),
      ),
      style: theme.bodyMedium.override(
        fontFamily: 'SF',
        fontSize: 16.0,
        letterSpacing: 0.0,
      ),
      cursorColor: theme.primaryText,
      validator: validator?.asValidator(context),
    );
  }

  Widget _priceModeOption({
    required int value,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    final theme = FlutterFlowTheme.of(context);
    final selected = _model.priceMode == value;
    return InkWell(
      borderRadius: BorderRadius.circular(16.0),
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _model.priceMode = value);
      },
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(14.0, 12.0, 14.0, 12.0),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: selected ? theme.tertiary : const Color(0xFFE5E7EB),
            width: selected ? 1.4 : 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 22.0,
                  height: 22.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? theme.tertiary
                          : const Color(0xFFD0CFCE),
                      width: 1.6,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: selected
                      ? Container(
                          width: 12.0,
                          height: 12.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.tertiary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: theme.bodyMedium.override(
                          fontFamily: 'SF',
                          fontSize: 16.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        subtitle,
                        style: theme.bodyMedium.override(
                          fontFamily: 'SF',
                          color: const Color(0xFF8F8F8E),
                          fontSize: 14.0,
                          letterSpacing: 0.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (trailing != null)
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(34.0, 8.0, 0.0, 0.0),
                child: trailing,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final customerPrice = _customerPrice;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22.0),
          topRight: Radius.circular(22.0),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                height: 64.0,
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(22.0),
                    topRight: Radius.circular(22.0),
                  ),
                ),
                padding: const EdgeInsetsDirectional.fromSTEB(
                    24.0, 0.0, 16.0, 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Отклик',
                      style: theme.bodyMedium.override(
                        fontFamily: 'SF',
                        fontSize: 21.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    FlutterFlowIconButton(
                      borderRadius: 54.0,
                      buttonSize: 32.0,
                      fillColor: const Color(0xFFF4F5F8),
                      icon: const Icon(
                        FFIcons.kkrestStroke,
                        color: Color(0xFF21201F),
                        size: 8.0,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Inputs section (white card)
              Container(
                width: double.infinity,
                color: theme.secondaryBackground,
                padding: const EdgeInsetsDirectional.fromSTEB(
                    24.0, 4.0, 24.0, 12.0),
                child: Form(
                  key: _model.formKey,
                  autovalidateMode: AutovalidateMode.disabled,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Budget display (read-only)
                      _underlineInput(
                        controller: TextEditingController(),
                        focusNode: FocusNode(),
                        hint: customerPrice > 0
                            ? 'Сумма, до $customerPrice ₽'
                            : 'Сумма',
                        enabled: false,
                      ),
                      _underlineInput(
                        controller: _model.commentBTextController!,
                        focusNode: _model.commentBFocusNode!,
                        hint:
                            'Расскажите о своём опыте. Уточните детали заказа или предложите свои условия.',
                        maxLines: 5,
                        minLines: 2,
                        validator: _model.commentBTextControllerValidator,
                      ),
                      _underlineInput(
                        controller: _model.etaTextController!,
                        focusNode: _model.etaFocusNode!,
                        hint: 'Прибытие до заказчика',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              // Price mode card
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                    16.0, 0.0, 16.0, 0.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.secondaryBackground,
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      14.0, 14.0, 14.0, 14.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Предложение по цене',
                        style: theme.bodyMedium.override(
                          fontFamily: 'SF',
                          fontSize: 17.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      _priceModeOption(
                        value: 1,
                        title: 'По цене заказчика',
                        subtitle: 'до $customerPrice ₽',
                      ),
                      const SizedBox(height: 10.0),
                      _priceModeOption(
                        value: 2,
                        title: 'По своей цене',
                        subtitle: 'Вы можете предложить больше',
                        trailing: TextFormField(
                          controller: _model.customPriceTextController,
                          focusNode: _model.customPriceFocusNode,
                          enabled: _model.priceMode == 2,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Укажите цену',
                            hintStyle: theme.bodyMedium.override(
                              fontFamily: 'SF',
                              color: const Color(0xFF8F8F8E),
                              fontSize: 16.0,
                              letterSpacing: 0.0,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color(0xFFE5E7EB), width: 1.0),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: theme.tertiary, width: 1.2),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color(0xFFE5E7EB), width: 1.0),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(
                                    horizontal: 12.0, vertical: 12.0),
                          ),
                          style: theme.bodyMedium.override(
                            fontFamily: 'SF',
                            fontSize: 16.0,
                            letterSpacing: 0.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              // Commission + help
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                    24.0, 0.0, 16.0, 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _commission > 0
                          ? 'Комиссия за заказ - $_commission ₽'
                          : 'Комиссия за заказ',
                      style: theme.bodyMedium.override(
                        fontFamily: 'SF',
                        fontSize: 14.0,
                        letterSpacing: 0.0,
                      ),
                    ),
                    FlutterFlowIconButton(
                      borderRadius: 8.0,
                      buttonSize: 32.0,
                      icon: Icon(
                        FFIcons.khelpOctagon,
                        color: theme.secondaryText,
                        size: 18.0,
                      ),
                      onPressed: () async {
                        await showModalBottomSheet(
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          context: context,
                          builder: (context) => WebViewAware(
                            child: Padding(
                              padding: MediaQuery.viewInsetsOf(context),
                              child: ZaChtoPlataWidget(),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12.0),
              // Submit button
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                    16.0, 0.0, 16.0, 28.0),
                child: FFButtonWidget(
                  onPressed: _canSubmit ? () => _submit() : null,
                  text: 'Откликнуться',
                  showLoadingIndicator: _isSending,
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 56.0,
                    color: _canSubmit
                        ? theme.tertiary
                        : const Color(0xFFEDEEF1),
                    textStyle: theme.titleSmall.override(
                      fontFamily: 'SF',
                      color: _canSubmit
                          ? theme.primaryBackground
                          : const Color(0xFFA4A6B2),
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                    ),
                    elevation: 0.0,
                    borderRadius: BorderRadius.circular(16.0),
                    disabledColor: const Color(0xFFEDEEF1),
                    disabledTextColor: const Color(0xFFA4A6B2),
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}
