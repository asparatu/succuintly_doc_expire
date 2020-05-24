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
