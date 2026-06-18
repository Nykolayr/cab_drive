class CheckInnEntity {
  final bool success;
  final bool status;
  final String message;
  final int statusCode;

  CheckInnEntity({
    required this.success,
    required this.status,
    required this.message,
    required this.statusCode,
  });
}