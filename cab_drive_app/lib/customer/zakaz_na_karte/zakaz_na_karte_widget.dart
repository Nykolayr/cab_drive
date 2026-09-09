import 'dart:async';

import '/backend/api/app_me_api.dart';
import '/backend/api/order_record_mapper.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/core/config/app_env.dart';
import '/core/config/test_driver_seed.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/bottom/app_bar/app_bar_widget.dart';
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
  Timer? _poll;
  OrderRecord? _order;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ZakazNaKarteModel());
    if (!AppEnv.isTest) {
      unawaited(_reload());
      _poll = Timer.periodic(const Duration(seconds: 5), (_) => _reload());
    }
  }

  Future<void> _reload() async {
    final id = widget.order?.id;
    if (id == null || id.isEmpty) return;
    try {
      final map = await AppMeApi.getOrder(id);
      if (!mounted) return;
      if (map == null) {
        setState(() => _loading = false);
        return;
      }
      setState(() {
        _order = OrderRecordMapper.fromApi(map, id);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AppEnv.isTest) {
      return _mapScaffold(TestDriverSeed.buildOrder());
    }

    if (_order != null) {
      return _mapScaffold(_order!);
    }

    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: Center(
        child: _loading
            ? SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              )
            : const Text('Не удалось загрузить заказ'),
      ),
    );
  }

  Widget _mapScaffold(OrderRecord order) {
    final showDriver = (order.status == StatusOrder.at_work ||
            order.status == StatusOrder.spec_set) &&
        order.hasDriverLocation();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            wrapWithModel(
              model: _model.appBarModel,
              updateCallback: () => safeSetState(() {}),
              child: const AppBarWidget(
                text: 'Заказ на карте',
              ),
            ),
            Expanded(
              child: custom_widgets.YandexOrderMap(
                width: double.infinity,
                height: double.infinity,
                startLatLng: order.pointA.latlng!,
                endLatLng: order.pointB.latlng!,
                driverLocation: order.driverLocation,
                showDriver: showDriver,
                etaText: order.hasTimeLeft() ? order.timeLeft : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
