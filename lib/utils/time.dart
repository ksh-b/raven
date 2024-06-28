import 'package:intl/intl.dart';

int stringToUnix(String timestamp, {String? format}) {
  try {
    if (format != null) {
      DateFormat inputFormat = DateFormat(format);
      DateTime parsedTime = inputFormat
          .parse(timestamp.replaceFirst("pm", "PM").replaceFirst("am", "AM"));
      return parsedTime.millisecondsSinceEpoch;
    }
    return isoToUnix(timestamp);
  } catch (e) {
    return -1;
  }
}

String unixToString(int then) {
  const int minute = 60;
  const int hour = 60 * minute;
  const int day = 24 * hour;
  const int month = 30 * day;
  var now = DateTime.now().millisecondsSinceEpoch;
  var timePassed = (now - then)~/1000;

  if (then == -1) {
    return '';
  } else if (timePassed < 1) {
    return 'just now';
  } else if (timePassed < minute) {
    return '$timePassed seconds ago';
  } else if (timePassed < hour) {
    int minutes = (timePassed / minute).floor();
    return '$minutes ${(minutes == 1) ? 'minute' : 'minutes'} ago';
  } else if (timePassed < day) {
    int hours = (timePassed / hour).floor();
    return '$hours ${(hours == 1) ? 'hour' : 'hours'} ago';
  } else if (timePassed < month) {
    int days = (timePassed / day).floor();
    if (days == 1) {
      return 'yesterday';
    } else {
      return '$days days ago';
    }
  } else {
    int months = (timePassed / month).floor();
    return '$months ${(months == 1) ? 'month' : 'months'} ago';
  }
}

int isoToUnix(String timestamp) {
  return DateTime.parse(timestamp).millisecondsSinceEpoch;
}

int relativeStringToUnix(String timeString) {
  try {
    if (timeString.contains("ago")) {
      if (timeString.startsWith("a ")) {
        timeString = timeString.replaceFirst("a ", "1 ");
      }
    }
    List<String> words = timeString.split(' ');
    int value = int.parse(words[0]);
    String unit = words[1].toLowerCase();
    int seconds;
    switch (unit) {
      case 'sec':
      case 'second':
      case 'seconds':
        seconds = value;
        break;
      case 'min':
      case 'minute':
      case 'minutes':
        seconds = value * 60;
        break;
      case 'hour':
      case 'hours':
        seconds = value * 3600;
        break;

      default:
        seconds = 0;
    }
    return DateTime.now().subtract(Duration(seconds: seconds)).millisecondsSinceEpoch;
  } catch (e) {
    return -1;
  }
}
