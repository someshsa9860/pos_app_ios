import 'package:flutter/material.dart';
import '../data_management/api.dart';
import '../data_management/pos_database.dart';
import '../data_management/sync.dart';

const payMetTable = 'pay_meth_table';

class PaymentMethodsProvider extends ChangeNotifier {
  var api = 'connector/api/payment-methods';

  Map<String, dynamic> get mapData {
    if (_mapData.isNotEmpty) {
      return _mapData.last;
    }
    return {};
  }

  logout() async{
    await database.logout(_mapData);
    notifyListeners();
  }

  final List<Map<String, dynamic>> _mapData = List.empty(growable: true);

  Future<String> getData() async {
    _syncStatus = SyncStatus.syncing;
    await getServerData(_mapData, api: api, database: database, dataKey: '',pm: true);
    _syncStatus = SyncStatus.synced;

    notifyListeners();
    return '';
  }

  //fixed
  var _syncStatus = SyncStatus.synced;

  get syncStatus => _syncStatus;

  UniqueDatabase get database => UniqueDatabase(tableName: payMetTable);
}
