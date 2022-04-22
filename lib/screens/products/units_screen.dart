import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pos_app/data_management/pos_web_links.dart';
import 'package:pos_app/provider/products_units_provider.dart';
import 'package:pos_app/screens/contacts/add_contact_screen.dart';
import 'package:pos_app/widgets/app_drawer.dart';
import 'package:pos_app/widgets/refresh_widget.dart';
import 'package:provider/provider.dart';

import '../webview.dart';

class ProductsUnitsScreen extends StatefulWidget {
  const ProductsUnitsScreen({Key? key}) : super(key: key);
  static const routeName = '/products-units';

  @override
  State<ProductsUnitsScreen> createState() => _Screen();
}

class _Screen extends State<ProductsUnitsScreen> {
  _titles() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Padding(
            padding: EdgeInsets.only(left: 24.0, top: 4.0, bottom: 4.0),
            child: Text(
              'Name',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 24.0, top: 4.0, bottom: 4.0),
            child: Text(
              'Short Name',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 24.0, top: 4.0, bottom: 4.0),
            child: Text(
              'Allow Decimal',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarName),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (ctx) => const MyWebView(addUnit)));
              },
              icon: const Icon(Icons.add)),
        ],
      ),
      body: Column(
        children: [
          _titles(),
          Expanded(
            child: Consumer<ProductsUnitsProvider>(
              builder: (BuildContext context, contacts, Widget? child) {
                return RefreshIndicator(
                  onRefresh: () => refresh(contacts),
                  child: getLength(contacts) == 0
                      ? const Center(
                          child: MyCustomProgressBar(
                          msg: 'waiting response from server',
                        ))
                      : ListView.builder(
                          itemCount: getLength(contacts),
                          itemBuilder: (ctx, index) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 24.0, top: 4.0, bottom: 4.0),
                                  child: Text(
                                      '${contacts.mapData[index]['actual_name']}'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 24.0, top: 4.0, bottom: 4.0),
                                  child: Text(
                                      '${contacts.mapData[index]['short_name']}'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 24.0, top: 4.0, bottom: 4.0),
                                  child: Text(contacts.mapData[index]
                                              ['allow_decimal']
                                          .toString()
                                          .contains('1')
                                      ? 'yes'
                                      : 'no'),
                                ),
                              ],
                            );
                          }),
                );
              },
            ),
          ),
        ],
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
      final contacts =
          Provider.of<ProductsUnitsProvider>(context, listen: false);
      refresh(contacts);
    }
    super.didChangeDependencies();
  }

  //screen-specific-changes

  final String appBarName = 'Product Units';

  //swipe-refresh
  Future<void> refresh(ProductsUnitsProvider contacts) async {
    await contacts.getData();
    await contacts.sync();
  }

  void addEdit(index) {
    Navigator.of(context).pushNamed(AddContact.routeName,
        arguments: [ContactType.supplier, index]);
  }

  setListForMenu(ProductsUnitsProvider value) {
    return value.mapData;
  }

  getLength(ProductsUnitsProvider contacts) {
    return contacts.mapData.length;
  }

  String get editKey => 'actual_name';

  Map<String, dynamic> getMapForFunction(
      ProductsUnitsProvider contacts, int index) {
    return contacts.mapData[index];
  }
}
