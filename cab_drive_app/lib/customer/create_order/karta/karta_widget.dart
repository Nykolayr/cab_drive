import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../create_map_page/domain/entities/entities.dart';
import '../../create_map_page/presentation/bloc/orders_bloc.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/custom_code/services/address_place_selection.dart';
import '/custom_code/services/safe_modal_pop.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'karta_model.dart';

export 'karta_model.dart';

class KartaWidget extends StatefulWidget {
  const KartaWidget({
    super.key,
    required this.point,
  });

  final String? point;

  @override
  State<KartaWidget> createState() => _KartaWidgetState();
}

class _KartaWidgetState extends State<KartaWidget> {
  late KartaModel _model;

  LatLng? currentUserLocationValue;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => KartaModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (widget!.point == 'A') {
        safeSetState(() {
          _model.pointTextController?.text = '${FFAppState().pointA.address} ';
          _model.pointFocusNode?.requestFocus();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _model.pointTextController?.selection = TextSelection.collapsed(
              offset: _model.pointTextController!.text.length,
            );
          });
        });
        return;
      } else if (widget!.point == 'C') {
        safeSetState(() {
          _model.pointTextController?.text = '${FFAppState().pointC.address} ';
          _model.pointFocusNode?.requestFocus();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _model.pointTextController?.selection = TextSelection.collapsed(
              offset: _model.pointTextController!.text.length,
            );
          });
        });
        return;
      } else {
        safeSetState(() {
          _model.pointTextController?.text = '${FFAppState().pointB.address} ';
          _model.pointFocusNode?.requestFocus();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _model.pointTextController?.selection = TextSelection.collapsed(
              offset: _model.pointTextController!.text.length,
            );
          });
        });
        return;
      }
    });

    _model.pointTextController ??= TextEditingController();
    _model.pointFocusNode ??= FocusNode();
    _model.pointFocusNode!.addListener(() => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Align(
      alignment: AlignmentDirectional(0.0, 1.0),
      child: Padding(
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
              bottomLeft: Radius.circular(5.0),
              bottomRight: Radius.circular(5.0),
              topLeft: Radius.circular(14.0),
              topRight: Radius.circular(14.0),
            ),
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(8.0, 5.0, 8.0, 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: AlignmentDirectional(0.0, -1.0),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                    child: Container(
                      width: 39.0,
                      height: 5.0,
                      decoration: BoxDecoration(
                        color: Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(28.0),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 62.0,
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
                    padding: EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.search,
                          color: (_model.pointFocusNode?.hasFocus ?? false)
                              ? FlutterFlowTheme.of(context).tertiary
                              : FlutterFlowTheme.of(context).secondaryText,
                          size: 17.0,
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                8.0, 0.0, 0.0, 0.0),
                            child: Container(
                              width: double.infinity,
                              child: TextFormField(
                                controller: _model.pointTextController,
                                focusNode: _model.pointFocusNode,
                                onChanged: (_) => EasyDebounce.debounce(
                                  '_model.pointTextController',
                                  Duration(milliseconds: 0),
                                  () async {
                                    currentUserLocationValue =
                                        await getCurrentUserLocation(
                                            defaultLocation: LatLng(0.0, 0.0));
                                    _model.apiResult1ve =
                                        await AutocompleteCall.call(
                                      input: _model.pointTextController.text,
                                      location:
                                          currentUserLocationValue?.toString(),
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
                                  hintText: widget!.point == 'A'
                                      ? 'Откуда забрать'
                                      : widget!.point == 'C'
                                          ? "Промежуточная точка"
                                          : 'Куда доставить',
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
                                  suffixIcon: _model
                                          .pointTextController!.text.isNotEmpty
                                      ? InkWell(
                                          onTap: () async {
                                            _model.pointTextController?.clear();
                                            currentUserLocationValue =
                                                await getCurrentUserLocation(
                                                    defaultLocation:
                                                        LatLng(0.0, 0.0));
                                            _model.apiResult1ve =
                                                await AutocompleteCall.call(
                                              input: _model
                                                  .pointTextController.text,
                                              location: currentUserLocationValue
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
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                    ),
                                cursorColor:
                                    FlutterFlowTheme.of(context).primaryText,
                                validator: _model.pointTextControllerValidator
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
                  ),
                ),
                Builder(
                  builder: (context) {
                    final point = AutocompleteCall.addresses(
                          (_model.apiResult1ve?.jsonBody ?? ''),
                        )?.toList() ??
                        [];

                    if (point.isEmpty) {
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
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: point.length,
                      itemBuilder: (context, pointIndex) {
                        final pointItem = point[pointIndex];
                        return InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            final tag = 'karta.${widget.point ?? "?"}';
                            final selectedPlaceId = AutocompleteCall.placeid(
                              (_model.apiResult1ve?.jsonBody ?? ''),
                            )?.elementAtOrNull(pointIndex);
                            final selectedMain = AutocompleteCall.addresses(
                              (_model.apiResult1ve?.jsonBody ?? ''),
                            )?.elementAtOrNull(pointIndex);
                            final resolved =
                                await AddressPlaceSelection.resolve(
                              fieldTag: tag,
                              placeId: selectedPlaceId,
                              mainText: selectedMain,
                            );
                            if (resolved.addressLabel.isNotEmpty) {
                              safeSetState(() {
                                _model.pointTextController?.text =
                                    resolved.addressLabel;
                              });
                            }
                            if (!resolved.ok) {
                              debugPrint(
                                '[Search.$tag] FAIL — label shown, point not set',
                              );
                              return;
                            }

                            final point = resolved.toPoint();
                            debugPrint(
                              '[Search.$tag] apply label="${resolved.addressLabel}"',
                            );

                            if (widget.point == 'A') {
                              FFAppState().pointA = point;
                            } else if (widget.point == 'C') {
                              FFAppState().pointC = point;
                            } else {
                              FFAppState().pointB = point;
                            }

                            if (!mounted) return;
                            final ordersBloc = context.read<OrdersBloc>();
                            // Только шторка karta — не главный экран.
                            safePopModal(context, tag: 'karta.close');
                            FFAppState().update(() {});

                            if (widget.point == 'A' && point.latlng != null) {
                              ordersBloc.add(
                                OrdersEvent.getEtas(
                                  userLocation: LocationEntity(
                                    lat: point.latlng!.latitude,
                                    lng: point.latlng!.longitude,
                                  ),
                                ),
                              );
                            }
                            if (FFAppState().pointA.latlng != null &&
                                FFAppState().pointB.latlng != null) {
                              ordersBloc.add(
                                    OrdersEvent.getPrices(
                                      userLocation: LocationEntity(
                                        lat: FFAppState()
                                            .pointA
                                            .latlng!
                                            .latitude,
                                        lng: FFAppState()
                                            .pointA
                                            .latlng!
                                            .longitude,
                                      ),
                                      destLocation: LocationEntity(
                                        lat: FFAppState()
                                            .pointB
                                            .latlng!
                                            .latitude,
                                        lng: FFAppState()
                                            .pointB
                                            .latlng!
                                            .longitude,
                                      ),
                                      intermediate: FFAppState()
                                              .pointC
                                              .address
                                              .isNotEmpty
                                          ? LocationEntity(
                                              lat: FFAppState()
                                                  .pointC
                                                  .latlng!
                                                  .latitude,
                                              lng: FFAppState()
                                                  .pointC
                                                  .latlng!
                                                  .longitude,
                                            )
                                          : null,
                                      movers: FFAppState().movers,
                                    ),
                                  );
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  24.0, 14.0, 24.0, 14.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pointItem,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          fontSize: 16.0,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                  ),
                                  if ((AutocompleteCall.region(
                                            (_model.apiResult1ve?.jsonBody ??
                                                ''),
                                          )?.elementAtOrNull(pointIndex)) !=
                                          null &&
                                      (AutocompleteCall.region(
                                            (_model.apiResult1ve?.jsonBody ??
                                                ''),
                                          )?.elementAtOrNull(pointIndex)) !=
                                          '')
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 6.0, 0.0, 0.0),
                                      child: Text(
                                        (AutocompleteCall.region(
                                          (_model.apiResult1ve?.jsonBody ?? ''),
                                        )!
                                            .elementAtOrNull(pointIndex))!,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              fontSize: 14.0,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
