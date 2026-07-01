import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'searh_address_model.dart';
export 'searh_address_model.dart';

class SearhAddressWidget extends StatefulWidget {
  const SearhAddressWidget({
    super.key,
    required this.index,
  });

  final int? index;

  @override
  State<SearhAddressWidget> createState() => _SearhAddressWidgetState();
}

class _SearhAddressWidgetState extends State<SearhAddressWidget> {
  late SearhAddressModel _model;

  LatLng? currentUserLocationValue;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SearhAddressModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (widget!.index == 1) {
        safeSetState(() {
          _model.pointATextController?.text = FFAppState().pointA.address;
          _model.pointAFocusNode?.requestFocus();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _model.pointATextController?.selection = TextSelection.collapsed(
              offset: _model.pointATextController!.text.length,
            );
          });
        });
        safeSetState(() {
          _model.pointBTextController?.text = FFAppState().pointB.address;
        });
        _model.currentPoint = 1;
        safeSetState(() {});
      } else {
        safeSetState(() {
          _model.pointATextController?.text = FFAppState().pointA.address;
        });
        if (FFAppState().pointB != null) {
          safeSetState(() {
            _model.pointBTextController?.text = FFAppState().pointB.address;
            _model.pointBFocusNode?.requestFocus();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _model.pointBTextController?.selection = TextSelection.collapsed(
                offset: _model.pointBTextController!.text.length,
              );
            });
          });
        } else {
          safeSetState(() {
            _model.pointBTextController?.text = '';
            _model.pointBFocusNode?.requestFocus();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _model.pointBTextController?.selection =
                  const TextSelection.collapsed(offset: 0);
            });
          });
        }

        _model.currentPoint = 2;
        safeSetState(() {});
      }
    });

    _model.pointATextController ??= TextEditingController();
    _model.pointAFocusNode ??= FocusNode();
    _model.pointAFocusNode!.addListener(
      () async {
        _model.currentPoint = 1;
        safeSetState(() {});
      },
    );
    _model.pointBTextController ??= TextEditingController();
    _model.pointBFocusNode ??= FocusNode();
    _model.pointBFocusNode!.addListener(
      () async {
        _model.currentPoint = 2;
        safeSetState(() {});
      },
    );
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 50.0, 0.0, 0.0),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          boxShadow: [
            BoxShadow(
              blurRadius: 4.0,
              color: Colors.black,
              offset: Offset(
                0.0,
                4.0,
              ),
              spreadRadius: 0.0,
            )
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(14.0),
            topRight: Radius.circular(14.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 5.0, 0.0, 8.0),
              child: Container(
                width: 39.0,
                height: 5.0,
                decoration: BoxDecoration(
                  color: Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(28.0),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 30.0,
                      color: Color(0x1E090909),
                      offset: Offset(
                        0.0,
                        0.0,
                      ),
                      spreadRadius: 2.0,
                    )
                  ],
                  borderRadius: BorderRadius.circular(17.0),
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(12.0, 4.0, 0.0, 4.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Builder(
                            builder: (context) {
                              if ((_model.pointAFocusNode?.hasFocus ?? false)) {
                                return FaIcon(
                                  FontAwesomeIcons.search,
                                  color: FlutterFlowTheme.of(context).tertiary,
                                  size: 17.0,
                                );
                              } else {
                                return Container(
                                  width: 16.0,
                                  height: 16.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Color(0xFFA4A6B2),
                                      width: 3.0,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  8.0, 0.0, 0.0, 0.0),
                              child: Container(
                                width: double.infinity,
                                child: TextFormField(
                                  controller: _model.pointATextController,
                                  focusNode: _model.pointAFocusNode,
                                  onChanged: (_) => EasyDebounce.debounce(
                                    '_model.pointATextController',
                                    Duration(milliseconds: 0),
                                    () async {
                                      currentUserLocationValue =
                                          await getCurrentUserLocation(
                                              defaultLocation:
                                                  LatLng(0.0, 0.0));
                                      _model.apiResult1veA =
                                          await AutocompleteCall.call(
                                        input: _model.pointATextController.text,
                                        location: currentUserLocationValue
                                            ?.toString(),
                                      );

                                      safeSetState(() {});
                                    },
                                  ),
                                  autofocus: false,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  textInputAction: TextInputAction.search,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    isDense: false,
                                    hintText: 'Откуда забрать',
                                    hintStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'SF',
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          fontSize: 16.0,
                                          letterSpacing: 0.0,
                                        ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                    errorBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                    focusedErrorBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                    contentPadding:
                                        EdgeInsetsDirectional.fromSTEB(
                                            0.0, 15.0, 0.0, 15.0),
                                    hoverColor: Colors.transparent,
                                    suffixIcon: _model.pointATextController!
                                            .text.isNotEmpty
                                        ? InkWell(
                                            onTap: () async {
                                              _model.pointATextController
                                                  ?.clear();
                                              currentUserLocationValue =
                                                  await getCurrentUserLocation(
                                                      defaultLocation:
                                                          LatLng(0.0, 0.0));
                                              _model.apiResult1veA =
                                                  await AutocompleteCall.call(
                                                input: _model
                                                    .pointATextController.text,
                                                location:
                                                    currentUserLocationValue
                                                        ?.toString(),
                                              );

                                              safeSetState(() {});
                                              safeSetState(() {});
                                            },
                                            child: Icon(
                                              Icons.clear,
                                              size: 24.0,
                                            ),
                                          )
                                        : null,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'SF',
                                        color: valueOrDefault<Color>(
                                          (_model.pointBFocusNode?.hasFocus ??
                                                      false) &&
                                                  (FFAppState()
                                                              .pointA
                                                              .address ==
                                                          null ||
                                                      FFAppState()
                                                              .pointA
                                                              .address ==
                                                          '')
                                              ? FlutterFlowTheme.of(context)
                                                  .error
                                              : FlutterFlowTheme.of(context)
                                                  .primaryText,
                                          FlutterFlowTheme.of(context)
                                              .primaryText,
                                        ),
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                      ),
                                  cursorColor:
                                      FlutterFlowTheme.of(context).primaryText,
                                  validator: _model
                                      .pointATextControllerValidator
                                      .asValidator(context),
                                  inputFormatters: [
                                    if (!isAndroid && !isiOS)
                                      TextInputFormatter.withFunction(
                                          (oldValue, newValue) {
                                        return TextEditingValue(
                                          selection: newValue.selection,
                                          text: newValue.text.toCapitalization(
                                              TextCapitalization.sentences),
                                        );
                                      }),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Builder(
                            builder: (context) {
                              if ((_model.pointBFocusNode?.hasFocus ?? false)) {
                                return FaIcon(
                                  FontAwesomeIcons.search,
                                  color: FlutterFlowTheme.of(context).tertiary,
                                  size: 17.0,
                                );
                              } else {
                                return Container(
                                  width: 16.0,
                                  height: 16.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Color(0xFFA4A6B2),
                                      width: 3.0,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  8.0, 0.0, 0.0, 0.0),
                              child: Container(
                                width: double.infinity,
                                child: TextFormField(
                                  controller: _model.pointBTextController,
                                  focusNode: _model.pointBFocusNode,
                                  onChanged: (_) => EasyDebounce.debounce(
                                    '_model.pointBTextController',
                                    Duration(milliseconds: 0),
                                    () async {
                                      currentUserLocationValue =
                                          await getCurrentUserLocation(
                                              defaultLocation:
                                                  LatLng(0.0, 0.0));
                                      _model.apiResult1veB =
                                          await AutocompleteCall.call(
                                        input: _model.pointBTextController.text,
                                        location: currentUserLocationValue
                                            ?.toString(),
                                      );

                                      safeSetState(() {});
                                    },
                                  ),
                                  autofocus: false,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  textInputAction: TextInputAction.search,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    isDense: false,
                                    hintText: 'Куда доставить',
                                    hintStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'SF',
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          fontSize: 16.0,
                                          letterSpacing: 0.0,
                                        ),
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                    contentPadding:
                                        EdgeInsetsDirectional.fromSTEB(
                                            0.0, 15.0, 0.0, 15.0),
                                    hoverColor: Colors.transparent,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'SF',
                                        color: valueOrDefault<Color>(
                                          (_model.pointAFocusNode?.hasFocus ??
                                                      false) &&
                                                  (FFAppState()
                                                              .pointB
                                                              .address ==
                                                          null ||
                                                      FFAppState()
                                                              .pointB
                                                              .address ==
                                                          '')
                                              ? FlutterFlowTheme.of(context)
                                                  .error
                                              : FlutterFlowTheme.of(context)
                                                  .primaryText,
                                          FlutterFlowTheme.of(context)
                                              .primaryText,
                                        ),
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                      ),
                                  cursorColor:
                                      FlutterFlowTheme.of(context).primaryText,
                                  validator: _model
                                      .pointBTextControllerValidator
                                      .asValidator(context),
                                  inputFormatters: [
                                    if (!isAndroid && !isiOS)
                                      TextInputFormatter.withFunction(
                                          (oldValue, newValue) {
                                        return TextEditingValue(
                                          selection: newValue.selection,
                                          text: newValue.text.toCapitalization(
                                              TextCapitalization.sentences),
                                        );
                                      }),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (_model.pointBTextController.text != null &&
                              _model.pointBTextController.text != '')
                            FlutterFlowIconButton(
                              borderRadius: 8.0,
                              buttonSize: 40.0,
                              hoverColor: Colors.transparent,
                              hoverIconColor: valueOrDefault<Color>(
                                (_model.pointBFocusNode?.hasFocus ?? false)
                                    ? FlutterFlowTheme.of(context).tertiary
                                    : FlutterFlowTheme.of(context)
                                        .secondaryText,
                                FlutterFlowTheme.of(context).secondaryText,
                              ),
                              icon: Icon(
                                FFIcons.kkrestStroke,
                                color: valueOrDefault<Color>(
                                  (_model.pointBFocusNode?.hasFocus ?? false)
                                      ? FlutterFlowTheme.of(context).tertiary
                                      : FlutterFlowTheme.of(context)
                                          .secondaryText,
                                  FlutterFlowTheme.of(context).secondaryText,
                                ),
                                size: 16.0,
                              ),
                              onPressed: () async {
                                safeSetState(() {
                                  _model.pointBTextController?.clear();
                                });
                                FFAppState().pointB = PointStruct();
                                safeSetState(() {});
                              },
                            ),
                        ],
                      ),
                    ].divide(SizedBox(height: 4.0)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 100.0,
                child: Stack(
                  children: [
                    if (((_model.currentPoint == 1) &&
                            (_model.pointATextController.text != null &&
                                _model.pointATextController.text != '')) ||
                        ((_model.currentPoint == 2) &&
                            (_model.pointBTextController.text != null &&
                                _model.pointBTextController.text != '')))
                      Builder(
                        builder: (context) {
                          if (_model.currentPoint == 1) {
                            return Builder(
                              builder: (context) {
                                final aAAList = AutocompleteCall.addresses(
                                      (_model.apiResult1veA?.jsonBody ?? ''),
                                    )?.toList() ??
                                    [];

                                return ListView.builder(
                                  padding: EdgeInsets.fromLTRB(
                                    0,
                                    12.0,
                                    0,
                                    0,
                                  ),
                                  scrollDirection: Axis.vertical,
                                  itemCount: aAAList.length,
                                  itemBuilder: (context, aAAListIndex) {
                                    final aAAListItem = aAAList[aAAListIndex];
                                    return InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        var _shouldSetState = false;
                                        _model.geocodeAAA =
                                            await GeocodePlaceIDCall.call(
                                          placeId: AutocompleteCall.placeid(
                                            (_model.apiResult1veA?.jsonBody ??
                                                ''),
                                          )?.elementAtOrNull(aAAListIndex),
                                        );

                                        _shouldSetState = true;
                                        if (('${GeocodePlaceIDCall.street(
                                                      (_model.geocodeAAA
                                                              ?.jsonBody ??
                                                          ''),
                                                    ) != null && GeocodePlaceIDCall.street(
                                                      (_model.geocodeAAA
                                                              ?.jsonBody ??
                                                          ''),
                                                    ) != '' ? GeocodePlaceIDCall.street(
                                                    (_model.geocodeAAA
                                                            ?.jsonBody ??
                                                        ''),
                                                  ) : GeocodePlaceIDCall.address(
                                                    (_model.geocodeAAA
                                                            ?.jsonBody ??
                                                        ''),
                                                  )} ' !=
                                                _model.pointATextController
                                                    .text) &&
                                            (GeocodePlaceIDCall.number(
                                                      (_model.geocodeAAA
                                                              ?.jsonBody ??
                                                          ''),
                                                    ) ==
                                                    null ||
                                                GeocodePlaceIDCall.number(
                                                      (_model.geocodeAAA
                                                              ?.jsonBody ??
                                                          ''),
                                                    ) ==
                                                    '')) {
                                          safeSetState(() {
                                            _model.pointATextController?.text =
                                                '${GeocodePlaceIDCall.street(
                                                      (_model.geocodeAAA
                                                              ?.jsonBody ??
                                                          ''),
                                                    ) != null && GeocodePlaceIDCall.street(
                                                      (_model.geocodeAAA
                                                              ?.jsonBody ??
                                                          ''),
                                                    ) != '' ? GeocodePlaceIDCall.street(
                                                    (_model.geocodeAAA
                                                            ?.jsonBody ??
                                                        ''),
                                                  ) : GeocodePlaceIDCall.address(
                                                    (_model.geocodeAAA
                                                            ?.jsonBody ??
                                                        ''),
                                                  )} ';
                                            _model.pointAFocusNode
                                                ?.requestFocus();
                                            WidgetsBinding.instance
                                                .addPostFrameCallback((_) {
                                              _model.pointATextController
                                                      ?.selection =
                                                  TextSelection.collapsed(
                                                offset: _model
                                                    .pointATextController!
                                                    .text
                                                    .length,
                                              );
                                            });
                                          });
                                          if (_shouldSetState)
                                            safeSetState(() {});
                                          return;
                                        } else {
                                          if (_model.pointBTextController
                                                      .text !=
                                                  null &&
                                              _model.pointBTextController
                                                      .text !=
                                                  '') {
                                            FFAppState().pointA = PointStruct(
                                              latlng: functions
                                                  .convertLatLngFromStrings(
                                                      GeocodePlaceIDCall.lat(
                                                        (_model.geocodeAAA
                                                                ?.jsonBody ??
                                                            ''),
                                                      )!
                                                          .toString(),
                                                      GeocodePlaceIDCall.lng(
                                                        (_model.geocodeAAA
                                                                ?.jsonBody ??
                                                            ''),
                                                      )!
                                                          .toString()),
                                              placeID: AutocompleteCall.placeid(
                                                (_model.apiResult1veA
                                                        ?.jsonBody ??
                                                    ''),
                                              )?.elementAtOrNull(aAAListIndex),
                                              address: GeocodePlaceIDCall
                                                              .number(
                                                            (_model.geocodeAAA
                                                                    ?.jsonBody ??
                                                                ''),
                                                          ) !=
                                                          null &&
                                                      GeocodePlaceIDCall.number(
                                                            (_model.geocodeAAA
                                                                    ?.jsonBody ??
                                                                ''),
                                                          ) !=
                                                          ''
                                                  ? '${GeocodePlaceIDCall.street(
                                                      (_model.geocodeAAA
                                                              ?.jsonBody ??
                                                          ''),
                                                    )}, ${GeocodePlaceIDCall.number(
                                                      (_model.geocodeAAA
                                                              ?.jsonBody ??
                                                          ''),
                                                    )}'
                                                  : (GeocodePlaceIDCall.street(
                                                                (_model.geocodeAAA
                                                                        ?.jsonBody ??
                                                                    ''),
                                                              ) !=
                                                              null &&
                                                          GeocodePlaceIDCall
                                                                  .street(
                                                                (_model.geocodeAAA
                                                                        ?.jsonBody ??
                                                                    ''),
                                                              ) !=
                                                              ''
                                                      ? GeocodePlaceIDCall
                                                          .street(
                                                          (_model.geocodeAAA
                                                                  ?.jsonBody ??
                                                              ''),
                                                        )
                                                      : GeocodePlaceIDCall
                                                          .address(
                                                          (_model.geocodeAAA
                                                                  ?.jsonBody ??
                                                              ''),
                                                        )),
                                              fullAddress:
                                                  GeocodePlaceIDCall.address(
                                                (_model.geocodeAAA?.jsonBody ??
                                                    ''),
                                              ),
                                              city: GeocodePlaceIDCall.city(
                                                (_model.geocodeAAA?.jsonBody ??
                                                    ''),
                                              ),
                                              region: GeocodePlaceIDCall.areal(
                                                (_model.geocodeAAA?.jsonBody ??
                                                    ''),
                                              ),
                                            );
                                            safeSetState(() {});
                                            Navigator.pop(context);
                                            _model.adsd2 =
                                                await DistanceMatrixCall.call(
                                              destination:
                                                  '${functions.extractLatLong(FFAppState().pointB.latlng!, true).toString()},${functions.extractLatLong(FFAppState().pointB.latlng!, false).toString()}',
                                              origin:
                                                  '${functions.extractLatLong(FFAppState().pointA.latlng!, true).toString()},${functions.extractLatLong(FFAppState().pointA.latlng!, false).toString()}',
                                            );

                                            _shouldSetState = true;
                                            FFAppState().distanceTime =
                                                DistanceMatrixCall.time(
                                              (_model.adsd2?.jsonBody ?? ''),
                                            )!;
                                            FFAppState().distanceKm =
                                                DistanceMatrixCall.distance(
                                              (_model.adsd2?.jsonBody ?? ''),
                                            )!;
                                            FFAppState().update(() {});
                                            FFAppState().priceLargus =
                                                functions.newCustomFunction(
                                                    0,
                                                    Car.largus,
                                                    FFAppState().pointA.latlng!,
                                                    FFAppState().pointB.latlng!,
                                                    FFAppState().distanceTime,
                                                    FFAppState().distanceKm);
                                            FFAppState().priceTermo =
                                                functions.newCustomFunction(
                                                    0,
                                                    Car.largusTermo,
                                                    FFAppState().pointA.latlng!,
                                                    FFAppState().pointB.latlng!,
                                                    FFAppState().distanceTime,
                                                    FFAppState().distanceKm);
                                            FFAppState().priceFiat =
                                                functions.newCustomFunction(
                                                    0,
                                                    Car.fiat,
                                                    FFAppState().pointA.latlng!,
                                                    FFAppState().pointB.latlng!,
                                                    FFAppState().distanceTime,
                                                    FFAppState().distanceKm);
                                            FFAppState().update(() {});
                                            if (_shouldSetState)
                                              safeSetState(() {});
                                            return;
                                          } else {
                                            FFAppState().pointA = PointStruct(
                                              latlng: functions
                                                  .convertLatLngFromStrings(
                                                      GeocodePlaceIDCall.lat(
                                                        (_model.geocodeAAA
                                                                ?.jsonBody ??
                                                            ''),
                                                      )!
                                                          .toString(),
                                                      GeocodePlaceIDCall.lng(
                                                        (_model.geocodeAAA
                                                                ?.jsonBody ??
                                                            ''),
                                                      )!
                                                          .toString()),
                                              placeID: AutocompleteCall.placeid(
                                                (_model.apiResult1veA
                                                        ?.jsonBody ??
                                                    ''),
                                              )?.elementAtOrNull(aAAListIndex),
                                              address: GeocodePlaceIDCall
                                                              .number(
                                                            (_model.geocodeAAA
                                                                    ?.jsonBody ??
                                                                ''),
                                                          ) !=
                                                          null &&
                                                      GeocodePlaceIDCall.number(
                                                            (_model.geocodeAAA
                                                                    ?.jsonBody ??
                                                                ''),
                                                          ) !=
                                                          ''
                                                  ? '${GeocodePlaceIDCall.street(
                                                      (_model.geocodeAAA
                                                              ?.jsonBody ??
                                                          ''),
                                                    )}, ${GeocodePlaceIDCall.number(
                                                      (_model.geocodeAAA
                                                              ?.jsonBody ??
                                                          ''),
                                                    )}'
                                                  : (GeocodePlaceIDCall.street(
                                                                (_model.geocodeAAA
                                                                        ?.jsonBody ??
                                                                    ''),
                                                              ) !=
                                                              null &&
                                                          GeocodePlaceIDCall
                                                                  .street(
                                                                (_model.geocodeAAA
                                                                        ?.jsonBody ??
                                                                    ''),
                                                              ) !=
                                                              ''
                                                      ? GeocodePlaceIDCall
                                                          .street(
                                                          (_model.geocodeAAA
                                                                  ?.jsonBody ??
                                                              ''),
                                                        )
                                                      : GeocodePlaceIDCall
                                                          .address(
                                                          (_model.geocodeAAA
                                                                  ?.jsonBody ??
                                                              ''),
                                                        )),
                                              fullAddress:
                                                  GeocodePlaceIDCall.address(
                                                (_model.geocodeAAA?.jsonBody ??
                                                    ''),
                                              ),
                                              city: GeocodePlaceIDCall.city(
                                                (_model.geocodeAAA?.jsonBody ??
                                                    ''),
                                              ),
                                              region: GeocodePlaceIDCall.areal(
                                                (_model.geocodeAAA?.jsonBody ??
                                                    ''),
                                              ),
                                            );
                                            FFAppState().update(() {});
                                            safeSetState(() {
                                              _model.pointBTextController
                                                  ?.text = '';
                                              _model.pointBFocusNode
                                                  ?.requestFocus();
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) {
                                                _model.pointBTextController
                                                        ?.selection =
                                                    const TextSelection
                                                        .collapsed(offset: 0);
                                              });
                                            });
                                            if (_shouldSetState)
                                              safeSetState(() {});
                                            return;
                                          }
                                        }

                                        if (_shouldSetState)
                                          safeSetState(() {});
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  24.0, 14.0, 24.0, 14.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                aAAListItem,
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          fontSize: 16.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                              ),
                                              if ((AutocompleteCall.region(
                                                        (_model.apiResult1veA
                                                                ?.jsonBody ??
                                                            ''),
                                                      )?.elementAtOrNull(
                                                          aAAListIndex)) !=
                                                      null &&
                                                  (AutocompleteCall.region(
                                                        (_model.apiResult1veA
                                                                ?.jsonBody ??
                                                            ''),
                                                      )?.elementAtOrNull(
                                                          aAAListIndex)) !=
                                                      '')
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 6.0, 0.0, 0.0),
                                                  child: Text(
                                                    (AutocompleteCall.region(
                                                      (_model.apiResult1veA
                                                              ?.jsonBody ??
                                                          ''),
                                                    )!
                                                        .elementAtOrNull(
                                                            aAAListIndex))!,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText,
                                                          fontSize: 14.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          } else {
                            return Builder(
                              builder: (context) {
                                final bBBList = AutocompleteCall.addresses(
                                      (_model.apiResult1veB?.jsonBody ?? ''),
                                    )?.toList() ??
                                    [];

                                return ListView.builder(
                                  padding: EdgeInsets.fromLTRB(
                                    0,
                                    12.0,
                                    0,
                                    0,
                                  ),
                                  scrollDirection: Axis.vertical,
                                  itemCount: bBBList.length,
                                  itemBuilder: (context, bBBListIndex) {
                                    final bBBListItem = bBBList[bBBListIndex];
                                    return InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        _model.geocodeBBB =
                                            await GeocodePlaceIDCall.call(
                                          placeId: AutocompleteCall.placeid(
                                            (_model.apiResult1veB?.jsonBody ??
                                                ''),
                                          )?.elementAtOrNull(bBBListIndex),
                                        );

                                        if (('${GeocodePlaceIDCall.street(
                                                      (_model.geocodeBBB
                                                              ?.jsonBody ??
                                                          ''),
                                                    ) != null && GeocodePlaceIDCall.street(
                                                      (_model.geocodeBBB
                                                              ?.jsonBody ??
                                                          ''),
                                                    ) != '' ? GeocodePlaceIDCall.street(
                                                    (_model.geocodeBBB
                                                            ?.jsonBody ??
                                                        ''),
                                                  ) : GeocodePlaceIDCall.address(
                                                    (_model.geocodeBBB
                                                            ?.jsonBody ??
                                                        ''),
                                                  )} ' !=
                                                _model.pointBTextController
                                                    .text) &&
                                            (GeocodePlaceIDCall.number(
                                                      (_model.geocodeBBB
                                                              ?.jsonBody ??
                                                          ''),
                                                    ) ==
                                                    null ||
                                                GeocodePlaceIDCall.number(
                                                      (_model.geocodeBBB
                                                              ?.jsonBody ??
                                                          ''),
                                                    ) ==
                                                    '')) {
                                          safeSetState(() {
                                            _model.pointBTextController?.text =
                                                '${GeocodePlaceIDCall.street(
                                                      (_model.geocodeBBB
                                                              ?.jsonBody ??
                                                          ''),
                                                    ) != null && GeocodePlaceIDCall.street(
                                                      (_model.geocodeBBB
                                                              ?.jsonBody ??
                                                          ''),
                                                    ) != '' ? GeocodePlaceIDCall.street(
                                                    (_model.geocodeBBB
                                                            ?.jsonBody ??
                                                        ''),
                                                  ) : GeocodePlaceIDCall.address(
                                                    (_model.geocodeBBB
                                                            ?.jsonBody ??
                                                        ''),
                                                  )} ';
                                            _model.pointBFocusNode
                                                ?.requestFocus();
                                            WidgetsBinding.instance
                                                .addPostFrameCallback((_) {
                                              _model.pointBTextController
                                                      ?.selection =
                                                  TextSelection.collapsed(
                                                offset: _model
                                                    .pointBTextController!
                                                    .text
                                                    .length,
                                              );
                                            });
                                          });
                                        } else {
                                          FFAppState().pointB = PointStruct(
                                            latlng: functions
                                                .convertLatLngFromStrings(
                                                    GeocodePlaceIDCall.lat(
                                                      (_model.geocodeBBB
                                                              ?.jsonBody ??
                                                          ''),
                                                    )!
                                                        .toString(),
                                                    GeocodePlaceIDCall.lng(
                                                      (_model.geocodeBBB
                                                              ?.jsonBody ??
                                                          ''),
                                                    )!
                                                        .toString()),
                                            placeID: AutocompleteCall.placeid(
                                              (_model.apiResult1veB?.jsonBody ??
                                                  ''),
                                            )?.elementAtOrNull(bBBListIndex),
                                            address: GeocodePlaceIDCall.number(
                                                          (_model.geocodeBBB
                                                                  ?.jsonBody ??
                                                              ''),
                                                        ) !=
                                                        null &&
                                                    GeocodePlaceIDCall.number(
                                                          (_model.geocodeBBB
                                                                  ?.jsonBody ??
                                                              ''),
                                                        ) !=
                                                        ''
                                                ? '${GeocodePlaceIDCall.street(
                                                    (_model.geocodeBBB
                                                            ?.jsonBody ??
                                                        ''),
                                                  )}, ${GeocodePlaceIDCall.number(
                                                    (_model.geocodeBBB
                                                            ?.jsonBody ??
                                                        ''),
                                                  )}'
                                                : (GeocodePlaceIDCall.street(
                                                              (_model.geocodeBBB
                                                                      ?.jsonBody ??
                                                                  ''),
                                                            ) !=
                                                            null &&
                                                        GeocodePlaceIDCall
                                                                .street(
                                                              (_model.geocodeBBB
                                                                      ?.jsonBody ??
                                                                  ''),
                                                            ) !=
                                                            ''
                                                    ? GeocodePlaceIDCall.street(
                                                        (_model.geocodeBBB
                                                                ?.jsonBody ??
                                                            ''),
                                                      )
                                                    : GeocodePlaceIDCall
                                                        .address(
                                                        (_model.geocodeBBB
                                                                ?.jsonBody ??
                                                            ''),
                                                      )),
                                            fullAddress:
                                                GeocodePlaceIDCall.address(
                                              (_model.geocodeBBB?.jsonBody ??
                                                  ''),
                                            ),
                                            city: GeocodePlaceIDCall.city(
                                              (_model.geocodeBBB?.jsonBody ??
                                                  ''),
                                            ),
                                            region: GeocodePlaceIDCall.areal(
                                              (_model.geocodeBBB?.jsonBody ??
                                                  ''),
                                            ),
                                          );
                                          FFAppState().update(() {});
                                          Navigator.pop(context);
                                          _model.adsd =
                                              await DistanceMatrixCall.call(
                                            destination:
                                                '${functions.extractLatLong(FFAppState().pointB.latlng!, true).toString()},${functions.extractLatLong(FFAppState().pointB.latlng!, false).toString()}',
                                            origin:
                                                '${functions.extractLatLong(FFAppState().pointA.latlng!, true).toString()},${functions.extractLatLong(FFAppState().pointA.latlng!, false).toString()}',
                                          );

                                          FFAppState().distanceTime =
                                              DistanceMatrixCall.time(
                                            (_model.adsd?.jsonBody ?? ''),
                                          )!;
                                          FFAppState().distanceKm =
                                              DistanceMatrixCall.distance(
                                            (_model.adsd?.jsonBody ?? ''),
                                          )!;
                                          FFAppState().update(() {});
                                          FFAppState().priceLargus =
                                              functions.newCustomFunction(
                                                  0,
                                                  Car.largus,
                                                  FFAppState().pointA.latlng!,
                                                  FFAppState().pointB.latlng!,
                                                  FFAppState().distanceTime,
                                                  FFAppState().distanceKm);
                                          FFAppState().priceTermo =
                                              functions.newCustomFunction(
                                                  0,
                                                  Car.largusTermo,
                                                  FFAppState().pointA.latlng!,
                                                  FFAppState().pointB.latlng!,
                                                  FFAppState().distanceTime,
                                                  FFAppState().distanceKm);
                                          FFAppState().priceFiat =
                                              functions.newCustomFunction(
                                                  0,
                                                  Car.fiat,
                                                  FFAppState().pointA.latlng!,
                                                  FFAppState().pointB.latlng!,
                                                  FFAppState().distanceTime,
                                                  FFAppState().distanceKm);
                                          FFAppState().update(() {});
                                        }

                                        safeSetState(() {});
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  24.0, 14.0, 24.0, 14.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                bBBListItem,
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          fontSize: 16.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                              ),
                                              if ((AutocompleteCall.region(
                                                        (_model.apiResult1veB
                                                                ?.jsonBody ??
                                                            ''),
                                                      )?.elementAtOrNull(
                                                          bBBListIndex)) !=
                                                      null &&
                                                  (AutocompleteCall.region(
                                                        (_model.apiResult1veB
                                                                ?.jsonBody ??
                                                            ''),
                                                      )?.elementAtOrNull(
                                                          bBBListIndex)) !=
                                                      '')
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 6.0, 0.0, 0.0),
                                                  child: Text(
                                                    (AutocompleteCall.region(
                                                      (_model.apiResult1veB
                                                              ?.jsonBody ??
                                                          ''),
                                                    )!
                                                        .elementAtOrNull(
                                                            bBBListIndex))!,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText,
                                                          fontSize: 14.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          }
                        },
                      ),
                    if (((_model.currentPoint == 1) &&
                            (_model.pointATextController.text == null ||
                                _model.pointATextController.text == '')) ||
                        ((_model.currentPoint == 2) &&
                            (_model.pointBTextController.text == null ||
                                _model.pointBTextController.text == '')))
                      AuthUserStreamWidget(
                        builder: (context) => Builder(
                          builder: (context) {
                            final address =
                                (currentUserDocument?.addresses?.toList() ?? [])
                                    .toList();

                            return ListView.builder(
                              padding: EdgeInsets.fromLTRB(
                                0,
                                12.0,
                                0,
                                0,
                              ),
                              primary: false,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: address.length,
                              itemBuilder: (context, addressIndex) {
                                final addressItem = address[addressIndex];
                                return InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    var _shouldSetState = false;
                                    if (_model.currentPoint == 1) {
                                      if (_model.pointBTextController.text !=
                                              null &&
                                          _model.pointBTextController.text !=
                                              '') {
                                        FFAppState().pointA = addressItem;
                                        FFAppState().update(() {});
                                        Navigator.pop(context);
                                        _model.adsd4 =
                                            await DistanceMatrixCall.call(
                                          destination:
                                              '${functions.extractLatLong(FFAppState().pointB.latlng!, true).toString()},${functions.extractLatLong(FFAppState().pointB.latlng!, false).toString()}',
                                          origin:
                                              '${functions.extractLatLong(FFAppState().pointA.latlng!, true).toString()},${functions.extractLatLong(FFAppState().pointA.latlng!, false).toString()}',
                                        );

                                        _shouldSetState = true;
                                        FFAppState().distanceTime =
                                            DistanceMatrixCall.time(
                                          (_model.adsd4?.jsonBody ?? ''),
                                        )!;
                                        FFAppState().distanceKm =
                                            DistanceMatrixCall.distance(
                                          (_model.adsd4?.jsonBody ?? ''),
                                        )!;
                                        _model.updatePage(() {});
                                        FFAppState().priceLargus =
                                            functions.newCustomFunction(
                                                0,
                                                Car.largus,
                                                FFAppState().pointA.latlng!,
                                                FFAppState().pointB.latlng!,
                                                FFAppState().distanceTime,
                                                FFAppState().distanceKm);
                                        FFAppState().priceTermo =
                                            functions.newCustomFunction(
                                                0,
                                                Car.largusTermo,
                                                FFAppState().pointA.latlng!,
                                                FFAppState().pointB.latlng!,
                                                FFAppState().distanceTime,
                                                FFAppState().distanceKm);
                                        FFAppState().priceFiat =
                                            functions.newCustomFunction(
                                                0,
                                                Car.fiat,
                                                FFAppState().pointA.latlng!,
                                                FFAppState().pointB.latlng!,
                                                FFAppState().distanceTime,
                                                FFAppState().distanceKm);
                                        FFAppState().update(() {});
                                        if (_shouldSetState)
                                          safeSetState(() {});
                                        return;
                                      } else {
                                        FFAppState().pointA = addressItem;
                                        FFAppState().update(() {});
                                        safeSetState(() {
                                          _model.pointATextController?.text =
                                              addressItem.address;
                                        });
                                        safeSetState(() {
                                          _model.pointBTextController?.text =
                                              '';
                                          _model.pointBFocusNode
                                              ?.requestFocus();
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                            _model.pointBTextController
                                                    ?.selection =
                                                const TextSelection.collapsed(
                                                    offset: 0);
                                          });
                                        });
                                        if (_shouldSetState)
                                          safeSetState(() {});
                                        return;
                                      }
                                    } else {
                                      FFAppState().pointB = addressItem;
                                      FFAppState().update(() {});
                                      Navigator.pop(context);
                                      _model.adsd3 =
                                          await DistanceMatrixCall.call(
                                        destination:
                                            '${functions.extractLatLong(FFAppState().pointB.latlng!, true).toString()},${functions.extractLatLong(FFAppState().pointB.latlng!, false).toString()}',
                                        origin:
                                            '${functions.extractLatLong(FFAppState().pointA.latlng!, true).toString()},${functions.extractLatLong(FFAppState().pointA.latlng!, false).toString()}',
                                      );

                                      _shouldSetState = true;
                                      FFAppState().distanceTime =
                                          DistanceMatrixCall.time(
                                        (_model.adsd3?.jsonBody ?? ''),
                                      )!;
                                      FFAppState().distanceKm =
                                          DistanceMatrixCall.distance(
                                        (_model.adsd3?.jsonBody ?? ''),
                                      )!;
                                      FFAppState().update(() {});
                                      FFAppState().priceLargus =
                                          functions.newCustomFunction(
                                              0,
                                              Car.largus,
                                              FFAppState().pointA.latlng!,
                                              FFAppState().pointB.latlng!,
                                              FFAppState().distanceTime,
                                              FFAppState().distanceKm);
                                      FFAppState().priceTermo =
                                          functions.newCustomFunction(
                                              0,
                                              Car.largusTermo,
                                              FFAppState().pointA.latlng!,
                                              FFAppState().pointB.latlng!,
                                              FFAppState().distanceTime,
                                              FFAppState().distanceKm);
                                      FFAppState().priceFiat =
                                          functions.newCustomFunction(
                                              0,
                                              Car.fiat,
                                              FFAppState().pointA.latlng!,
                                              FFAppState().pointB.latlng!,
                                              FFAppState().distanceTime,
                                              FFAppState().distanceKm);
                                      FFAppState().update(() {});
                                      if (_shouldSetState) safeSetState(() {});
                                      return;
                                    }

                                    if (_shouldSetState) safeSetState(() {});
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          24.0, 14.0, 24.0, 14.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            addressItem.address,
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  fontSize: 16.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 6.0, 0.0, 0.0),
                                            child: Text(
                                              addressItem.city,
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText,
                                                        fontSize: 14.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
