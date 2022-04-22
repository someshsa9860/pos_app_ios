import 'dart:convert';

import 'package:flutter/material.dart';

import '../data_management/api.dart';
import '../data_management/pos_database.dart';
import '../data_management/sync.dart';

const productUnitsTable = 'product_units_table';

class ProductsUnitsProvider extends ChangeNotifier {
  var api = 'connector/api/unit';

  final List<Map<String, dynamic>> _mapData = List.empty(growable: true);

  List<Map<String, dynamic>> get mapData => [..._mapData];

  logout() async{
    await database.logout(_mapData);
    notifyListeners();
  }

  Future<String> getData() async {
    _syncStatus = SyncStatus.syncing;
    await getServerData(_mapData, api: api, database: database);
    _syncStatus = SyncStatus.synced;

    notifyListeners();
    return '';
  }

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

  addData(data, String kw) async {
    await serverAdd(_mapData, data, api: api, database: database, kw: kw);
    return '';
  }

  updateData(data, String kw) async {
    await serverUpdate(_mapData, data, data['id'],
        api: api, database: database, kw: kw);
    return '';
  }

  addDataData(Map<String, dynamic> mainData) async {
    if (mainData[keyWhere] == null) {
      mainData[keyWhere] = getRandomId();
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

  update(Map<String, dynamic> mainData) async {
    _syncStatus = SyncStatus.syncing;
    if (mainData[keyWhere] == null) {
      mainData[keyWhere] = getRandomId();
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

  UniqueDatabase get database => UniqueDatabase(tableName: productUnitsTable);
}
