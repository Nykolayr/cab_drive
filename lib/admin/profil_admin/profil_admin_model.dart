import '/admin/navbar_admin/navbar_admin_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'profil_admin_widget.dart' show ProfilAdminWidget;
import 'package:flutter/material.dart';

class ProfilAdminModel extends FlutterFlowModel<ProfilAdminWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for navbar_admin component.
  late NavbarAdminModel navbarAdminModel;

  @override
  void initState(BuildContext context) {
    navbarAdminModel = createModel(context, () => NavbarAdminModel());
  }

  @override
  void dispose() {
    navbarAdminModel.dispose();
  }
}
