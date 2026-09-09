import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '/backend/backend.dart';
import '/custom_code/actions/index.dart' as actions;
import '/driver/order_page_driver/order_page_driver_widget.dart';
import '/driver/vkl_geo/vkl_geo_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/permissions_util.dart';
import '/flutter_flow/upload_data.dart';
import '/pages/bottom/error_popup/error_popup_widget.dart';
import '../../../auth/firebase_auth/auth_util.dart';
import '../../../backend/api/app_me_api.dart';
import '../../../backend/firebase_storage/storage.dart';
import '../../../backend/push_notifications/push_notifications_util.dart';
import '../../../backend/schema/enums/enums.dart';
import '../../create_otklick/create_otklick_widget.dart';
import '../order_page_driver_model.dart';

// Bottom actions extracted: respond, start, take photo, finish, etc.
class BottomActionsWidget extends StatelessWidget {
  const BottomActionsWidget({
    super.key,
    required this.order,
    required this.model,
    required this.widgetOrderRef,
    this.onStateChanged,
  });

  final OrderRecord order;
  final OrderPageDriverModel model;
  final DocumentReference widgetOrderRef;
  final VoidCallback? onStateChanged;



  Future<bool> _pushOrderStatus(
    StatusOrder status, {
    LatLng? loc,
    List<String>? imageCompl,
  }) async {
    final extra = <String, dynamic>{};
    if (loc != null) {
      extra['driverLocation'] = {'lat': loc.latitude, 'lng': loc.longitude};
      extra['driver_lat'] = loc.latitude;
      extra['driver_lng'] = loc.longitude;
    }
    if (imageCompl != null) {
      extra['image_compl'] = imageCompl;
    }
    return AppMeApi.setOrderStatus(
      widgetOrderRef.id,
      status.serialize(),
      extra: extra.isEmpty ? null : extra,
    );
  }

  Future<void> _patchCurrentOrder(String? orderId) async {
    await AppMeApi.patchMe({
      'current_order_json':
          orderId == null ? null : {'order_id': orderId},
    });
    await refreshAppMeCache();
  }

  Future<void> _atPlacePickup(BuildContext context) async {
    final loc = await getCurrentUserLocation(defaultLocation: LatLng(0.0, 0.0));
    if (await getPermissionStatus(locationPermission)) {
      final ok = await _pushOrderStatus(StatusOrder.place_pickup, loc: loc);
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось обновить статус заказа')),
        );
        return;
      }
      await _patchCurrentOrder(order.reference.id);
      await actions.toggleRouteTracking(
          'AIzaSyBSKcBWb1nCdTBjrOPC9okX-lVa3PdjzcY',
          true,
          widgetOrderRef,
          order.pointB.latlng!);
      triggerPushNotification(
        notificationTitle: 'Статус заказа изменен на \"Готов к подаче\"',
        notificationText:
        'Водитель ожидает подачи в течении 10 минут',
        notificationSound: 'default',
        userRefs: [order.userCustomer!],
        initialPageName: 'order_Page_Customer',
        parameterData: {'index': 1, 'order': widgetOrderRef},
      );
    } else {
      await showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Padding(
              padding: MediaQuery.viewInsetsOf(context),
              child: VklGeoWidget(),
            ),
          );
        },
      );
    }
  }

  Future<void> _atPlaceDelivery(BuildContext context) async {
    final loc = await getCurrentUserLocation(defaultLocation: LatLng(0.0, 0.0));
    if (await getPermissionStatus(locationPermission)) {
      final ok = await _pushOrderStatus(StatusOrder.place_delivery, loc: loc);
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось обновить статус заказа')),
        );
        return;
      }
      await _patchCurrentOrder(order.reference.id);
      await actions.toggleRouteTracking(
          'AIzaSyBSKcBWb1nCdTBjrOPC9okX-lVa3PdjzcY',
          true,
          widgetOrderRef,
          order.pointB.latlng!);
      triggerPushNotification(
        notificationTitle: 'Статус заказа изменен на \"Готов к разгрузке\"',
        notificationText:
        'Водитель ожидает в месте разгрузки. У вас есть 10 минут',
        notificationSound: 'default',
        userRefs: [order.userCustomer!],
        initialPageName: 'order_Page_Customer',
        parameterData: {'index': 1, 'order': widgetOrderRef},
      );
    } else {
      await showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Padding(
              padding: MediaQuery.viewInsetsOf(context),
              child: VklGeoWidget(),
            ),
          );
        },
      );
    }
  }

  Future<void> _startOrder(BuildContext context) async {
    final loc = await getCurrentUserLocation(defaultLocation: LatLng(0.0, 0.0));
    if (await getPermissionStatus(locationPermission)) {
      final ok = await _pushOrderStatus(StatusOrder.at_work, loc: loc);
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось обновить статус заказа')),
        );
        return;
      }
      await _patchCurrentOrder(order.reference.id);
      await actions.toggleRouteTracking(
          'AIzaSyBSKcBWb1nCdTBjrOPC9okX-lVa3PdjzcY',
          true,
          widgetOrderRef,
          order.pointB.latlng!);
      triggerPushNotification(
        notificationTitle: 'Статус заказа изменен на \"В работе\"',
        notificationText:
            'Водитель начал выполнение заказа. Вы можете отследить выполнение в приложении',
        notificationSound: 'default',
        userRefs: [order.userCustomer!],
        initialPageName: 'order_Page_Customer',
        parameterData: {'index': 1, 'order': widgetOrderRef},
      );
    } else {
      await showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Padding(
              padding: MediaQuery.viewInsetsOf(context),
              child: VklGeoWidget(),
            ),
          );
        },
      );
    }
  }

  Future<void> _finishWithPhoto(BuildContext context) async {
    if (!(await getPermissionStatus(cameraPermission))) {
      await requestPermission(cameraPermission);
      return;
    }

    final selectedMedia = await selectMedia(
        maxWidth: 500.00,
        maxHeight: 500.00,
        imageQuality: 95,
        multiImage: false);

    // Юзер закрыл камеру или не дал ни одного файла — молча выходим.
    if (selectedMedia == null || selectedMedia.isEmpty) return;

    if (!selectedMedia.every((m) => validateFileFormat(m.storagePath, context))) {
      return;
    }

    model.isDataUploading_uploadDataG298 = true;
    final newFiles = <FFUploadedFile>[];
    try {
      for (final m in selectedMedia) {
        if (m.bytes == null || m.bytes!.isEmpty) {
          print('[_finishWithPhoto] WARNING: media has no bytes path=${m.storagePath}');
          continue;
        }
        newFiles.add(FFUploadedFile(
          name: m.storagePath.split('/').last,
          bytes: m.bytes,
          height: m.dimensions?.height,
          width: m.dimensions?.width,
          blurHash: m.blurHash,
        ));
      }
    } finally {
      model.isDataUploading_uploadDataG298 = false;
    }

    if (newFiles.isEmpty) {
      print('[_finishWithPhoto] no valid files to add');
      return;
    }

    model.uploadedLocalFile_uploadDataG298 = newFiles;
    model.images.addAll(newFiles);
    print('[_finishWithPhoto] added ${newFiles.length} file(s), total=${model.images.length}');
    onStateChanged?.call();
  }

  Future<void> _uploadAndComplete(BuildContext context) async {
    model.isDataUploading_uploadDataSk6 = true;
    var selectedUploadedFiles = <FFUploadedFile>[];
    var selectedMedia = <SelectedFile>[];
    var downloadUrls = <String>[];
    try {
      selectedUploadedFiles = model.images;
      print('_uploadAndComplete: selectedUploadedFiles.length = ${selectedUploadedFiles.length}');

      selectedMedia = selectedFilesFromUploadedFiles(
        selectedUploadedFiles,
        isMultiData: true,
      );
      print('_uploadAndComplete: selectedMedia.length = ${selectedMedia.length}');

      final results = await Future.wait(selectedMedia
          .map((m) async {
            print('_uploadAndComplete: uploading ${m.storagePath} (${m.bytes.length} bytes)');
            return await uploadData(m.storagePath, m.bytes);
          }));

      print('_uploadAndComplete: upload results = $results');

      downloadUrls = results
          .where((u) => u != null)
          .map((u) => u!.toString())
          .toList();

      print('_uploadAndComplete: downloadUrls.length = ${downloadUrls.length}');
    } finally {
      model.isDataUploading_uploadDataSk6 = false;
    }
    if (selectedUploadedFiles.length == selectedMedia.length &&
        downloadUrls.length == selectedMedia.length) {
      model.uploadedLocalFile_uploadDataSk6 = selectedUploadedFiles;
      model.uploadedFileUrl_uploadDataSk6 = downloadUrls;
    } else {
      print('_uploadAndComplete: FAILED - counts dont match: files=${selectedUploadedFiles.length}, media=${selectedMedia.length}, urls=${downloadUrls.length}');
      await showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Padding(
              padding: MediaQuery.viewInsetsOf(context),
              child: ErrorPopupWidget(
                title: 'Ошибка загрузки',
                text: 'Не удалось загрузить фотографии. Попробуйте ещё раз.',
              ),
            ),
          );
        },
      );
      return;
    }

    final statusOk = await _pushOrderStatus(
      StatusOrder.on_confirmation,
      imageCompl: model.uploadedFileUrl_uploadDataSk6,
    );
    if (!statusOk) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось обновить статус заказа')),
      );
      return;
    }

    await _patchCurrentOrder(null);
    await actions.toggleRouteTracking('AIzaSyBSKcBWb1nCdTBjrOPC9okX-lVa3PdjzcY',
        false, widgetOrderRef, order.pointB.latlng!);
    triggerPushNotification(
      notificationTitle:
          'Статус заказа изменен на \"Ожидает подтверждения клиента\"',
      notificationText:
          'Если вы не подтвердите вручение в течение 12 часов, заказ будет завершён автоматически.',
      notificationSound: 'default',
      userRefs: [order.userCustomer!],
      initialPageName: 'order_Page_Customer',
      parameterData: {'index': 1, 'order': widgetOrderRef},
    );

    await _advanceQueue(context);
  }

  /// Удаляет текущий orderRef из очереди и, если в очереди есть следующий
  /// заказ, переходит на него (replace текущей страницы).
  Future<void> _advanceQueue(BuildContext context) async {
    final userRef = currentUserReference;
    if (userRef == null) return;

    Map<String, dynamic>? apiResult;
    try {
      apiResult = await AppMeApi.dequeueOrder(widgetOrderRef.id, advance: true);
    } catch (e) {
      print('[BottomActions.completeOrder] dequeue API ERROR $e');
    }

    if (apiResult == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось обновить очередь заказов')),
        );
      }
      return;
    }

    final nextId = apiResult['next_order_id']?.toString();
    final remaining = apiResult['remaining'];
    print('[BottomActions.completeOrder] API dequeue ok next=$nextId remaining=$remaining');
    if (nextId == null || nextId.isEmpty) return;
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => OrderPageDriverWidget(
          order: OrderRecord.collection.doc(nextId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine which button to show based on order status and selection
    if ((order.status == StatusOrder.newOrder) &&
        !order.userWhoResponced.contains(currentUserReference)) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondary,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.0),
                topRight: Radius.circular(18.0))),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 34.0),
          child: FFButtonWidget(
            onPressed: () async {
              if (valueOrDefault<bool>(
                  currentUserDocument?.verifCompl, false)) {
                if (await getPermissionStatus(locationPermission)) {
                  await showModalBottomSheet(
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (context) {
                      return GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        child: Padding(
                          padding: MediaQuery.viewInsetsOf(context),
                          child: CreateOtklickWidget(order: order),
                        ),
                      );
                    },
                  );
                  return;
                } else {
                  await showModalBottomSheet(
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (context) {
                      return GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        child: Padding(
                          padding: MediaQuery.viewInsetsOf(context),
                          child: VklGeoWidget(),
                        ),
                      );
                    },
                  );
                  await showModalBottomSheet(
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (context) {
                      return GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        child: Padding(
                          padding: MediaQuery.viewInsetsOf(context),
                          child: CreateOtklickWidget(order: order),
                        ),
                      );
                    },
                  );
                  return;
                }
              } else {
                await showModalBottomSheet(
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (context) {
                    return GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      child: Padding(
                        padding: MediaQuery.viewInsetsOf(context),
                        child: ErrorPopupWidget(
                            title: 'Аккаунт на модерации!',
                            text:
                                'Мы проверим ваш аккаунт в течении 24 часов, и откроем вам доступ ко всему приложению.'),
                      ),
                    );
                  },
                );
                return;
              }
            },
            text: 'Откликнуться',
            options: FFButtonOptions(
              width: double.infinity,
              height: 56.0,
              color: FlutterFlowTheme.of(context).tertiary,
              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                  fontFamily: 'SF',
                  color: FlutterFlowTheme.of(context).primaryBackground),
              elevation: 0.0,
              borderRadius: BorderRadius.circular(16.0),
            ),
            showLoadingIndicator: false,
          ),
        ),
      );
    }

    if ((order.selectedDriver == currentUserReference) &&
        (order.status == StatusOrder.spec_set) &&
        (currentUserDocument?.currentOrder?.orderDocRef == null)) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondary,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.0),
                topRight: Radius.circular(18.0))),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 34.0),
          child: FFButtonWidget(
            onPressed: () async {
              await _atPlacePickup(context);
            },
            text: 'Готов к подаче',
            options: FFButtonOptions(
              width: double.infinity,
              height: 56.0,
              color: FlutterFlowTheme.of(context).tertiary,
              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                  fontFamily: 'SF',
                  color: FlutterFlowTheme.of(context).primaryBackground),
              elevation: 0.0,
              borderRadius: BorderRadius.circular(16.0),
            ),
            showLoadingIndicator: false,
          ),
        ),
      );
    }

    if ((order.selectedDriver == currentUserReference) &&
        (order.status == StatusOrder.at_work)) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondary,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.0),
                topRight: Radius.circular(18.0))),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 34.0),
          child: FFButtonWidget(
            onPressed: () async {
              await _atPlaceDelivery(context);
            },
            text: 'Готов к выгрузке',
            options: FFButtonOptions(
              width: double.infinity,
              height: 56.0,
              color: FlutterFlowTheme.of(context).tertiary,
              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                  fontFamily: 'SF',
                  color: FlutterFlowTheme.of(context).primaryBackground),
              elevation: 0.0,
              borderRadius: BorderRadius.circular(16.0),
            ),
            showLoadingIndicator: false,
          ),
        ),
      );
    }

    if ((order.selectedDriver == currentUserReference) &&
        (order.status == StatusOrder.place_pickup)) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondary,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.0),
                topRight: Radius.circular(18.0))),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 34.0),
          child: FFButtonWidget(
            onPressed: () async {
              await _startOrder(context);
            },
            text: 'Начать поездку',
            options: FFButtonOptions(
              width: double.infinity,
              height: 56.0,
              color: FlutterFlowTheme.of(context).tertiary,
              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                  fontFamily: 'SF',
                  color: FlutterFlowTheme.of(context).primaryBackground),
              elevation: 0.0,
              borderRadius: BorderRadius.circular(16.0),
            ),
            showLoadingIndicator: false,
          ),
        ),
      );
    }

    if ((order.selectedDriver == currentUserReference) &&
        (order.status == StatusOrder.place_delivery)) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondary,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.0),
                topRight: Radius.circular(18.0))),
        child: Row(
          children: [
            if ((order.selectedDriver == currentUserReference) &&
                (order.status == StatusOrder.place_delivery) &&
                ((model.images.length > 2)))
              SizedBox(width: 10,),
            if ((order.selectedDriver == currentUserReference) &&
                (order.status == StatusOrder.place_delivery) &&
                ((model.images.length > 2)))
            Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 8.0, 0, 35.0),
                    child: FFButtonWidget(
                      onPressed: () async {
                        await _uploadAndComplete(context);
                      },
                      text: 'Завершить заказ',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 56.0,
                        color: FlutterFlowTheme.of(context).tertiary,
                        textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                            fontFamily: 'SF',
                            color: FlutterFlowTheme.of(context).primaryBackground),
                        elevation: 0.0,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      showLoadingIndicator: false,
                    ),
                  )),
            SizedBox(width: 10,),
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(00, 8.0, 0, 35.0),
                child: FFButtonWidget(
                  onPressed: () async {
                    await _finishWithPhoto(context);
                  },
                  text: 'Сделать фото',
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 56.0,
                    color: FlutterFlowTheme.of(context).tertiary,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                        fontFamily: 'SF',
                        color: FlutterFlowTheme.of(context).primaryBackground),
                    elevation: 0.0,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  showLoadingIndicator: false,
                ),
              ),
            ),
            SizedBox(width: 10,),

          ],
        ),
      );
    }

    if ((order.selectedDriver == currentUserReference) &&
        (order.status == StatusOrder.at_work) &&
        ((model.images.length > 3))) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondary,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.0),
                topRight: Radius.circular(18.0))),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 35.0),
          child: FFButtonWidget(
            onPressed: () async {
              await _uploadAndComplete(context);
            },
            text: 'Завершить заказ',
            options: FFButtonOptions(
              width: double.infinity,
              height: 56.0,
              color: FlutterFlowTheme.of(context).tertiary,
              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                  fontFamily: 'SF',
                  color: FlutterFlowTheme.of(context).primaryBackground),
              elevation: 0.0,
              borderRadius: BorderRadius.circular(16.0),
            ),
            showLoadingIndicator: false,
          ),
        ),
      );
    }

    return Container(
        decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground));
  }
}
