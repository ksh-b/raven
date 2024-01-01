import 'package:intl/intl.dart';

MapEntry<int, String> parseDateString(String timestamp) {
  try {
    DateTime dateTime = DateTime.parse(timestamp);
    DateTime now = DateTime.now();
    int differenceInSeconds = now.difference(dateTime).inSeconds;
    const int minute = 60;
    const int hour = 60 * minute;
    const int day = 24 * hour;
    const int month = 30 * day;

    if (differenceInSeconds < 1) {
      return MapEntry(differenceInSeconds, 'just now');
    } else if (differenceInSeconds < minute) {
      return MapEntry(differenceInSeconds, '$differenceInSeconds seconds ago');
    } else if (differenceInSeconds < hour) {
      int minutes = (differenceInSeconds / minute).floor();
      return MapEntry(differenceInSeconds,
          '$minutes ${(minutes == 1) ? 'minute' : 'minutes'} ago');
    } else if (differenceInSeconds < day) {
      int hours = (differenceInSeconds / hour).floor();
      return MapEntry(
          differenceInSeconds, '$hours ${(hours == 1) ? 'hour' : 'hours'} ago');
    } else if (differenceInSeconds < month) {
      int days = (differenceInSeconds / day).floor();
      if (days == 1) {
        return MapEntry(differenceInSeconds, 'yesterday');
      } else {
        return MapEntry(differenceInSeconds, '$days days ago');
      }
    } else {
      int months = (differenceInSeconds / month).floor();
      return MapEntry(differenceInSeconds,
          '$months ${(months == 1) ? 'month' : 'months'} ago');
    }
  } catch (e) {
    return MapEntry(
        0, timestamp); // Return 0 differenceInSeconds in case of an error.
  }
}

String convertToIso8601(String inputTime, String inputFormatString) {
  try {
    DateFormat inputFormat = DateFormat(inputFormatString);
    DateTime parsedTime = inputFormat.parse(inputTime);
    return parsedTime.toString();
  } catch (e) {
    return inputTime;
  }
}
