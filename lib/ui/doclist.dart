import 'dart:async';

import 'package:flutter/material.dart';

import './docdetail.dart';
import '../model/doc.dart';
import '../util/dbhelper.dart';
import '../util/utils.dart';

//Menu item
const menuReset = "Reset Local Data";
List<String> menuOptions = const <String>[menuReset];

class DocList extends StatefulWidget {
  @override
  _DocListState createState() => _DocListState();
}

class _DocListState extends State<DocList> {
  DbHelper _dbHelper = DbHelper();
  List<Doc> _docs;
  int _count = 0;
  DateTime _currentDate;

  @override
  void initState() {
    super.initState();
  }

  Future getData() async {
    final dbFuture = _dbHelper.initializeDb();
    dbFuture.then(
        //result here is the actual reference to the database object
        (result) {
      final docsFuture = _dbHelper.getDocs();
      docsFuture.then(
          //result here is the list of docs in the database
          (result) {
        if (result.length >= 0) {
          List<Doc> docList = List<Doc>();
          int count = result.length;
          for (int i = 0; i <= count - 1; i++) {
            docList.add(Doc.fromObject(result[i]));
          }
          setState(() {
            if (this._docs.length > 0) {
              this._docs.clear();
            }

            this._docs = docList;
            this._count = count;
          });
        }
      });
    });
  }

  void _checkDate() {
    const secs = const Duration(seconds: 10);

    new Timer.periodic(secs, (Timer t) {
      DateTime nw = DateTime.now();

      if (_currentDate.day != nw.day ||
          _currentDate.month != nw.month ||
          _currentDate.year != nw.year) {
        getData();
        _currentDate = DateTime.now();
      }
    });
  }

  void navigateToDetail(Doc doc) async {
    bool r = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => DocDetail(doc)));
    if (r == true) {
      getData();
    }
  }

  void _showResetDialog() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text("Reset"),
            content: new Text("Do you want to delete all local data?"),
            actions: <Widget>[
              //Cancel Button
              FlatButton(
                  child: new Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              //Ok Button
              FlatButton(
                  child: new Text("Ok"),
                  onPressed: () {
                    Future f = _resetLocalData();
                    f.then((result) {
                      Navigator.of(context).pop();
                    });
                  }),
            ],
          );
        });
  }

  Future _resetLocalData() async {
    final dbFuture = _dbHelper.initializeDb();
    dbFuture.then((result) {
      final dDocs = _dbHelper.deleteRows(DbHelper.tblDocs);
      dDocs.then((result) {
        setState(() {
          this._docs.clear();
          this._count = 0;
        });
      });
    });
  }

  void _selectMenu(String value) async {
    switch (value) {
      case menuReset:
        _showResetDialog();
    }
  }

  ListView docListItems() {
    return ListView.builder(
        itemCount: _count,
        itemBuilder: (BuildContext context, int position) {
          String dd = Validation.getExpiryStr(this._docs[position].expiration);
          String dl = (dd != "1") ? " days left" : " day left";
          return Card(
            color: Colors.white,
            elevation: 1.0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    (Validation.getExpiryStr(this._docs[position].expiration) !=
                            "0")
                        ? Colors.blue
                        : Colors.red,
                child: Text(this._docs[position].id.toString()),
              ),
              title: Text(this._docs[position].title),
              subtitle: Text(
                  Validation.getExpiryStr(this._docs[position].expiration) +
                      dl +
                      "\nExp: " +
                      DateUtils.convertToDateShort(
                          this._docs[position].expiration)),
              onTap: () {
                navigateToDetail(this._docs[position]);
              },
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    this._currentDate = DateTime.now();

    if (this._docs == null) {
      this._docs = List<Doc>();
      getData();
    }

    _checkDate();

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text("DocExpore"),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: _selectMenu,
            itemBuilder: (BuildContext context) {
              return menuOptions.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          )
        ],
      ),
      body: Center(
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              docListItems(),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              navigateToDetail(Doc.withId(-1, "", "", 1, 1, 1, 1));
            },
            tooltip: "Add new Doc",
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
