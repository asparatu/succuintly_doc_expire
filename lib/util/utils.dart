import 'dart:html';

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
}
