import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:pos_app/api/api.dart';
import 'package:pos_app/models/contact_unit.dart';
import 'package:sqflite/sqflite.dart';

class ContactsProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _mapSupplyer = [];
  List<Map<String, dynamic>> _mapCustomer = [];
  var api = 'connector/api/contactapi';

  void getContactSupplyer() async {
    final body = {'type': 'supplier'};
    final response = await CallApi().getData(api, body: body);
    //print(response.body);
    final result = json.decode(response.body);
    //print(result.toString());
    final mpSupplyer = result["data"] as List<dynamic>;
    _mapSupplyer.clear();
    for (var map in mpSupplyer) {
      Map<String, dynamic> m = map as Map<String, dynamic>;

      _mapSupplyer.add(map);
    }
    print(_mapSupplyer.length.toString());
    if (_mapSupplyer.length > 0) {
      print(getField('contact_id', 0));
    }

    //   print(_mapSupplyer.toString());
    notifyListeners();
  }

  List<Map<String, dynamic>> get mapSupplyer => _mapSupplyer;

  void getContactCustomer() async {
    final body = {'type': 'customer'};
    final response =
        await CallApi().getData(api, body: body).catchError((error) {
      print('13 error ' + error.toString());
    });
    final result = json.decode(response.body);
    _mapCustomer.clear();
    final mpSupplyer = result["data"] as List<dynamic>;
    for (var map in mpSupplyer) {
      Map<dynamic, dynamic> m = map as Map<dynamic, dynamic>;
      m.forEach((key, value) {
        _mapCustomer.add({key.toString(): value});
      });
    }
    notifyListeners();
  }

  String? getField(String key, int index) {
    return _mapSupplyer.elementAt(index)[key];
  }

  addContact(Map<String,dynamic> data) async{
    final response= await CallApi().postData(data, api);
    return response;
  }


  void addContactCustomer(Map<String,dynamic> data) {}

  List<Map<String, dynamic>> get mapCustomer => _mapCustomer;
}

class ContactDatabase {
  Future<Database> getInstance() async {
    var pathRoot = await getDatabasesPath();
    String path = join(pathRoot, 'contacts.db');

    Database database =
        await openDatabase(path, onCreate: (Database db, int v) async {
      await db.execute(
          'create table if not exists contacts (srn integer primary key AUTO_INCREMENT,id text, business_id text, type text, supplier_business_name text, name text, prefix text, first_name text, middle_name text, last_name text, email text, contact_id text, contact_status text, tax_number text, city text, state text, country text, address_line_1 text, address_line_2 text, zip_code text, dob text, mobile text, landline text, alternate_number text, pay_term_number text, pay_term_type text, credit_limit text, created_by text, balance text, total_rp text, total_rp_used text, total_rp_expired text, is_default text, shipping_address text, shipping_custom_field_details text, is_export text, export_custom_field_1 text, export_custom_field_2 text, export_custom_field_3 text, export_custom_field_4 text, export_custom_field_5 text, export_custom_field_6 text, position text, customer_group_id text, custom_field1 text, custom_field2 text, custom_field3 text, custom_field4 text, custom_field5 text, custom_field6 text, custom_field7 text, custom_field8 text, custom_field9 text, custom_field10 text, deleted_at text, created_at text, updated_at text)');
    });

    return database;
  }

  void addData(data) {}

  void getData() {}
}
