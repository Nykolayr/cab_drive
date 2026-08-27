import 'package:cab_drive/customer/create_order/detaliy_sozdanie/widgets/custom_widget.dart';
import 'package:cab_drive/flutter_flow/flutter_flow_util.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

import '../../../../app_state.dart';
import '../../../../flutter_flow/custom_icons.dart';
import '../../../../flutter_flow/flutter_flow_theme.dart';
import '../../karta/karta_widget.dart';
import '../../recipient/recipient_widget.dart';
import '../detaliy_sozdanie_model.dart';
import '/flutter_flow/custom_functions.dart' as functions;

class IntermediatePoint extends StatelessWidget {
  final DetaliySozdanieModel model;
  final Function(Function()) safeSetState;
  final Function(bool)? isExpanded;
  final Function()? onSelectAddress;

  const IntermediatePoint({super.key, required this.safeSetState, required this.model, this.isExpanded, this.onSelectAddress});

  @override
  Widget build(BuildContext context) {
    return ExpandableWidget(
      ifExpanded: isExpanded,
     iconBuilder: (isExpandable) {
       return isExpandable ? Icons.remove : Icons.add;
     },
      children: [
        Text(
          'Промежуточная выгрузка',
          style: FlutterFlowTheme.of(context)
              .bodyMedium
              .override(
            fontFamily: 'SF',
            fontSize: 21.0,
            letterSpacing: 0.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            await showModalBottomSheet(
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              context: context,
              builder: (context) {
                return WebViewAware(
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context)
                          .unfocus();
                      FocusManager
                          .instance.primaryFocus
                          ?.unfocus();
                    },
                    child: Padding(
                      padding:
                      MediaQuery.viewInsetsOf(
                          context),
                      child: KartaWidget(
                        point: 'C',
                      ),
                    ),
                  ),
                );
              },
            ).then((value) => safeSetState(() {
              onSelectAddress?.call();
            }));
          },
          child: Container(
            constraints: BoxConstraints(
              minHeight: 57.0,
            ),
            decoration: BoxDecoration(),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              crossAxisAlignment:
              CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    FFAppState().pointC.address,
                    style:
                    FlutterFlowTheme.of(context)
                        .bodyMedium
                        .override(
                      fontFamily: 'SF',
                      fontSize: 16.0,
                      letterSpacing: 0.0,
                    ),
                  ),
                ),
                Icon(
                  FFIcons.kiconrightStroke,
                  color:
                  FlutterFlowTheme.of(context)
                      .primaryText,
                  size: 12.0,
                ),
              ].divide(SizedBox(width: 12.0)),
            ),
          ),
        ),
        Divider(
          height: 0.3,
          thickness: 0.3,
          color: Color(0xFFD0CFCE),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment:
          CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextFormField(
                controller:
                model.entranceCTextController,
                focusNode:
                model.entranceCFocusNode,
                onFieldSubmitted: (_) async {
                  FFAppState().updatePointCStruct(
                        (e) => e
                      ..entrance = int.tryParse(model
                          .entranceCTextController
                          .text),
                  );
                  safeSetState(() {});
                },
                autofocus: false,
                textCapitalization:
                TextCapitalization.sentences,
                textInputAction:
                TextInputAction.next,
                obscureText: false,
                decoration: InputDecoration(
                  isDense: false,
                  labelText: 'Подъезд',
                  labelStyle:
                  FlutterFlowTheme.of(context)
                      .labelMedium
                      .override(
                    fontFamily: 'SF',
                    color:
                    Color(0xFF8F8F8E),
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                  ),
                  enabledBorder:
                  UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFD0CFCE),
                      width: 0.3,
                    ),
                    borderRadius:
                    BorderRadius.circular(0.0),
                  ),
                  focusedBorder:
                  UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFD0CFCE),
                      width: 0.3,
                    ),
                    borderRadius:
                    BorderRadius.circular(0.0),
                  ),
                  errorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: FlutterFlowTheme.of(
                          context)
                          .error,
                      width: 0.3,
                    ),
                    borderRadius:
                    BorderRadius.circular(0.0),
                  ),
                  focusedErrorBorder:
                  UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: FlutterFlowTheme.of(
                          context)
                          .error,
                      width: 0.3,
                    ),
                    borderRadius:
                    BorderRadius.circular(0.0),
                  ),
                  contentPadding:
                  EdgeInsetsDirectional
                      .fromSTEB(
                      0.0, 8.0, 0.0, 8.0),
                  hoverColor: Colors.transparent,
                ),
                style: FlutterFlowTheme.of(context)
                    .bodyMedium
                    .override(
                  fontFamily: 'SF',
                  fontSize: 16.0,
                  letterSpacing: 0.0,
                ),
                cursorColor:
                FlutterFlowTheme.of(context)
                    .primaryText,
                validator: model
                    .entranceCTextControllerValidator
                    .asValidator(context),
                inputFormatters: [
                  if (!isAndroid && !isiOS)
                    TextInputFormatter.withFunction(
                            (oldValue, newValue) {
                          return TextEditingValue(
                            selection:
                            newValue.selection,
                            text: newValue.text
                                .toCapitalization(
                                TextCapitalization
                                    .sentences),
                          );
                        }),
                ],
              ),
            ),
            Expanded(
              child: TextFormField(
                controller:
                model.flatCTextController,
                focusNode: model.flatCFocusNode,
                onFieldSubmitted: (_) async {
                  FFAppState().updatePointCStruct(
                        (e) => e
                      ..flat = model
                          .flatCTextController.text,
                  );
                  safeSetState(() {});
                },
                autofocus: false,
                textCapitalization:
                TextCapitalization.sentences,
                textInputAction:
                TextInputAction.next,
                obscureText: false,
                decoration: InputDecoration(
                  isDense: false,
                  labelText: 'Кв./офис',
                  labelStyle:
                  FlutterFlowTheme.of(context)
                      .labelMedium
                      .override(
                    fontFamily: 'SF',
                    color:
                    Color(0xFF8F8F8E),
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                  ),
                  enabledBorder:
                  UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFD0CFCE),
                      width: 0.3,
                    ),
                    borderRadius:
                    BorderRadius.circular(0.0),
                  ),
                  focusedBorder:
                  UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFD0CFCE),
                      width: 0.3,
                    ),
                    borderRadius:
                    BorderRadius.circular(0.0),
                  ),
                  errorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: FlutterFlowTheme.of(
                          context)
                          .error,
                      width: 0.3,
                    ),
                    borderRadius:
                    BorderRadius.circular(0.0),
                  ),
                  focusedErrorBorder:
                  UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: FlutterFlowTheme.of(
                          context)
                          .error,
                      width: 0.3,
                    ),
                    borderRadius:
                    BorderRadius.circular(0.0),
                  ),
                  contentPadding:
                  EdgeInsetsDirectional
                      .fromSTEB(
                      0.0, 8.0, 0.0, 8.0),
                  hoverColor: Colors.transparent,
                ),
                style: FlutterFlowTheme.of(context)
                    .bodyMedium
                    .override(
                  fontFamily: 'SF',
                  fontSize: 16.0,
                  letterSpacing: 0.0,
                ),
                cursorColor:
                FlutterFlowTheme.of(context)
                    .primaryText,
                validator: model
                    .flatCTextControllerValidator
                    .asValidator(context),
                inputFormatters: [
                  if (!isAndroid && !isiOS)
                    TextInputFormatter.withFunction(
                            (oldValue, newValue) {
                          return TextEditingValue(
                            selection:
                            newValue.selection,
                            text: newValue.text
                                .toCapitalization(
                                TextCapitalization
                                    .sentences),
                          );
                        }),
                ],
              ),
            ),
          ].divide(SizedBox(width: 16.0)),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller:
                model.floorCTextController,
                focusNode: model.floorCFocusNode,
                onFieldSubmitted: (_) async {
                  FFAppState().updatePointCStruct(
                        (e) => e
                      ..floor = int.tryParse(model
                          .floorCTextController
                          .text),
                  );
                  safeSetState(() {});
                },
                autofocus: false,
                textCapitalization:
                TextCapitalization.sentences,
                textInputAction:
                TextInputAction.next,
                obscureText: false,
                decoration: InputDecoration(
                  isDense: false,
                  labelText: 'Этаж',
                  labelStyle:
                  FlutterFlowTheme.of(context)
                      .labelMedium
                      .override(
                    fontFamily: 'SF',
                    color:
                    Color(0xFF8F8F8E),
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                  ),
                  enabledBorder:
                  UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFD0CFCE),
                      width: 0.3,
                    ),
                    borderRadius:
                    BorderRadius.circular(0.0),
                  ),
                  focusedBorder:
                  UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFD0CFCE),
                      width: 0.3,
                    ),
                    borderRadius:
                    BorderRadius.circular(0.0),
                  ),
                  errorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: FlutterFlowTheme.of(
                          context)
                          .error,
                      width: 0.3,
                    ),
                    borderRadius:
                    BorderRadius.circular(0.0),
                  ),
                  focusedErrorBorder:
                  UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: FlutterFlowTheme.of(
                          context)
                          .error,
                      width: 0.3,
                    ),
                    borderRadius:
                    BorderRadius.circular(0.0),
                  ),
                  contentPadding:
                  EdgeInsetsDirectional
                      .fromSTEB(
                      0.0, 8.0, 0.0, 8.0),
                  hoverColor: Colors.transparent,
                ),
                style: FlutterFlowTheme.of(context)
                    .bodyMedium
                    .override(
                  fontFamily: 'SF',
                  fontSize: 16.0,
                  letterSpacing: 0.0,
                ),
                cursorColor:
                FlutterFlowTheme.of(context)
                    .primaryText,
                validator: model
                    .floorCTextControllerValidator
                    .asValidator(context),
                inputFormatters: [
                  if (!isAndroid && !isiOS)
                    TextInputFormatter.withFunction(
                            (oldValue, newValue) {
                          return TextEditingValue(
                            selection:
                            newValue.selection,
                            text: newValue.text
                                .toCapitalization(
                                TextCapitalization
                                    .sentences),
                          );
                        }),
                ],
              ),
            ),
            Expanded(
              child: TextFormField(
                controller:
                model.intercomCTextController,
                focusNode:
                model.intercomCFocusNode,
                onFieldSubmitted: (_) async {
                  FFAppState().updatePointCStruct(
                        (e) => e
                      ..intercom = model
                          .intercomCTextController
                          .text,
                  );
                  safeSetState(() {});
                },
                autofocus: false,
                textCapitalization:
                TextCapitalization.sentences,
                textInputAction:
                TextInputAction.next,
                obscureText: false,
                decoration: InputDecoration(
                  isDense: false,
                  labelText: 'Домофон',
                  labelStyle:
                  FlutterFlowTheme.of(context)
                      .labelMedium
                      .override(
                    fontFamily: 'SF',
                    color:
                    Color(0xFF8F8F8E),
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                  ),
                  enabledBorder:
                  UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFD0CFCE),
                      width: 0.3,
                    ),
                    borderRadius:
                    BorderRadius.circular(0.0),
                  ),
                  focusedBorder:
                  UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFD0CFCE),
                      width: 0.3,
                    ),
                    borderRadius:
                    BorderRadius.circular(0.0),
                  ),
                  errorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: FlutterFlowTheme.of(
                          context)
                          .error,
                      width: 0.3,
                    ),
                    borderRadius:
                    BorderRadius.circular(0.0),
                  ),
                  focusedErrorBorder:
                  UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: FlutterFlowTheme.of(
                          context)
                          .error,
                      width: 0.3,
                    ),
                    borderRadius:
                    BorderRadius.circular(0.0),
                  ),
                  contentPadding:
                  EdgeInsetsDirectional
                      .fromSTEB(
                      0.0, 8.0, 0.0, 8.0),
                  hoverColor: Colors.transparent,
                ),
                style: FlutterFlowTheme.of(context)
                    .bodyMedium
                    .override(
                  fontFamily: 'SF',
                  fontSize: 16.0,
                  letterSpacing: 0.0,
                ),
                cursorColor:
                FlutterFlowTheme.of(context)
                    .primaryText,
                validator: model
                    .intercomCTextControllerValidator
                    .asValidator(context),
                inputFormatters: [
                  if (!isAndroid && !isiOS)
                    TextInputFormatter.withFunction(
                            (oldValue, newValue) {
                          return TextEditingValue(
                            selection:
                            newValue.selection,
                            text: newValue.text
                                .toCapitalization(
                                TextCapitalization
                                    .sentences),
                          );
                        }),
                ],
              ),
            ),
          ].divide(SizedBox(width: 16.0)),
        ),
        Container(
          width: double.infinity,
          child: TextFormField(
            controller:
            model.commentCTextController,
            focusNode: model.commentCFocusNode,
            onChanged: (_) => EasyDebounce.debounce(
              'model.commentCTextController',
              Duration(milliseconds: 0),
                  () => safeSetState(() {}),
            ),
            onFieldSubmitted: (_) async {
              FFAppState().updatePointCStruct(
                    (e) => e
                  ..comment = model
                      .commentCTextController.text,
              );
              safeSetState(() {});
            },
            autofocus: false,
            textCapitalization:
            TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            obscureText: false,
            decoration: InputDecoration(
              isDense: false,
              labelText: 'Комментарий водителю',
              labelStyle:
              FlutterFlowTheme.of(context)
                  .labelMedium
                  .override(
                fontFamily: 'SF',
                color: Color(0xFF8F8F8E),
                fontSize: 16.0,
                letterSpacing: 0.0,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFFD0CFCE),
                  width: 0.3,
                ),
                borderRadius:
                BorderRadius.circular(0.0),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFFD0CFCE),
                  width: 0.3,
                ),
                borderRadius:
                BorderRadius.circular(0.0),
              ),
              errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color:
                  FlutterFlowTheme.of(context)
                      .error,
                  width: 0.3,
                ),
                borderRadius:
                BorderRadius.circular(0.0),
              ),
              focusedErrorBorder:
              UnderlineInputBorder(
                borderSide: BorderSide(
                  color:
                  FlutterFlowTheme.of(context)
                      .error,
                  width: 0.3,
                ),
                borderRadius:
                BorderRadius.circular(0.0),
              ),
              contentPadding:
              EdgeInsetsDirectional.fromSTEB(
                  0.0, 8.0, 0.0, 8.0),
              hoverColor: Colors.transparent,
            ),
            style: FlutterFlowTheme.of(context)
                .bodyMedium
                .override(
              fontFamily: 'SF',
              fontSize: 16.0,
              letterSpacing: 0.0,
            ),
            maxLength: 300,
            cursorColor:
            FlutterFlowTheme.of(context)
                .primaryText,
            validator: model
                .commentCTextControllerValidator
                .asValidator(context),
            inputFormatters: [
              if (!isAndroid && !isiOS)
                TextInputFormatter.withFunction(
                        (oldValue, newValue) {
                      return TextEditingValue(
                        selection: newValue.selection,
                        text: newValue.text
                            .toCapitalization(
                            TextCapitalization
                                .sentences),
                      );
                    }),
            ],
          ),
        ),
        InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            await showModalBottomSheet(
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              context: context,
              builder: (context) {
                return WebViewAware(
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context)
                          .unfocus();
                      FocusManager
                          .instance.primaryFocus
                          ?.unfocus();
                    },
                    child: Padding(
                      padding:
                      MediaQuery.viewInsetsOf(
                          context),
                      child: RecipientWidget(point: 'C',),
                    ),
                  ),
                );
              },
            ).then((value) => safeSetState(() {}));
          },
          child: Container(
            width: double.infinity,
            height: 57.0,
            decoration: BoxDecoration(),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              crossAxisAlignment:
              CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    'Контакт получателя*',
                    style:
                    FlutterFlowTheme.of(context)
                        .bodyMedium
                        .override(
                      fontFamily: 'SF',
                      fontSize: 16.0,
                      letterSpacing: 0.0,
                      lineHeight: 1.0,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment:
                  MainAxisAlignment.end,
                  children: [
                    if (FFAppState()
                        .pointC
                        .sender !=
                        null)
                      Padding(
                        padding:
                        EdgeInsetsDirectional
                            .fromSTEB(0.0, 0.0,
                            8.0, 0.0),
                        child: Text(
                          valueOrDefault<String>(
                            FFAppState()
                                .pointC
                                .sender != null ? functions
                                .formatPhoneNumber1(
                                FFAppState()
                                    .pointC
                                    .sender
                                    .phone)
                                : '  ',
                            'Номер телефона',
                          ),
                          style: FlutterFlowTheme
                              .of(context)
                              .bodyMedium
                              .override(
                            fontFamily: 'SF',
                            color: FlutterFlowTheme
                                .of(context)
                                .secondaryText,
                            fontSize: 14.0,
                            letterSpacing: 0.0,
                            lineHeight: 1.0,
                          ),
                        ),
                      ),
                    Icon(
                      FFIcons.kiconrightStroke,
                      color: FlutterFlowTheme.of(
                          context)
                          .primaryText,
                      size: 12.0,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
