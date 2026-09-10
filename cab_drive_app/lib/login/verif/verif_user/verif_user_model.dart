import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/core/utils/formatters/ru_phone.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'verif_user_widget.dart' show VerifUserWidget;
import 'package:flutter/material.dart';

class VerifUserModel extends FlutterFlowModel<VerifUserWidget> {
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

  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // State field(s) for Name widget.
  FocusNode? nameFocusNode;
  TextEditingController? nameTextController =
      TextEditingController(text: currentUserDocument?.displayName);
  String? Function(BuildContext, String?)? nameTextControllerValidator;
  String? _nameTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Пожалуйста, представьтесь';
    }

    if (val.length < 1) {
      return 'Имя должно быть от 1 до 32 символов';
    }
    if (val.length > 32) {
      return 'Имя должно быть от 1 до 32 символов';
    }
    if (!RegExp('^[А-Яа-яЁё]+(?: [А-Яа-яЁё]+)*\\s*\$').hasMatch(val)) {
      return 'Некорректное имя';
    }
    return null;
  }

  // State field(s) for AdditionalPhone widget.
  FocusNode? additionalPhoneFocusNode;
  TextEditingController? additionalPhoneTextController = TextEditingController(
    text: RuPhone.mask(currentUserDocument?.additionalPhoneNumber),
  );
  String? Function(BuildContext, String?)?
      additionalPhoneTextControllerValidator;
  String? _additionalPhoneTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.trim().isEmpty) {
      return null;
    }
    if (!RuPhone.isComplete(val)) {
      return 'Введите номер полностью';
    }
    return null;
  }

  @override
  void initState(BuildContext context) {
    nameTextControllerValidator = _nameTextControllerValidator;
    additionalPhoneTextControllerValidator =
        _additionalPhoneTextControllerValidator;
  }

  @override
  void dispose() {
    nameFocusNode?.dispose();
    nameTextController?.dispose();
    additionalPhoneFocusNode?.dispose();
    additionalPhoneTextController?.dispose();
  }
}
