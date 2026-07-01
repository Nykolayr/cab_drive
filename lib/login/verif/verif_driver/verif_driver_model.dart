import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'verif_driver_widget.dart' show VerifDriverWidget;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VerifDriverModel extends FlutterFlowModel<VerifDriverWidget> {
  ///  Local state fields for this page.

  String? passport;

  List<FFUploadedFile> car = [];
  void addToCar(FFUploadedFile item) => car.add(item);
  void removeFromCar(FFUploadedFile item) => car.remove(item);
  void removeAtIndexFromCar(int index) => car.removeAt(index);
  void insertAtIndexInCar(int index, FFUploadedFile item) =>
      car.insert(index, item);
  void updateCarAtIndex(int index, Function(FFUploadedFile) updateFn) =>
      car[index] = updateFn(car[index]);

  String? prava1;

  String? tehps1;

  String? selfi1;

  String? prava2;

  Car? mark = Car.largus;

  String? region;

  ///  State fields for stateful widgets in this page.

  final formKey2 = GlobalKey<FormState>();
  final formKey1 = GlobalKey<FormState>();
  // State field(s) for PageView widget.
  PageController? pageViewController;

  int get pageViewCurrentIndex => pageViewController != null &&
          pageViewController!.hasClients &&
          pageViewController!.page != null
      ? pageViewController!.page!.round()
      : 0;
  bool isDataUploading_uploadData2pb2 = false;
  FFUploadedFile uploadedLocalFile_uploadData2pb2 =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadData2pb2 = '';

  // State field(s) for nameInput widget.
  FocusNode? nameInputFocusNode;
  TextEditingController? nameInputTextController;
  String? Function(BuildContext, String?)? nameInputTextControllerValidator;
  String? _nameInputTextControllerValidator(BuildContext context, String? val) {
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

  // State field(s) for lastNameInput widget.
  FocusNode? lastNameInputFocusNode;
  TextEditingController? lastNameInputTextController;
  String? Function(BuildContext, String?)? lastNameInputTextControllerValidator;
  String? _lastNameInputTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Пожалуйста, представьтесь';
    }

    if (val.length < 1) {
      return 'Фамилия должна быть от 1 до 32 символов';
    }
    if (val.length > 32) {
      return 'Фамилия должна быть от 1 до 32 символов';
    }
    if (!RegExp('^[А-Яа-яЁё]+(?: [А-Яа-яЁё]+)*\\s*\$').hasMatch(val)) {
      return 'Некорректная фамилия';
    }
    return null;
  }

  DateTime? datePicked;
  // State field(s) for dtbInput widget.
  FocusNode? dtbInputFocusNode;
  TextEditingController? dtbInputTextController;
  String? Function(BuildContext, String?)? dtbInputTextControllerValidator;
  String? _dtbInputTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Пожалуйста, укажите вашу дату рождения';
    }

    return null;
  }

  // State field(s) for emailInput widget.
  FocusNode? emailInputFocusNode;
  TextEditingController? emailInputTextController;
  String? Function(BuildContext, String?)? emailInputTextControllerValidator;
  String? _emailInputTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Пожалуйста, укажите вашу электронную почту';
    }

    if (!RegExp('^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}\$')
        .hasMatch(val)) {
      return 'Неправильный адрес электронной почты';
    }
    return null;
  }

  // State field(s) for cityInput widget.
  FocusNode? cityInputFocusNode;
  TextEditingController? cityInputTextController;
  String? Function(BuildContext, String?)? cityInputTextControllerValidator;
  String? _cityInputTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Пожалуйста, укажите ваш город';
    }

    return null;
  }

  // State field(s) for number widget.
  FocusNode? numberFocusNode;
  TextEditingController? numberTextController;
  String? Function(BuildContext, String?)? numberTextControllerValidator;
  String? _numberTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Обязательно для заполнения';
    }

    return null;
  }

  bool isDataUploading_uploadDataH1g22 = false;
  List<FFUploadedFile> uploadedLocalFiles_uploadDataH1g22 = [];

  @override
  void initState(BuildContext context) {
    nameInputTextControllerValidator = _nameInputTextControllerValidator;
    lastNameInputTextControllerValidator =
        _lastNameInputTextControllerValidator;
    dtbInputTextControllerValidator = _dtbInputTextControllerValidator;
    emailInputTextControllerValidator = _emailInputTextControllerValidator;
    cityInputTextControllerValidator = _cityInputTextControllerValidator;
    numberTextControllerValidator = _numberTextControllerValidator;
  }

  @override
  void dispose() {
    nameInputFocusNode?.dispose();
    nameInputTextController?.dispose();

    lastNameInputFocusNode?.dispose();
    lastNameInputTextController?.dispose();

    dtbInputFocusNode?.dispose();
    dtbInputTextController?.dispose();

    emailInputFocusNode?.dispose();
    emailInputTextController?.dispose();

    cityInputFocusNode?.dispose();
    cityInputTextController?.dispose();

    numberFocusNode?.dispose();
    numberTextController?.dispose();
  }
}
