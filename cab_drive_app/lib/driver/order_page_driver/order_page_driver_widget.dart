import 'package:cab_drive/driver/order_page_driver/widgets/bottom_actions_widget.dart';
import 'package:cab_drive/driver/order_page_driver/widgets/customer_card_widget.dart';
import 'package:cab_drive/driver/order_page_driver/widgets/details_section_widget.dart';
import 'package:cab_drive/driver/order_page_driver/widgets/images_grid_widget.dart';
import 'package:cab_drive/driver/order_page_driver/widgets/map_card_widget.dart';
import 'package:cab_drive/driver/order_page_driver/widgets/order_warning_widget.dart';
import 'package:cab_drive/driver/order_page_driver/widgets/queue_indicator_widget.dart';
import '../../pages/bottom/app_bar/app_bar_widget.dart';
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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OrderPageDriverModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AppEnv.isTest) {
      return _buildOrderScaffold(TestDriverSeed.buildOrder());
    }

    return StreamBuilder<OrderRecord>(
      stream: OrderRecord.getDocument(widget.order!),
      builder: (context, snapshot) {
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

        return _buildOrderScaffold(snapshot.data!);
      },
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
