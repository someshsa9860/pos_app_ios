import 'dart:convert';

import 'package:flutter/material.dart';

import '../data_management/api.dart';
import '../data_management/pos_database.dart';
import '../data_management/sync.dart';

const sellTable = 'sell_table';

class SellProvider extends ChangeNotifier {
  var api = 'connector/api/sell';

  sync() async {
    final maps = await database.getData();
    for (Map<String, dynamic> map0 in maps) {
      final map = jsonDecode(map0['data']);
      if (map0[keyWhere] != null) {
        if (isNewPending(map0[syncKey])) {
          _syncStatus = SyncStatus.syncing;
          addData(map, map0[keyWhere]);
        }
        if (isUpdatePending(map0[syncKey])) {
          _syncStatus = SyncStatus.syncing;
          updateData(map, map0[keyWhere]);
        }
      }
    }
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
    print('testing');
    print(data[keyWhere]);
    _syncStatus = SyncStatus.syncing;
    notifyListeners();

    data[syncKey] =
        SyncStatus.pendingNew.toString().split('.').last.toLowerCase();

    _mapData.add(mainData);
    await database.addData(data);
    await addData(mainData, kw);
    _syncStatus = SyncStatus.synced;
    notifyListeners();
    return '';
  }


  addData(data, kw) async {
    var d = {
      'sells': [data]
    };

    await serverAdd(_mapData, d,
        api: api, database: database, isSell: true, kw: kw);
  }

  updateData(data, kw) async {
    //var d = {'sells': [data]};
    await serverUpdate(_mapData, data, '',
        api: 'connector/api/update-shipping-status',
        database: database,
        kw: kw);
  }

  logout() async{
    await database.logout(_mapData);
    notifyListeners();
  }

  final List<Map<String, dynamic>> _mapData = List.empty(growable: true);

  List<Map<String, dynamic>> get mapData {
    return [..._mapData].reversed.toList();
  }
  Future<String> getData() async {
    _syncStatus = SyncStatus.syncing;
    await getServerData(_mapData, api: api, database: database);
    _syncStatus = SyncStatus.synced;

    notifyListeners();
    return '';
  }

  update(Map<dynamic, dynamic> mainData) async {
    //only for shipping status
    _syncStatus = SyncStatus.syncing;
    await updateData(mainData, getRandomId());
    _syncStatus = SyncStatus.synced;
    notifyListeners();
  }

  //fixed
  var _syncStatus = SyncStatus.synced;

  get syncStatus => _syncStatus;

  UniqueDatabase get database => UniqueDatabase(tableName: sellTable);
}
