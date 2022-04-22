import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../data_management/api.dart';
import '../data_management/pos_web_links.dart';
import '../data_management/sync.dart';
import '../provider/customer_provider.dart';
import '../provider/expense_provider.dart';
import '../provider/location_provider.dart';
import '../provider/paccounts_provider.dart';
import '../provider/pmethods_provider.dart';
import '../provider/pos_provider.dart';
import '../provider/products_brands_provider.dart';
import '../provider/products_category_provider.dart';
import '../provider/products_provider.dart';
import '../provider/products_stock_provider.dart';
import '../provider/products_units_provider.dart';
import '../provider/products_var_provider.dart';
import '../provider/reports_provider.dart';
import '../provider/sell_provider.dart';
import '../provider/sell_return_provider.dart';
import '../provider/selling_group_provider.dart';
import '../provider/supplier_provider.dart';
import '../provider/tax_provider.dart';
import '../provider/user_provider.dart';

const syncKey = 'sync';
const keyWhere = 'invoice_no';

class UniqueDatabase {
  String tableName;

  String? get databaseName => 'pos_data.db';

  String query(table) {
    return 'create table if not exists $table (srn integer primary key AUTOINCREMENT,id text, data text,$keyWhere text, $syncKey text)';
  }

  UniqueDatabase({
    required this.tableName,
  });

  //get instance of database
  Future<Database> getInstance() async {
    var pathRoot = await getDatabasesPath();
    String path = join(pathRoot, databaseName);

    Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int v) async {
      await db.execute(query(imgTable));
      await db.execute(query(customersTable));
      await db.execute(query(expenseTable));
      await db.execute(query(locationTable));
      await db.execute(query(payAccTable));
      await db.execute(query(payMetTable));
      await db.execute(query(posTable));
      await db.execute(query(brandsTable));
      await db.execute(query(productTable));
      await db.execute(query(pstockTable));
      await db.execute(query(productUnitsTable));
      await db.execute(query(productVarTable));
      await db.execute(query(reportsTable));
      await db.execute(query(sellTable));
      await db.execute(query(sellReturnTable));
      await db.execute(query(sellPGTable));
      await db.execute(query(suppliersTable));
      await db.execute(query(taxTable));
      await db.execute(query(userTable));
      await db.execute(query(posDefaultValuesTable));
      await db.execute(query(settingsTable));
      await db.execute(query(categoryTable));
    });

    return database;
  }

  //add new record before response from server
  Future<int> addData(Map<String, dynamic> values) async {
    final database = await getInstance();
    final result = await database.insert(tableName, values);
    return result;
  }

  //update data after synced to server
  Future<int> updateSyncData(Map<String, dynamic> values, String kw) async {
    values[syncKey] =
        SyncStatus.synced.toString().split('.').last.toLowerCase();
    final database = await getInstance();
    final result = database
        .update(tableName, values, where: '$keyWhere=?', whereArgs: [kw]);
    return result;
  }

  //update record which will be created/update from website
  Future<int> updateGetData(Map<String, dynamic> values) async {
    values[syncKey] =
        SyncStatus.synced.toString().split('.').last.toLowerCase();
    final database = await getInstance();
    final result = database
        .update(tableName, values, where: "id=?", whereArgs: [values['id']]);
    return result;
  }

  Future<int> updateReport(Map<String, dynamic> values) async {
    values[syncKey] =
        SyncStatus.synced.toString().split('.').last.toLowerCase();
    final database = await getInstance();
    final result = await database
        .update(tableName, values, where: "srn=?", whereArgs: ['1']);
    return result;
  }

  //update record before response from server
  Future<int> updateData(Map<String, dynamic> values, String kw) async {
    values.removeWhere((key, value) => value == null);
    values[syncKey] =
        SyncStatus.pendingUpdate.toString().split('.').last.toLowerCase();
    final database = await getInstance();
    final result = await database
        .update(tableName, values, where: "$keyWhere=?", whereArgs: [kw]);
    return result;
  }

//update record before response from server
  Future<int> updateStock(Map<String, dynamic> values, String kw) async {
    values.removeWhere((key, value) => value == null);
    values[syncKey] =
        SyncStatus.pendingUpdate.toString().split('.').last.toLowerCase();
    final database = await getInstance();
    print('Stock1');
    print('Stock2');
    print('Stock3');
    print('Stock4');
    print(kw);
    final result = await database
        .update(tableName, values, where: "id=?", whereArgs: [kw]);
    print(result);
    print(values);
    print('Stock3');
    print('Stock4');
    print('Stock1');
    return result;
  }

  //get all data
  Future<List<Map<String, dynamic>>> getData() async {
    final database = await getInstance();

    List<Map<String, dynamic>> data =
        await database.rawQuery('select * from $tableName');

    return data;
  }

  Future<List<Map<String, dynamic>>> getDataAt(ref) async {
    final database = await getInstance();

    List<Map<String, dynamic>> data = await database
        .rawQuery('select * from $tableName where $keyWhere=?', [ref]);

    return data;
  }

  Future<List<Map<String, dynamic>>> delData(String type) async {
    final database = await getInstance();

    List<Map<String, dynamic>> data = await database
        .rawQuery('delete from $tableName where $keyWhere=?', [type]);

    return data;
  }

  Future<List<Map<String, dynamic>>> getAllData() async {
    final database = await getInstance();

    List<Map<String, dynamic>> data =
        await database.rawQuery('select * from $tableName');

    return data;
  }

  Future<void> deleteDB() async {
    final db = await getInstance();
    await db.rawQuery(deleteQuery(imgTable));
    await db.rawQuery(deleteQuery(customersTable));
    await db.rawQuery(deleteQuery(expenseTable));
    await db.rawQuery(deleteQuery(locationTable));
    await db.rawQuery(deleteQuery(payAccTable));
    await db.rawQuery(deleteQuery(payMetTable));
    await db.rawQuery(deleteQuery(posTable));
    await db.rawQuery(deleteQuery(brandsTable));
    await db.rawQuery(deleteQuery(productTable));
    await db.rawQuery(deleteQuery(pstockTable));
    await db.rawQuery(deleteQuery(productUnitsTable));
    await db.rawQuery(deleteQuery(productVarTable));
    await db.rawQuery(deleteQuery(reportsTable));
    await db.rawQuery(deleteQuery(sellTable));
    await db.rawQuery(deleteQuery(sellReturnTable));
    await db.rawQuery(deleteQuery(sellPGTable));
    await db.rawQuery(deleteQuery(suppliersTable));
    await db.rawQuery(deleteQuery(taxTable));
    await db.rawQuery(deleteQuery(userTable));
    await db.rawQuery(deleteQuery(posDefaultValuesTable));
    await db.rawQuery(deleteQuery(settingsTable));
    await db.rawQuery(deleteQuery(categoryTable));
  }

  String deleteQuery(table) {
    return 'delete from $table';
  }
  Future<String> logout(List<dynamic> list) async{
    final db = await getInstance();
    //await db.rawQuery(deleteQuery(tableName));
    list.clear();
    //print('logout');
    return '';
  }
}
