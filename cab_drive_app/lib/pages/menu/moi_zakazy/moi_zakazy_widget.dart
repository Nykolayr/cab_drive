import 'dart:async';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/api/app_me_api.dart';
import '/backend/api/order_record_mapper.dart';
import '/backend/backend.dart';
import '/customer/order_card_customer/order_card_customer_widget.dart';
import '/driver/order_card_driver/order_card_driver_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'moi_zakazy_model.dart';
export 'moi_zakazy_model.dart';

class MoiZakazyWidget extends StatefulWidget {
  const MoiZakazyWidget({super.key});

  @override
  State<MoiZakazyWidget> createState() => _MoiZakazyWidgetState();
}

class _MoiZakazyWidgetState extends State<MoiZakazyWidget> {
  late MoiZakazyModel _model;
  Timer? _poll;
  List<OrderRecord>? _orders;
  bool _loading = true;
  bool _useFsFallback = false;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MoiZakazyModel());
    unawaited(_reload());
    _poll = Timer.periodic(const Duration(seconds: 5), (_) => _reload());
  }

  bool get _isDriver =>
      valueOrDefault<bool>(currentUserDocument?.isDriver, false);

  Future<void> _reload() async {
    final role = _isDriver ? 'driver' : 'customer';
    try {
      final maps = await AppMeApi.ordersMine(role: role, limit: 100);
      final out = <OrderRecord>[];
      for (final m in maps) {
        final id = m['id']?.toString();
        if (id == null || id.isEmpty) continue;
        try {
          final rec = OrderRecordMapper.fromApi(m, id);
          // шторка водителя: только назначенные (как старый FS where selected_driver)
          if (_isDriver && rec.selectedDriver?.id != currentUserUid) {
            continue;
          }
          out.add(rec);
        } catch (_) {}
      }
      if (!mounted) return;
      setState(() {
        _orders = out;
        _loading = false;
        _useFsFallback = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _orders = const [];
        _useFsFallback = false;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    _model.maybeDispose();
    super.dispose();
  }

  Widget _loadingBox() => Center(
        child: SizedBox(
          width: 50.0,
          height: 50.0,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              FlutterFlowTheme.of(context).primary,
            ),
          ),
        ),
      );

  Widget _list(List<OrderRecord> list, {required bool driver}) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 50.0),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 5.0),
      itemBuilder: (context, index) {
        final order = list[index];
        return InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            context.pushNamed(
              driver
                  ? OrderPageDriverWidget.routeName
                  : OrderPageCustomerWidget.routeName,
              queryParameters: {
                if (!driver)
                  'index': serializeParam(2, ParamType.int),
                'order': serializeParam(
                  order.reference,
                  ParamType.DocumentReference,
                ),
              }.withoutNulls,
            );
          },
          child: driver
              ? OrderCardDriverWidget(
                  key: Key('Keyciq_${index}_of_${list.length}'),
                  order: order,
                )
              : OrderCardCustomerWidget(
                  key: Key('Keym8i_${index}_of_${list.length}'),
                  order: order,
                ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final driver = _isDriver;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 50.0, 0.0, 0.0),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryBackground,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(0.0),
            bottomRight: Radius.circular(0.0),
            topLeft: Radius.circular(22.0),
            topRight: Radius.circular(22.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 64.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(5.0),
                  bottomRight: Radius.circular(5.0),
                  topLeft: Radius.circular(22.0),
                  topRight: Radius.circular(22.0),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Мои заказы',
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'SF',
                            fontSize: 21.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    FlutterFlowIconButton(
                      borderColor:
                          FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: 54.0,
                      borderWidth: 0.0,
                      buttonSize: 32.0,
                      fillColor: FlutterFlowTheme.of(context).primary,
                      hoverColor: FlutterFlowTheme.of(context).primary,
                      hoverIconColor: FlutterFlowTheme.of(context).primaryText,
                      icon: Icon(
                        FFIcons.kkrestStroke,
                        color: FlutterFlowTheme.of(context).primaryText,
                        size: 8.0,
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              child: Builder(
                builder: (context) {
                  if (_loading && _orders == null) return _loadingBox();
                  return _list(_orders ?? const [], driver: driver);
                },
              ),
            ),
          ].divide(const SizedBox(height: 5.0)),
        ),
      ),
    );
  }
}
