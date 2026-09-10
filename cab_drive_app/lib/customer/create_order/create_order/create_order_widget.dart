import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/api/app_me_api.dart';
import '/backend/api/saved_cards_record_mapper.dart';
import '/backend/backend.dart';
import '/backend/firebase_storage/storage.dart';
import '/backend/push_notifications/push_notifications_util.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/upload_data.dart';
import '/index.dart';
import 'create_order_model.dart';

export 'create_order_model.dart';

class CreateOrderWidget extends StatefulWidget {
  const CreateOrderWidget({
    super.key,
    required this.supply,
    this.dateTime,
    int? movers,
    this.images,
    required this.description,
    required this.budget,
    required this.car,
    this.intermediateOn = false,
  }) : this.movers = movers ?? 0;

  final bool intermediateOn;
  final int? supply;
  final DateTime? dateTime;
  final int movers;
  final List<FFUploadedFile>? images;
  final String? description;
  final int? budget;
  final Car? car;

  @override
  State<CreateOrderWidget> createState() => _CreateOrderWidgetState();
}

class _CreateOrderWidgetState extends State<CreateOrderWidget> {
  late CreateOrderModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CreateOrderModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (widget!.images != null && (widget!.images)!.isNotEmpty) {
        {
          safeSetState(() => _model.isDataUploading_uploadDataGw5 = true);
          var selectedUploadedFiles = <FFUploadedFile>[];
          var selectedMedia = <SelectedFile>[];
          var downloadUrls = <String>[];
          try {
            selectedUploadedFiles = widget!.images!;
            selectedMedia = selectedFilesFromUploadedFiles(
              selectedUploadedFiles,
              isMultiData: true,
            );
            downloadUrls = (await Future.wait(
              selectedMedia.map(
                (m) async => await uploadData(m.storagePath, m.bytes),
              ),
            ))
                .where((u) => u != null)
                .map((u) => u!)
                .toList();
          } finally {
            _model.isDataUploading_uploadDataGw5 = false;
          }
          if (selectedUploadedFiles.length == selectedMedia.length &&
              downloadUrls.length == selectedMedia.length) {
            safeSetState(() {
              _model.uploadedLocalFiles_uploadDataGw5 = selectedUploadedFiles;
              _model.uploadedFileUrls_uploadDataGw5 = downloadUrls;
            });
          } else {
            safeSetState(() {});
            return;
          }
        }

        var orderRecordReference1 = OrderRecord.collection.doc();
        final orderPayload1 = {
          ...createOrderRecordData(
            userCustomer: currentUserReference,
            supply: widget!.supply,
            dateTime: widget!.dateTime,
            pointA: updatePointStruct(
              FFAppState().pointA,
              clearUnsetFields: false,
              create: true,
            ),
            pointB: updatePointStruct(
              FFAppState().pointB,
              clearUnsetFields: false,
              create: true,
            ),
            pointC: widget.intermediateOn
                ? updatePointStruct(
                    FFAppState().pointC,
                    clearUnsetFields: false,
                    create: true,
                  )
                : null,
            movers: widget!.movers,
            description: widget!.description,
            budget: widget!.budget,
            dateTimeCreated: functions.toUtc(),
            status: StatusOrder.newOrder,
            driverReviewed: false,
            customerReviewed: false,
            dateUpd: getCurrentTimestamp,
            distance: FFAppState().distanceKm,
            time: FFAppState().distanceTime,
            car: widget!.car,
            payMethod: FFAppState().payMethod,
          ),
          ...mapToFirestore(
            {
              'images': _model.uploadedFileUrls_uploadDataGw5,
            },
          ),
        };
        final api1 = await AppMeApi.createOrder({
          'id': orderRecordReference1.id,
          'user_customer_id': currentUserUid,
          'supply': widget!.supply,
          'dateTime': widget!.dateTime?.toUtc().toIso8601String(),
          'pointA': pointToApiMap(FFAppState().pointA),
          'pointB': pointToApiMap(FFAppState().pointB),
          if (widget.intermediateOn)
            'pointC': pointToApiMap(FFAppState().pointC),
          'movers': widget!.movers,
          'description': widget!.description,
          'budget': widget!.budget,
          'currentPrice': widget!.budget,
          'dateTime_created': functions.toUtc().toIso8601String(),
          'status': 'newOrder',
          'distance': FFAppState().distanceKm,
          'time': FFAppState().distanceTime,
          'car': widget!.car?.serialize(),
          'payMethod': FFAppState().payMethod?.serialize(),
          'images': _model.uploadedFileUrls_uploadDataGw5,
        });
        if (api1 == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Не удалось создать заказ. Попробуйте ещё раз.')),
            );
          }
          return;
        }
        _model.neworderImage = OrderRecord.getDocumentFromData(
            orderPayload1, orderRecordReference1);
        safeSetState(() {
          _model.isDataUploading_uploadDataGw5 = false;
          _model.uploadedLocalFiles_uploadDataGw5 = [];
          _model.uploadedFileUrls_uploadDataGw5 = [];
        });

        // Notify drivers: FS user query убран (SoT=PG); push опционален с сервера.
        _model.listU = const [];
        print('[CreateOrder] Sending push notifications for order with image');
        print('[CreateOrder] Order city: ${_model.neworderImage?.pointA?.city}');
        print('[CreateOrder] Found ${_model.listU?.length ?? 0} drivers to notify');
        final driverIds = _model.listU?.map((e) => e.uid).whereType<String>().toList() ?? [];
        if (driverIds.isNotEmpty) {
          print('[CreateOrder] Driver IDs: $driverIds');
          await sendPushToUsers(
            title: 'Новый заказ',
            text: 'В приложении появился новый заказ',
            userIds: driverIds,
            data: {
              'order_id': _model.neworderImage?.reference.id ?? '',
              'page': 'order_Page_Driver',
            },
          );
          print('[CreateOrder] Push notification sent via backend');
        } else {
          print('[CreateOrder] WARNING: No drivers found for city "${_model.neworderImage?.pointA?.city}"');
        }
      } else {
        print('[CreateOrder] === DEBUG: pointA data before order creation ===');
        print('[CreateOrder] FFAppState().pointA.city: "${FFAppState().pointA.city}"');
        print('[CreateOrder] FFAppState().pointA.address: "${FFAppState().pointA.address}"');
        print('[CreateOrder] FFAppState().pointA.fullAddress: "${FFAppState().pointA.fullAddress}"');
        print('[CreateOrder] FFAppState().pointA.region: "${FFAppState().pointA.region}"');
        print('[CreateOrder] FFAppState().pointA.latlng: ${FFAppState().pointA.latlng}');
        print('[CreateOrder] ===============================================');
        var orderRecordReference2 = OrderRecord.collection.doc();
        final orderPayload2 = createOrderRecordData(
          userCustomer: currentUserReference,
          supply: widget!.supply,
          dateTime: widget!.dateTime,
          pointA: updatePointStruct(
            FFAppState().pointA,
            clearUnsetFields: false,
            create: true,
          ),
          pointB: updatePointStruct(
            FFAppState().pointB,
            clearUnsetFields: false,
            create: true,
          ),
          pointC: widget.intermediateOn
              ? updatePointStruct(
                  FFAppState().pointC,
                  clearUnsetFields: false,
                  create: true,
                )
              : null,
          movers: widget!.movers,
          description: widget!.description,
          budget: widget!.budget,
          dateTimeCreated: functions.toUtc(),
          status: StatusOrder.newOrder,
          driverReviewed: false,
          customerReviewed: false,
          dateUpd: getCurrentTimestamp,
          distance: FFAppState().distanceKm,
          time: FFAppState().distanceTime,
          car: widget!.car,
          payMethod: FFAppState().payMethod,
        );
        final api2 = await AppMeApi.createOrder({
          'id': orderRecordReference2.id,
          'user_customer_id': currentUserUid,
          'supply': widget!.supply,
          'dateTime': widget!.dateTime?.toUtc().toIso8601String(),
          'pointA': pointToApiMap(FFAppState().pointA),
          'pointB': pointToApiMap(FFAppState().pointB),
          if (widget.intermediateOn)
            'pointC': pointToApiMap(FFAppState().pointC),
          'movers': widget!.movers,
          'description': widget!.description,
          'budget': widget!.budget,
          'currentPrice': widget!.budget,
          'dateTime_created': functions.toUtc().toIso8601String(),
          'status': 'newOrder',
          'distance': FFAppState().distanceKm,
          'time': FFAppState().distanceTime,
          'car': widget!.car?.serialize(),
          'payMethod': FFAppState().payMethod?.serialize(),
        });
        if (api2 == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Не удалось создать заказ. Попробуйте ещё раз.')),
            );
          }
          return;
        }
        _model.neworder = OrderRecord.getDocumentFromData(
            orderPayload2, orderRecordReference2);
        _model.listU2 = const [];
        print('[CreateOrder] Sending push notifications for order without image');
        print('[CreateOrder] Order city: ${_model.neworder?.pointA?.city}');
        print('[CreateOrder] Found ${_model.listU2?.length ?? 0} drivers to notify');
        final driverIds2 = _model.listU2?.map((e) => e.uid).whereType<String>().toList() ?? [];
        if (driverIds2.isNotEmpty) {
          print('[CreateOrder] Driver IDs: $driverIds2');
          await sendPushToUsers(
            title: 'Новый заказ',
            text: 'В приложении появился новый заказ',
            userIds: driverIds2,
            data: {
              'order_id': _model.neworder?.reference.id ?? '',
              'page': 'order_Page_Driver',
            },
          );
          print('[CreateOrder] Push notification sent via backend');
        } else {
          print('[CreateOrder] WARNING: No drivers found for city "${_model.neworder?.pointA?.city}"');
        }
      }

      if (!((currentUserDocument?.addresses?.toList() ?? [])
          .where((e) =>
              (e.placeID == FFAppState().pointA.placeID) ||
              (e.address == FFAppState().pointA.address) ||
              (e.fullAddress == FFAppState().pointA.fullAddress))
          .toList()
          .isNotEmpty)) {
        final ok = await AppMeApi.addAddress(pointToApiMap(FFAppState().pointA));
        if (ok) {
          try {
            await refreshAppMeCache();
          } catch (_) {}
        }
      }
      if (!((currentUserDocument?.addresses?.toList() ?? [])
          .where((e) =>
              (e.placeID == FFAppState().pointB.placeID) ||
              (e.address == FFAppState().pointB.address) ||
              (e.fullAddress == FFAppState().pointB.fullAddress))
          .toList()
          .isNotEmpty)) {
        final ok = await AppMeApi.addAddress(pointToApiMap(FFAppState().pointB));
        if (ok) {
          try {
            await refreshAppMeCache();
          } catch (_) {}
        }
      }
      FFAppState().pointB = PointStruct();
      FFAppState().pointA = PointStruct();
      FFAppState().pointC = PointStruct();

      FFAppState().distanceTime = '';
      FFAppState().distanceKm = 0;
      FFAppState().movers = 0;
      FFAppState().update(() {});
      Navigator.pop(context);

      context.goNamed(MyOrdersWidget.routeName);
    });
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.only(
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
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(5.0),
                bottomRight: Radius.circular(5.0),
                topLeft: Radius.circular(22.0),
                topRight: Radius.circular(22.0),
              ),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 0.0, 0.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Публикуем заказ',
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'SF',
                          fontSize: 21.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Lottie.asset(
                    'assets/jsons/QxDtZdOkBw.json',
                    width: 114.0,
                    height: 130.0,
                    fit: BoxFit.contain,
                    animate: true,
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 50.0),
                child: Text(
                  'Скоро его увидят водители',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'SF',
                        fontSize: 18.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ),
          ),
        ].divide(SizedBox(height: 5.0)),
      ),
    );
  }
}
