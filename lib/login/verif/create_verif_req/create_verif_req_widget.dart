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
import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'create_verif_req_model.dart';
export 'create_verif_req_model.dart';

class CreateVerifReqWidget extends StatefulWidget {
  const CreateVerifReqWidget({
    super.key,
    required this.name,
    required this.surnme,
    required this.mail,
    required this.dtb,
    required this.marka,
    required this.nomer,
    required this.photoDoc,
    required this.photoCar,
    required this.city,
    required this.region,
  });

  final String? name;
  final String? surnme;
  final String? mail;
  final DateTime? dtb;
  final Car? marka;
  final String? nomer;
  final List<String>? photoDoc;
  final List<FFUploadedFile>? photoCar;
  final String? city;
  final String? region;

  @override
  State<CreateVerifReqWidget> createState() => _CreateVerifReqWidgetState();
}

class _CreateVerifReqWidgetState extends State<CreateVerifReqWidget> {
  late CreateVerifReqModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CreateVerifReqModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      {
        safeSetState(() => _model.isDataUploading_uploadData1tw = true);
        var selectedUploadedFiles = <FFUploadedFile>[];
        var selectedMedia = <SelectedFile>[];
        var downloadUrls = <String>[];
        try {
          selectedUploadedFiles = widget.photoCar!;
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
          _model.isDataUploading_uploadData1tw = false;
        }
        if (selectedUploadedFiles.length == selectedMedia.length &&
            downloadUrls.length == selectedMedia.length) {
          safeSetState(() {
            _model.uploadedLocalFiles_uploadData1tw = selectedUploadedFiles;
            _model.uploadedFileUrls_uploadData1tw = downloadUrls;
          });
        } else {
          safeSetState(() {});
          return;
        }
      }

      _model.count = await queryRequestVereficationRecordCount();

      var requestVereficationRecordReference =
          RequestVereficationRecord.collection.doc();
      await requestVereficationRecordReference.set({
        ...createRequestVereficationRecordData(
          city: widget.city,
          name: widget.name,
          surname: widget.surnme,
          numberAvto: widget.nomer,
          phoneNumber: currentPhoneNumber,
          dfb: widget.dtb,
          user: currentUserReference,
          status: StatusVerif.onVerif,
          dateCreated: functions.toUtc(),
          numberId: (_model.count!) + 1,
          email: widget.mail,
          avatar: currentUserPhoto,
          marka: widget.marka,
        ),
        ...mapToFirestore(
          {
            'photo_doc': widget.photoDoc,
            'photo_avto': _model.uploadedFileUrls_uploadData1tw,
          },
        ),
      });
      _model.verif = RequestVereficationRecord.getDocumentFromData({
        ...createRequestVereficationRecordData(
          city: widget.city,
          name: widget.name,
          surname: widget.surnme,
          numberAvto: widget.nomer,
          phoneNumber: currentPhoneNumber,
          dfb: widget.dtb,
          user: currentUserReference,
          status: StatusVerif.onVerif,
          dateCreated: functions.toUtc(),
          numberId: (_model.count!) + 1,
          email: widget.mail,
          avatar: currentUserPhoto,
          marka: widget.marka,
        ),
        ...mapToFirestore(
          {
            'photo_doc': widget.photoDoc,
            'photo_avto': _model.uploadedFileUrls_uploadData1tw,
          },
        ),
      }, requestVereficationRecordReference);

      await currentUserReference!.update(createUsersRecordData(
        displayName: widget.name,
        loginComplete: true,
        isDriver: true,
        admin: false,
        surname: widget.surnme,
        city: widget.city,
        dfb: widget.dtb,
        verifCompl: false,
        onVerifNow: true,
        car: updateCarStruct(
          CarStruct(
            nomer: widget.nomer,
            images: _model.uploadedFileUrls_uploadData1tw,
            mark: widget.marka,
          ),
          clearUnsetFields: false,
        ),
        verifNeProidena: false,
        verifId: _model.verif?.numberId,
        emailUser: widget.mail,
      ));
      _model.admin = await queryUsersRecordOnce(
        queryBuilder: (usersRecord) => usersRecord.where(
          'admin',
          isEqualTo: true,
        ),
        singleRecord: true,
      ).then((s) => s.firstOrNull);
      triggerPushNotification(
        notificationTitle: 'Новый водитель!',
        notificationText:
            'В приложении появился новый водитель, перейдите на страницу заявки и рассмотрите ее',
        notificationSound: 'default',
        userRefs: [_model.admin!.reference],
        initialPageName: 'Detali_zayavki_Admin',
        parameterData: {
          'docref': _model.verif?.reference,
        },
      );
      FFAppState().driver = true;
      FFAppState().update(() {});

      context.goNamed(MainDriverWidget.routeName);
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
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32.0),
          topRight: Radius.circular(32.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 36.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 32.0, 0.0, 0.0),
                        child: AutoSizeText(
                          'Создание заявки на верификацию',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'SF',
                                    fontSize: 24.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ),
                    ],
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
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 24.0, 0.0),
              child: Text(
                'Создаем вашу заявку на верификацию. Это может занять несколько секунд. Пожалуйста, подождите.',
                textAlign: TextAlign.start,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'SF',
                      color: FlutterFlowTheme.of(context).primaryText,
                      fontSize: 16.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.normal,
                      lineHeight: 1.5,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
