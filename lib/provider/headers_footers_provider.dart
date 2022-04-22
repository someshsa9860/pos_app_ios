import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../data_management/pos_database.dart';
import '../data_management/pos_web_links.dart';
import '../screens/sell/headers_footers.dart';

class HeadersFootersProvider extends ChangeNotifier {
  final List<String> _headers = [
    'RENOTECH SYSTEMS LTD',
    'P.O BOX 34899-00200',
    'NAIROBI',
    'NJENGI HSE,TOM MBOYA',
    'TEL: 0722 456786',
    'TILL NO-782992'
  ];

  final List<String> _footers = [
    'ALL POS SOLUTION PROVIDER ',
    'WELCOME AGAIN',
    '',
    ''
  ];

  String _headerUpdate = 'Default';
  String _footerUpdate = 'Default';
  int _footerSRN = -1;
  int _headerSRN = -1;

  int get headerSRN => _headerSRN;

  int get footerSRN => _footerSRN;

  List<String> get headers => _headers;
  final UniqueDatabase _database = UniqueDatabase(tableName: settingsTable);

  logout() async{
    await database.logout(_footers);
    await database.logout(_headers);
    notifyListeners();
  }

  Future<String> getData() async {
    final list = await _database.getData();

    if (list.isNotEmpty) {
      final listH = list.where((element) => element[keyWhere] == typeHeader);
      final listF = list.where((element) => element[keyWhere] == typeFooter);

      if (listH.isNotEmpty) {
        final map = listH.last;
        _headerSRN = map['srn'];
        _headerUpdate = map['id'];
        _headers.clear();
        for (var text in jsonDecode(map['data'])) {
          _headers.add(text.toString());
        }
      }

      if (listF.isNotEmpty) {
        final map = listF.last;
        _footerSRN = map['srn'];
        _footerUpdate = map['id'];
        _footers.clear();
        for (var text in jsonDecode(map['data'])) {
          _footers.add(text.toString());
        }
      }
    }
    notifyListeners();
    return '';
  }

  Future<String> addHeaders(String text) async {
    _headers.add(text);
    final data = {
      'id': DateFormat('yyyy-MM-dd hh:mm a').format(DateTime.now()),
      'data': jsonEncode(_headers),
      keyWhere: typeHeader
    };
    await database.delData(typeHeader);
    await database.addData(data);
    notifyListeners();
    return '';
  }

  Future<String> rearrangeHeaders(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final String item = _headers.removeAt(oldIndex);
    _headers.insert(newIndex, item);
    print('_headers.length');
    print(_headers.length);

    final data = {
      'id': DateFormat('yyyy-MM-dd hh:mm a').format(DateTime.now()),
      'data': jsonEncode(_headers),
      keyWhere: typeHeader
    };
    await database.delData(typeHeader);
    await database.addData(data);

    notifyListeners();
    return '';
  }

  Future<String> rearrangeFooters(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final String item = _footers.removeAt(oldIndex);
    _footers.insert(newIndex, item);

    final data = {
      'id': DateFormat('yyyy-MM-dd hh:mm a').format(DateTime.now()),
      'data': jsonEncode(_footers),
      keyWhere: typeFooter
    };
    await database.delData(typeFooter);
    await database.addData(data);
    notifyListeners();
    return '';
  }

  Future<String> updateHeaders(String text, int index) async {
    _headers[index] = (text);
    final data = {
      'id': DateFormat('yyyy-MM-dd hh:mm a').format(DateTime.now()),
      'data': jsonEncode(_headers),
      keyWhere: typeHeader
    };

    await database.delData(typeHeader);
    await database.addData(data);
    notifyListeners();
    return '';
  }

  Future<String> removeHeaders(int index) async {
    _headers.removeAt(index);
    final data = {
      'id': DateFormat('yyyy-MM-dd hh:mm a').format(DateTime.now()),
      'data': jsonEncode(_headers),
      keyWhere: typeHeader
    };

    await database.delData(typeHeader);
    await database.addData(data);
    notifyListeners();
    return '';
  }

  Future<String> addFooters(String text) async {
    _footers.add(text);
    final data = {
      'id': DateFormat('yyyy-MM-dd hh:mm a').format(DateTime.now()),
      'data': jsonEncode(_footers),
      keyWhere: typeFooter
    };
    await database.delData(typeFooter);
    await database.addData(data);
    notifyListeners();
    return '';
  }

  Future<String> updateFooters(String text, int index) async {
    _footers[index] = text;
    final data = {
      'id': DateFormat('yyyy-MM-dd hh:mm a').format(DateTime.now()),
      'data': jsonEncode(_footers),
      keyWhere: typeFooter
    };
    await database.delData(typeFooter);
    await database.addData(data);
    notifyListeners();
    return '';
  }

  Future<String> removeFooters(int index) async {
    _footers.removeAt(index);
    final data = {
      'id': DateFormat('yyyy-MM-dd hh:mm a').format(DateTime.now()),
      'data': jsonEncode(_footers),
      keyWhere: typeFooter
    };
    await database.delData(typeFooter);
    await database.addData(data);
    notifyListeners();
    return '';
  }

  List<String> get footers => _footers;

  String get headerUpdate => _headerUpdate;

  String get footerUpdate => _footerUpdate;

  UniqueDatabase get database => _database;
}
