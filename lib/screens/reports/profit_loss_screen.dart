import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_app/provider/reports_provider.dart';
import 'package:pos_app/screens/contacts/add_contact_screen.dart';
import 'package:pos_app/widgets/app_drawer.dart';
import 'package:pos_app/widgets/list_items.dart';
import 'package:pos_app/widgets/refresh_widget.dart';
import 'package:provider/provider.dart';

final format = NumberFormat.decimalPattern();

class ReportProfitLossScreen extends StatefulWidget {
  const ReportProfitLossScreen({Key? key}) : super(key: key);
  static const routeName = '/report-profit-loss';

  @override
  State<ReportProfitLossScreen> createState() => _Screen();
}

class _Screen extends State<ReportProfitLossScreen> {
  List<MapUnit> listMap(map) {
    final List<MapUnit> list = [];

    map.forEach((key, value) {
      if (value != null) {
        list.add(MapUnit(key, value.toString()));
      }
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarName),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
        ],
      ),
      body: Consumer<ReportsProvider>(
          builder: (BuildContext context, contacts, Widget? child) {
        return RefreshIndicator(
            onRefresh: () => refresh(contacts),
            child: getLength(contacts) == 0
                ? const Center(
                    child: MyCustomProgressBar(
                    msg: 'waiting response from server',
                  ))
                : buildListView(contacts, context));
      }),
      drawer: const AppDrawer(),
    );
  }

  var _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _isInit = false;
      final contacts = Provider.of<ReportsProvider>(context, listen: false);
      refresh(contacts);
    }
    super.didChangeDependencies();
  }

  //screen-specific-changes

  final String appBarName = 'Profit and Loss Report';

  //swipe-refresh
  Future<void> refresh(ReportsProvider contacts) async {
    await contacts.getData();
  }

  void addEdit(index) {
    Navigator.of(context).pushNamed(AddContact.routeName, arguments: [index]);
  }

  setListForMenu(ReportsProvider value) {
    return value.mapData;
  }

  getLength(ReportsProvider contacts) {
    return contacts.mapData.length;
  }

  Widget buildListView(ReportsProvider contacts, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          _ViewItem(
              keyText: 'Opening Stock:',
              hintText: 'By purchase price',
              valueText: 'Ksh ' + getValue(contacts.mapData, 'opening_stock')),
          // _ViewItem(
          //         keyText: 'Opening Stock:',
          //         hintText: 'By sale price',
          //         valueText:
          //             'Ksh ' + getValue(contacts.mapData, 'total_purchase')),
          _ViewItem(
              keyText: 'Total purchase:',
              hintText: 'Exc. tax, Discount',
              valueText: 'Ksh ' + getValue(contacts.mapData, 'total_purchase')),
          _ViewItem(
              keyText: 'Total Stock Adjustment:',
              valueText:
                  'Ksh ' + getValue(contacts.mapData, 'total_adjustment')),
          _ViewItem(
              keyText: 'Total Expense:',
              valueText: 'Ksh ' + getValue(contacts.mapData, 'total_expense')),
          _ViewItem(
              keyText: 'Total purchase shipping charge:',
              valueText: 'Ksh ' +
                  getValue(contacts.mapData, 'total_purchase_shipping_charge')),
          _ViewItem(
              keyText: 'Purchase additional expenses:',
              valueText: 'Ksh ' +
                  getValue(
                      contacts.mapData, 'total_purchase_additional_expense')),
          _ViewItem(
              keyText: 'Total transfer shipping charge:',
              valueText: 'Ksh ' +
                  getValue(
                      contacts.mapData, 'total_transfer_shipping_charges')),
          _ViewItem(
              keyText: 'Total Sell discount:',
              valueText:
                  'Ksh ' + getValue(contacts.mapData, 'total_sell_discount')),
          _ViewItem(
              keyText: 'Total customer reward:',
              valueText:
                  'Ksh ' + getValue(contacts.mapData, 'total_reward_amount')),
          _ViewItem(
              keyText: 'Total Sell Return:',
              valueText:
                  'Ksh ' + getValue(contacts.mapData, 'total_sell_return')),
          _ViewItem(
              keyText: 'Total Payroll:',
              valueText:
                  'Ksh ${contacts.mapData['left_side_module_data']?[0]?['value']}'),
          _ViewItem(
              keyText: 'Total Production Cost:',
              valueText:
                  'Ksh ${contacts.mapData['left_side_module_data']?[1]?['value']}'),
          _ViewItem(
              keyText: 'Closing stock:',
              hintText: 'By purchase price',
              valueText: 'Ksh ' + getValue(contacts.mapData, 'closing_stock')),
          // _ViewItem(
          //     keyText: 'Closing stock:',
          //     hintText: 'By sale price',
          //     valueText:
          //         'Ksh ' + getValue(contacts.mapData, 'total_adjustment')),
          _ViewItem(
              keyText: 'Total Sales:',
              hintText: 'Exc. tax, Discount',
              valueText: 'Ksh ' + getValue(contacts.mapData, 'total_sell')),
          _ViewItem(
              keyText: 'Total sell shipping charge:',
              valueText: 'Ksh ' +
                  getValue(contacts.mapData, 'total_sell_shipping_charge')),
          _ViewItem(
              keyText: 'Total Stock Recovered:',
              valueText:
                  'Ksh ' + getValue(contacts.mapData, 'total_recovered')),
          _ViewItem(
              keyText: 'Total Purchase Return:',
              valueText:
                  'Ksh ' + getValue(contacts.mapData, 'total_purchase_return')),
          _ViewItem(
              keyText: 'Total Purchase discount:',
              valueText: 'Ksh ' +
                  getValue(contacts.mapData, 'total_purchase_discount')),
          _ViewItem(
              keyText: 'Total sell round off:',
              valueText:
                  'Ksh ' + getValue(contacts.mapData, 'total_sell_round_off')),
          _ViewItem(
              keyText: 'Gross Profit:',
              valueText: 'Ksh ' + getValue(contacts.mapData, 'gross_profit')),
          _ViewItem(
              keyText: 'Net Profit:',
              valueText: 'Ksh ' + getValue(contacts.mapData, 'net_profit')),
        ],
      ),
    );
  }

  String getValue(Map<String, dynamic> map, String key) {
    if (map.containsKey(key) &&
        map[key] != null &&
        map[key].toString().isNotEmpty) {
      return format.format(double.parse(
          map[key].toString().trim().isEmpty ? '0.0' : map[key].toString()));
    }
    return '0.00';
  }
}

class _ViewItem extends StatelessWidget {
  final String keyText;
  final String hintText;
  final String valueText;

  const _ViewItem(
      {Key? key,
      required this.keyText,
      required this.valueText,
      this.hintText = ''})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  keyText,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (hintText.isNotEmpty)
                  Text(
                    '( $hintText )',
                    style: const TextStyle(fontWeight: FontWeight.w300),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              valueText.toString(),
              textAlign: TextAlign.left,
              style: const TextStyle(fontWeight: FontWeight.w300),
            ),
          ),
        ],
      ),
    );
  }
}
