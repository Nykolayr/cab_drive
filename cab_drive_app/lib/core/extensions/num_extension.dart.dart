extension NumExtension on num {
  String formatNumber() {
    final number = this;

    // Преобразуем число в строку
    String numberStr = number.toStringAsFixed(0);

    // Используем регулярное выражение для вставки пробелов
    RegExp regExp = RegExp(r'(?<=\d)(?=(\d{3})+$)');
    String formatted = numberStr.replaceAll(regExp, ' ');

    return formatted;
  }


  String formatSeconds() {
    final seconds = this;
    int minutes = seconds ~/ 60; // Деление на 60 для получения минут
    num remainingSeconds = seconds % 60; // Остаток от деления для получения оставшихся секунд

    // Форматируем минуты и секунды так, чтобы они всегда были в виде двух цифр
    String formattedMinutes = minutes.toString();
    String formattedSeconds = remainingSeconds.toString().padLeft(2, '0');

    return '$formattedMinutes:$formattedSeconds'; // Возвращаем отформатированную строку
  }

}