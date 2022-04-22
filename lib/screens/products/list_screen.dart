import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pos_app/provider/location_provider.dart';
import 'package:pos_app/provider/products_provider.dart';
import 'package:pos_app/provider/products_stock_provider.dart';
import 'package:pos_app/widgets/app_drawer.dart';
import 'package:pos_app/widgets/refresh_widget.dart';
import 'package:provider/provider.dart';

const String placeholder = 'assets/placeholder.jpg';

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({Key? key}) : super(key: key);
  static const routeName = '/products-list';

  @override
  State<ProductsListScreen> createState() => _Screen();
}

class _Screen extends State<ProductsListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarName),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
        ],
      ),
      body: Consumer<ProductsProvider>(
        builder: (BuildContext context, contacts, Widget? child) {
          return RefreshIndicator(
            onRefresh: () => refresh(contacts),
            child: getLength(contacts) == 0
                ? const Center(
                    child: MyCustomProgressBar(
                    msg: 'waiting for response from server',
                  ))
                : showList(contacts, context),
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

  Widget showList(ProductsProvider contacts, BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Text(
                'Image ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Name ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Selling Price ',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
              itemCount: getLength(contacts),
              itemBuilder: (ctx, index) {
                return ProductListItem(
                  index: '$index',
                  title: _getTitle(contacts, index),
                  imgUrl: contacts.mapData[index]['image_url'],
                  onClickItem: () {
                    Map<String, dynamic> map =
                        getMapForFunction(contacts, index);

                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (ctx) {
                      return ProductPageItem(
                          list: map,
                          title: _getTitle(contacts, index),
                          index: '$index');
                    }));
                  },
                  price: (contacts.mapData[index]['product_variations']?[0]
                          ?['variations']?[0]?['sell_price_inc_tax'])
                      .toString(),
                );
              }),
        ),
      ],
    );
  }

  var _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _isInit = false;
      final contacts = Provider.of<ProductsProvider>(context, listen: false);

      init(contacts);
    }
    super.didChangeDependencies();
  }

  //screen-specific-changes

  final String appBarName = 'List Products';

  init(ProductsProvider contacts) async {
    final stock = Provider.of<ProductsStockProvider>(context, listen: false);
    await contacts.getData();
    stock.getData();
    contacts.sync();
  }

  //swipe-refresh
  Future<String> refresh(ProductsProvider contacts) async {
    await contacts.getData();
    await contacts.sync();
    await Provider.of<ProductsStockProvider>(context, listen: false).getData();

    return '';
  }

  setListForMenu(ProductsProvider value) {
    return value.mapData;
  }

  getLength(ProductsProvider contacts) {
    return contacts.mapData.length;
  }

  String get editKey => 'name';

  Map<String, dynamic> getMapForFunction(ProductsProvider products, int index) {
    return products.mapData[index];
  }

  _getTitle(ProductsProvider contacts, int index) {
    return contacts.mapData[index][editKey] ?? '';
  }
}

class ProductListItem extends StatelessWidget {
  final String price;
  final String imgUrl;
  final String title;
  final String index;
  final VoidCallback onClickItem;

  const ProductListItem({
    Key? key,
    required this.price,
    required this.imgUrl,
    required this.title,
    required this.onClickItem,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          trailing: Text('Ksh ' + price),
          title: Text(title),
          leading: Hero(
            tag: index,
            child: SizedBox(
              height: 100.0,
              width: 100.0,
              child: Consumer<ProductsProvider>(
                builder: (ctx, snapshot, _) {
                  if (snapshot.images[imgUrl] != null) {
                    return FadeInImage(
                        placeholder: const AssetImage(placeholder),
                        image: FileImage(File(snapshot.images[imgUrl])));
                  }

                  return const FadeInImage(
                    placeholder: AssetImage(placeholder),
                    image: AssetImage(placeholder),
                  );
                },
              ),
            ),
          ),
          onTap: onClickItem,
        ),
        const Divider(),
      ],
    );
  }
}

Widget builder(context, error, stackTrace) {
  return const SizedBox(
    width: 100.0,
  );
}

class ProductPageItem extends StatefulWidget {
  final Map<String, dynamic> list;

  final String title;
  final String index;

  const ProductPageItem(
      {Key? key, required this.list, required this.title, required this.index})
      : super(key: key);

  @override
  State<ProductPageItem> createState() => _ProductPageItemState();
}

class _ProductPageItemState extends State<ProductPageItem> {
  var refreshing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                iconTheme: const IconThemeData(color: Colors.cyan),
                backgroundColor: Colors.white,
                expandedHeight: 256.0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    widget.title,
                    style: const TextStyle(
                        color: Colors.cyan, fontWeight: FontWeight.bold),
                  ),
                  background: Hero(
                    tag: widget.index,
                    child: SizedBox(
                      width: double.infinity,
                      child: refreshing
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : Consumer<ProductsProvider>(
                              builder: (ctx, snapshot, _) {
                                if (snapshot.images[widget.list['image_url']] !=
                                    null) {
                                  return FadeInImage(
                                      placeholder:
                                          const AssetImage(placeholder),
                                      image: FileImage(File(snapshot
                                          .images[widget.list['image_url']])));
                                }

                                return const FadeInImage(
                                  placeholder: AssetImage(placeholder),
                                  image: AssetImage(placeholder),
                                );
                              },
                            ),
                    ),
                  ),
                ),
              ),
              SliverList(
                  delegate: SliverChildListDelegate([
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text('Refresh Image:'),
                    refreshing
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          )
                        : IconButton(
                            color: Colors.white,
                            onPressed: () async {
                              setState(() {
                                refreshing = true;
                              });
                              try {
                                await Provider.of<ProductsProvider>(context,
                                        listen: false)
                                    .refreshImage(widget.list['image_url']);
                              } catch (e) {
                                //
                              }

                              setState(() {
                                refreshing = false;
                              });
                            },
                            icon: Center(
                                child: Icon(
                              Icons.refresh,
                              color: Theme.of(context).primaryColor,
                            )))
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _ViewPage(map: widget.list, title: widget.title),
                )
              ]))
            ],
          ),
        ),
      ),
      drawer: const AppDrawer(),
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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _item(context, 'Sku:', 'sku'),
            _getCustomItem('Brand:', map['brand']?['name']),
            _item(context, 'Type:', 'type'),
          ],
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _getCustomItem('Category:', map['category']?['name']),
            _item(context, 'Sub Category:', 'sub_category'),
          ],
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _getCustomItem('Unit:', map['unit']?['short_name']),
            _item(context, 'Barcode Type:', 'barcode_type'),
          ],
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _getCustomItem('Location:', (map['product_locations']!=null&&map['product_locations'].isNotEmpty)?(map['product_locations'][0]?['name']):''),
            _getCustomItem('ManageStock?:',
                getValue(map, 'enable_stock').contains('1') ? 'yes' : 'no'),
          ],
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _item(context, 'Alert Quantity:', 'alert_quantity',
                prefix1: 'Ksh '),
            _item(context, 'Expires In:', 'expiry_period'),
          ],
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _getCustomItem('Application Tax:', map['product_tax']?['name']),
            _getCustomItem('Selling Price Tax Type:', 'inclusive'),
            //   _item(context, 'Selling Price Tax Type:', 'expiry_period'),
          ],
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Purchase Details',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  _getCustomItem(
                      'Default Purchase Price:',
                      'Ksh ' +
                          map['product_variations']?[0]?['variations']?[0]
                          ?['default_purchase_price'],
                      hint: 'Exc. Tax'),
                  _getCustomItem(
                      'Default Purchase Price:',
                      'Ksh ' +
                          map['product_variations']?[0]?['variations']?[0]
                          ?['dpp_inc_tax'],
                      hint: 'Inc. Tax'),
                  _getCustomItem(
                      'Margin:',
                      map['product_variations']?[0]?['variations']?[0]
                      ?['profit_percent'] +
                          '%'),
                ],
              ),
            ),
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Sell Details',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  _getCustomItem(
                      'Default Selling Price:',
                      'Ksh ' +
                          map['product_variations']?[0]?['variations']?[0]
                          ?['default_sell_price'],
                      hint: 'Exc. Tax'),
                  _getCustomItem(
                      'Default Purchase Price:',
                      'Ksh ' +
                          map['product_variations']?[0]?['variations']?[0]
                          ?['sell_price_inc_tax'],
                      hint: 'Inc. Tax'),
                ],
              ),
            ),
          ),
        ),
        const Divider(),
        Consumer<LocationProvider>(
          builder: (BuildContext context, value, Widget? child) {
            return Column(
              children: value.mapData
                  .map((e) => _setPStockDetail(context, e))
                  .toList(),
            );
          },
        )

      ],
    );
  }

  Widget _item(BuildContext context, title1, key1, {prefix1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(
          title1,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(
          width: 5.0,
        ),
        Text(
          prefix1 != null
              ? '$prefix1 ${getValue(map, key1)}'
              : ' ' + (getValue(map, key1)),
          style: const TextStyle(fontWeight: FontWeight.w300),
        ),
      ]),
    );
  }

  String getValue(Map<String, dynamic> map, String key) {
    if (key.contains('0.0')) {
      return key;
    }
    if (map.containsKey(key) &&
        map[key] != null &&
        map[key].toString().isNotEmpty) {
      return map[key].toString().trim().isEmpty ? '0.0' : map[key].toString();
    }
    return 'unavailable';
  }

  _getCustomItem(key, value, {String hint = ''}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(
              children: [
                Text(
                  key,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (hint.isNotEmpty)
                  Text(
                    '(' + hint + ')',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
              ],
            ),
            const SizedBox(
              width: 5.0,
            ),
            Text(
              value ?? '',
              style: const TextStyle(fontWeight: FontWeight.w300),
            ),
          ]),
          const Divider()
        ],
      ),
    );
  }

  Widget _setPStockDetail(BuildContext context, lid) {
    var products =
        Provider.of<ProductsStockProvider>(context, listen: false).mapData;
    final product = products.firstWhere(
        (element) =>
            element['sku'].toString() == map['sku'].toString() &&
            element['location_id'].toString() == lid['id'].toString(),
        orElse: () => {});
    if (product.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Center(child: Text('Stock Detail not available at location (${lid['name']})',style:const TextStyle(fontWeight: FontWeight.bold,color: Colors.red) ,)),
          const Divider(),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
                Align(
                alignment: Alignment.center,
                child: Padding(
                  padding:const EdgeInsets.all(8.0),
                  child: Text(
                    'Stock Detail (${lid['name']})',
                    style:const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              _getCustomItem('Sku:', map['sku']),
              _getCustomItem('Product:', map['name']),
              _getCustomItem('Location:', product['location_name']),
              _getCustomItem('Unit Price:', product['unit_price']),
              _getCustomItem('Current Stock:',
                  product['stock'].toString() + ' ' + product['unit']),
              _getCustomItem('Current Stock Value:',
                  getTotal(product['stock'].toString(), product['unit_price'])),
              _getCustomItem('Total Unit sold:',
                  product['total_sold'].toString() + ' ' + product['unit']),
              _getCustomItem(
                  'Total Unit Transfered:',
                  product['total_transfered'].toString() +
                      ' ' +
                      product['unit'].toString()),
              _getCustomItem('Total Unit Adjusted:',
                  product['total_adjusted'].toString() + ' ' + product['unit']),
            ],
          ),
        ),
      ),
    );
  }

  getTotal(String product1, String product2) {
    int p1 = int.tryParse(product1.trim()) ?? 0;
    int p2 = int.tryParse(product2.trim()) ?? 0;

    return 'Ksh ${p1 * p2}';
  }
}
