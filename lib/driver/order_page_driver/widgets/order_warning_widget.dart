import 'dart:async';
import 'dart:typed_data';
import '../../../auth/firebase_auth/auth_util.dart';
import '../../../backend/schema/enums/enums.dart';
import '../../../pages/bottom/text_info/text_info_widget.dart';
import '../../otmena_otklika/otmena_otklika_widget.dart';
import '../order_page_driver_model.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/pages/bottom/error_popup/error_popup_widget.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'countdown_or_expired.dart';

// Shows top block with different driver-specific statuses and image upload UI.
// Kept behavior similar to original but simplified and extracted.
class OrderWarningWidget extends StatelessWidget {
  const OrderWarningWidget({
    super.key,
    required this.order,
    required this.model,
    required this.widgetOrderRef, this.onTap,
  });

  final OrderRecord order;
  final Function()? onTap;
  final OrderPageDriverModel model;
  final DocumentReference widgetOrderRef;

  @override
  Widget build(BuildContext context) {
    final isSelectedDriver = order.selectedDriver == currentUserReference;
    final status = order.status;

    if (!order.userWhoResponced.contains(currentUserReference)) {
      return SizedBox.shrink();
    }

    // Case: driver selected and at_work -> instruction and photo UI
    if (isSelectedDriver && status == StatusOrder.place_delivery) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(18.0),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Сделайте фото перед завершением!',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'SF',
                        color: FlutterFlowTheme.of(context).error,
                        fontSize: 21.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    FFIcons.kalertHexagon,
                    color: FlutterFlowTheme.of(context).error,
                    size: 30.0,
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Text(
                'Перед тем как завершить заказ, сфотографируйте груз на месте доставки (от 3 до 10 снимков). \nЭто нужно для подтверждения, что всё доставлено.',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'SF',
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: CountdownOrExpired(
                  dateUpd: order.dateUpd,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'SF',
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: FlutterFlowTheme.of(context).error,
                  ),
                  expiredStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'SF',
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: FlutterFlowTheme.of(context).error,
                  ),
                  descriptionTextStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'SF',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if ((model.images?.isNotEmpty ?? false))
                Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width,
                        height: 150,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: model.images.map((e) => Padding(
                            padding: EdgeInsetsGeometry.only(right: 10),
                            child: GestureDetector(
                              onTap: () async {
                                final selectedMedia = await selectMedia(
                                  maxWidth: 500.00,
                                  maxHeight: 500.00,
                                  imageQuality: 95,
                                  multiImage: false,
                                );
                                if (selectedMedia != null &&
                                    selectedMedia.every((m) =>
                                        validateFileFormat(m.storagePath, context))) {
                                  // prepare uploaded file
                                  model.isDataUploading_uploadDataG2983 = true;
                                  List<FFUploadedFile> selectedUploadedFiles = [];
                                  try {
                                    selectedUploadedFiles = selectedMedia
                                        .map((m) => FFUploadedFile(
                                      name: m.storagePath.split('/').last,
                                      bytes: m.bytes,
                                      height: m.dimensions?.height,
                                      width: m.dimensions?.width,
                                      blurHash: m.blurHash,
                                    ))
                                        .toList();
                                  } finally {
                                    model.isDataUploading_uploadDataG2983 = false;
                                  }
                                  if (selectedUploadedFiles.length ==
                                      selectedMedia.length) {
                                    model.uploadedLocalFile_uploadDataG2983 =
                                        selectedUploadedFiles.first;
                                    model.images[model.images.indexOf(e)] = model.uploadedLocalFile_uploadDataG2983;
                                  } else {
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
                                          title: 'Что-то пошло не так',
                                          text: 'Давайте попробуем позже.',
                                        ),
                                      ),
                                    );
                                  },
                                  );
                                  return;
                                }
                                onTap?.call();
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.memory(
                                  e.bytes ?? Uint8List.fromList([]),
                                  width: 150,
                                  height: 150.0,
                                  fit: BoxFit.cover,
                                ),
                              ),

                            ),
                          )).toList(),
                        ),
                      ),

                      SizedBox(height: 12.0),

                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // Case: selectedDriver & on_confirmation -> show confirmation message and review prompt
    if (isSelectedDriver && status == StatusOrder.on_confirmation) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(18.0),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Заказ на подтверждении',
                  style:
                  FlutterFlowTheme.of(context).bodyMedium.override(fontFamily: 'SF', fontSize: 21.0, fontWeight: FontWeight.w600)),
              SizedBox(height: 8.0),
              Text(
                order.payMethod == PayMethod.card
                    ? 'Клиент должен подтвердить завершение заказа. Если он не сделает этого в течение 12 часов, заказ автоматически завершится, и вы получите оплату.'
                    : 'Вы завершили заказ и получили оплату наличными. Клиенту осталось подтвердить получение. Если он не сделает этого в течение 12 часов, заказ автоматически закроется в системе.',
                style: FlutterFlowTheme.of(context).bodyMedium.override(fontFamily: 'SF', fontSize: 18.0, fontWeight: FontWeight.w500),
              ),
              // The original contained review buttons — keep that behavior encapsulated elsewhere if needed.
            ],
          ),
        ),
      );
    }

    // Case: selectedDriver & completed -> simple completed block
    if (isSelectedDriver && status == StatusOrder.completed) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(18.0),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Заказ завершён',
                  style:
                  FlutterFlowTheme.of(context).bodyMedium.override(fontFamily: 'SF', fontSize: 21.0, fontWeight: FontWeight.w600)),
              SizedBox(height: 8.0),
              Text(
                (order.selectedDriver == currentUserReference) && !order.customerReviewed
                    ? 'Клиент подтвердил выполнение заказа.Спасибо за работу — заказ успешно завершён! Теперь вы можете оценить заказчика — это поможет другим водителям.'
                    : 'Клиент подтвердил выполнение заказа.Спасибо за работу — заказ успешно завершён!',
                style: FlutterFlowTheme.of(context).bodyMedium.override(fontFamily: 'SF', fontSize: 18.0, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    // Case: selectedDriver & spec_set
    if (isSelectedDriver && status == StatusOrder.spec_set) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(18.0),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Вас выбрали!',
                  style:
                  FlutterFlowTheme.of(context).bodyMedium.override(fontFamily: 'SF', fontSize: 21.0, fontWeight: FontWeight.w600)),
              SizedBox(height: 8.0),
              Text(
                order.supply == 1 ? 'Подача в ближайшее время: Подготовьтесь и отправляйтесь на точку подачи как можно скорее.' : 'Заказ нужно выполнить к назначенному времени — заранее спланируйте маршрут и выезд.',
                style: FlutterFlowTheme.of(context).bodyMedium.override(fontFamily: 'SF', fontSize: 18.0, fontWeight: FontWeight.w500),
              ),

            ],
          ),
        ),
      );
    }

    if (isSelectedDriver && status == StatusOrder.place_pickup) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(18.0),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ожидание подачи',
                  style:
                  FlutterFlowTheme.of(context).bodyMedium.override(fontFamily: 'SF', fontSize: 21.0, fontWeight: FontWeight.w600)),
              SizedBox(height: 8.0),
                Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: CountdownOrExpired(
                    dateUpd: order.dateUpd,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'SF',
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: FlutterFlowTheme.of(context).error,
                    ),
                    expiredStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'SF',
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: FlutterFlowTheme.of(context).error,
                    ),
                    descriptionTextStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'SF',
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    if (isSelectedDriver && status == StatusOrder.at_work) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(18.0),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ожидаем вас на месте выгрузки',
                  style:
                  FlutterFlowTheme.of(context).bodyMedium.override(fontFamily: 'SF', fontSize: 21.0, fontWeight: FontWeight.w600)),

            ],
          ),
        ),
      );
    }

    // Default: if driver hasn't been selected, show "Отклик отправлен" block by querying responses.
    return FutureBuilder<List<ResponsesRecord>>(
      future: queryResponsesRecordOnce(
        parent: widgetOrderRef,
        queryBuilder: (responsesRecord) => responsesRecord.where(
          'user_driver',
          isEqualTo: currentUserReference,
        ),
        singleRecord: true,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: SizedBox(
              width: 50.0,
              height: 50.0,
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(FlutterFlowTheme.of(context).primary)),
            ),
          );
        }
        final responses = snapshot.data!;
        if (responses.isEmpty) return SizedBox.shrink();
        final resp = responses.first;

        return Container(
          decoration: BoxDecoration(),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Отклик отправлен', style: FlutterFlowTheme.of(context).bodyMedium.override(fontFamily: 'SF', fontSize: 21.0, fontWeight: FontWeight.w600)),
                SizedBox(height: 8.0),
                Text('Вы откликнулись на заказ.\nКлиент ещё не выбрал исполнителя — вы можете отменить отклик, пока заказ не принят.',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(fontFamily: 'SF', fontSize: 18.0, fontWeight: FontWeight.w500)),
                SizedBox(height: 12.0),
                // Price info
                TextInfoWidget(tittle: 'Сумма отклика', pole: resp.price?.toString()),
                SizedBox(height: 12.0),
                TextInfoWidget(tittle: 'Комментарий отклика', pole: resp.text),
                if (order.status == StatusOrder.newOrder)
                  Padding(
                    padding: EdgeInsets.only(top: 12.0),
                    child: FFButtonWidget(
                      onPressed: () async {
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
                                child: OtmenaOtklikaWidget(order: order, resp: resp.reference),
                              ),
                            );
                          },
                        );
                      },
                      text: 'Отменить отклик',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 45.0,
                        color: FlutterFlowTheme.of(context).primaryBackground,
                        textStyle: FlutterFlowTheme.of(context).titleSmall.override(fontFamily: 'SF', color: FlutterFlowTheme.of(context).error, fontSize: 15.0),
                        elevation: 0.0,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      showLoadingIndicator: false,
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
