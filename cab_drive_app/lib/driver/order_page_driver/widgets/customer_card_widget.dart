import '../../../auth/firebase_auth/auth_util.dart';
import '../../../backend/api/chat_open.dart';
import '../../../backend/api/file_storage_service.dart';
import '../../../backend/api/users_record_api.dart';
import '../order_page_driver_model.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/bottom/ratting/ratting_widget.dart';
import '/pages/bottom/create_rewievs/create_rewievs_widget.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '/flutter_flow/flutter_flow_util.dart';

// Customer card with contact and actions (chat/call)
class CustomerCardWidget extends StatelessWidget {
  const CustomerCardWidget({
    super.key,
    required this.order,
    required this.model,
    required this.widgetOrderRef,
  });

  final OrderRecord order;
  final OrderPageDriverModel model;
  final DocumentReference widgetOrderRef;

  @override
  Widget build(BuildContext context) {
    final isSelectedDriver = order.selectedDriver == currentUserReference;
    final height = isSelectedDriver ? 185.0 : 140.0;

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: FutureBuilder<UsersRecord>(
        future: UsersRecordApi.getOnce(order.userCustomer!),
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
          final user = snapshot.data!;
          return Padding(
            padding: EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Заказчик', style: FlutterFlowTheme.of(context).bodyMedium.override(fontFamily: 'SF', fontSize: 21.0, fontWeight: FontWeight.w600)),
                SizedBox(height: 12.0),
                InkWell(
                  onTap: () async {
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
                            child: RattingWidget(user: user.reference, index: 2),
                          ),
                        );
                      },
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Color(0x27A4A6B2)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(FileStorageService.getImageUrl(user.photoUrl), width: 45.0, height: 60.0, fit: BoxFit.cover),
                        ),
                      ),
                      SizedBox(width: 11.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.displayName, maxLines: 1, style: FlutterFlowTheme.of(context).bodyMedium.override(fontFamily: 'SF', fontSize: 16.0)),
                            SizedBox(height: 9.0),
                            Builder(builder: (context) {
                              if (user.numberOfReviews != 0) {
                                return Row(
                                  children: [
                                    Container(
                                      height: 30.0,
                                      decoration: BoxDecoration(color: FlutterFlowTheme.of(context).primaryBackground, borderRadius: BorderRadius.circular(8.0)),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(10.0, 4.0, 10.0, 4.0),
                                        child: Row(
                                          children: [
                                            Icon(FFIcons.kantDesignStarFilled, color: FlutterFlowTheme.of(context).warning, size: 16.0),
                                            SizedBox(width: 6.0),
                                            Text(
                                              formatNumber(
                                                user.averageRating,
                                                formatType: FormatType.custom,
                                                format: '0.0',
                                                locale: '',
                                              ),
                                              style: FlutterFlowTheme.of(context).bodyMedium.override(fontFamily: 'SF', color: Color(0xFFA4A6B2)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 4.0),
                                    Container(
                                      height: 30.0,
                                      decoration: BoxDecoration(color: FlutterFlowTheme.of(context).primaryBackground, borderRadius: BorderRadius.circular(8.0)),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(10.0, 4.0, 10.0, 4.0),
                                        child: Row(
                                          children: [
                                            Icon(FFIcons.kmessageTextCircle02, color: FlutterFlowTheme.of(context).primaryText, size: 14.0),
                                            SizedBox(width: 6.0),
                                            Text(user.numberOfReviews.toString(), style: FlutterFlowTheme.of(context).bodyMedium.override(fontFamily: 'SF', color: Color(0xFFA4A6B2), fontWeight: FontWeight.w500)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return Container(
                                  height: 30.0,
                                  decoration: BoxDecoration(color: FlutterFlowTheme.of(context).primaryBackground, borderRadius: BorderRadius.circular(8.0)),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(10.0, 4.0, 10.0, 4.0),
                                    child: Row(
                                      children: [
                                        Icon(FFIcons.kantDesignStarFilled, color: FlutterFlowTheme.of(context).warning, size: 16.0),
                                        SizedBox(width: 6.0),
                                        Text('Нет отзывов', style: FlutterFlowTheme.of(context).bodyMedium.override(fontFamily: 'SF', color: Color(0xFFA4A6B2))),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelectedDriver) SizedBox(height: 8.0),
                if (isSelectedDriver)
                  Row(
                    children: [
                      Expanded(
                        child: FFButtonWidget(
                          onPressed: () async {
                            await openPeerChat(
                              context,
                              peerUid: user.reference.id,
                              name: '${user.displayName} ${user.surname}',
                            );
                          },
                          text: 'Написать',
                          options: FFButtonOptions(
                            height: 45.0,
                            color: FlutterFlowTheme.of(context).primaryBackground,
                            textStyle: FlutterFlowTheme.of(context).titleSmall.override(fontFamily: 'SF', color: FlutterFlowTheme.of(context).tertiary, fontSize: 15.0),
                            elevation: 0.0,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          showLoadingIndicator: false,
                        ),
                      ),
                      SizedBox(width: 7.0),
                      Expanded(
                        child: FFButtonWidget(
                          onPressed: () async {
                            await launchUrl(Uri(scheme: 'tel', path: user.phoneNumber));
                          },
                          text: 'Позвонить',
                          options: FFButtonOptions(
                            height: 45.0,
                            color: FlutterFlowTheme.of(context).primaryBackground,
                            textStyle: FlutterFlowTheme.of(context).titleSmall.override(fontFamily: 'SF', color: FlutterFlowTheme.of(context).tertiary, fontSize: 15.0),
                            elevation: 0.0,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          showLoadingIndicator: false,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}