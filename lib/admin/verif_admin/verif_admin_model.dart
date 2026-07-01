import '/admin/navbar_admin/navbar_admin_widget.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/request_manager.dart';

import 'verif_admin_widget.dart' show VerifAdminWidget;
import 'package:flutter/material.dart';

class VerifAdminModel extends FlutterFlowModel<VerifAdminWidget> {
  ///  Local state fields for this page.

  int index = 1;

  ///  State fields for stateful widgets in this page.

  // Model for navbar_admin component.
  late NavbarAdminModel navbarAdminModel;

  /// Query cache managers for this widget.

  final _verifManager = StreamRequestManager<List<RequestVereficationRecord>>();
  Stream<List<RequestVereficationRecord>> verif({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Stream<List<RequestVereficationRecord>> Function() requestFn,
  }) =>
      _verifManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearVerifCache() => _verifManager.clear();
  void clearVerifCacheKey(String? uniqueKey) =>
      _verifManager.clearRequest(uniqueKey);

  @override
  void initState(BuildContext context) {
    navbarAdminModel = createModel(context, () => NavbarAdminModel());
  }

  @override
  void dispose() {
    navbarAdminModel.dispose();

    /// Dispose query cache managers for this widget.

    clearVerifCache();
  }
}
