import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

import '../model/doc.dart';
import '../util/dbhelper.dart';
import '../util/utils.dart';

//Menu items
const _menuDelete = "Delete";
final List<String> _menuOptions = const <String>[_menuDelete];

class DocDetail extends StatefulWidget {
  Doc doc;
  final DbHelper dbh = DbHelper();

  DocDetail(this.doc);

  @override
  _DocDetailState createState() => _DocDetailState();
}

class _DocDetailState extends State<DocDetail> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final int _daysAhead = 5475; //15 years in the future.

  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _expirationCtrl =
      MaskedTextController(mask: '2000-00-00');

  bool _fqYearCtrl = true;
  bool _fqHalfYearCtrl = true;
  bool _fqQuarterCtrl = true;
  bool _fqMonthCtrl = true;
  bool _fqLessMonthCtrl = true;

  //initialization code
  void _initCtrls() {
    _titleCtrl.text = widget.doc.title != null ? widget.doc.title : "";
    _expirationCtrl.text =
        widget.doc.expiration != null ? widget.doc.expiration : "";

    _fqYearCtrl = widget.doc.fqYear != null
        ? Validation.intToBool(widget.doc.fqYear)
        : false;
    _fqHalfYearCtrl = widget.doc.fqHalfYear != null
        ? Validation.intToBool(widget.doc.fqHalfYear)
        : false;
    _fqQuarterCtrl = widget.doc.fqQuarter != null
        ? Validation.intToBool(widget.doc.fqQuarter)
        : false;
    _fqMonthCtrl = widget.doc.fqMonth != null
        ? Validation.intToBool(widget.doc.fqMonth)
        : false;

    //Date Picker & Date function
    Future _chooseDate(BuildContext context, String initialDateString) async {
      DateTime now = new DateTime.now();
      DateTime initialDate = DateUtils.convertToDate(initialDateString) ?? now;

      initialDate = (initialDate.year >= now.year && initialDate.isAfter(now)
          ? initialDate
          : now);

      DatePicker.showDatePicker(context,
          showTitleActions: true, currentTime: initialDate, onConfirm: (date) {
        setState(() {
          DateTime dt = date;
          String r = DateUtils.ftDateAsStr(dt);
          _expirationCtrl.text = r;
        });
      });
    }

    //Delete Doc
    void _deleteDoc(int id) async {
      await widget.dbh.deleteDoc(widget.doc.id);
      Navigator.pop(context, true);
    }

    //Upper Menu
    void _selectMenu(String value) async {
      switch (value) {
        case _menuDelete:
          if (widget.doc.id == -1) {
            return;
          }
          await _deleteDoc(widget.doc.id);
      }
    }

    //Save Doc
    void _saveDoc() {
      widget.doc.title = _titleCtrl.text;
      widget.doc.expiration = _expirationCtrl.text;

      widget.doc.fqYear = Validation.boolToInt(_fqYearCtrl);
      widget.doc.fqHalfYear = Validation.boolToInt(_fqHalfYearCtrl);
      widget.doc.fqYear = Validation.boolToInt(_fqYearCtrl);
      widget.doc.fqMonth = Validation.boolToInt(_fqMonthCtrl);

      if (widget.doc.id > -1) {
        debugPrint("_update->Doc Id: " + widget.doc.id.toString());
        widget.dbh.updateDoc(widget.doc);
        Navigator.pop(context, true);
      } else {
        Future<int> idd = widget.dbh.getMaxId();
        idd.then((result) {
          debugPrint("_insert->Doc Id: " + widget.doc.id.toString());
          widget.doc.id = (result != null) ? result + 1 : 1;
          widget.dbh.insertDoc(widget.doc);
          Navigator.pop(context, true);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
