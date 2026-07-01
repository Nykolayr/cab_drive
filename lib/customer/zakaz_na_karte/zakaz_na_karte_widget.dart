import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'zakaz_na_karte_model.dart';
export 'zakaz_na_karte_model.dart';

class ZakazNaKarteWidget extends StatefulWidget {
  const ZakazNaKarteWidget({
    super.key,
    required this.order,
  });

  final DocumentReference? order;

  static String routeName = 'zakaz_na_karte';
  static String routePath = '/zakazNaKarte';

  @override
  State<ZakazNaKarteWidget> createState() => _ZakazNaKarteWidgetState();
}

class _ZakazNaKarteWidgetState extends State<ZakazNaKarteWidget> {
  late ZakazNaKarteModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ZakazNaKarteModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<OrderRecord>(
      stream: OrderRecord.getDocument(widget!.order!),
      builder: (context, snapshot) {
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            ),
          );
        }

        final zakazNaKarteOrderRecord = snapshot.data!;

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Stack(
              children: [
                Builder(
                  builder: (context) {
                    final order = zakazNaKarteOrderRecord;
                    return Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: custom_widgets.YandexOrderMap(
                        width: double.infinity,
                        height: double.infinity,
                        startLatLng: order.pointA.latlng!,
                        endLatLng: order.pointB.latlng!,
                        driverLocation: order.driverLocation,
                        showDriver: order.status == StatusOrder.at_work &&
                            order.hasDriverLocation(),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(18.0, 61.0, 0.0, 0.0),
                  child: FlutterFlowIconButton(
                    borderColor: Colors.transparent,
                    borderRadius: 88.0,
                    buttonSize: 48.0,
                    fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                    icon: Icon(
                      FFIcons.kiconStroke,
                      color: FlutterFlowTheme.of(context).primaryText,
                      size: 12.0,
                    ),
                    onPressed: () async {
                      context.safePop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
