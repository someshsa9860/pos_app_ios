import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pos_app/data_management/pos_web_links.dart';
import 'package:pos_app/provider/products_category_provider.dart';
import 'package:pos_app/screens/contacts/add_contact_screen.dart';
import 'package:pos_app/screens/webview.dart';
import 'package:pos_app/widgets/app_drawer.dart';
import 'package:pos_app/widgets/refresh_widget.dart';
import 'package:provider/provider.dart';

class ProductsCategoryScreen extends StatefulWidget {
  const ProductsCategoryScreen({Key? key}) : super(key: key);
  static const routeName = '/products-category';

  @override
  State<ProductsCategoryScreen> createState() => _Screen();
}

class _Screen extends State<ProductsCategoryScreen> {
  _titles() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Padding(
            padding: EdgeInsets.only(left: 24.0, top: 4.0, bottom: 4.0),
            child: Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 24.0, top: 4.0, bottom: 4.0),
            child: Text(
              'Category Code',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 24.0, top: 4.0, bottom: 4.0),
            child: Text(
              'Description',
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
                        builder: (ctx) => const MyWebView(addCategory)));
              },
              icon: const Icon(Icons.add)),
        ],
      ),
      body: Column(
        children: [
          _titles(),
          Expanded(
            child: Consumer<ProductCategoryProvider>(
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
                                      '${contacts.mapData[index]['name']}'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 24.0, top: 4.0, bottom: 4.0),
                                  child: Text(
                                      '${contacts.mapData[index]['short_code']}'),
                                ),Padding(
                                  padding: const EdgeInsets.only(
                                      right: 24.0, top: 4.0, bottom: 4.0),
                                  child: Text(
                                      '${contacts.mapData[index]['description']}'),
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
          Provider.of<ProductCategoryProvider>(context, listen: false);
      refresh(contacts);
    }
    super.didChangeDependencies();
  }

  //screen-specific-changes

  final String appBarName = 'Category';

  //swipe-refresh
  Future<void> refresh(ProductCategoryProvider contacts) async {
    await contacts.getData();
    await contacts.getData();
  }

  void addEdit(index) {
    Navigator.of(context).pushNamed(AddContact.routeName,
        arguments: [ContactType.supplier, index]);
  }

  setListForMenu(ProductCategoryProvider value) {
    return value.mapData;
  }

  getLength(ProductCategoryProvider contacts) {
    return contacts.mapData.length;
  }

  String get editKey => 'name';

  Map<String, dynamic> getMapForFunction(
      ProductCategoryProvider contacts, int index) {
    return contacts.mapData[index];
  }
}
