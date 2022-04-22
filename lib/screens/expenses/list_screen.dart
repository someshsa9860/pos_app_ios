import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pos_app/provider/customer_provider.dart';
import 'package:pos_app/provider/expense_provider.dart';
import 'package:pos_app/provider/location_provider.dart';
import 'package:pos_app/provider/supplier_provider.dart';
import 'package:pos_app/widgets/app_drawer.dart';
import 'package:pos_app/widgets/refresh_widget.dart';
import 'package:provider/provider.dart';

import 'add_screen.dart';

class ExpensesListScreen extends StatefulWidget {
  const ExpensesListScreen({Key? key}) : super(key: key);
  static const routeName = '/expenses-list';

  @override
  State<ExpensesListScreen> createState() => _Screen();
}

class _Screen extends State<ExpensesListScreen> {
  @override
  Widget build(BuildContext context) {
    final width=MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarName),
        actions: [
          IconButton(onPressed: () => addEdit(-1), icon: const Icon(Icons.add)),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (BuildContext context, providerData, Widget? child) {
          return RefreshIndicator(
            onRefresh: () => refresh(providerData),
            child: getLength(providerData) == 0
                ? const Center(
                    child: MyCustomProgressBar(
                    msg: 'waiting response from server',
                  ))
                : SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _title('Date', width * 0.2),
                                  _title('Reference No.',
                                      width * 0.2),
                                  _title('Total Amount',
                                      width * 0.2),
                                  _title('Payment Status',
                                      width * 0.2),
                                  _title(
                                      'Expense For', width * 0.2),
                                  _title('Edit', width * 0.1),
                                ],
                              ),
                            ),
                            buildListView(providerData, context),
                          ],
                        ),
                    ),
                  ),
                ),
          );
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: const Icon(Icons.add),
      //   onPressed: () => addEdit(-1),
      // ),
      drawer: const AppDrawer(),
    );
  }

  var _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _isInit = false;
      final contacts = Provider.of<ExpenseProvider>(context, listen: false);
      refresh(contacts);
    }
    super.didChangeDependencies();
  }

  //screen-specific-changes

  final String appBarName = 'List Expense';

  //swipe-refresh
  Future<void> refresh(ExpenseProvider contacts) async {
    await contacts.getData();
    await contacts.sync();
  }

  void addEdit(index) {
    Navigator.of(context)
        .pushNamed(ExpensesAddScreen.routeName, arguments: [index]);
  }



  getLength(ExpenseProvider contacts) {
    return contacts.mapData.length;
  }

  String get titleKey => 'ref_no';

  Map<String, dynamic> getMapForFunction(ExpenseProvider contacts, int index) {
    return contacts.mapData[index];
  }
  Widget buildListView(ExpenseProvider providerData, BuildContext context) {
    final width=MediaQuery.of(context).size.width;
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: providerData.mapData.map((e) => Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (ctx) {
                    return _ViewPage(
                        map: e,
                        title:
                        '${e[titleKey]}');
                  }));
                },
                child: Row(
                  children: [
                    _item(width * 0.2, 'transaction_date',
                        e),
                    _item(width * 0.2, 'ref_no',
                        e),
                    _item(width * 0.2, 'final_total',
                        e),
                    _item(width * 0.2, 'payment_status',
                        e),
                    _title(
                        '${e['expense_for'] == null || e['expense_for'].runtimeType == (1).runtimeType || e['expense_for'].runtimeType == ([]).runtimeType || (e['expense_for'].isEmpty) ? 'unavailable' : (e['expense_for']['surname'] ?? '') + ' ' + (e['expense_for']['first_name'] ?? '') + ' ' + (e['expense_for']['last_name'] ?? '')}',
                        width * 0.2)
                  ],
                ),
              ),
              IconButton(
                  onPressed: () {
                    addEdit(providerData.mapData.indexOf(e));
                  },
                  icon: const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.edit,
                      color: Colors.black45,
                    ),
                  )),
            ],
          )).toList(),
        )

    );
  }


  Widget _item(width, key1, map, {prefix1}) {
    return SizedBox(
        width: width,
        child: Text(
          prefix1 != null
              ? '$prefix1 ${getValue(map, key1)}'
              : '' + (getValue(map, key1)),
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w300),
        ));
  }

  _title(String v, double size) {
    return SizedBox(
      width: size,
      child: Text(v),
    );
  }
}

class _ViewPage extends StatelessWidget {
  final Map<String, dynamic> map;

  final String title;

  const _ViewPage({Key? key, required this.map, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _item(context, 'Reference No.:', 'ref_no'),
              _getCustomItem('Location:', getLocation(context)),
              _getCustomItem('Created By:', getUserName(context)),
              _item(context, 'Payment Status:', 'payment_status'),
              _item(context, 'Total Amount:', 'final_total'),
              _getCustomItem('Expense For:',
                  '${map['expense_for'] == null || map['expense_for'].runtimeType == (1).runtimeType || map['expense_for'].runtimeType == ([]).runtimeType || (map['expense_for'].isEmpty) ? 'unavailable' : (map['expense_for']['surname'] ?? '') + ' ' + (map['expense_for']['first_name'] ?? '') + ' ' + (map['expense_for']['last_name'] ?? '')}'),
              _item(context, 'Date:', 'transaction_date'),
              _item(context, 'Added On:', 'created_at'),
              _item(context, 'Updated At.:', 'updated_at'),
            ],
          ),
        ),
      ),
      drawer: const AppDrawer(),
    );
  }

  Widget _item(BuildContext context, title1, key1, {prefix1}) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title1,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              prefix1 != null
                  ? '$prefix1 ${getValue(map, key1)}'
                  : '' + (getValue(map, key1)),
              textAlign: TextAlign.left,
              style: const TextStyle(fontWeight: FontWeight.w300),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getCustomItem(key, value) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              key,
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.start,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: const TextStyle(fontWeight: FontWeight.w300),
            ),
          ),
        ],
      ),
    );
  }

  String getLocation(context) {
    var id = map['location_id'];

    if (id == null) {
      return 'unavailable';
    }
    var locations =
        Provider.of<LocationProvider>(context, listen: false).mapData;
    var index = locations
        .indexWhere((element) => element['id'].toString() == id.toString());

    if (index < 0) {
      return 'unavailable';
    }

    return locations[index]['name'];
  }

  String getUserName(context) {
    var id = map['created_by'];

    if (id == null) {
      return 'unavailable';
    }
    var users = Provider.of<SupplierProvider>(context, listen: false).mapData;
    var index = users
        .indexWhere((element) => element['id'].toString() == id.toString());

    if (index < 0) {
      var users = Provider.of<CustomerProvider>(context, listen: false).mapData;
      var index = users
          .indexWhere((element) => element['id'].toString() == id.toString());

      if (index < 0) {
        return 'unavailable';
      }

      return '${users[index]['name']}';
    }

    return '${users[index]['name']}';
  }
}

String getValue(Map<String, dynamic> map, String key) {
  if (map.containsKey(key) &&
      map[key] != null &&
      map[key].toString().isNotEmpty) {
    return map[key].toString().trim().isEmpty ? '0.0' : map[key].toString();
  }
  return 'unavailable';
}
