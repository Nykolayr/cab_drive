import 'package:cab_drive/customer/create_map_page/domain/entities/entities.dart';

import '../../create_map_page/map_picker/map_picker_widget.dart';
import '../../create_map_page/presentation/bloc/orders_bloc.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
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

  /// Закрывает шторку поиска, не снимая единственный экран go_router.
  void _closeSearchSheet() {
    if (!mounted) return;
    final route = ModalRoute.of(context);
    if (route is PopupRoute && _navigatorCanPopSafe()) {
      Navigator.of(context).pop();
    }
  }

  bool _navigatorCanPopSafe() {
    final navigator = Navigator.maybeOf(context);
    return navigator != null && navigator.canPop();
  }

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
          () {
        if (_model.pointAFocusNode?.hasFocus ?? false) {
          _model.currentPoint = 1;
          safeSetState(() {});
        }
      },
    );
    _model.pointBTextController ??= TextEditingController();
    _model.pointBFocusNode ??= FocusNode();
    _model.pointBFocusNode!.addListener(
          () {
        if (_model.pointBFocusNode?.hasFocus ?? false) {
          _model.currentPoint = 2;
          safeSetState(() {});
        }
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
          color: FlutterFlowTheme
              .of(context)
              .secondaryBackground,
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
            bottomLeft: Radius.circular(0.0),
            bottomRight: Radius.circular(0.0),
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
                  color: FlutterFlowTheme
                      .of(context)
                      .secondaryBackground,
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
                                  color: FlutterFlowTheme
                                      .of(context)
                                      .tertiary,
                                  size: 17.0,
                                );
                              } else {
                                return Container(
                                  width: 16.0,
                                  height: 16.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme
                                        .of(context)
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
                                  onChanged: (_) =>
                                      EasyDebounce.debounce(
                                        '_model.pointATextController',
                                        Duration(milliseconds: 0),
                                            () async {
                                          currentUserLocationValue =
                                          await getCurrentUserLocation(
                                              defaultLocation:
                                              LatLng(0.0, 0.0));
                                          _model.apiResult1veA =
                                          await AutocompleteCall.call(
                                            input: _model.pointATextController
                                                .text,
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
                                    hintStyle: FlutterFlowTheme
                                        .of(context)
                                        .bodyMedium
                                        .override(
                                      fontFamily: 'SF',
                                      color: FlutterFlowTheme
                                          .of(context)
                                          .secondaryText,
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: FlutterFlowTheme
                                            .of(context)
                                            .primaryBackground,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: FlutterFlowTheme
                                            .of(context)
                                            .primaryBackground,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                    errorBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                        FlutterFlowTheme
                                            .of(context)
                                            .error,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                    focusedErrorBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                        FlutterFlowTheme
                                            .of(context)
                                            .error,
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
                                  style: FlutterFlowTheme
                                      .of(context)
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
                                          ? FlutterFlowTheme
                                          .of(context)
                                          .error
                                          : FlutterFlowTheme
                                          .of(context)
                                          .primaryText,
                                      FlutterFlowTheme
                                          .of(context)
                                          .primaryText,
                                    ),
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                  ),
                                  cursorColor:
                                  FlutterFlowTheme
                                      .of(context)
                                      .primaryText,
                                  validator: _model
                                      .pointATextControllerValidator
                                      .asValidator(context),
                                  inputFormatters: [
                                    if (!isAndroid && !isiOS)
                                      TextInputFormatter.withFunction(
                                              (oldValue, newValue) {
                                            return TextEditingValue(
                                              selection: newValue.selection,
                                              text: newValue.text
                                                  .toCapitalization(
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
                                  color: FlutterFlowTheme
                                      .of(context)
                                      .tertiary,
                                  size: 17.0,
                                );
                              } else {
                                return Container(
                                  width: 16.0,
                                  height: 16.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme
                                        .of(context)
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
                                  onChanged: (_) =>
                                      EasyDebounce.debounce(
                                        '_model.pointBTextController',
                                        Duration(milliseconds: 0),
                                            () async {
                                          currentUserLocationValue =
                                          await getCurrentUserLocation(
                                              defaultLocation:
                                              LatLng(0.0, 0.0));
                                          _model.apiResult1veB =
                                          await AutocompleteCall.call(
                                            input: _model.pointBTextController
                                                .text,
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
                                    hintStyle: FlutterFlowTheme
                                        .of(context)
                                        .bodyMedium
                                        .override(
                                      fontFamily: 'SF',
                                      color: FlutterFlowTheme
                                          .of(context)
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
                                  style: FlutterFlowTheme
                                      .of(context)
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
                                          ? FlutterFlowTheme
                                          .of(context)
                                          .error
                                          : FlutterFlowTheme
                                          .of(context)
                                          .primaryText,
                                      FlutterFlowTheme
                                          .of(context)
                                          .primaryText,
                                    ),
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                  ),
                                  cursorColor:
                                  FlutterFlowTheme
                                      .of(context)
                                      .primaryText,
                                  validator: _model
                                      .pointBTextControllerValidator
                                      .asValidator(context),
                                  inputFormatters: [
                                    if (!isAndroid && !isiOS)
                                      TextInputFormatter.withFunction(
                                              (oldValue, newValue) {
                                            return TextEditingValue(
                                              selection: newValue.selection,
                                              text: newValue.text
                                                  .toCapitalization(
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
                                    ? FlutterFlowTheme
                                    .of(context)
                                    .tertiary
                                    : FlutterFlowTheme
                                    .of(context)
                                    .secondaryText,
                                FlutterFlowTheme
                                    .of(context)
                                    .secondaryText,
                              ),
                              icon: Icon(
                                FFIcons.kkrestStroke,
                                color: valueOrDefault<Color>(
                                  (_model.pointBFocusNode?.hasFocus ?? false)
                                      ? FlutterFlowTheme
                                      .of(context)
                                      .tertiary
                                      : FlutterFlowTheme
                                      .of(context)
                                      .secondaryText,
                                  FlutterFlowTheme
                                      .of(context)
                                      .secondaryText,
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
                          Container(
                            width: 0.5,
                            height: 37.0,
                            margin: const EdgeInsetsDirectional.fromSTEB(
                                4.0, 0.0, 0.0, 0.0),
                            color: const Color(0xFFD0CFCE),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () async {
                              final point = _model.currentPoint ?? 1;
                              final rootNavigator =
                                  Navigator.of(context, rootNavigator: true);
                              _closeSearchSheet();
                              await rootNavigator.push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      MapPickerWidget(point: point),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  12.0, 12.0, 16.0, 12.0),
                              child: Text(
                                'Карта',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'SF',
                                      color: const Color(0xFF232222),
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),
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
                        builder: (_context) {
                          if (_model.currentPoint == 1) {
                            return Builder(
                              builder: (context) {
                                final aAAList = AutocompleteCall.addresses(
                                  (_model.apiResult1veA?.jsonBody ?? ''),
                                )?.toList() ??
                                    [];

                                if (aAAList.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
                                    child: Text(
                                      'Ничего не найдено',
                                      style: TextStyle(
                                        fontFamily: 'SF',
                                        color: Color(0xFFA4A6B2),
                                        fontSize: 15.0,
                                      ),
                                    ),
                                  );
                                }

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
                                            ) != null &&
                                                GeocodePlaceIDCall.street(
                                                  (_model.geocodeAAA
                                                      ?.jsonBody ??
                                                      ''),
                                                ) != '' ? GeocodePlaceIDCall
                                                .street(
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
                                            final latlng = functions
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
                                                    .toString());
                                            context.read<OrdersBloc>().add(OrdersEvent.getEtas(userLocation: LocationEntity(lat: latlng.latitude, lng: latlng.longitude)));

                                            FFAppState().pointA = PointStruct(
                                              latlng: latlng,
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
                                                  ? '${GeocodePlaceIDCall
                                                  .street(
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
                                              city: GeocodePlaceIDCall.areal2(
                                                (_model.geocodeAAA?.jsonBody ??
                                                    ''),
                                              ) ?? GeocodePlaceIDCall.city(
                                                (_model.geocodeAAA?.jsonBody ??
                                                    ''),
                                              ),
                                              region: GeocodePlaceIDCall.areal(
                                                (_model.geocodeAAA?.jsonBody ??
                                                    ''),
                                              ),
                                            );
                                            safeSetState(() {});
                                            final ordersBloc = context.read<OrdersBloc>();
                                            _closeSearchSheet();
                                            ordersBloc.add(
                                                OrdersEvent.getPrices(
                                                    userLocation: LocationEntity(
                                                        lat: FFAppState().pointA
                                                            .latlng!.latitude,
                                                        lng: FFAppState().pointA
                                                            .latlng!.longitude),
                                                    destLocation: LocationEntity(
                                                        lat: FFAppState().pointB
                                                            .latlng!.latitude,
                                                        lng: FFAppState().pointB
                                                            .latlng!.longitude),
                                                    intermediate: FFAppState().pointC.address.isNotEmpty ? LocationEntity(
                                                        lat: FFAppState().pointC
                                                            .latlng!.latitude,
                                                        lng: FFAppState().pointC
                                                            .latlng!.longitude) : null,
                                                    movers: 0));
                                            if (_shouldSetState)
                                              safeSetState(() {});
                                            return;
                                          } else {
                                            final latlng = functions
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
                                                    .toString());
                                            context.read<OrdersBloc>().add(OrdersEvent.getEtas(userLocation: LocationEntity(lat: latlng.latitude, lng: latlng.longitude)));

                                            FFAppState().pointA = PointStruct(
                                              latlng: latlng,
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
                                                  ? '${GeocodePlaceIDCall
                                                  .street(
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
                                              city: GeocodePlaceIDCall.areal2(
                                                (_model.geocodeAAA?.jsonBody ??
                                                    ''),
                                              ) ?? GeocodePlaceIDCall.city(
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
                                                FlutterFlowTheme
                                                    .of(context)
                                                    .bodyMedium
                                                    .override(
                                                  font:
                                                  GoogleFonts.inter(
                                                    fontWeight:
                                                    FlutterFlowTheme
                                                        .of(
                                                        context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                    fontStyle:
                                                    FlutterFlowTheme
                                                        .of(
                                                        context)
                                                        .bodyMedium
                                                        .fontStyle,
                                                  ),
                                                  fontSize: 16.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                  FlutterFlowTheme
                                                      .of(
                                                      context)
                                                      .bodyMedium
                                                      .fontWeight,
                                                  fontStyle:
                                                  FlutterFlowTheme
                                                      .of(
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
                                                    style: FlutterFlowTheme
                                                        .of(
                                                        context)
                                                        .bodyMedium
                                                        .override(
                                                      font:
                                                      GoogleFonts.inter(
                                                        fontWeight:
                                                        FlutterFlowTheme
                                                            .of(
                                                            context)
                                                            .bodyMedium
                                                            .fontWeight,
                                                        fontStyle:
                                                        FlutterFlowTheme
                                                            .of(
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
                                                      FlutterFlowTheme
                                                          .of(
                                                          context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                      fontStyle:
                                                      FlutterFlowTheme
                                                          .of(
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
                              builder: (_context) {
                                final bBBList = AutocompleteCall.addresses(
                                  (_model.apiResult1veB?.jsonBody ?? ''),
                                )?.toList() ??
                                    [];

                                if (bBBList.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
                                    child: Text(
                                      'Ничего не найдено',
                                      style: TextStyle(
                                        fontFamily: 'SF',
                                        color: Color(0xFFA4A6B2),
                                        fontSize: 15.0,
                                      ),
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  padding: EdgeInsets.fromLTRB(
                                    0,
                                    12.0,
                                    0,
                                    0,
                                  ),
                                  scrollDirection: Axis.vertical,
                                  itemCount: bBBList.length,
                                  itemBuilder: (_context, bBBListIndex) {
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
                                                    .toString()),);
                                        if( FFAppState().pointB
                                            .latlng != null)
                                        context.read<OrdersBloc>().add(
                                            OrdersEvent.getPrices(
                                                userLocation: LocationEntity(
                                                    lat: FFAppState().pointA
                                                        .latlng!.latitude,
                                                    lng: FFAppState().pointA
                                                        .latlng!.longitude),
                                                destLocation: LocationEntity(
                                                    lat: FFAppState().pointB
                                                        .latlng!.latitude,
                                                    lng: FFAppState().pointB
                                                        .latlng!.longitude),
                                                intermediate: FFAppState().pointC.latlng != null ? LocationEntity(
                                                    lat: FFAppState().pointC
                                                        .latlng!.latitude,
                                                    lng: FFAppState().pointC
                                                        .latlng!.longitude) : null,
                                                movers: 0));


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
                                            ) != null &&
                                                GeocodePlaceIDCall.street(
                                                  (_model.geocodeBBB
                                                      ?.jsonBody ??
                                                      ''),
                                                ) != '' ? GeocodePlaceIDCall
                                                .street(
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
                                            city: GeocodePlaceIDCall.areal2(
                                              (_model.geocodeBBB?.jsonBody ??
                                                  ''),
                                            ) ?? GeocodePlaceIDCall.city(
                                              (_model.geocodeBBB?.jsonBody ??
                                                  ''),
                                            ),
                                            region: GeocodePlaceIDCall.areal(
                                              (_model.geocodeBBB?.jsonBody ??
                                                  ''),
                                            ),
                                          );
                                          FFAppState().update(() {});
                                          final ordersBloc = context.read<OrdersBloc>();
                                          _closeSearchSheet();
                                          ordersBloc.add(
                                              OrdersEvent.getPrices(
                                                  userLocation: LocationEntity(
                                                      lat: FFAppState().pointA
                                                          .latlng!.latitude,
                                                      lng: FFAppState().pointA
                                                          .latlng!.longitude),
                                                  destLocation: LocationEntity(
                                                      lat: FFAppState().pointB
                                                          .latlng!.latitude,
                                                      lng: FFAppState().pointB
                                                          .latlng!.longitude),
                                                  intermediate: FFAppState().pointC.address.isNotEmpty ? LocationEntity(
                                                      lat: FFAppState().pointC
                                                          .latlng!.latitude,
                                                      lng: FFAppState().pointC
                                                          .latlng!.longitude) : null,
                                                  movers: FFAppState().movers));

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
                                                FlutterFlowTheme
                                                    .of(context)
                                                    .bodyMedium
                                                    .override(
                                                  font:
                                                  GoogleFonts.inter(
                                                    fontWeight:
                                                    FlutterFlowTheme
                                                        .of(
                                                        context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                    fontStyle:
                                                    FlutterFlowTheme
                                                        .of(
                                                        context)
                                                        .bodyMedium
                                                        .fontStyle,
                                                  ),
                                                  fontSize: 16.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                  FlutterFlowTheme
                                                      .of(
                                                      context)
                                                      .bodyMedium
                                                      .fontWeight,
                                                  fontStyle:
                                                  FlutterFlowTheme
                                                      .of(
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
                                                    style: FlutterFlowTheme
                                                        .of(
                                                        context)
                                                        .bodyMedium
                                                        .override(
                                                      font:
                                                      GoogleFonts.inter(
                                                        fontWeight:
                                                        FlutterFlowTheme
                                                            .of(
                                                            context)
                                                            .bodyMedium
                                                            .fontWeight,
                                                        fontStyle:
                                                        FlutterFlowTheme
                                                            .of(
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
                                                      FlutterFlowTheme
                                                          .of(
                                                          context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                      fontStyle:
                                                      FlutterFlowTheme
                                                          .of(
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
                        builder: (context) =>
                            Builder(
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
                                          if (_model.pointBTextController
                                              .text !=
                                              null &&
                                              _model.pointBTextController
                                                  .text !=
                                                  '') {
                                            context.read<OrdersBloc>().add(OrdersEvent.getEtas(userLocation: LocationEntity(lat: addressItem.latlng!.latitude, lng: addressItem.latlng!.longitude)));

                                            FFAppState().pointA = addressItem;
                                            FFAppState().update(() {});

                                            final ordersBloc = context.read<OrdersBloc>();
                                            _closeSearchSheet();
                                            ordersBloc.add(
                                                OrdersEvent.getPrices(
                                                    userLocation: LocationEntity(
                                                        lat: FFAppState().pointA
                                                            .latlng!.latitude,
                                                        lng: FFAppState().pointA
                                                            .latlng!.longitude),
                                                    destLocation: LocationEntity(
                                                        lat: FFAppState().pointB
                                                            .latlng!.latitude,
                                                        lng: FFAppState().pointB
                                                            .latlng!.longitude),
                                                    intermediate: FFAppState().pointC.address.isNotEmpty ? LocationEntity(
                                                        lat: FFAppState().pointC
                                                            .latlng!.latitude,
                                                        lng: FFAppState().pointC
                                                            .latlng!.longitude) : null,
                                                    movers: FFAppState().movers));
                                            if (_shouldSetState)
                                              safeSetState(() {});
                                            return;
                                          } else {
                                            context.read<OrdersBloc>().add(OrdersEvent.getEtas(userLocation: LocationEntity(lat: addressItem.latlng!.latitude, lng: addressItem.latlng!.longitude)));

                                            FFAppState().pointA = addressItem;
                                            FFAppState().update(() {});
                                            safeSetState(() {
                                              _model.pointATextController
                                                  ?.text =
                                                  addressItem.address;
                                            });
                                            safeSetState(() {
                                              _model.pointBTextController
                                                  ?.text =
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

                                          final ordersBloc = context.read<OrdersBloc>();
                                          _closeSearchSheet();
                                          ordersBloc.add(
                                              OrdersEvent.getPrices(
                                                  userLocation: LocationEntity(
                                                      lat: FFAppState().pointA
                                                          .latlng!.latitude,
                                                      lng: FFAppState().pointA
                                                          .latlng!.longitude),
                                                  destLocation: LocationEntity(
                                                      lat: FFAppState().pointB
                                                          .latlng!.latitude,
                                                      lng: FFAppState().pointB
                                                          .latlng!.longitude),
                                                  intermediate: FFAppState().pointC.address.isNotEmpty ? LocationEntity(
                                                      lat: FFAppState().pointC
                                                          .latlng!.latitude,
                                                      lng: FFAppState().pointC
                                                          .latlng!.longitude) : null,
                                                  movers: FFAppState().movers));
                                          if (_shouldSetState) safeSetState(() {});
                                          return;
                                        }

                                        if (_shouldSetState) safeSetState(() {});
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(),
                                        child: Padding(
                                          padding: EdgeInsetsDirectional
                                              .fromSTEB(
                                              24.0, 14.0, 24.0, 14.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                addressItem.address,
                                                style: FlutterFlowTheme
                                                    .of(context)
                                                    .bodyMedium
                                                    .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight:
                                                    FlutterFlowTheme
                                                        .of(
                                                        context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                    fontStyle:
                                                    FlutterFlowTheme
                                                        .of(
                                                        context)
                                                        .bodyMedium
                                                        .fontStyle,
                                                  ),
                                                  fontSize: 16.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                  FlutterFlowTheme
                                                      .of(
                                                      context)
                                                      .bodyMedium
                                                      .fontWeight,
                                                  fontStyle:
                                                  FlutterFlowTheme
                                                      .of(
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
                                                  FlutterFlowTheme
                                                      .of(context)
                                                      .bodyMedium
                                                      .override(
                                                    font: GoogleFonts.inter(
                                                      fontWeight:
                                                      FlutterFlowTheme
                                                          .of(
                                                          context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                      fontStyle:
                                                      FlutterFlowTheme
                                                          .of(
                                                          context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                    ),
                                                    color:
                                                    FlutterFlowTheme
                                                        .of(
                                                        context)
                                                        .secondaryText,
                                                    fontSize: 14.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight:
                                                    FlutterFlowTheme
                                                        .of(
                                                        context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                    fontStyle:
                                                    FlutterFlowTheme
                                                        .of(
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
