import '/admin/navbar_admin/navbar_admin_widget.dart';
import '/backend/backend.dart';
import '/chat/sms_chat/sms_chat_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'chat_admin_widget.dart' show ChatAdminWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ChatAdminModel extends FlutterFlowModel<ChatAdminWidget> {
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
