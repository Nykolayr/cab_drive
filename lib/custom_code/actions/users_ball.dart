// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future usersBall(
  List<DocumentReference>? users,
  double summ,
) async {
  // Если список пуст или равен null, выходим из функции
  if (users == null) return;

  // Проходим по каждому документу в списке
  for (final userRef in users) {
    try {
      // Обновляем поле 'balance', прибавляя к нему значение summ
      // FieldValue.increment обеспечивает атомарное обновление
      await userRef.update({
        'balance': FieldValue.increment(summ),
      });
    } catch (e) {
      // Выводим ошибку в консоль, если обновление не удалось
      print("Ошибка при обновлении баланса пользователя: $e");
    }
  }
}
