import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

extension DateExtension on DateTime {
    DateTime onlyDate () {
      return DateTime(year, month, day);
    }


    equalDate(DateTime different) {
      return day == different.day &&
          month == different.month &&
          year == different.year;
    }

    String getMonthWithDayName () {

      if(DateTime.now().onlyDate() == this.onlyDate()) {
        return 'Сегодня';
      }

      if(DateTime.now().onlyDate().difference(this.onlyDate()).inDays.abs() < 2) {
        return 'Вчера';
      }

      return '$day ${getMonthName()} ${getWeekDayName().toLowerCase()}';
    }

    String getMonthName ([bool short = true]) {
      switch (this.month) {
        case 1:
          return short ? 'янв.' : 'Январь';
        case 2:
          return short ? 'фев.' : 'Февраль';
        case 3:
          return short ? 'мар.' : 'Март';
        case 4:
          return short ? 'апр.' : 'Апрель';
        case 5:
          return short ? 'май.' : 'Май';
        case 6:
          return short ? 'июн.' : 'Июнь';
        case 7:
          return short ? 'июл.' : 'Июль';
        case 8:
          return short ? 'авг.' : 'Август';
        case 9:
          return short ? 'сен.' : 'Сентябрь';
        case 10:
          return short ? 'окт.' : 'Октябрь';
        case 11:
          return short ? 'нбр.' : 'Ноябрь';
        default:
          return short ? 'дек.' : 'Декабрь';
      }
    }

    String getWeekDayName () {
      switch (this.weekday) {
        case 1:
          return 'Понедельник';
        case 2:
          return 'Вторник';
        case 3:
          return 'Среда';
        case 4:
          return 'Четверг';
        case 5:
          return 'Пятница';
        case 6:
          return 'Субота';
        default:
          return 'Воскресенье';
      }
    }

    String getTitleFromTimesOfDay () {
      String timeOfDay = hour >= 5 && hour < 13 ? 'Утром' : hour >= 13 && hour < 18 ? 'Днём' : hour >= 18 && hour < 21 ? 'Вечером' : 'Ночью';

      return '$timeOfDay в ${DateFormat('HH:mm').format(this)}';
    }

}
