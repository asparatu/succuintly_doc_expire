import 'package:intl/intl.dart';

class Validation {
  //Validation
  static String validateTitle(String text) {
    return (text != null && text != '') ? null : 'Title cannot be empty';
  }

  static String getExpiryStr(String expires) {
    DateTime e = DateUtils.convertToDate(expires);
    DateTime td = new DateTime.now();

    Duration dif = e.difference(td);
    int dd = dif.inDays + 1;
    return (dd > 0) ? dd.toString() : '0';
  }

  static bool strToBool(String str) {
    return (int.parse(str) > 0) ? true : false;
  }

  static bool intToBool(int val) {
    return (val > 0) ? true : false;
  }

  static String boolToStr(bool val) {
    return (val == true) ? '1' : '0';
  }

  static int boolToInt(bool val) {
    return (val == true) ? 1 : 0;
  }
}

class DateUtils {
  static DateTime convertToDate(String input) {
    try {
      DateTime d = new DateFormat('yyyy-MM-dd').parseStrict(input);
      return d;
    } catch (e) {
      return null;
    }
  }

  static String convertToDateShort(String input) {
    try {
      DateTime d = new DateFormat('yyyy-MM-dd').parseStrict(input);
      DateFormat formatter = new DateFormat('dd MMM yyyy');
      return formatter.format(d);
    } catch (e) {
      return null;
    }
  }

  static String convertToDateShortFromDateTime(DateTime dt) {
    try {
      DateFormat formatter = new DateFormat('dd MMM yyyy');
      return formatter.format(dt);
    } catch (e) {
      return null;
    }
  }

  static bool isDate(String dt) {
    try {
      DateFormat('yyyy-MM-dd').parseStrict(dt);
      return true;
    } catch (e) {
      return false;
    }
  }

  static bool isValidDate(String dt) {
    if (dt.isEmpty || !dt.contains('-') || dt.length < 10) return false;

    List<String> dtItems = dt.split('-');
    DateTime d = DateTime(
        int.parse(dtItems[0]), int.parse(dtItems[1]), int.parse(dtItems[2]));

    return d != null && isDate(dt) && d.isAfter(new DateTime.now());
  }

  //String Functions
  static String daysAheadAsStr(int daysAhead) {
    DateTime now = new DateTime.now();

    DateTime ft = now.add(new Duration(days: daysAhead));
    return ftDateAsStr(ft);
  }

  static String ftDateAsStr(DateTime ft) {
    return ft.year.toString() +
        '-' +
        ft.month.toString().padLeft(2, '0') +
        '-' +
        ft.day.toString().padLeft(2, '0');
  }

  static String trimDate(String dt) {
    if (dt.contains(' ')) {
      List<String> p = dt.split(' ');
      return p[0];
    } else {
      return dt;
    }
  }
}
