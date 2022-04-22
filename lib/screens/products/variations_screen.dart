import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pos_app/provider/products_var_provider.dart';
import 'package:pos_app/widgets/app_drawer.dart';
import 'package:pos_app/widgets/list_items.dart';
import 'package:pos_app/widgets/refresh_widget.dart';
import 'package:provider/provider.dart';

class ProductsVariationsScreen extends StatefulWidget {
  const ProductsVariationsScreen({Key? key}) : super(key: key);
  static const routeName = '/products-variations';

  @override
  State<ProductsVariationsScreen> createState() => _Screen();
}

class _Screen extends State<ProductsVariationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarName),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
        ],
      ),
      body: Consumer<ProductsVarProvider>(
        builder: (BuildContext context, providerData, Widget? child) {
          return RefreshIndicator(
            onRefresh: () => refresh(providerData),
            child: getLength(providerData) == 0
                ? const Center(
                    child: MyCustomProgressBar(
                    msg: 'waiting response from server',
                  ))
                : ListView.builder(
                    itemCount: getLength(providerData),
                    itemBuilder: (ctx, index) {
                      return ListView.builder(
                          itemCount: getLength(providerData),
                          itemBuilder: (ctx, index) {
                            return ListItem(
                              icon: Icons.edit,
                              title: providerData.mapData[index][editKey] ?? '',
                              onClickItem: () {
                                final List<MapUnit> listMap = [];
                                Map<String, dynamic> map =
                                    getMapForFunction(providerData, index);
                                map.forEach((key, value) {
                                  if (value != null) {
                                    listMap.add(MapUnit(key, value.toString()));
                                  }
                                });
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (ctx) {
                                  return ViewPageItem(
                                    list: listMap,
                                    title: providerData.mapData[index]
                                            [editKey] ??
                                        '',
                                  );
                                }));
                              },
                              onClickIcon: () {},
                            );
                          });
                    }),
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
      final products = Provider.of<ProductsVarProvider>(context, listen: false);
      refresh(products);
    }
    super.didChangeDependencies();
  }

  //screen-specific-changes

  final String appBarName = 'Product Variation';

  //swipe-refresh
  Future<void> refresh(ProductsVarProvider products) async {
    await products.getData();
    await products.sync();
  }

  getLength(ProductsVarProvider products) {
    return products.mapData.length;
  }

  String get editKey => 'product_name';

  Map<String, dynamic> getMapForFunction(
      ProductsVarProvider products, int index) {
    return products.mapData[index];
  }
}
