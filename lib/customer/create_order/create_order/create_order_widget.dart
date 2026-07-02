import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/firebase_storage/storage.dart';
import '/backend/push_notifications/push_notifications_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/upload_data.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
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
  }) : this.movers = movers ?? 0;

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
      if (widget.images != null && (widget.images)!.isNotEmpty) {
        {
          safeSetState(() => _model.isDataUploading_uploadDataGw5 = true);
          var selectedUploadedFiles = <FFUploadedFile>[];
          var selectedMedia = <SelectedFile>[];
          var downloadUrls = <String>[];
          try {
            selectedUploadedFiles = widget.images!;
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
        await orderRecordReference1.set({
          ...createOrderRecordData(
            userCustomer: currentUserReference,
            supply: widget.supply,
            dateTime: widget.dateTime,
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
            movers: widget.movers,
            description: widget.description,
            budget: widget.budget,
            dateTimeCreated: functions.toUtc(),
            status: StatusOrder.newOrder,
            driverReviewed: false,
            customerReviewed: false,
            dateUpd: getCurrentTimestamp,
            distance: FFAppState().distanceKm,
            time: FFAppState().distanceTime,
            car: widget.car,
            payMethod: FFAppState().payMethod,
          ),
          ...mapToFirestore(
            {
              'images': _model.uploadedFileUrls_uploadDataGw5,
            },
          ),
        });
        _model.neworderImage = OrderRecord.getDocumentFromData({
          ...createOrderRecordData(
            userCustomer: currentUserReference,
            supply: widget.supply,
            dateTime: widget.dateTime,
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
            movers: widget.movers,
            description: widget.description,
            budget: widget.budget,
            dateTimeCreated: functions.toUtc(),
            status: StatusOrder.newOrder,
            driverReviewed: false,
            customerReviewed: false,
            dateUpd: getCurrentTimestamp,
            distance: FFAppState().distanceKm,
            time: FFAppState().distanceTime,
            car: widget.car,
            payMethod: FFAppState().payMethod,
          ),
          ...mapToFirestore(
            {
              'images': _model.uploadedFileUrls_uploadDataGw5,
            },
          ),
        }, orderRecordReference1);
        safeSetState(() {
          _model.isDataUploading_uploadDataGw5 = false;
          _model.uploadedLocalFiles_uploadDataGw5 = [];
          _model.uploadedFileUrls_uploadDataGw5 = [];
        });

        _model.listU = await queryUsersRecordOnce(
          queryBuilder: (usersRecord) => usersRecord
              .where(
                'is_driver',
                isEqualTo: true,
              )
              .where(
                'verif_compl',
                isEqualTo: true,
              )
              .where(
                'city',
                isEqualTo: _model.neworderImage?.pointA.city,
              ),
        );
        triggerPushNotification(
          notificationTitle: 'Новый заказ',
          notificationText: 'В приложении появился новый заказ',
          notificationSound: 'default',
          userRefs: _model.listU!.map((e) => e.reference).toList().toList(),
          initialPageName: 'order_Page_Driver',
          parameterData: {
            'order': _model.neworderImage?.reference,
          },
        );
      } else {
        var orderRecordReference2 = OrderRecord.collection.doc();
        await orderRecordReference2.set(createOrderRecordData(
          userCustomer: currentUserReference,
          supply: widget.supply,
          dateTime: widget.dateTime,
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
          movers: widget.movers,
          description: widget.description,
          budget: widget.budget,
          dateTimeCreated: functions.toUtc(),
          status: StatusOrder.newOrder,
          driverReviewed: false,
          customerReviewed: false,
          dateUpd: getCurrentTimestamp,
          distance: FFAppState().distanceKm,
          time: FFAppState().distanceTime,
          car: widget.car,
          payMethod: FFAppState().payMethod,
        ));
        _model.neworder = OrderRecord.getDocumentFromData(
            createOrderRecordData(
              userCustomer: currentUserReference,
              supply: widget.supply,
              dateTime: widget.dateTime,
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
              movers: widget.movers,
              description: widget.description,
              budget: widget.budget,
              dateTimeCreated: functions.toUtc(),
              status: StatusOrder.newOrder,
              driverReviewed: false,
              customerReviewed: false,
              dateUpd: getCurrentTimestamp,
              distance: FFAppState().distanceKm,
              time: FFAppState().distanceTime,
              car: widget.car,
              payMethod: FFAppState().payMethod,
            ),
            orderRecordReference2);
        _model.listU2 = await queryUsersRecordOnce(
          queryBuilder: (usersRecord) => usersRecord
              .where(
                'is_driver',
                isEqualTo: true,
              )
              .where(
                'verif_compl',
                isEqualTo: true,
              )
              .where(
                'city',
                isEqualTo: _model.neworder?.pointA.city,
              ),
        );
        triggerPushNotification(
          notificationTitle: 'Новый заказ',
          notificationText: 'В приложении появился новый заказ',
          notificationSound: 'default',
          userRefs: _model.listU2!.map((e) => e.reference).toList().toList(),
          initialPageName: 'order_Page_Driver',
          parameterData: {
            'order': _model.neworder?.reference,
          },
        );
      }

      if (!((currentUserDocument?.addresses.toList() ?? [])
          .where((e) =>
              (e.placeID == FFAppState().pointA.placeID) ||
              (e.address == FFAppState().pointA.address) ||
              (e.fullAddress == FFAppState().pointA.fullAddress))
          .toList()
          .isNotEmpty)) {
        await currentUserReference!.update({
          ...mapToFirestore(
            {
              'addresses': FieldValue.arrayUnion([
                getPointFirestoreData(
                  updatePointStruct(
                    FFAppState().pointA,
                    clearUnsetFields: false,
                  ),
                  true,
                )
              ]),
            },
          ),
        });
      }
      if (!((currentUserDocument?.addresses.toList() ?? [])
          .where((e) =>
              (e.placeID == FFAppState().pointB.placeID) ||
              (e.address == FFAppState().pointB.address) ||
              (e.fullAddress == FFAppState().pointB.fullAddress))
          .toList()
          .isNotEmpty)) {
        await currentUserReference!.update({
          ...mapToFirestore(
            {
              'addresses': FieldValue.arrayUnion([
                getPointFirestoreData(
                  updatePointStruct(
                    FFAppState().pointB,
                    clearUnsetFields: false,
                  ),
                  true,
                )
              ]),
            },
          ),
        });
      }
      FFAppState().pointB = PointStruct();
      FFAppState().pointA = PointStruct();
      FFAppState().distanceTime = '';
      FFAppState().distanceKm = '';
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
        borderRadius: const BorderRadius.only(
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
                topLeft: Radius.circular(22.0),
                topRight: Radius.circular(22.0),
                bottomLeft: Radius.circular(5.0),
                bottomRight: Radius.circular(5.0),
              ),
            ),
            child: Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 0.0, 0.0),
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
                padding: const EdgeInsetsDirectional.fromSTEB(
                    24.0, 24.0, 24.0, 50.0),
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
        ].divide(const SizedBox(height: 5.0)),
      ),
    );
  }
}
