import '/flutter_flow/flutter_flow_util.dart';
import '/pages/bottom/app_bar/app_bar_widget.dart';
import 'zakaz_na_karte_widget.dart' show ZakazNaKarteWidget;
import 'package:flutter/material.dart';

class ZakazNaKarteModel extends FlutterFlowModel<ZakazNaKarteWidget> {
  late AppBarModel appBarModel;

  @override
  void initState(BuildContext context) {
    appBarModel = createModel(context, () => AppBarModel());
  }

  @override
  void dispose() {
    appBarModel.dispose();
  }
}
