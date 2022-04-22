import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_app/provider/customer_provider.dart';
import 'package:pos_app/provider/location_provider.dart';
import 'package:pos_app/provider/sell_provider.dart';
import 'package:pos_app/provider/user_provider.dart';
import 'package:pos_app/screens/sell/add_screen.dart';
import 'package:pos_app/widgets/app_drawer.dart';
import 'package:pos_app/widgets/refresh_widget.dart';
import 'package:provider/provider.dart';

class SellAllScreen extends StatefulWidget {
  const SellAllScreen({Key? key}) : super(key: key);
  static const routeName = '/sell-all';

  @override
  State<SellAllScreen> createState() => _Screen();
}

class _Screen extends State<SellAllScreen> {
  @override
  Widget build(BuildContext context) {
    final width=MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarName),
      ),
      body: Consumer<SellProvider>(
        builder: (BuildContext context, contacts, Widget? child) {
          return RefreshIndicator(
            onRefresh: () => refresh(contacts),
            child: getLength(contacts) == 0
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
                              child:  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _title('Date', width * 0.2),
                                      _title(
                                          'Invoice No.', width * 0.2),
                                      _title('Customer name',
                                          width * 0.2),
                                      _title(
                                          'Final Total', width * 0.2),
                                      _title('Payment Status',
                                          width * 0.2),
                                      _title('Update Delivery',
                                          width * 0.2),
                                    ],
                                  )
                            ),
                           buildListView(contacts, context),
                          ],
                        ),
                    ),
                  ),
                ),
          );
        },
      ),
      drawer: const AppDrawer(),
    );
  }

  var _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _isInit = false;
      final contacts = Provider.of<SellProvider>(context, listen: false);
      refresh(contacts);
    }
    super.didChangeDependencies();
  }

  //screen-specific-changes

  final String appBarName = 'Sell';

  //swipe-refresh
  refresh(SellProvider contacts) async {
    await contacts.getData();
    await contacts.sync();
    return '';
  }

  void addEdit(index) {
    Navigator.of(context)
        .pushNamed(SellAddScreen.routeName, arguments: [index]);
  }

  setListForMenu(SellProvider value) {
    return value.mapData;
  }

  getLength(SellProvider contacts) {
    return contacts.mapData.length;
  }

  String get titleKey => 'invoice_no';

  Map<String, dynamic> getMapForFunction(SellProvider contacts, int index) {
    return contacts.mapData[index];
  }

  final format = NumberFormat.decimalPattern();

  Widget buildListView(SellProvider providerData, BuildContext context) {
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
                      title: getUserName(
                          context, e));
                }));
              },
              child: Row(
                children: [
                  _item(width * 0.2, 'transaction_date',
                      e),
                  _item(width * 0.2, 'invoice_no',
                      e),
                  _title(
                      getUserName(context, e),
                      width * 0.2),
                  _title(e['final_total'],
                      width * 0.2),
                  _item(width * 0.2, 'payment_status',
                      e),
                ],
              ),
            ),
            IconButton(
                onPressed: () {
                  final initData = {};

                  TextEditingController _sDeliverTo =
                  TextEditingController();
                  TextEditingController _sStatusC =
                  TextEditingController();

                  _sDeliverTo.text = initData['delivered_to'] ?? '';
                  var _sStatus = initData['shipping_status'];

                  showDialog<void>(
                    context: context,
                    barrierDismissible: true,
                    // false = user must tap button, true = tap outside dialog
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: const Text('Edit Order Tax'),
                        content: StatefulBuilder(builder: (ctx, st) {
                          return SizedBox(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  height: 10.0,
                                ),
                                TextField(
                                  keyboardType: TextInputType.text,
                                  controller: _sDeliverTo,
                                  decoration: const InputDecoration(
                                    labelText: 'Deliver To',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Shipping Status: '),
                                    Expanded(
                                      child: DropdownButton(
                                          value: _sStatus,
                                          onChanged: (v) {
                                            if (v != null) {
                                              setState(() {
                                                _sStatus = v;
                                                _sStatusC.text = '$v';
                                              });
                                            }
                                          },
                                          items: const [
                                            DropdownMenuItem(
                                              child: Text('Ordered'),
                                              value: 'ordered',
                                            ),
                                            DropdownMenuItem(
                                              child: Text('Packed'),
                                              value: 'packed',
                                            ),
                                            DropdownMenuItem(
                                              child: Text('Shipped'),
                                              value: 'shipped',
                                            ),
                                            DropdownMenuItem(
                                              child: Text('Delivered'),
                                              value: 'delivered',
                                            ),
                                            DropdownMenuItem(
                                              child: Text('Cancelled'),
                                              value: 'cancelled',
                                            )
                                          ]),
                                    )
                                  ],
                                ),
                                TextField(
                                  keyboardType: TextInputType.text,
                                  controller: _sStatusC,
                                  enabled: false,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Update'),
                            onPressed: () async {
                              initData['delivered_to'] =
                                  _sDeliverTo.text;
                              initData['shipping_status'] = _sStatus;
                              initData['id'] =
                              e['id'];
                              try {
                                Provider.of<SellProvider>(context,
                                    listen: false)
                                    .update(initData);
                                Navigator.of(context).pop();
                              } catch (e) {
                                _sStatusC.text = e.toString();
                              }
                            },
                          ),
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.of(dialogContext)
                                  .pop(); // Dismiss alert dialog
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.local_shipping_outlined,
                    color: Colors.black45,
                  ),
                )),
          ],
        )).toList(),
      )

    );
  }

  Widget _item(width, key1, map, {prefix1 = ''}) {
    return SizedBox(
        width: width,
        child: Text(
          '$prefix1 ${map[key1]}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w300),
        ));
  }

  _title(String? v, double size) {
    return SizedBox(
      width: size,
      child: Text('$v',textAlign: TextAlign.center,),
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
              _item(context, 'Date:', 'transaction_date'),
              _item(context, 'Invoice No.:', 'invoice_no'),
              _getCustomItem('Location:', getLocation(context)),
              _getCustomItem('Created By:', getUserName(context, map)),
              _item(context, 'Payment Status:', 'payment_status'),
              _getCustomItem(
                  'Payment Method:',
                  '${(map['payment_lines'] == null) ? '' : ((map['payment_lines'] as List<dynamic>).isEmpty) ? '' : map['payment_lines']?[0]?['method']}'),
              _item(context, 'Total Amount:', 'final_total', prefix1: 'Ksh'),
              _getCustomItem('Total Paid:', '${map['final_total']}'),
              _item(context, 'Shipping Status:', 'shipping_status'),
              _getCustomItem(
                  'Total items:', '${map['sell_lines']?[0]?['quantity']}'),
              _item(context, 'Staff Note:', 'staff_note'),
              _getCustomItem(
                  'Sell note:', map['sell_lines']?[0]?['sell_line_note']),
              _item(context, 'Shipping Details:', 'shipping_details'),
              _item(context, 'Added On:', 'created_at'),
              _item(context, 'Updated At.:', 'updated_at'),
            ],
          ),
        ),
      ),
      drawer: const AppDrawer(),
    );
  }

  Widget _item(BuildContext context, title1, key1, {prefix1 = ''}) {
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
              '$prefix1 ${(map[key1])}',
              textAlign: TextAlign.left,
              style: const TextStyle(fontWeight: FontWeight.w300),
            ),
          ),
        ],
      ),
    );
  }

  String getLocation(context) {
    var id = (map['location_id']);

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
              value ?? '',
              textAlign: TextAlign.left,
              style: const TextStyle(fontWeight: FontWeight.w300),
            ),
          ),
        ],
      ),
    );
  }
}

String getUserName(context, map) {
  int? id;
  try {
    id = int.tryParse(map['created_by'].toString());
  } catch (e) {
    //
  }

  if (id == null) {
    return 'unavailable';
  }
  var users = Provider.of<UsersProvider>(context, listen: false).mapData;


  var index =
      users.indexWhere((element) => element['id'].toString() == id.toString());


  if (index < 0) {
    return 'unavailable';
  }

  return '${users[index]['username']}';
}
