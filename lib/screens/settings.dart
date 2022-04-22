import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart' as basic;
import 'package:intl/intl.dart';
import 'package:pos_app/provider/headers_footers_provider.dart';
import 'package:pos_app/screens/sell/headers_footers.dart';
import 'package:pos_app/widgets/app_drawer.dart';
import 'package:pos_app/widgets/border_row.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/auth_provider.dart';
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
import 'bluetooth_printer.dart';
import 'home.dart';

class AppSettings extends StatefulWidget {
  static const routeName = '/settings-screen';

  const AppSettings({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _State();
  }
}

enum DefaultPrinters { cs10, cs30, bluetooth, pdfShare, pdfSave }

class _State extends State<AppSettings> {
  var printerItems = {};

  final settingKeys = ["settings_printer", "blue_device"];
  final settingValues = {
    "settings_printer": DefaultPrinters.pdfSave.index.toString()
  };

  @override
  void initState() {
    init();
    printerItems = {
      DefaultPrinters.bluetooth.index.toString(): 'Bluetooth Printer',
      DefaultPrinters.pdfShare.index.toString(): 'Share as pdf',
      DefaultPrinters.pdfSave.index.toString(): 'Save as pdf',
    };
    if(Platform.isAndroid){
      printerItems[DefaultPrinters.cs10.index.toString()]='CS10';
      printerItems[DefaultPrinters.cs30.index.toString()]='CS30';
    }
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'General Settings',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                title: const Text(
                  "Default Printer",
                  style: TextStyle(fontWeight: FontWeight.w400),
                ),
                leading: const Icon(Icons.print),
                subtitle: Text(
                  printerItems[settingValues[settingKeys[0]]] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w400),
                ),
                trailing: DropdownButton(
                  value: settingValues[settingKeys[0]],
                  onChanged: (v) {
                    settingValues[settingKeys[0]] = v as String;
                    setState(() {});
                    save(settingKeys[0], v);
                  },
                  items: _mapToList(printerItems),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.bluetooth),
                title: const Text(
                  "Bluetooth Printer",
                  style: TextStyle(fontWeight: FontWeight.w400),
                ),
                subtitle: Text(
                  settingValues[settingKeys[1]] ?? "",
                  style: const TextStyle(fontWeight: FontWeight.w300),
                ),
                trailing: IconButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed(BluetoothScreen.routeName);
                    },
                    icon: const Icon(Icons.settings_bluetooth_outlined)),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Receipt Layout Settings',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.border_top_sharp),
                title: const Text(
                  "Manage Headers",
                  style: TextStyle(fontWeight: FontWeight.w400),
                ),
                subtitle: Text(
                  Provider.of<HeadersFootersProvider>(context, listen: false)
                      .headerUpdate,
                  style: const TextStyle(fontWeight: FontWeight.w300),
                ),
                trailing: IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (ctx) => const HeadersFooters(
                                    type: typeHeader,
                                  )));
                    },
                    icon: const Icon(Icons.arrow_right_alt_rounded)),
              ),
              ListTile(
                leading: const Icon(Icons.border_bottom_sharp),
                title: const Text(
                  "Manage Footers",
                  style: TextStyle(fontWeight: FontWeight.w400),
                ),
                subtitle: Text(
                  Provider.of<HeadersFootersProvider>(context, listen: false)
                      .footerUpdate,
                  style: const TextStyle(fontWeight: FontWeight.w300),
                ),
                trailing: IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (ctx) => const HeadersFooters(
                                    type: typeFooter,
                                  )));
                    },
                    icon: const Icon(Icons.arrow_right_alt_rounded)),
              ),
              ListTile(
                leading: const Icon(Icons.receipt_long),
                title: const Text(
                  "Set Receipt Number ",
                  style: TextStyle(fontWeight: FontWeight.w400),
                ),
                subtitle: FutureBuilder(
                  future: SharedPreferences.getInstance(),
                  builder: (BuildContext context,
                      AsyncSnapshot<SharedPreferences> snapshot) {
                    final format = NumberFormat('00000');

                    if (!snapshot.hasData) {
                      return SizedBox();
                    }
                    return Text(
                      'POS${snapshot.data!.getString('getInvoiceNumPrefix') ?? ''}${format.format(snapshot.data!.getInt('getInvoiceNum') ?? 0)}',
                      style: const TextStyle(fontWeight: FontWeight.w300),
                    );
                  },
                ),
                trailing: IconButton(
                    onPressed: () async {
                      final prefix = TextEditingController();
                      final number = TextEditingController();

                      await showDialog<void>(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext ctx) {
                            return AlertDialog(
                              title: const Text('Update Receipt Number'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: BorderRow(
                                      child: TextField(
                                        controller: prefix,
                                        decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            hintText: 'Enter Prefix after POS'),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: BorderRow(
                                      child: TextField(
                                        controller: number,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            hintText: 'Enter starting number'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                    },
                                    child: const Text('Cancel')),
                                ElevatedButton(
                                    onPressed: () async {
                                      Navigator.of(ctx).pop();
                                      final pref =
                                          await SharedPreferences.getInstance();
                                      if (number.text.isNotEmpty) {
                                        await pref.setInt(
                                            'getInvoiceNum',
                                            int.tryParse(
                                                    number.text.toString()) ??
                                                0);
                                      }
                                      await pref.setString(
                                          'getInvoiceNumPrefix',
                                          prefix.text.toUpperCase());

                                      setState(() {});
                                    },
                                    child: const Text('Update')),
                              ],
                            );
                          });
                    },
                    icon: const Icon(Icons.settings)),
              ),
              ListTile(
                leading: Icon(
                  Icons.power_settings_new_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Delete Account'),
                onTap: () => logout(true),
              ),
            ],
          )),
    );
  }

  List<DropdownMenuItem<Object>>? _mapToList(
      Map<dynamic, dynamic> printerItems) {
    final List<DropdownMenuItem<Object>> list = [];
    var keys = printerItems.keys;
    for (var key in keys) {
      print(key);
      list.add(DropdownMenuItem(
        child: Text(printerItems[key]),
        value: key,
      ));
    }
    print(list.toString());
    return list.toSet().toList();
  }

  void save(String key, value) async {
    final pref = await SharedPreferences.getInstance();
    pref.setString(key, value.toString());
  }

  init() async {



    final pref = await SharedPreferences.getInstance();

    var key = 'settings_printer';
    if (pref.getString(key) != null) {
      settingValues[key] = pref.getString(key) ?? '';
    }
    key = 'blue_device';
    if (pref.getString(key) != null) {
      var _dev =
          basic.BluetoothDevice.fromJson(jsonDecode(pref.getString(key) ?? ''));

      settingValues[key] = _dev.address ?? '';
    }
    setState(() {});
  }

  logout(bool delete) async {
    Navigator.pop(context);
    Provider.of<AuthProvider>(context, listen: false).logout();
    Provider.of<ProductsStockProvider>(context, listen: false).logout();
    Provider.of<ExpenseProvider>(context, listen: false).logout();
    Provider.of<CustomerProvider>(context, listen: false).logout();
    Provider.of<SupplierProvider>(context, listen: false).logout();
    Provider.of<LocationProvider>(context, listen: false).logout();
    Provider.of<PaymentAccountProvider>(context, listen: false).logout();
    Provider.of<PaymentMethodsProvider>(context, listen: false).logout();
    Provider.of<ProductsProvider>(context, listen: false).logout();
    Provider.of<PosProvider>(context, listen: false).logout();
    Provider.of<SellProvider>(context, listen: false).logout();
    Provider.of<SellingGroupProvider>(context, listen: false).logout();
    Provider.of<ProductsBrandProvider>(context, listen: false).logout();
    Provider.of<ProductCategoryProvider>(context, listen: false).logout();
    Provider.of<ProductsUnitsProvider>(context, listen: false).logout();
    Provider.of<ProductsVarProvider>(context, listen: false).logout();
    Provider.of<SellReturnProvider>(context, listen: false).logout();
    Provider.of<ReportsProvider>(context, listen: false).logout();
    Provider.of<TaxProvider>(context, listen: false).logout();
    Provider.of<UsersProvider>(context, listen: false).logout();
    Navigator.pushReplacementNamed(context, MyHomePage.routeName,
        arguments: delete);
    final preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }
}
