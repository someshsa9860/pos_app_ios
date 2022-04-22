import 'dart:convert';

import 'package:flutter/material.dart';
import '../data_management/api.dart';
import '../data_management/pos_database.dart';
import '../data_management/sync.dart';

const posTable = 'pos_table';

class PosProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _mapData = List.empty(growable: true);

  List<Map<String, dynamic>> get mapData {
    return [..._mapData].reversed.toList();
  }

  getData() async {
    _syncStatus = SyncStatus.syncing;
    await getServerData(_mapData, api: '', database: database, pos: true);
    _syncStatus = SyncStatus.synced;

    notifyListeners();
  }

  sync() async {}

  addData(data, kw) async {
    return '';
  }

  updateData(data, kw) async {
    return '';
  }

  Future<String> addDataData(Map<String, dynamic> mainData) async {
    if (mainData[keyWhere] == null) {
      mainData[keyWhere] = await getInvoiceNum();
    }
    final kw = mainData[keyWhere];
    var data = {
      'id': mainData['id'],
      keyWhere: mainData[keyWhere],
      'data': jsonEncode(mainData)
    };
    _syncStatus = SyncStatus.syncing;
    notifyListeners();

    data[syncKey] =
        SyncStatus.pendingNew.toString().split('.').last.toLowerCase();

    _mapData.add(mainData);
    database.addData(data);
    await addData(mainData, kw);
    _syncStatus = SyncStatus.synced;
    notifyListeners();
    return '';
  }

  logout() async{
    await database.logout(_mapData);
    notifyListeners();
  }

  update(Map<String, dynamic> mainData) async {
    _syncStatus = SyncStatus.syncing;
    if (mainData[keyWhere] == null) {
      mainData[keyWhere] = await getInvoiceNum();
    }
    final kw = mainData[keyWhere];
    var data = {
      'id': mainData['id'],
      keyWhere: mainData[keyWhere],
      'data': jsonEncode(mainData)
    };

    data[syncKey] =
        SyncStatus.pendingUpdate.toString().split('.').last.toLowerCase();

    if (data['id'] == null) {
      data[syncKey] =
          SyncStatus.pendingNew.toString().split('.').last.toLowerCase();

      _mapData[_mapData.indexWhere(
          (element) => element[keyWhere] == data[keyWhere])] = (data);

      database.updateData(data, kw);
    } else {
      _mapData[_mapData.indexWhere((element) => element['id'] == data['id'])] =
          (data);
      database.updateData(data, kw);
      await updateData(mainData, kw);
    }
    _syncStatus = SyncStatus.synced;

    notifyListeners();
    return '';
  }

  //fixed
  var _syncStatus = SyncStatus.synced;

  get syncStatus => _syncStatus;

  UniqueDatabase get database => UniqueDatabase(tableName: posTable);
}
