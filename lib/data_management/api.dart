import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data_management/pos_database.dart';
import '../data_management/sync.dart';
import '../data_management/user.dart';

const imgTable = 'tbl_img_path';

User user = User();

class CallApi {
  final String url = 'https://pospoa.com/pos/';

  Future<http.Response> postData(data, apiUrl) async {
    if (user.token == null) {
      await getUser();
    }


    var fulUrl = url + apiUrl;

    return http.post(Uri.parse(fulUrl),
        body: jsonEncode(data), headers: _setHeader());
  }

  Future<http.Response> updateData(Map<dynamic, dynamic> data, apiUrl) async {
    if (user.token == null) {
      await getUser();
    }
    data.removeWhere((key, value) => value == null);
    var fulUrl = url + apiUrl;
    return http.patch(Uri.parse(fulUrl),
        body: jsonEncode(data), headers: _setHeader());
  }

  Future<http.Response> putData(data, apiUrl) async {
    if (user.token == null) {
      await getUser();
    }
    var fulUrl = url + apiUrl;
    return http.put(Uri.parse(fulUrl),
        body: jsonEncode(data), headers: _setHeader());
  }

  Future<http.Response> getData(apiUrl, {body}) async {
    var fulUrl = url + apiUrl;
    if (user.token == null) {
      await getUser();
    }
    if (body != null) {
      final uri = Uri.http('pospoa.com', 'pos/' + apiUrl, body);
      return http.get(uri, headers: _setHeader());
    }
    return http.get(Uri.parse(fulUrl), headers: _setHeader());
  }

  _setHeader() {
    return {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${user.token}'
    };
  }


  bool sessionExpired = false;
}
Future<User?> getUser() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  var v = preferences.getString('user');
  if (v == null||v.isEmpty) {
    return null;
  }

  var userData = jsonDecode(v);
  user.username = userData['username'];
  user.password = userData['password'];
  user.token = userData['token'];
  user.id = userData['id'];
  user.expiresIn = userData['expiresIn'];

  if (user.expiresIn != null) {
    if (DateTime.parse(user.expiresIn!).isBefore(DateTime.now())) {
      //_token = user.token;
      return null;
    }
  }
  return user;
}

String? directoryThumbnails;

Future<File> getFile() async {
  //if(directoryThumbnails==null){
  final root = await getApplicationDocumentsDirectory();
  directoryThumbnails = root.path +
      Platform.pathSeparator +
      'thumbnails' +
      Platform.pathSeparator;
  //}
  final path =
      directoryThumbnails! + 'img_' + getRandomId().toString() + '.jpg';
  await Directory(path).create(recursive: true);
  File file = File(path);
  return file;
}

Future<String> getServerData(List<Map<String, dynamic>> mapList,
    {required UniqueDatabase database,
    required api,
    var body,
    bool pos = false,
    String dataKey = 'data',
    bool pm = false,
    bool stock = false}) async {
  final map = await database.getData();

  if (dataKey.isEmpty) {
    mapList.clear();
  }

  for (var element in map) {
    final nm = jsonDecode(element['data']) as Map<String, dynamic>;
    if (stock) {
      if (mapList.indexWhere((element) => element['sku'] == nm['sku']) < 0) {
        mapList.add(nm);
      }
    } else if (dataKey.isEmpty) {
      mapList.add(nm);
    } else if (pos) {
      if (mapList.indexWhere((element) => element[keyWhere] == nm[keyWhere]) <
          0) {
        mapList.add(nm);
      }
    } else {
      if (mapList.indexWhere((element) => element['id'] == nm['id']) < 0) {
        mapList.add(nm);
      }
    }
  }

  if (pos) {
    return '';
  }

  try {
    final response = await CallApi().getData(api, body: body);

    print(response.body.toString());

    if (response.statusCode <= 250) {
      final result = json.decode(response.body);
      if (result == null) {
        return '';
      }
      if (dataKey.isEmpty) {
        final Map<String, dynamic> map0;
        if (pm) {
          map0 = result as Map<String, dynamic>;
        } else {
          map0 = result['data'] as Map<String, dynamic>;
        }

        if (map0.isEmpty) {
          return '';
        }

        Map<String, dynamic> mapData = map0;

        var data = {
          'id': mapData['id'].toString(),
          'data': jsonEncode(mapData)
        };

        data[syncKey] =
            SyncStatus.synced.toString().split('.').last.toLowerCase();

        int index = indexOf(mapList, mapData);

        if (index == -1) {
          if (!mapList.contains(mapData)) {
            mapList.add(mapData);
            database.addData(data);
          }
        } else if (index >= 0) {
          mapList[index] = mapData;
          database.updateGetData(data);
        } else {
          database.updateReport(data);
        }
      } else if (stock) {
        final mpProducts = result["data"] as List<dynamic>;
        if (mpProducts.isEmpty) {
          return '';
        }

        for (var map0 in mpProducts) {
          Map<String, dynamic> mapData = map0 as Map<String, dynamic>;

          var data = {
            'id': mapData['sku'].toString()+mapData['location_id'].toString(),
            'data': jsonEncode(mapData)
          };

          data[syncKey] =
              SyncStatus.synced.toString().split('.').last.toLowerCase();

          int index =
              mapList.indexWhere((element) => element['sku'].toString() == mapData['sku'].toString()&&element['location_id'].toString() == mapData['location_id'].toString());

          if (index == -1) {
            mapList.add(mapData);

            database.addData(data);
          } else if (index >= 0) {
            mapList[index] = mapData;

            database.updateGetData(data);
          }
        }

        if(result['links']!=null){
          if(result['links']['next']!=null){
            print('page:');
            print(result['links']['next'].toString().split('=').last);
            await getServerData(mapList, api: api, database: database, stock: true,body: {'page':(result['links']['next']).toString().split('=').last});
          }
        }


      } else {
        final mpProducts = result["data"] as List<dynamic>;
        if (mpProducts.isEmpty) {
          return '';
        }

        for (var map0 in mpProducts) {
          Map<String, dynamic> mapData = map0 as Map<String, dynamic>;

          var data = {
            'id': mapData['id'].toString(),
            'data': jsonEncode(mapData)
          };

          data[syncKey] =
              SyncStatus.synced.toString().split('.').last.toLowerCase();

          int index = indexOf(mapList, mapData);

          if (index == -1) {
            mapList.add(mapData);

            database.addData(data);
          } else if (index >= 0) {
            mapList[index] = mapData;

            database.updateGetData(data);
          }
        }
      }
    }
  }
  catch (e) {
    //
    print(e);
  }

  return '';
}

Future<String> getUpdatedServerData(List<Map<String, dynamic>> mapList,
    {required UniqueDatabase database,
    required api,
    required id,
    required index}) async {
  try {
    final response = await CallApi().getData('$api/$id');

    if (response.statusCode <= 250) {
      final result = json.decode(response.body);
      if (result == null) {
        return '';
      }
      {
        final mpProducts = result["data"] as List<dynamic>;
        if (mpProducts.isEmpty) {
          return '';
        }

        for (var map0 in mpProducts) {
          Map<String, dynamic> mapData = map0 as Map<String, dynamic>;

          var data = {
            'id': mapData['id'].toString(),
            'data': jsonEncode(mapData)
          };

          data[syncKey] =
              SyncStatus.synced.toString().split('.').last.toLowerCase();
          if (index >= 0) {
            mapList[index] = mapData;
          }
          database.updateGetData(data);
        }
      }
    }
  } catch (e) {
    //
  }

  return '';
}

int indexOf(List<Map<String, dynamic>> mapList, Map<String, dynamic> data) {
  for (Map<String, dynamic> map in mapList) {
    if (map['id'].toString() == data['id'].toString()) {
      if (map['updated_at'].toString() != data['updated_at'].toString()) {
        return mapList.indexOf(map);
      } else if (map['updated_at'] == null &&
          data['updated_at'] == null &&
          map['id'] == null &&
          data['id'] == null) {
        return -2;
      } else {
        return -400;
      }
    }
  }
  return -1;
}

Future<void> serverAdd(
    List<Map<String, dynamic>> mapList, Map<dynamic, dynamic> data,
    {required UniqueDatabase database,
    required api,
    isSell = false,
    required kw}) async {
  try {
    final value = await CallApi().postData(data, api);

    if (value.statusCode <= 250) {
      final body = json.decode(value.body);

      final map0 = isSell
          ? body[0] as Map<String, dynamic>
          : body['data'] as Map<String, dynamic>;

      var map = Map.of(map0);

      map.removeWhere((key, value) => (value == null));
      var ndata = {
        'id': map['id'],
        keyWhere: data[keyWhere],
        'data': jsonEncode(map)
      };

      await database.updateSyncData(ndata, '$kw');

      int index;
      if(isSell){
        index = mapList.indexOf(data['sells'][0] as Map<String, dynamic>);

      }else{
        index = mapList.indexOf(data as Map<String, dynamic>);

      }
      if (index >= 0) {
        mapList[index] = map;
      }
      getUpdatedServerData(mapList,
          database: database, api: api, id: map['id'], index: index);
    }
  } catch (e) {
    //
  }
}

Future<void> serverUpdate(
    List<Map<String, dynamic>> mapList, Map<dynamic, dynamic> data, String id,
    {required UniqueDatabase database,
    required String api,
    required kw}) async {
  try {
    http.Response value; //= await CallApi()

    if (id.isEmpty) {
      value = await CallApi().postData(data, api).catchError((error) {});
    } else {
      int index =
          mapList.indexWhere((element) => element[keyWhere] == data[keyWhere]);

      mapList[index] = data as Map<String, dynamic>;

      data.remove(syncKey);
      value = await CallApi()
          .updateData(data, api + "/" + id.toString())
          .catchError((error) {});
      if (value.statusCode <= 250) {
        final body = json.decode(value.body);

        final map0 = body['data'] as Map<String, dynamic>;
        var map = Map.of(map0);

        var ndata = {
          'id': map['id'],
          keyWhere: data[keyWhere],
          'data': jsonEncode(map)
        };
        database.updateSyncData(ndata, '$kw');

        int index =
            mapList.indexWhere((element) => element[keyWhere] == data[keyWhere]);

        mapList[index] = map;
        getUpdatedServerData(mapList,
            database: database, api: api, id: map['id'], index: index);
      }
    }
  } catch (e) {
    //
  }
}
