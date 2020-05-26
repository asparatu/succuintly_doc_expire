import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  }

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

  //Submit form
  void showMessage(String message, [MaterialColor color = Colors.red]) {
    _scaffoldKey.currentState.showSnackBar(
        new SnackBar(backgroundColor: color, content: new Text(message)));
  }

  void _submitForm() {
    final FormState form = _formKey.currentState;

    if (!form.validate()) {
      showMessage('Some data is invalid. Please correct.');
    } else {
      _saveDoc();
    }
  }

  @override
  void initState() {
    super.initState();
    _initCtrls();
  }

  @override
  Widget build(BuildContext context) {
    const String cStrDays = "Enter a number of days";
    TextStyle tStyle = Theme
        .of(context)
        .textTheme
        .headline6;
    String ttl = widget.doc.title;

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(ttl != "" ? widget.doc.title : "New Document"),
        actions: (ttl == "")
            ? <Widget>[]
            : <Widget>[
          PopupMenuButton(
            onSelected: _selectMenu,
            itemBuilder: (BuildContext context) {
              return _menuOptions.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(
                    choice,
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        autovalidate: true,
        child: SafeArea(
          top: false,
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: <Widget>[
              //Title Form Field
              TextFormField(
                inputFormatters: [
                  WhitelistingTextInputFormatter(RegExp('[a-zA-Z0-9]')),
                ],
                controller: _titleCtrl,
                style: tStyle,
                validator: (val) => Validation.validateTitle(val),
                decoration: InputDecoration(
                  icon: const Icon(Icons.title),
                  hintText: 'Enter the document name',
                  labelText: 'Document Name',
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _expirationCtrl,
                      maxLength: 10,
                      decoration: InputDecoration(
                          icon: const Icon(Icons.calendar_today),
                          hintText: 'Expiry date (i.e. ' +
                              DateUtils.daysAheadAsStr(_daysAhead) +
                              ')',
                          labelText: 'Expiry Date'),
                      keyboardType: TextInputType.number,
                      validator: (val) =>
                      DateUtils.isValidDate(val)
                          ? null
                          : 'Not a valid future date',
                    ),
                  ),
                  IconButton(
                      icon: new Icon(Icons.more_horiz),
                      tooltip: 'Choose date',
                      onPressed: (() {
                        _chooseDate(context, _expirationCtrl.text);
                      }))
                ],
              ),
              //Expiration Date
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(' '),
                  ),
                ],
              ),
              //One Year Switch Button
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text('a. Alert @ 1.5 & 1 year(s)'),
                  ),
                  Switch(
                      value: _fqYearCtrl,
                      onChanged: (bool value) {
                        setState(() {
                          _fqYearCtrl = value;
                        });
                      })
                ],
              ),
              //Half Year Switch Button
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text('b. Alert @ 6 Months'),
                  ),
                  Switch(
                      value: _fqHalfYearCtrl,
                      onChanged: (bool value) {
                        setState(() {
                          _fqHalfYearCtrl = value;
                        });
                      })
                ],
              ),
              // Quarter Year Switch Button
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text('a. Alert @ 3 Months'),
                  ),
                  Switch(
                      value: _fqQuarterCtrl,
                      onChanged: (bool value) {
                        setState(() {
                          _fqQuarterCtrl = value;
                        });
                      })
                ],
              ),
              //One month or less Switch Button
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text('a. Alert @ 1 month or less'),
                  ),
                  Switch(
                      value: _fqMonthCtrl,
                      onChanged: (bool value) {
                        setState(() {
                          _fqMonthCtrl = value;
                        });
                      })
                ],
              ),
              //Save Button
              Container(
                padding: const EdgeInsets.only(left: 40.0, top: 20.0),
                child: RaisedButton(
                  child: Text('Save'),
                  onPressed: _submitForm,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
