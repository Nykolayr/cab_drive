import 'dart:async';

import 'package:cab_drive/driver/order_page_driver/widgets/bottom_actions_widget.dart';
import 'package:cab_drive/driver/order_page_driver/widgets/customer_card_widget.dart';
import 'package:cab_drive/driver/order_page_driver/widgets/details_section_widget.dart';
import 'package:cab_drive/driver/order_page_driver/widgets/images_grid_widget.dart';
import 'package:cab_drive/driver/order_page_driver/widgets/map_card_widget.dart';
import 'package:cab_drive/driver/order_page_driver/widgets/order_warning_widget.dart';
import 'package:cab_drive/driver/order_page_driver/widgets/queue_indicator_widget.dart';
import '../../pages/bottom/app_bar/app_bar_widget.dart';
import '/backend/api/app_me_api.dart';
import '/backend/api/order_record_mapper.dart';
import '/backend/backend.dart';
import '/core/config/app_env.dart';
import '/core/config/test_driver_seed.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'order_page_driver_model.dart';
export 'order_page_driver_model.dart';

class OrderPageDriverWidget extends StatefulWidget {
  const OrderPageDriverWidget({
    super.key,
    required this.order,
  });

  final DocumentReference? order;

  static String routeName = 'order_Page_Driver';
  static String routePath = '/orderPageDriver';

  @override
  State<OrderPageDriverWidget> createState() => _OrderPageDriverWidgetState();
}

class _OrderPageDriverWidgetState extends State<OrderPageDriverWidget> {
  late OrderPageDriverModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  LatLng? currentUserLocationValue;
  Timer? _poll;
  OrderRecord? _order;
  bool _loading = true;
  bool _useFsFallback = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OrderPageDriverModel());
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
        setState(() {
          _useFsFallback = false;
          _loading = false;
        });
        return;
      }
      setState(() {
        _order = OrderRecordMapper.fromApi(map, id);
        _useFsFallback = false;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _useFsFallback = false;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    _model.dispose();
    super.dispose();
  }

  Widget _loadingScaffold() {
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

  @override
  Widget build(BuildContext context) {
    if (AppEnv.isTest) {
      return _buildOrderScaffold(TestDriverSeed.buildOrder());
    }

    if (_order != null) {
      return _buildOrderScaffold(_order!);
    }

    if (_loading) {
      return _loadingScaffold();
    }

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: const Center(child: Text('Не удалось загрузить заказ')),
    );
  }

  Widget _buildOrderScaffold(OrderRecord orderRec) {
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
            if (_model.appBarModel != null)
              wrapWithModel(
                model: _model.appBarModel,
                updateCallback: () => setState(() {}),
                child: const AppBarWidget(text: 'Детали заказа'),
              ),
            Flexible(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        primary: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!AppEnv.isTest)
                              OrderWarningWidget(
                                order: orderRec,
                                onTap: () {
                                  setState(() {});
                                },
                                model: _model,
                                widgetOrderRef: widget.order!,
                              ),
                            if (!AppEnv.isTest)
                              QueueIndicatorWidget(
                                currentOrderRef: widget.order!,
                              ),
                            if (!AppEnv.isTest)
                              CustomerCardWidget(
                                order: orderRec,
                                model: _model,
                                widgetOrderRef: widget.order!,
                              ),
                            MapCardWidget(order: orderRec),
                            DetailsSectionWidget(
                              order: orderRec,
                              model: _model,
                            ),
                            ImagesGridWidget(order: orderRec),
                            const SizedBox(height: 120.0),
                          ].divide(const SizedBox(height: 5.0)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (!AppEnv.isTest)
              BottomActionsWidget(
                order: orderRec,
                model: _model,
                onStateChanged: () {
                  setState(() {});
                },
                widgetOrderRef: widget.order!,
              ),
          ].divide(const SizedBox(height: 5.0)),
        ),
      ),
    );
  }
}
