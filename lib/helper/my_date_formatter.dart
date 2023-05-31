import 'package:flutter/material.dart';

class MyDateFormatter {
  static String getFormatDate(
      {required BuildContext context, required String time}) {
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(date).format(context);
  }

  static String getLastMessageTime(
      {required BuildContext context,
      required String time,
      required bool year}) {
    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();

    if (sent.day == now.day &&
        sent.month == now.month &&
        sent.year == now.year) {
      return TimeOfDay.fromDateTime(sent).format(context);
    }

    return year == true
        ? '${sent.day} ${MyDateFormatter._getMonth(sent.month)} ${sent.year}'
        : '${sent.day} ${MyDateFormatter._getMonth(sent.month)}';
  }

  static String _getMonth(int month) {
    switch (month) {
      case 1:
        return 'Jan';

      case 2:
        return 'Feb';

      case 3:
        return 'Mar';

      case 4:
        return 'Apr';

      case 5:
        return 'May';

      case 6:
        return 'Jun';

      case 7:
        return 'Jul';

      case 8:
        return 'Aug';

      case 9:
        return 'Sep';

      case 10:
        return 'Oct';

      case 11:
        return 'Nov';

      case 12:
        return 'Dec';

      default:
        return 'N/A';
    }
  }

  // for getting the last active time of user
  static String getlastActiveTime(
      {required BuildContext context, required String lastActive}) {
    final int i = int.tryParse(lastActive) ?? -1;

    if (i == -1) return 'Last seen not available';

    DateTime time = DateTime.fromMillisecondsSinceEpoch(i);
    DateTime now = DateTime.now();

    String formattedTime = TimeOfDay.fromDateTime(time).format(context);
    if (time.day == now.day &&
        time.month == now.month &&
        time.year == now.year) {
      return 'Last seen today at ${formattedTime}';
    }

    if ((now.difference(time).inHours / 24).round() == 1) {
      return 'Last seen yesterday at ${formattedTime}';
    }

    String month = _getMonthh(time);
    return 'Last seen on  ${time.day} ${month} on ${formattedTime}';
  }

  static String _getMonthh(DateTime date) {
    switch (date.month) {
      case 1:
        return 'Jan';

      case 2:
        return 'Feb';

      case 3:
        return 'Mar';

      case 4:
        return 'Apr';

      case 5:
        return 'May';

      case 6:
        return 'Jun';

      case 7:
        return 'Jul';

      case 8:
        return 'Aug';

      case 9:
        return 'Sep';

      case 10:
        return 'Oct';

      case 11:
        return 'Nov';

      case 12:
        return 'Dec';

      default:
        return 'N/A';
    }
  }

  // for getting last message sent and read time
  static String getMessageTime(
      {required BuildContext context, required String time}) {
    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();

    final formattedTime = TimeOfDay.fromDateTime(sent).format(context);
    if (sent.day == now.day &&
        sent.month == now.month &&
        sent.year == now.year) {
      return formattedTime;
    }

    return sent.year == now.year
        ? '${formattedTime} - ${sent.day} ${MyDateFormatter._getMonth(sent.month)}'
        : '${formattedTime} - ${sent.day} ${MyDateFormatter._getMonth(sent.month)} ${sent.year}';
  }
}
