import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/driver/city/city_widget.dart';
import '/driver/popolnit_balans/popolnit_balans_widget.dart';
import '/driver/sposobviplat/sposobviplat_widget.dart';
import '/driver/za_chto_plata/za_chto_plata_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/login/verif/verification_preview/verification_preview_widget.dart';
import '/pages/bottom/navbar/navbar_widget.dart';
import '/pages/bottom/ratting/ratting_widget.dart';
import '/pages/menu/moi_adresa/moi_adresa_widget.dart';
import '/pages/menu/moi_otzivi/moi_otzivi_widget.dart';
import '/pages/menu/moi_zakazy/moi_zakazy_widget.dart';
import '/pages/menu/o_prilozhen/o_prilozhen_widget.dart';
import '/pages/menu/rate_app/rate_app_widget.dart';
import 'dart:async';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/request_manager.dart';

import '/index.dart';
import 'profile_widget.dart' show ProfileWidget;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class ProfileModel extends FlutterFlowModel<ProfileWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for navbar component.
  late NavbarModel navbarModel;

  /// Query cache managers for this widget.

  final _kuhoihManager = FutureRequestManager<int>();
  Future<int> kuhoih({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<int> Function() requestFn,
  }) =>
      _kuhoihManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearKuhoihCache() => _kuhoihManager.clear();
  void clearKuhoihCacheKey(String? uniqueKey) =>
      _kuhoihManager.clearRequest(uniqueKey);

  @override
  void initState(BuildContext context) {
    navbarModel = createModel(context, () => NavbarModel());
  }

  @override
  void dispose() {
    navbarModel.dispose();

    /// Dispose query cache managers for this widget.

    clearKuhoihCache();
  }
}
