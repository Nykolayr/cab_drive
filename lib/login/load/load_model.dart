import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'load_widget.dart' show LoadWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LoadModel extends FlutterFlowModel<LoadWidget> {
  ///  Local state fields for this page.

  FFUploadedFile? passport;

  List<FFUploadedFile> car = [];
  void addToCar(FFUploadedFile item) => car.add(item);
  void removeFromCar(FFUploadedFile item) => car.remove(item);
  void removeAtIndexFromCar(int index) => car.removeAt(index);
  void insertAtIndexInCar(int index, FFUploadedFile item) =>
      car.insert(index, item);
  void updateCarAtIndex(int index, Function(FFUploadedFile) updateFn) =>
      car[index] = updateFn(car[index]);

  FFUploadedFile? prava1;

  FFUploadedFile? tehps1;

  FFUploadedFile? selfi1;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
