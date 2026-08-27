
abstract class StatusEnum {

}

class SuccessStatus extends StatusEnum {

}

class LoadingStatus extends StatusEnum {

}

class FailedStatus extends StatusEnum {
  final dynamic exception;

  @override
  String toString () {
    return 'FailedStatus - ${exception.toString()}';
  }

  FailedStatus({required this.exception});
}