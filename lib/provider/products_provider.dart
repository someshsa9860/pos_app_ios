import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../data_management/api.dart';
import '../data_management/pos_database.dart';
import '../data_management/sync.dart';

const productTable = 'product_table';

class ProductsProvider extends ChangeNotifier {
  var api = 'connector/api/product';

  final List<Map<String, dynamic>> _mapData = List.empty(growable: true);
  final Map<String, dynamic> _currentStock = {};

  setCurrentStock(String sku, value) {
    _currentStock[sku] = value??0.0;
  }

  logout() async{
    await database.logout(_mapData);
    notifyListeners();
  }

  String getCurrentStock(String sku) {
    return '${_currentStock[sku]}';
  }

  final Map<dynamic, dynamic> images = {};

  UniqueDatabase get imgDatabase => UniqueDatabase(tableName: imgTable);

  List<Map<String, dynamic>> get mapData => [..._mapData];

  Future<String> getData() async {
    _syncStatus = SyncStatus.syncing;
    await getServerData(_mapData, api: api, database: database,body: {'per_page':'-1'});
    _syncStatus = SyncStatus.synced;
    getImageData();
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
    return '';
  }

  addData(data, kw) async {
    await serverAdd(_mapData, data, api: api, database: database, kw: kw);
    return '';
  }

  updateData(data, kw) async {
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

  UniqueDatabase get database => UniqueDatabase(tableName: productTable);

  getImageData() async {
    for (var map in _mapData) {
      if (map['image_url'] != null) {
        getImgFromUrl(map['image_url']).then((value) {
          images[map['image_url']] = value;
          try {
            notifyListeners();
          } catch (e) {
            //
          }
        });
      }
    }
  }

  Future<String?>? getImagePath(url) async {
    var data = await imgDatabase.getDataAt(url);
    if (data.isEmpty) {
      return null;
    }

    var imgId = data.last['id'];

    return imgId;
  }

  Future<String?> getImgFromUrl(String url0) async {
    final url = url0;
    var path = await getImagePath(url);

    if (path == null) {
      try {
        final response = await http.get(Uri.parse(url));
        //if(directoryThumbnails==null){
        final root = await getApplicationDocumentsDirectory();
        directoryThumbnails = root.path + Platform.pathSeparator + 'thumbnails';
        //}
        final path = directoryThumbnails! +
            Platform.pathSeparator +
            'img_' +
            getRandomId().toString() +
            '.jpg';
        await Directory(directoryThumbnails!).create(recursive: true);
        File file = File(path);
        await file.writeAsBytes(response.bodyBytes);

        file.writeAsBytesSync(response.bodyBytes);

        await imgDatabase.addData({'id': file.path, keyWhere: url});

        print('G success:' + file.path);
        return file.path;
      } catch (e) {
        print(e);
        return null;
      }
    }
    return path;
  }

  Future<void> refreshImage(imgUrl) async {
    await imgDatabase.delData(imgUrl);
    final path = await getImgFromUrl(imgUrl);
    images[imgUrl] = path;
    notifyListeners();
  }
}
