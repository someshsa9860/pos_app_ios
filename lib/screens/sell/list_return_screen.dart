import 'package:flutter/material.dart';
import 'package:pos_app/provider/expense_provider.dart';
import 'package:pos_app/provider/sell_return_provider.dart';
import 'package:pos_app/screens/sell/add_screen.dart';
import 'package:pos_app/widgets/app_drawer.dart';
import 'package:pos_app/widgets/refresh_widget.dart';
import 'package:provider/provider.dart';

class SellListReturnScreen extends StatefulWidget {
  const SellListReturnScreen({Key? key}) : super(key: key);
  static const routeName = '/sell-list-return';

  @override
  State<SellListReturnScreen> createState() => _Screen();
}

class _Screen extends State<SellListReturnScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarName),
        actions: [
          IconButton(onPressed: () => addEdit(-1), icon: const Icon(Icons.add)),
        ],
      ),
      body: Consumer<SellReturnProvider>(
        builder: (BuildContext context, contacts, Widget? child) {
          return RefreshIndicator(
            onRefresh: () => refresh(contacts),
            child: getLength(contacts) == 0
                ? const Center(
                    child: MyCustomProgressBar(
                    msg: 'waiting response from server',
                  ))
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Invoice No. & date ',
                              style: TextStyle(fontWeight: FontWeight.w300),
                            ),
                            Text(
                              'Payment Status ',
                              style: TextStyle(fontWeight: FontWeight.w300),
                            ),
                          ],
                        ),
                      ),
                      Expanded(child: buildListView(contacts, context)),
                    ],
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
      final contacts = Provider.of<SellReturnProvider>(context, listen: false);
      refresh(contacts);
    }
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  //screen-specific-changes

  final String appBarName = 'Sell';

  //swipe-refresh
  Future<void> refresh(SellReturnProvider contacts) async {
    await contacts.getData();
    await contacts.sync();
  }

  void addEdit(index) {
    Navigator.of(context)
        .pushNamed(SellAddScreen.routeName, arguments: [index]);
  }

  setListForMenu(SellReturnProvider value) {
    return value.mapData;
  }

  getLength(SellReturnProvider contacts) {
    return contacts.mapData.length;
  }

  String get titleKey => 'invoice_no';

  Map<String, dynamic> getMapForFunction(
      SellReturnProvider contacts, int index) {
    return contacts.mapData[index];
  }

  ListView buildListView(SellReturnProvider contacts, BuildContext context) {
    return ListView.builder(
        itemCount: getLength(contacts),
        itemBuilder: (ctx, index) {
          return Column(
            children: [
              ListTile(
                leading: (contacts.mapData[index][titleKey] ?? '') +
                        ' at ' +
                        contacts.mapData[index]['transaction_date'] ??
                    '',
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
                    return _ViewPage(
                        map: getMapForFunction(contacts, index),
                        title: contacts.mapData[index][titleKey] ?? '');
                  }));
                },
                trailing: contacts.mapData[index]['payment_status'] ?? '',
              ),
              const Divider()
            ],
          );
        });
  }
}

class _ViewPage extends StatelessWidget {
  final Map<String, dynamic> map;

  final String title;

  const _ViewPage({Key? key, required this.map, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              _item(context, 'Date:', 'transaction_date'),
              _item(context, 'Invoice No.:', 'invoice_no'),
              _getCustomItem('Location:', getLocation(context)),
              _getCustomItem('Created By:', getUserName(context)),
              _item(context, 'Payment Status:', 'payment_status'),
              _item(context, 'Total Amount:', 'final_total', prefix1: 'Ksh'),
              _getCustomItem(
                  'Total Due:',
                  'Ksh' +
                      (getValue(map, 'payment_status').contains('paid')
                          ? '0.0'
                          : getValue(map, 'final_total'))),
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

  String getLocation(context) {
    var id = int.tryParse(getValue(map, 'location_id'));

    if (id == null) {
      return 'unavailable';
    }
    var locations =
        Provider.of<ExpenseProvider>(context, listen: false).mapData;
    var index = locations.indexWhere((element) => element['id'] == id);

    if (index < 0) {
      return 'unavailable';
    }

    return locations[index]['name'];
  }

  String getUserName(context) {
    var id = int.tryParse(getValue(map, 'created_by'));

    if (id == null) {
      return 'unavailable';
    }
    var users = Provider.of<ExpenseProvider>(context, listen: false).mapData;
    var index = users.indexWhere((element) => element['id'] == id);

    if (index < 0) {
      return 'unavailable';
    }

    return users[index]['surname'] +
        ' ' +
        users[index]['first_name'] +
        ' ' +
        users[index]['last_name'];
  }
}
