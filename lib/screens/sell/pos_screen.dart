import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart'
    as barcode;
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart' as basic;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:pos_app/data_management/pos_database.dart';
import 'package:pos_app/data_management/pos_web_links.dart';
import 'package:pos_app/data_management/print.dart';
import 'package:pos_app/data_management/sync.dart';
import 'package:pos_app/provider/customer_provider.dart';
import 'package:pos_app/provider/headers_footers_provider.dart';
import 'package:pos_app/provider/location_provider.dart';
import 'package:pos_app/provider/paccounts_provider.dart';
import 'package:pos_app/provider/pmethods_provider.dart';
import 'package:pos_app/provider/pos_provider.dart';
import 'package:pos_app/provider/products_category_provider.dart';
import 'package:pos_app/provider/products_provider.dart';
import 'package:pos_app/provider/products_stock_provider.dart';
import 'package:pos_app/provider/sell_provider.dart';
import 'package:pos_app/provider/selling_group_provider.dart';
import 'package:pos_app/provider/supplier_provider.dart';
import 'package:pos_app/provider/tax_provider.dart';
import 'package:pos_app/screens/bluetooth_printer.dart';
import 'package:pos_app/screens/contacts/add_contact_screen.dart';
import 'package:pos_app/screens/products/list_screen.dart';
import 'package:pos_app/screens/reports/profit_loss_screen.dart';
import 'package:pos_app/screens/sell/pos_all_screen.dart';
import 'package:pos_app/screens/settings.dart';
import 'package:pos_app/widgets/app_drawer.dart';
import 'package:pos_app/widgets/border_row.dart';
import 'package:pos_app/widgets/pos_search.dart';
import 'package:pos_app/widgets/special_design.dart';
import 'package:printer_one/printer_one.dart';
import 'package:provider/provider.dart';
import 'package:search_page/search_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({Key? key}) : super(key: key);
  static const routeName = '/pos-screen';

  @override
  State<StatefulWidget> createState() {
    return POSState();
  }
}

class POSState extends State<POSScreen> {
  List<Map<String, dynamic>> mapProductList = [];

  String get items {
    var value = 0;
    for (Map<String, dynamic> product in mapProductList) {
      value = value + (product['quantity'] ?? 1) as int;
    }
    return '$value';
  }

  double get total {
    var value = 0.0;
    for (Map<String, dynamic> product in mapProductList) {
      value = value +
          ((product['quantity'] ?? 1) *
              (double.tryParse(product['unit_price'].toString()) ?? 0));
    }
    return value;
  }

  double get totalPayable {
    var value = 0.0;
    for (Map<String, dynamic> product in mapProductList) {
      value = value +
          ((product['quantity'] ?? 1) *
              (double.tryParse(product['unit_price'].toString()) ?? 0));
    }

    return value - calDiscount + calTax + (initData['shipping_charges'] ?? 0.0);
  }

  double get calDiscount {
    if (discountType == 'fixed') {
      return discount;
    } else {
      return (total * discount / 100).truncateToDouble();
    }
  }

  double get calTax {
    return (total - calDiscount) * tax / 100;
  }

  Map<String, dynamic> initData = {};
  final FlutterBlue _flutterBlue = FlutterBlue.instance;

  String? filter = 'all';

  bool _required(List<String> keys, List<String> messages) {
    bool valid = true;
    int id = 0;
    for (int i = 0; i < keys.length; i++) {
      if (initData[keys[i]] == null) {
        id = i;
        valid = false;
      }
    }
    if (!valid) {
      Fluttertoast.showToast(msg: messages[id]);
    }
    return valid;
  }

  bool _keyRequired(String key, List<String> keys, List<String> messages) {
    bool valid = true;
    int id = 0;
    if ((initData[key] as List<dynamic>).isEmpty) {
      Fluttertoast.showToast(msg: 'Add/Select at least one $key');
      return false;
    }
    for (int j = 0; j < initData[key].length; j++) {
      for (int i = 0; i < keys.length; i++) {
        if (initData[key][j][keys[i]] == null) {
          id = i;
          valid = false;
        }
      }
    }
    if (!valid) {
      Fluttertoast.showToast(msg: messages[id]);
    }
    return valid;
  }

  var _isInit = true;
  var id, amount, account, note;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _isInit = false;

      try {
        List<dynamic>? list =
            ModalRoute.of(context)!.settings.arguments as List<dynamic>?;
        if (list != null && list.first != null) {
          initData = Map.from(list.first as Map<String, dynamic>);
          for (var map in initData['products']) {
            mapProductList.add(map as Map<String, dynamic>);
          }
        }
      } catch (e) {}
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop: () async {
        bool pop = false;
        if (mapProductList.isNotEmpty) {
          await showDialog<void>(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext ctx) {
                return AlertDialog(
                  title: const Text('Cancel Transaction'),
                  content: const Text(
                      'Are you sure to cancel this transaction and exit?'),
                  actions: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          pop = false;
                        },
                        child: const Text('no')),
                    ElevatedButton(
                        onPressed: () {
                          cancel();

                          Navigator.of(ctx).pop();
                          pop = true;
                        },
                        child: const Text('yes')),
                  ],
                );
              });
        } else {
          cancel();
          return true;
        }
        return pop;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('POS'),
          actions: [
            TextButton(
                onPressed: () {
                  if (mapProductList.isNotEmpty) {
                    showDialog<void>(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext ctx) {
                          return AlertDialog(
                            title: const Text('Cancel Transaction'),
                            content: const Text(
                                'Are you sure to cancel this transaction?'),
                            actions: [
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                  },
                                  child: const Text('no')),
                              ElevatedButton(
                                  onPressed: () {
                                    cancel();
                                    Navigator.of(ctx).pop();
                                  },
                                  child: const Text('yes')),
                            ],
                          );
                        });
                  } else {
                    cancel();
                  }
                },
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.white))),
            TextButton(
                onPressed: () async {
                  var ck = await _check();
                  if (ck) {
                    save();
                    setState(() {
                      uploading=true;
                    });
                    upload();
                  }
                },
                child:
                    //Text(id != null ? "Update Expense" : "Add new Expense"))
                    const Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                )),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context).pushNamed(AppSettings.routeName);
              },
            )
          ],
        ),
        drawer: const AppDrawer(),
        body: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: uploading?const Center(
              child: CircularProgressIndicator(),
            ):Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              BorderRow(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Consumer<CustomerProvider>(
                                        builder: (ctx, customers, _) {
                                          return Autocomplete<
                                              Map<String, dynamic>>(
                                            displayStringForOption: (map) =>
                                                map['name'],
                                            onSelected: (map) {
                                              setState(() {
                                                initData['contact_id'] =
                                                    map['id'];
                                              });
                                            },
                                            optionsBuilder: (v) {
                                              if (v.text == '') {
                                                return [];
                                              }
                                              return customers.mapData.where(
                                                  (element) => element['name']
                                                      .toString()
                                                      .toLowerCase()
                                                      .contains(v.text
                                                          .toLowerCase()));
                                            },
                                            fieldViewBuilder: (context,
                                                controller,
                                                focusNode,
                                                onSubmitted) {
                                              if (controller.text.isEmpty) {
                                                controller.text = customers
                                                        .mapData
                                                        .firstWhere(
                                                            (element) =>
                                                                element['id'] ==
                                                                initData[
                                                                    'contact_id'],
                                                            orElse: () =>
                                                                {})['name'] ??
                                                    '';
                                              }
                                              return TextFormField(
                                                focusNode: focusNode,
                                                controller: controller,
                                                decoration:
                                                    const InputDecoration(
                                                        border:
                                                            InputBorder.none),
                                                onFieldSubmitted: (v) =>
                                                    onSubmitted,
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    Container(
                                      decoration: const BoxDecoration(
                                          border: Border.symmetric(
                                              vertical: BorderSide(
                                                  width: 0.4,
                                                  color: Colors.grey,
                                                  style: BorderStyle.solid))),
                                      child: IconButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context, AddContact.routeName);
                                        },
                                        icon: const Icon(
                                          Icons.add,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                icon: const Icon(
                                  Icons.person_rounded,
                                  color: Colors.grey,
                                ),
                              ),
                              const Divider(),
                              BorderRow(
                                child: Consumer<LocationProvider>(
                                  builder: (ctx, provider, _) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        FittedBox(
                                          child: DropdownButton(
                                              //icon: const Icon(Icons.contact_support),
                                              value: initData['location_id'],
                                              underline: null,
                                              onChanged: (v) async{
                                                initData['location_id'] = v!;

                                                await getStocks();
                                                setState(() {
                                                });
                                              },
                                              items:
                                                  getLocationsList(provider)),
                                        ),
                                        Container(
                                            decoration: const BoxDecoration(
                                                border: Border.symmetric(
                                                    vertical: BorderSide(
                                                        width: 0.4,
                                                        color: Colors.grey,
                                                        style: BorderStyle
                                                            .solid))),
                                            child: FittedBox(
                                              child: TextButton(
                                                  onPressed: () {
                                                    _selectSellDate();
                                                  },
                                                  child: Text(initData[
                                                          'transaction_date'] ??
                                                      DateFormat("y-M-d HH:mm")
                                                          .format(
                                                              DateTime.now()))),
                                            ))
                                      ],
                                    );
                                  },
                                ),
                                icon: const Icon(
                                  Icons.location_city_outlined,
                                  color: Colors.grey,
                                ),
                              ),
                              const Divider(),
                              // BorderRow(
                              //     icon: const Icon(
                              //       Icons.money_rounded,
                              //       color: Colors.grey,
                              //     ),
                              //     child: Consumer<SellingGroupProvider>(
                              //       builder: (ctx, provider, _) {
                              //         return DropdownButton(
                              //             //icon: const Icon(Icons.contact_support),
                              //             value: initData[
                              //                 'selling_price_group_id'],
                              //             underline: null,
                              //             hint: const Text(
                              //               'Select',
                              //               textAlign: TextAlign.end,
                              //             ),
                              //             onChanged: (v) {
                              //               initData['selling_price_group_id'] =
                              //                   v!;
                              //               setState(() {});
                              //             },
                              //             items: getSellingGroupList(provider));
                              //       },
                              //     )),
                              // const Divider(),
                              _searchWidget(context),
                              const Divider(),
                              BorderRow(
                                icon: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        filter = 'all';
                                      });
                                    },
                                    child: const Text('Show All')),
                                child: Consumer<ProductCategoryProvider>(
                                  builder: (ctx, data, _) {
                                    return Autocomplete<Map<String, dynamic>>(
                                      displayStringForOption: (map) =>
                                          map['name'],
                                      onSelected: (map) {
                                        setState(() {
                                          filter = map['name'];
                                        });
                                      },
                                      optionsBuilder: (v) {
                                        if (v.text == '') {
                                          return [];
                                        }
                                        return data.mapData.where((element) =>
                                            element['name']
                                                .toString()
                                                .toLowerCase()
                                                .contains(
                                                    v.text.toLowerCase()));
                                      },
                                      fieldViewBuilder: (context, controller,
                                          focusNode, onSubmitted) {
                                        if (controller.text.isEmpty) {
                                          controller.text = 'all';
                                        }
                                        return TextFormField(
                                          focusNode: focusNode,
                                          controller: controller,
                                          decoration: const InputDecoration(
                                              border: InputBorder.none),
                                          onFieldSubmitted: (v) => onSubmitted,
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              if(initData['location_id']==null)
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Please select location to get current stock',style: TextStyle(color: Colors.redAccent,fontWeight: FontWeight.w100),),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  height: 800.0,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  width: MediaQuery.of(context).size.width,
                                  child: Consumer<ProductsProvider>(
                                    builder: (ctx, products, _) =>
                                        _grids(products.mapData),
                                  ),
                                ),
                              ),
                              const Divider(),
                              SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: _showProductList())
                            ],
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.all(8.0),
                          shape: const RoundedRectangleBorder(),
                          elevation: 4.0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Items: ' + items),
                                      Text(
                                          'Total: ' + total.toStringAsFixed(2)),
                                      Text('Total Payable: ' +
                                          totalPayable.toStringAsFixed(2)),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextButton(
                                            onPressed: () {
                                              var controller =
                                                  TextEditingController();
                                              var dtype = discountType;
                                              controller.text =
                                                  discount.toString();
                                              showDialog<void>(
                                                context: context,
                                                barrierDismissible: true,
                                                // false = user must tap button, true = tap outside dialog
                                                builder: (BuildContext
                                                    dialogContext) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Edit Discount'),
                                                    content: StatefulBuilder(
                                                      builder: (ctx, st) {
                                                        return Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            SizedBox(
                                                              width:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                              child: Autocomplete<
                                                                  Map<String,
                                                                      dynamic>>(
                                                                optionsBuilder:
                                                                    (c) {
                                                                  if (c.text
                                                                      .isEmpty) {
                                                                    return [];
                                                                  }
                                                                  return discounts
                                                                      .where((element) => element[
                                                                              'name']
                                                                          .toString()
                                                                          .toLowerCase()
                                                                          .contains(c
                                                                              .text
                                                                              .toLowerCase()))
                                                                      .toList();
                                                                },
                                                                onSelected:
                                                                    (map) {
                                                                  dtype = map[
                                                                      'value'];
                                                                },
                                                                displayStringForOption:
                                                                    (m) => m[
                                                                        'name'],
                                                                fieldViewBuilder:
                                                                    (ctx,
                                                                        ctrlr,
                                                                        focus,
                                                                        onSubmit) {
                                                                  if (ctrlr.text
                                                                      .isEmpty) {
                                                                    ctrlr.text = discountType.replaceRange(
                                                                        0,
                                                                        1,
                                                                        discountType
                                                                            .substring(0,
                                                                                1)
                                                                            .toUpperCase());
                                                                  }
                                                                  return TextFormField(
                                                                    controller:
                                                                        ctrlr,
                                                                    onFieldSubmitted:
                                                                        (v) =>
                                                                            onSubmit,
                                                                    decoration: const InputDecoration(
                                                                        border: InputBorder
                                                                            .none,
                                                                        hintText:
                                                                            'Enter discount type'),
                                                                    focusNode:
                                                                        focus,
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                            TextField(
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              controller:
                                                                  controller,
                                                              decoration:
                                                                  const InputDecoration(
                                                                labelText:
                                                                    'Discount amount',
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        child: const Text(
                                                            'Cancel'),
                                                        onPressed: () {
                                                          Navigator.of(
                                                                  dialogContext)
                                                              .pop(); // Dismiss alert dialog
                                                        },
                                                      ),
                                                      TextButton(
                                                        child: const Text(
                                                            'Update'),
                                                        onPressed: () {
                                                          Navigator.of(
                                                                  dialogContext)
                                                              .pop(); // Dismiss alert dialog

                                                          setState(() {
                                                            discountType =
                                                                dtype;

                                                            discount =
                                                                double.tryParse(
                                                                        controller
                                                                            .text) ??
                                                                    discount;
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            child: Text('Discount(-): ' +
                                                calDiscount
                                                    .toStringAsFixed(2))),
                                        TextButton(
                                          onPressed: () {
                                            var taxId;

                                            final controller =
                                                TextEditingController();
                                            showDialog<void>(
                                              context: context,
                                              barrierDismissible: true,
                                              // false = user must tap button, true = tap outside dialog
                                              builder:
                                                  (BuildContext dialogContext) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      'Edit Order Tax'),
                                                  content: StatefulBuilder(
                                                      builder: (ctx, st) {
                                                    return Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      child: BorderRow(
                                                        icon: const Icon(Icons
                                                            .info_outlined),
                                                        child: Consumer<
                                                            TaxProvider>(
                                                          builder:
                                                              (ctx, taxP, _) {
                                                            return Autocomplete<
                                                                Map<String,
                                                                    dynamic>>(
                                                              displayStringForOption:
                                                                  (map) => map[
                                                                      'name'],
                                                              onSelected:
                                                                  (map) {
                                                                setState(() {
                                                                  taxId =
                                                                      map['id'];
                                                                });
                                                              },
                                                              optionsBuilder:
                                                                  (v) {
                                                                if (v.text ==
                                                                    '') {
                                                                  return [];
                                                                }
                                                                return taxP.mapData.where((element) => element[
                                                                        'name']
                                                                    .toString()
                                                                    .toLowerCase()
                                                                    .contains(v
                                                                        .text
                                                                        .toLowerCase()));
                                                              },
                                                              fieldViewBuilder:
                                                                  (context,
                                                                      controller,
                                                                      focusNode,
                                                                      onSubmitted) {
                                                                if (controller
                                                                    .text
                                                                    .isEmpty) {
                                                                  controller
                                                                          .text =
                                                                      taxName;
                                                                }
                                                                return TextFormField(
                                                                  focusNode:
                                                                      focusNode,
                                                                  controller:
                                                                      controller,
                                                                  decoration:
                                                                      const InputDecoration(
                                                                          border:
                                                                              InputBorder.none),
                                                                  onFieldSubmitted:
                                                                      (v) =>
                                                                          onSubmitted,
                                                                );
                                                              },
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child:
                                                          const Text('Update'),
                                                      onPressed: () {
                                                        if (taxId != null) {
                                                          var taxMaps =
                                                              Provider.of<TaxProvider>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .mapData;
                                                          Map<String, dynamic>?
                                                              taxMap =
                                                              taxMaps.firstWhere(
                                                                  (element) =>
                                                                      element[
                                                                          'id'] ==
                                                                      taxId);

                                                          initData['tax_rate_id']=taxMap['id'];
                                                          setState(() {
                                                            taxName =
                                                                taxMap['name'];

                                                            tax = double.tryParse(
                                                                    taxMap['amount']
                                                                        .toString()) ??
                                                                tax;
                                                          });
                                                        }
                                                        Navigator.of(
                                                                dialogContext)
                                                            .pop();
                                                        // Dismiss alert dialog
                                                      },
                                                    ),
                                                    TextButton(
                                                      child:
                                                          const Text('Cancel'),
                                                      onPressed: () {
                                                        Navigator.of(
                                                                dialogContext)
                                                            .pop(); // Dismiss alert dialog
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: Text('Order Tax(+): ' +
                                              calTax.toStringAsFixed(2)),
                                        ),
                                        TextButton(
                                            onPressed: () {
                                              TextEditingController _sDetail =
                                                  TextEditingController();
                                              TextEditingController _sAddress =
                                                  TextEditingController();
                                              TextEditingController _sCharges =
                                                  TextEditingController();
                                              TextEditingController
                                                  _sDeliverTo =
                                                  TextEditingController();

                                              _sDetail.text = initData[
                                                      'shipping_details'] ??
                                                  '';
                                              _sAddress.text = initData[
                                                      'shipping_address'] ??
                                                  '';
                                              _sCharges.text =
                                                  '${initData['shipping_charges'] ?? 0.0}';
                                              _sDeliverTo.text =
                                                  initData['delivered_to'] ??
                                                      '';
                                              var _sStatus =
                                                  initData['shipping_status'];

                                              showDialog<void>(
                                                context: context,
                                                barrierDismissible: true,
                                                // false = user must tap button, true = tap outside dialog
                                                builder: (BuildContext
                                                    dialogContext) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Edit Order Tax'),
                                                    content: StatefulBuilder(
                                                        builder: (ctx, st) {
                                                      return SizedBox(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.4,
                                                        child:
                                                            SingleChildScrollView(
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              TextField(
                                                                controller:
                                                                    _sDetail,
                                                                keyboardType:
                                                                    TextInputType
                                                                        .multiline,
                                                                decoration:
                                                                    const InputDecoration(
                                                                  labelText:
                                                                      'Shipping Detail',
                                                                  border:
                                                                      OutlineInputBorder(),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 10.0,
                                                              ),
                                                              TextField(
                                                                keyboardType:
                                                                    TextInputType
                                                                        .multiline,
                                                                controller:
                                                                    _sAddress,
                                                                decoration:
                                                                    const InputDecoration(
                                                                  labelText:
                                                                      'Shipping Address',
                                                                  border:
                                                                      OutlineInputBorder(),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 10.0,
                                                              ),
                                                              TextField(
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                controller:
                                                                    _sCharges,
                                                                decoration:
                                                                    const InputDecoration(
                                                                  labelText:
                                                                      'Shipping Charge',
                                                                  border:
                                                                      OutlineInputBorder(),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 10.0,
                                                              ),
                                                              TextField(
                                                                keyboardType:
                                                                    TextInputType
                                                                        .text,
                                                                controller:
                                                                    _sDeliverTo,
                                                                decoration:
                                                                    const InputDecoration(
                                                                  labelText:
                                                                      'Deliver To',
                                                                  border:
                                                                      OutlineInputBorder(),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 10.0,
                                                              ),
                                                              CustomRow(
                                                                  borderStyle:
                                                                      BorderStyle
                                                                          .solid,
                                                                  icon:
                                                                      const Text(
                                                                    'Shipping Status: ',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            8.0),
                                                                    child: Autocomplete<
                                                                        Map<String,
                                                                            dynamic>>(
                                                                      displayStringForOption:
                                                                          (map) =>
                                                                              map['name'],
                                                                      onSelected:
                                                                          (map) {
                                                                        setState(
                                                                            () {
                                                                          _sStatus =
                                                                              map['value'];
                                                                        });
                                                                      },
                                                                      optionsBuilder:
                                                                          (v) {
                                                                        if (v.text ==
                                                                            '') {
                                                                          return [];
                                                                        }
                                                                        return shippingStatuse.where((element) => element['name']
                                                                            .toString()
                                                                            .toLowerCase()
                                                                            .contains(v.text.toLowerCase()));
                                                                      },
                                                                      fieldViewBuilder: (context,
                                                                          controller,
                                                                          focusNode,
                                                                          onSubmitted) {
                                                                        if (controller
                                                                            .text
                                                                            .isEmpty) {
                                                                          controller.text =
                                                                              '${initData['shipping_status']}';
                                                                        }
                                                                        return TextFormField(
                                                                          focusNode:
                                                                              focusNode,
                                                                          controller:
                                                                              controller,
                                                                          decoration:
                                                                              const InputDecoration(border: InputBorder.none),
                                                                          onFieldSubmitted: (v) =>
                                                                              onSubmitted,
                                                                        );
                                                                      },
                                                                    ),
                                                                  )),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        child: const Text(
                                                            'Update'),
                                                        onPressed: () {
                                                          initData[
                                                                  'shipping_details'] =
                                                              _sDetail.text;
                                                          initData[
                                                                  'shipping_address'] =
                                                              _sAddress.text;


                                                          initData[
                                                              'shipping_charges'] = double
                                                                  .tryParse(
                                                                      _sCharges
                                                                          .text) ??
                                                              initData[
                                                                  'shipping_charges'];



                                                          initData[
                                                                  'delivered_to'] =
                                                              _sDeliverTo.text;
                                                          initData[
                                                                  'shipping_status'] =
                                                              _sStatus;
                                                          setState(() {});
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                      TextButton(
                                                        child: const Text(
                                                            'Cancel'),
                                                        onPressed: () {
                                                          Navigator.of(
                                                                  dialogContext)
                                                              .pop(); // Dismiss alert dialog
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            child: Text('Shipping(+): ' +
                                                (initData['shipping_charges'] ??
                                                        0.0)
                                                    .toStringAsFixed(2))),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CustomButton(
                              child: Consumer<PaymentMethodsProvider>(
                                builder: (ctx, provider, _) {
                                  return DropdownButton(
                                      underline: null,
                                      hint: const Text('Payment Methods'),
                                      value: initData['method'],
                                      onChanged: (v) {
                                        initData['method'] = v;
                                        setState(() {});
                                      },
                                      items: methodList(provider));
                                },
                              ),
                            ),
                          ),
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  var ck = await _check();
                                  if (!ck) {
                                    return;
                                  }
                                  setState(() {
                                    _printing = true;
                                  });
                                  try {
                                    save();
                                    Fluttertoast.showToast(msg: 'printing');
                                    setState(() {
                                      uploading=true;
                                    });
                                    var list = await genInvoice();
                                    var pdf = await printPDF(list);
                                    pdfShare(pdf.path);

                                    upload();
                                  } catch (e) {
                                    Fluttertoast.showToast(msg: e.toString());
                                  }

                                  setState(() {
                                    _printing = false;
                                  });
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.share),
                                    SizedBox(width: 5.0),
                                    Text('Share PDF'),
                                  ],
                                ),
                              ),
                              _printing
                                  ? const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(),
                                    )
                                  : ElevatedButton(
                                      onPressed: printReceipt,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(Icons.print),
                                          SizedBox(
                                            width: 5.0,
                                          ),
                                          Text('Pay & Print')
                                        ],
                                      ))
                            ],
                          ),
                        ),
                        const Divider(),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 2.0,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24.0),
                          topRight: Radius.circular(24.0))),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomButton(
                          color: Colors.cyan,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Total Payable: ' +
                                  totalPayable.toStringAsFixed(2),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.of(context)
                                .pushNamed(PosAllScreen.routeName);
                          },
                          child: const Text(
                            'Recent Transactions',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  final discounts = [
    {'name': 'Fixed', 'value': 'fixed'},
    {'name': 'Percentage', 'value': 'percentage'}
  ];
  final shippingStatuse = [
    {
      'name': 'Ordered',
      'value': 'ordered',
    },
    {
      'name': 'Packed',
      'value': 'packed',
    },
    {
      'name': 'Shipped',
      'value': 'shipped',
    },
    {
      'name': 'Delivered',
      'value': 'delivered',
    },
    {
      'name': 'Cancelled',
      'value': 'cancelled',
    }
  ];

  DefaultPrinters defaultPrinter = DefaultPrinters.pdfSave;

  bool _printing = false;

  printReceipt() async {

    var ck = await _check();
    if (!ck) {
      return;
    }
    save();

    setState(() {
      uploading=true;
      _printing = true;
    });
    final pref = await SharedPreferences.getInstance();
    if (pref.getString('settings_printer') != null) {
      defaultPrinter = DefaultPrinters
          .values[int.tryParse(pref.getString('settings_printer') ?? '0') ?? 0];
    }

    try {
      switch (defaultPrinter) {
        case DefaultPrinters.cs30:
          var list = await genInvoiceSDK();
          //var pdf = await printPDF(list);
          printSDKOne(list);
          break;
        case DefaultPrinters.cs10:
          var list = await genInvoiceSDK();

          printSDKTwo(list);
          break;
        case DefaultPrinters.bluetooth:
          Fluttertoast.showToast(msg: 'printing');
          if (!mounted) {
            return;
          }

          var on = await _flutterBlue.isOn;

          if (!on) {
            setState(() {
              _printing = false;
            });
            Fluttertoast.showToast(
                msg: 'please turn on bluetooth and location');
            return;
          }

          var blu = await Permission.bluetooth.status;
          if (blu.isDenied) {
            await Permission.bluetooth.request();
          }
          var location = await Permission.location.status;
          if (location.isDenied) {
            await Permission.location.request();
          }
          PrinterBluetooth? _bluetoothDevice = await getPrinterBlu();
          if (_bluetoothDevice == null) {
            Navigator.of(context).pushNamed(BluetoothScreen.routeName);
            return;
          }
          final pm = PrinterBluetoothManager();

          pm.selectPrinter(_bluetoothDevice);
          final result = await pm.printTicket(await printBluetooth());
          Fluttertoast.showToast(msg: result.msg);
          break;
        case DefaultPrinters.pdfShare:
          Fluttertoast.showToast(msg: 'printing');
          var list = await genInvoice();
          var pdf = await printPDF(list);
          pdfShare(pdf.path);
          break;
        case DefaultPrinters.pdfSave:
        default:
          Fluttertoast.showToast(msg: 'printing');
          var list =await  genInvoice();
          var pdf = await printPDF(list);
          Fluttertoast.showToast(msg: 'saved successfully');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }

    upload();
    setState(() {
      _printing = false;
    });
  }

  void _selectSellDate() async {
    final date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1950),
        lastDate: DateTime.now());
    if (date != null) {
      final sdate = DateFormat("y-M-d").format(date);
      final time = await showTimePicker(
        context: context,
        builder: (ctx, child) {
          return MediaQuery(
              data:
                  MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child!);
        },
        initialTime: TimeOfDay.now(),
      );
      var stime = (TimeOfDay.now().hour.toString() +
              ':' +
              TimeOfDay.now().minute.toString() +
              ':' +
              '0')
          .toString();
      if (time != null) {
        stime =
            (time.hour.toString() + ':' + time.minute.toString() + ':' + '0')
                .toString();
      }
      initData['transaction_date'] = sdate + " " + stime;
      setState(() {});
    }
  }

  _searchWidget(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
              width: 0.5, color: Colors.grey, style: BorderStyle.solid)),
      child: PosSearch(scan: _scan, search: _search),
    );
  }

  void _search() async {
    var result = await showSearch(
        context: context,
        delegate: SearchPage<Map<String, dynamic>>(
          items: Provider.of<ProductsProvider>(context, listen: false).mapData,
          searchLabel: 'Enter product name or sku',
          suggestion: const Center(
            child: Text('Start entering product name or sku'),
          ),
          failure: const Center(
            child: Text('Product not found'),
          ),
          filter: (m) {
            return [m['sku'], m['name']];
          },
          builder: (m) => ListTile(
            onTap: () {
              Navigator.pop(context);
              addProductList(m);
            },
            trailing: Text(m['sku'] ?? 'unknown'),
            title: Text(m['name'] ?? 'unknown'),
            leading: m['image_url'] != null
                ? SizedBox(
                    width: 78.0,
                    child: Consumer<ProductsProvider>(
                      builder: (ctx, snapshot, _) {
                        return FadeInImage(
                            placeholder: const AssetImage(placeholder),
                            image: FileImage(
                                File(snapshot.images[m['image_url']])));
                      },
                    ),
                  )
                : Container(),
          ),
        ));
  }

  Widget _showProductList() {
    var size = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            SizedBox(
              width: size.width * (0.3),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Product',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(
              width: size.width * (0.3),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Quantity',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(
              width: size.width * (0.2),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Subtotal',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        Column(
          children: mapProductList
              .map((e) => _productListUnit(mapProductList.indexOf(e)))
              .toList(),
        ),
      ],
    );
  }

  int min = -1;

  Widget _productListUnit(index) {
    var size = MediaQuery.of(context).size;
    return Card(
      margin: const EdgeInsets.all(4.0),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            SizedBox(
              width: size.width * (0.3),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  mapProductList[index]['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(
              width: size.width * (0.3),
              child: Column(
                children: [
                  CustomRow(
                    borderStyle: BorderStyle.solid,
                    child: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints c2) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: c2.maxWidth * 0.25,
                              child: InkWell(
                                child: const Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Icon(
                                    Icons.remove,
                                    size: 16.0,
                                  ),
                                ),
                                onTap: () {
                                  if (mapProductList[index]['quantity'] ==
                                      null) {
                                    mapProductList[index]['quantity'] = 0;
                                  }
                                  mapProductList[index]['quantity'] = math.max(
                                      (mapProductList[index]['quantity']
                                              as int) -
                                          1,
                                      0);
                                  final product=mapProductList.elementAt(index);

                                  changeStocks(product, 1);
                                  setState(() {});
                                  if (mapProductList[index]['quantity'] == 0) {
                                    mapProductList.removeAt(index);
                                  }


                                },
                              ),
                            ),
                            SizedBox(
                              width: c2.maxWidth * 0.5,
                              child: Container(
                                margin: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.0)),
                                child: Text(
                                  '${mapProductList[index]['quantity']}',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: c2.maxWidth * 0.25,
                              child: InkWell(
                                child: const Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Icon(Icons.add,
                                      size: 16.0, color: Colors.green),
                                ),
                                onTap: () {
                                  if (mapProductList[index]['quantity'] ==
                                      null) {
                                    mapProductList[index]['quantity'] = 1;
                                  } else {
                                    mapProductList[index]['quantity'] =
                                        math.max(
                                            (mapProductList[index]['quantity']
                                                    as int) +
                                                1,
                                            0);
                                  }
                                  final product=mapProductList.elementAt(index);
                                  changeStocks(product, -1);
                                  setState(() {});
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  CustomRow(
                    borderStyle: BorderStyle.solid,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          mapProductList[index]['unit'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        InkWell(
                            onTap: () {

                              final product=mapProductList.elementAt(index);
                              changeStocks(product, product['quantity']??0);
                              setState(() {
                                mapProductList.removeAt(index);
                              });
                            },
                            child: const Icon(
                              Icons.clear_outlined,
                              color: Colors.red,
                            ))
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              width: size.width * (0.2),
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    getSubTotal(
                      index,
                      mapProductList[index]['quantity'] ?? 0,
                      mapProductList[index]['unit_price'] ?? 0,
                      discount,
                      discountType,
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  String getSubTotal(index, qty0, price0, discount0, type) {
    var qty = double.tryParse(qty0.toString()) ?? 0.0;
    var price = double.tryParse(price0.toString()) ?? 0.0;
    var discount = double.tryParse(discount0.toString()) ?? 0.0;

    if (type.toString().contains('percentage')) {
      price = price - (discount * price / 100);
    } else {
      price = price - (discount);
    }
    var v = qty * price;

    return v.toStringAsFixed(2);
  }

  void _scan() async {
    String res = await FlutterBarcodeScanner.scanBarcode(
        '#ffffff', 'cancel', true, barcode.ScanMode.DEFAULT);
    if (res.isNotEmpty) {
      final product = Provider.of<ProductsProvider>(context, listen: false)
          .mapData
          .firstWhere(
              (element) =>
                  element['sku'].toString().toLowerCase() == res.toLowerCase(),
              orElse: () => {});
      if (product.isNotEmpty) {
        addProductList(product);
        return;
      }
    }
    Fluttertoast.showToast(msg: 'Invalid barcode or sku not found');
  }

  var list = [];

  _grids(products) {
    list.clear();
    list.addAll(products);

    if (filter != 'all') {
      list.removeWhere((product) =>
          product['category'] == null || product['category']?['name'] == null);
      list.removeWhere((product) => !product['category']['name']
          .toString()
          .toLowerCase()
          .contains(filter.toString().toLowerCase()));
    }

    return list.isEmpty
        ? const Center(
            child: Text(
              'Products not available with this category',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          )
        : GridView.builder(
            scrollDirection: Axis.horizontal,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              mainAxisExtent: 150.0,
            ),
            itemBuilder: (ctx, index) {
              return gridItem(list[index]);
            },
            itemCount: list.length,
          );
  }

  Widget gridItem(Map<String, dynamic> product) {
    return CustomRow(
      child: InkWell(
        onTap: () {
          addProductList(product);
        },
        child: SizedBox(
          width: 150.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomButton(
                child: Center(
                  child: Text(
                    'Ksh.${format.format(double.tryParse(product['product_variations']?[0]?['variations']?[0]?['default_sell_price']) ?? 0.0)}',
                    style: const TextStyle(fontWeight: FontWeight.w500,color: Colors.lightGreen,),
                  ),
                ),
              ),
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Consumer<ProductsProvider>(
                      builder: (ctx, snapshot, _) {
                        if (snapshot.images[product['image_url']] != null) {
                          return FadeInImage(
                            height: 120.0,
                              placeholder: const AssetImage(placeholder),
                              image: FileImage(
                                  File(snapshot.images[product['image_url']])));
                        }

                        return const FadeInImage(
                          placeholder: AssetImage(placeholder),
                          image: AssetImage(placeholder),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 4.0,
                    child: Center(
                  child: FittedBox(
                    child: CustomButton(
                      color: Colors.white,
                      child: Text(
                        product['name'],
                        style: const TextStyle(color: Colors.cyan,fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  ),
                  )
                ],
              ),

              Center(
                child: FittedBox(
                  child: Text(
                    '(${Provider.of<ProductsProvider>(context, listen: false).getCurrentStock(product['sku'])})',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12.0,color: Colors.cyan,),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  int maxChars = 60;
  int maxCharsCol1 = 3;
  int maxCharsCol2 = 15;
  int maxCharsCol3 = 5;
  int maxCharsCol4 = 15;
  int maxCharsCol5 = 15;
  var discount = 0.0;
  var tax = 0.0;
  var taxPercent = 0.0;
  var taxName = 'vat';

  Future<List<pw.Widget>> genInvoice() async{
    if (initData['invoice_no'] == null) {
      initData['invoice_no'] = await getInvoiceNum();
    }

    final supplier = Provider.of<SupplierProvider>(context, listen: false);
    final customer = Provider.of<CustomerProvider>(context, listen: false);
    final contactsData = getMapContacts(supplier, customer);

    List<pw.Widget> posLines = [];
    posLines.addAll(sellInvoiceHead(
        Provider.of<HeadersFootersProvider>(context, listen: false).headers));

    //DATA START

    posLines.add(pw.Padding(
        padding: const pw.EdgeInsets.all(1.0),
        child: pw.Text('Receipt',
            textAlign: pw.TextAlign.left,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold))));

    posLines.add(pw.Padding(
        padding: const pw.EdgeInsets.all(1.0),
        child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Receipt No.'),
              pw.Text('Order ' + initData['invoice_no'].toString()),
            ])));
    posLines.add(pw.Padding(
        padding: const pw.EdgeInsets.all(1.0),
        child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Date'),
              pw.Text((initData['transaction_date'] ??
                      DateFormat('MM/dd/yyyy HH:mm').format(DateTime.now()))
                  .toString()),
            ])));
    posLines.add(pw.Padding(
        padding: const pw.EdgeInsets.all(1.0),
        child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Customer'),
              pw.Text(initData['contact_id'] == null
                  ? ''
                  : contactsData.elementAt(contactsData.indexWhere((element) =>
                          element['id'].toString() ==
                          initData['contact_id'].toString()))['name'] ??
                      ''),
            ])));
    posLines.add(pw.Divider());

    posLines.add(pw.Padding(
        padding: const pw.EdgeInsets.all(1.0),
        child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('#'),
              pw.SizedBox(width: 80.0, child: pw.Text('Product')),
              pw.Text('Quantity'),
              pw.Text('Unit price'),
              pw.Text('sub-total'),
            ])));
    posLines.add(pw.Divider());

    for (Map<String, dynamic> map in mapProductList) {
      posLines.add(pw.Padding(
          padding: const pw.EdgeInsets.all(1.0),
          child: pw.Column(children: [
            // pw.Row(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
            //
            // ]),
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text((mapProductList.indexOf(map) + 1).toString() + ' ',
                      textAlign: pw.TextAlign.center),
                  pw.SizedBox(
                      width: 80.0,
                      child: pw.Text(
                        map['name'].toString().substring(
                            0, math.min(map['name'].toString().length - 1, 20)),
                      )),
                  pw.Text(map['quantity'].toString(),
                      textAlign: pw.TextAlign.center),
                  pw.Text(
                      (double.tryParse(map['unit_price'].toString()) ?? 0.0)
                          .toStringAsFixed(2),
                      textAlign: pw.TextAlign.center),
                  pw.Text(
                      (getSubTotal(
                        0,
                        map['quantity'] ?? 0,
                        map['unit_price'] ?? 0,
                        discount,
                        discountType,
                      )),
                      textAlign: pw.TextAlign.center),
                ]),
            //           pw.Divider(),
          ])));
    }
    posLines.add(pw.Divider());

    posLines.add(pw.Padding(
        padding: const pw.EdgeInsets.all(1.0),
        child: pw.Align(
            alignment: pw.Alignment.bottomRight,
            child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text(''),
                ]))));
    posLines.add(pw.Padding(
        padding: const pw.EdgeInsets.all(1.0),
        child: pw.Align(
            alignment: pw.Alignment.bottomRight,
            child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text('Subtotal:  Ksh ' + (total).toStringAsFixed(2)),
                ]))));

    posLines.add(pw.Padding(
        padding: const pw.EdgeInsets.all(1.0),
        child: pw.Align(
            alignment: pw.Alignment.bottomRight,
            child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text(
                      'Discount:  -Ksh ' + (calDiscount).toStringAsFixed(2)),
                ]))));

    posLines.add(pw.Padding(
        padding: const pw.EdgeInsets.all(1.0),
        child: pw.Align(
            alignment: pw.Alignment.bottomRight,
            child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text(
                      'Tax($taxName):  +Ksh ' + (calTax).toStringAsFixed(2)),
                ]))));
    posLines.add(pw.Padding(
        padding: const pw.EdgeInsets.all(1.0),
        child: pw.Align(
            alignment: pw.Alignment.bottomRight,
            child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text('Shipping Charge:  +Ksh ' +
                      (initData['shipping_charges'] ?? 0.0).toStringAsFixed(2)),
                ]))));
    posLines.add(pw.Padding(
        padding: const pw.EdgeInsets.all(1.0),
        child: pw.Align(
            alignment: pw.Alignment.bottomRight,
            child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text(
                      'Total:  Ksh ' +
                          (total - calDiscount + calTax).toStringAsFixed(2),
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ]))));

    posLines.add(pw.Padding(
        padding: const pw.EdgeInsets.all(1.0),
        child: pw.Align(
            alignment: pw.Alignment.bottomRight,
            child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text('Payment Method: ${initData['method']}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ]))));

    //DATA END
    posLines.add(pw.Divider());

    posLines.addAll(sellInvoiceBottom(
        Provider.of<HeadersFootersProvider>(context, listen: false).footers));

    return posLines;
  }

  Future<List<POSLine>> genInvoiceSDK() async{
    if (initData['invoice_no'] == null) {
      initData['invoice_no'] = await getInvoiceNum();
    }

    final supplier = Provider.of<SupplierProvider>(context, listen: false);
    final customer = Provider.of<CustomerProvider>(context, listen: false);
    final contactsData = getMapContacts(supplier, customer);

    List<POSLine> posLines = [];
    posLines.addAll(sellInvoiceHeadSDK(
        Provider.of<HeadersFootersProvider>(context, listen: false).headers));

    //DATA STAR

    posLines.add(POSLine(
      col1: '',
      col2: '',
      col3: 'RECEIPT',
      col4: '',
      format: '%${math.max(1,((26-('RECEIPT').length)/2).toInt())}s %1s %-${math.max(1,math.min(28,((26-('RECEIPT').length)).toInt()))}s %1s %${math.max(1,((26-('RECEIPT').length)/2).toInt())}s ',
      col5: '',
      bold: true.toString(),
      font: fontLarge,
      bitmap: '',
    ));
    posLines.add(POSLine(
        col1: 'Receipt No.',
        col2: '',
        col3: '',
        col4: '',
        format: '%-1s %1s %1s %1s %-15s',
        col5: initData['invoice_no'].toString(),
        bold: false.toString(),
        font: 'small',
        bitmap: ''));

    posLines.add(POSLine(
        col1: 'Date',
        col2: '',
        col3: '',
        col4: '',
        format: '%-4s %1s %1s %1s %15s',
        col5: (initData['transaction_date'] ??
            DateFormat('MM/dd/yyyy HH:mm').format(DateTime.now()))
            .toString(),
        bold: false.toString(),
        font: 'small',
        bitmap: ''));

    posLines.add(POSLine(
        col1: 'Customer',
        col2: '',
        col3: '',
        col4: '',
        format: '%-1s %1s %1s %1s %-15s',
        col5: trim(initData['contact_id'] == null
            ? ''
            : contactsData.elementAt(contactsData.indexWhere((element) =>
        element['id'].toString() ==
            initData['contact_id'].toString()))['name'] ??
            ''),
        bold: false.toString(),
        font: 'small',
        bitmap: ''));

    posLines.add(POSLine(
        col1: '------------------------',
        col2: '',
        col3: '',
        col4: '',
        format: '%-24s %1s %1s %1s %1s',
        col5: '',
        bold: false.toString(),
        font: 'small',
        bitmap: ''));
    posLines.add(POSLine(
        col1: '',
        col2: '',
        col3: 'Qty',
        col4: 'price',
        format: '%-1s %-1s %-4s %10s %12s',
        col5: 'total',
        bold: false.toString(),
        font: 'small',
        bitmap: ''));
    posLines.add(POSLine(
        col1: '------------------------',
        col2: '',
        col3: '',
        col4: '',
        format: '%-24s %1s %1s %1s %1s',
        col5: '',
        bold: false.toString(),
        font: 'small',
        bitmap: ''));
    for (Map<String, dynamic> map in mapProductList) {
      posLines.add(POSLine(
          col1: (mapProductList.indexOf(map) + 1).toString(),
          col2: trim2(map['name']),
          col3: '',
          col4:'',
          format: '%-3s %-22s %-1s %1s %1s',
          col5:'',

          bold: false.toString(),
          font: 'small',
          bitmap: ''));

      posLines.add(POSLine(
          col1: '',
          col2: '',
          col3: map['quantity'].toString(),
          col4: (double.tryParse(map['unit_price'].toString()) ?? 0.0)
              .toStringAsFixed(2),
          format: '%-1s %-1s %-4s %10s %12s',
          col5:(getSubTotal(
            0,
            map['quantity'] ?? 0,
            map['unit_price'] ?? 0,
            discount,
            discountType,
          )),

          bold: false.toString(),
          font: 'small',
          bitmap: ''));
    }
    posLines.add(POSLine(
        col1: '------------------------',
        col2: '',
        col3: '',
        col4: '',
        format: '%-24s %1s %1s %1s %1s',
        col5: '',
        bold: false.toString(),
        font: 'small',
        bitmap: ''));
    posLines.add(POSLine(
        col1: ' ',
        col2: ' ',
        col3: ' ',
        col4: 'Subtotal:',
        format: '%-1s %1s %1s %-9s %16s',
        col5: 'Ksh ${(total).toStringAsFixed(2)}',
        bold: false.toString(),
        font: 'small',
        bitmap: ''));
    posLines.add(POSLine(
        col1: ' ',
        col2: ' ',
        col3: ' ',
        col4: 'Discount:',
        format: '%-1s %1s %1s %-10s %15s',
        col5: '-Ksh ${calDiscount.toStringAsFixed(2)}',
        bold: false.toString(),
        font: 'small',
        bitmap: ''));
    posLines.add(POSLine(
        col1: ' ',
        col2: ' ',
        col3: ' ',
        col4: 'Tax($taxName):',
        format: '%-1s %1s %1s %-10s %15s',
        col5: '+Ksh ${(calTax).toStringAsFixed(2)}',
        bold: false.toString(),
        font: 'small',
        bitmap: ''));

    // posLines.add(POSLine(
    //     col1: ' ',
    //     col2: ' ',
    //     col3: ' ',
    //     col4: 'Shipping Charge:',
    //     format: '%-4s %1s %1s %-15s %9s',
    //     col5:
    //     '+Ksh ${(initData['shipping_charges'] ?? 0.0).toStringAsFixed(2)}',
    //     bold: false.toString(),
    //     font: 'small',
    //     bitmap: ''));

    posLines.add(POSLine(
        col1: ' ',
        col2: ' ',
        col3: ' ',
        col4: 'Total:',
        format: '%-1s %1s %1s %-6s %19s',
        col5:
        '+Ksh ${(total - calDiscount + calTax).toStringAsFixed(2)}',
        bold: true.toString(),
        font: fontLarge,
        bitmap: ''));
    posLines.add(POSLine(
        col1: ' ',
        col2: ' ',
        col3: ' ',
        col4: 'Payment Method:',
        format: '%-1s %1s %1s %-15s %10s',
        col5: '${initData['method']}',
        bold: true.toString(),
        font: 'small',
        bitmap: ''));
    posLines.add(POSLine(
        col1: '------------------------',
        col2: '',
        col3: '',
        col4: '',
        format: '%-24s %1s %1s %1s %1s',
        col5: '',
        bold: false.toString(),
        font: 'small',
        bitmap: ''));
    posLines.addAll(sellInvoiceBottomSDK(
        Provider.of<HeadersFootersProvider>(context, listen: false).footers));

    return posLines;
  }

  double getDiscount(qty0, price0, discount0, type) {
    var qty = double.tryParse(qty0.toString()) ?? 0.0;
    var price = double.tryParse(price0.toString()) ?? 0.0;
    var discount = double.tryParse(discount0.toString()) ?? 0.0;

    if (type.toString().contains('percentage')) {
      discount = (discount * price / 100);
    }
    var v = qty * discount;

    return v;
  }

  var discountType = 'fixed';
  bool uploading=false;

  upload() async {
    // save();
    Map<String, dynamic> initData = {};

    initData = Map.from(this.initData);
    mapProductList.forEach((element) {
      setStocks(element);
    });


    initData.removeWhere((key, value) => value == null);
    var provider = Provider.of<SellProvider>(context, listen: false);
    var provider2 = Provider.of<PosProvider>(context, listen: false);

    if (initData['invoice_no'] == null) {
      initData['invoice_no'] = await getInvoiceNum();
    }
    initData['status'] = 'final';
    initData['tax'] = tax;
    initData['transaction_date'] = initData[
    'transaction_date'] ??
        DateFormat("y-M-d HH:mm")
            .format(
            DateTime.now());
    initData['discount'] = discount;
    initData['taxPercent'] = taxPercent;
    initData['taxName'] = taxName;
    initData['discountType'] = discountType;
    initData['total'] = total;
    initData['totalPayable'] = totalPayable;
    initData['round_off_amount'] = totalPayable;
    initData['calDiscount'] = calDiscount;
    initData['calTax'] = calTax;

    initData['final_total'] = totalPayable.toStringAsFixed(2);
    //initData['sell_price_inc_tax'] = totalPayable.toStringAsFixed(2);
    initData['unit_price_inc_tax'] = totalPayable.toStringAsFixed(2);
    {
      await provider.addDataData(initData);
      await provider2.addDataData(initData);
    }
    cancel();
  }

   save() async{
    final list = List.from(mapProductList);
    Map<String, dynamic> data = {};
    data.addAll(initData);

    initData['payments'] = [
      {
        'amount': totalPayable,
        'method': initData['method'],
        'account_id': account,
        'note': 'paid',
      }
    ];

    initData['products'] = list;
    if (initData['invoice_no'] == null) {
      initData['invoice_no'] = await getInvoiceNum();
    }
    setDefaults(data).then((value) => data.clear());

    setState(() {});
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  Future<List<int>> printBluetooth() async {
    if (initData['invoice_no'] == null) {
      initData['invoice_no'] = await getInvoiceNum();
    }
    final paper = PaperSize.mm58;
    final cProfile = await CapabilityProfile.load();
    final Generator ticket = Generator(paper, cProfile);
    List<int> bytes = [];
    //ticket.text(text);

    final supplier = Provider.of<SupplierProvider>(context, listen: false);
    final customer = Provider.of<CustomerProvider>(context, listen: false);
    final contactsData = getMapContacts(supplier, customer);

    bytes.addAll(await sellInvoiceHeadBlue(paper, cProfile,
        Provider.of<HeadersFootersProvider>(context, listen: false).headers));

    //DATA START
    bytes += ticket.text('Receipt',
        styles: const PosStyles(bold: true, align: PosAlign.left));

    bytes += ticket.row([
      PosColumn(
          text: 'Receipt No.',
          width: 6,
          styles: const PosStyles(bold: false, align: PosAlign.left)),
      PosColumn(
          text: 'Order ' + initData['invoice_no'].toString(),
          width: 6,
          styles: const PosStyles(bold: false, align: PosAlign.right)),
    ]);
    bytes += ticket.row([
      PosColumn(
          text: 'Date',
          width: 6,
          styles: const PosStyles(bold: false, align: PosAlign.left)),
      PosColumn(
          text: (initData['transaction_date'] ??
                  DateFormat('MM/dd/yyyy HH:mm').format(DateTime.now()))
              .toString(),
          width: 6,
          styles: const PosStyles(bold: false, align: PosAlign.right)),
    ]);

    bytes += ticket.row([
      PosColumn(
          text: 'Customer',
          width: 6,
          styles: const PosStyles(bold: false, align: PosAlign.left)),
      PosColumn(
          text: initData['contact_id'] == null
              ? ''
              : contactsData.elementAt(contactsData.indexWhere((element) =>
                      element['id'].toString() ==
                      initData['contact_id'].toString()))['name'] ??
                  '',
          width: 6,
          styles: const PosStyles(bold: false, align: PosAlign.right)),
    ]);
    bytes += ticket.hr(ch: '_');
    bytes += ticket.row([
      PosColumn(
          text: 'Quantity',
          width: 4,
          styles: const PosStyles(bold: false, align: PosAlign.center)),
      PosColumn(
          text: 'Unit price',
          width: 4,
          styles: const PosStyles(bold: false, align: PosAlign.center)),
      PosColumn(
          text: 'sub-total',
          width: 4,
          styles: const PosStyles(bold: false, align: PosAlign.center)),
    ]);
    bytes += ticket.hr(ch: '_');

    for (Map<String, dynamic> map in mapProductList) {
      bytes += ticket.row([
        PosColumn(
            text: '# ' + (mapProductList.indexOf(map) + 1).toString() + ' ',
            width: 3,
            styles: const PosStyles(bold: false, align: PosAlign.left)),
        PosColumn(
            text: map['name']
                .toString()
                .substring(0, math.min(map['name'].toString().length - 1, 20)),
            width: 9,
            styles: const PosStyles(bold: false, align: PosAlign.left)),
      ]);
      bytes += ticket.row([
        PosColumn(
            text: map['quantity'].toString(),
            width: 4,
            styles: const PosStyles(bold: false, align: PosAlign.center)),
        PosColumn(
            text: (double.tryParse(map['unit_price'].toString()) ?? 0.0)
                .toStringAsFixed(2),
            width: 4,
            styles: const PosStyles(bold: false, align: PosAlign.center)),
        PosColumn(
            text: (total).toStringAsFixed(2),
            width: 4,
            styles: const PosStyles(bold: false, align: PosAlign.center)),
      ]);
    }
    bytes += ticket.hr(ch: '_');

    bytes += ticket.text('Subtotal:  Ksh ' + (total).toStringAsFixed(2),
        styles: const PosStyles(bold: false, align: PosAlign.right));
    bytes += ticket.text('Discount:  -Ksh ' + (calDiscount).toStringAsFixed(2),
        styles: const PosStyles(bold: false, align: PosAlign.right));
    bytes += ticket.text('Tax($taxName):  +Ksh ' + (calTax).toStringAsFixed(2),
        styles: const PosStyles(bold: false, align: PosAlign.right));
    bytes += ticket.text(
        'Shipping Charge:  +Ksh ' +
            (initData['shipping_charges'] ?? 0.0).toStringAsFixed(2),
        styles: const PosStyles(bold: false, align: PosAlign.right));
    bytes += ticket.text(
        'Total:  Ksh ' + (total - calDiscount + calTax).toStringAsFixed(2),
        styles: const PosStyles(bold: false, align: PosAlign.right));

    bytes += ticket.text('Payment Method: ${initData['method']}',
        styles: const PosStyles(bold: false, align: PosAlign.right));
    bytes += ticket.hr(ch: '_');

    bytes.addAll(await sellInvoiceBottomBlue(paper, cProfile,
        Provider.of<HeadersFootersProvider>(context, listen: false).footers));
    bytes += ticket.feed(2);
    bytes += ticket.cut();

    return bytes;
  }

  Future<PrinterBluetooth?>? getPrinterBlu() async {
    final preferences = await SharedPreferences.getInstance();
    final _jd = preferences.getString('blue_device');
    if (_jd != null) {
      final _dev = basic.BluetoothDevice.fromJson(jsonDecode(_jd));
      return PrinterBluetooth(_dev);
    }
    return null;
  }

  cancel() async {
    Future.delayed(const Duration(milliseconds: 500)).whenComplete(() async {
      initData = await getDefaults();
      mapProductList.clear();
      setState(() {
        uploading=false;

      });
    });
  }

  Future<bool> _check() async {
    save();
    {
      if (_required(['location_id', 'contact_id', 'products'],
          ['Select Location', 'Select customer', 'add at least one product'])) {
        if (_keyRequired('products', [
          'product_id',
          'variation_id',
          'quantity'
        ], [
          'Invalid Product(error in id)',
          'Invalid Product(error in variation id)',
          'Invalid Product(error in quantity)'
        ])) {
          {
            bool pop = false;
            if (mapProductList.isNotEmpty) {
              await showDialog<void>(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext ctx) {
                    return AlertDialog(
                      title: const Text('Confirm'),
                      content: const Text(
                          'Are you sure to complete to transaction or go back and add more items'
                      ),
                      actions: [
                        ElevatedButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              pop = false;
                            },
                            child: const Text('no')),
                        ElevatedButton(
                            onPressed: () {
                            //  cancel();

                              Navigator.of(ctx).pop();
                              pop = true;
                            },
                            child: const Text('yes')),
                      ],
                    );
                  });
            } else {
             // cancel();
              return true;
            }
            return pop;
          }
        }
      }
    }
    return false;
  }

  List<DropdownMenuItem<int>> getSellingGroupList(
      SellingGroupProvider provider) {
    final list = getmapDataingGroups(provider).map((v) {
      return DropdownMenuItem(
        child: Text(v['name']),
        value: (v['id']) as int,
      );
    });

    return list.toSet().toList();
  }

  Future<String> setDefaults(Map<String, dynamic> initData) async {
    // initData['contact_id'] = 4;
    // initData['location_id'] = 4;
    // initData['method'] = 'cash';
    // initData['selling_price_group_id'] = 1;

    UniqueDatabase database = UniqueDatabase(tableName: posDefaultValuesTable);
    await database.addData({'data': jsonEncode({
    'contact_id':initData['contact_id'] ,
    'location_id':initData['location_id'] ,
    'method':initData['method'],
    'selling_price_group_id':initData['selling_price_group_id']

    })});
    return '';
  }

  Future<Map<String, dynamic>> getDefaults() async{
    Map<String, dynamic> m = {
  //    'contact_id': 4,
//      'location_id': 4,
      'method': 'cash',
  //    'selling_price_group_id': 1
    };
    UniqueDatabase database = UniqueDatabase(tableName: posDefaultValuesTable);
    final list = await database.getData();
    if (list.isEmpty) {
      return m;
    }
    return jsonDecode(list.last['data']);
    return m;
  }

  List<DropdownMenuItem<int>> getLocationsList(LocationProvider provider) {
    final list = getMapLocations(provider)
        .map((v) {
          return DropdownMenuItem(
            child: Text(v['name']),
            value: v['id'] as int,
          );
        })
        .toSet()
        .toList();

    return list;
  }

  List<Map<String, dynamic>> getMapLocations(LocationProvider provider) =>
      [...provider.mapData];

  List<DropdownMenuItem<String>> methodList(PaymentMethodsProvider provider) {
    List<DropdownMenuItem<String>> list = [];
    getMapMethods(provider).forEach((key, valu) {
      if (valu != null && list.length < 5) {
        var value = valu.toString();
        if (!list.contains(DropdownMenuItem(
          child: Text(value),
          value: key,
        ))) {
          list.add(DropdownMenuItem(
            child: Text(value),
            value: key,
          ));
        }
      }
    });
    return list;
  }

  Map<String, dynamic> getMapMethods(PaymentMethodsProvider provider) {
    return provider.mapData;
  }

  List<DropdownMenuItem<int>> accountsList(PaymentAccountProvider provider) {
    return getMapAccounts(provider)
        .map((v) {
          return DropdownMenuItem(
            child: Text(v['name']),
            value: v['id'] as int,
          );
        })
        .toSet()
        .toList();
  }

  List<Map<String, dynamic>> getMapAccounts(PaymentAccountProvider provider) {
    return [...provider.mapData.toSet().toList()];
  }

  List<DropdownMenuItem<int>> contactsList(
      SupplierProvider supplierProvider, CustomerProvider customerProvider) {
    return getMapContacts(supplierProvider, customerProvider)
        .map((v) {
          return DropdownMenuItem(
            child: Text(v['name']),
            value: v['id'] as int,
          );
        })
        .toSet()
        .toList();
  }

  List<Map<String, dynamic>> getMapContacts(
      SupplierProvider supplierProvider, CustomerProvider customerProvider) {
    var mlist = [];

    mlist.addAll(customerProvider.mapData);

    mlist.removeWhere((element) => element['id'] == null);
    return [...mlist.toSet().toList()];
  }

  List<Map<String, dynamic>> getmapDataingGroups(
          SellingGroupProvider provider) =>
      [...provider.mapData];

  void addProductList(Map<String, dynamic> product) {

    if(initData['location_id']==null){
      Fluttertoast.showToast(msg: 'Please select location id first to get stock details');
      return;
    }
    final stock=double.tryParse(Provider.of<ProductsProvider>(context, listen: false).getCurrentStock(product['sku']).toString())??0.0;
    if(stock<=0){
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(seconds: 1),
        dismissDirection: DismissDirection.startToEnd,
        content: Text('Selected Product is Out of stock'),
      ));
      return;
    }
    double po=totalPayable;

    changeStocks(product,-1);
    var index = mapProductList
        .indexWhere((element) => element['product_id'] == product['id']);
    if (index < 0) {
      Map<String, dynamic> map = {};
      map['product_id'] = product['id'];
      map['id'] = product['id'];
      map['sku'] = product['sku'];
      map['name'] = product['name'];
      try {
        '${map['variation_id'] = product['product_variations']?[0]?['variations']?[0]?['id']}';
      } catch (_) {}

      map['quantity'] = 1;
      try {
        map['unit_price'] = product['product_variations']?[0]?['variations']?[0]
            ?['default_sell_price'];
      } catch (_) {}
      //map['sub_total'] = double.tryParse(map['unit_price']) ?? 0;

      // try {
      //   map['tax_rate_id'] = product['product_tax']?['id'];
      // } catch (_) {}
      // map['discount_amount'] = 0;
      // map['discount_type'] = 'percentage';
      map['sub_unit_id'] = null;
      map['note'] = null;
      //map['sell_price_inc_tax'] = 0.0;
      try {
        map['unit'] = product['unit']?['actual_name'];
      } catch (_) {}

      ScaffoldMessenger.of(context).clearSnackBars();
      mapProductList.add(map);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(seconds: 1),
        dismissDirection: DismissDirection.startToEnd,
        content: Text('${map['name']} added'),
      ));
      //mapProductList.last.update('sell_price_inc_tax', (value) => totalPayable-po);
    } else {
      mapProductList.elementAt(index).update('quantity', (value) => value + 1);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(seconds: 1),
        dismissDirection: DismissDirection.startToEnd,
        content: Text('${mapProductList[index]['name']} increased'),
      ));
      //mapProductList.elementAt(index).update('sell_price_inc_tax', (value) => totalPayable-po);
    }

    setState(() {});
  }

  Future<String> getStocks() async {
    var stocks =
        Provider.of<ProductsStockProvider>(context, listen: false).mapData;
    final productsProvider =
        Provider.of<ProductsProvider>(context, listen: false);
    List<Map<String, dynamic>> products = productsProvider.mapData;

    for (var product in products) {
      final stock = stocks.firstWhere(
              (element) => element['product_id'].toString() == product['id'].toString()&&(element['location_id'].toString()==initData['location_id'].toString()),
          orElse: () => {});
      if (product.isNotEmpty) {
        productsProvider.setCurrentStock(product['sku'], stock['stock']);
      }
    }
    return '';
  }
 Future<String> setStocks(Map<String,dynamic> product) async {
    var stocks =
        Provider.of<ProductsStockProvider>(context, listen: false).mapData;

    final stock = stocks.firstWhere(
            (element) => element['product_id'].toString() == product['id'].toString()&&(element['location_id'].toString()==initData['location_id'].toString()),
        orElse: () => {});

    if (product.isNotEmpty) {
      int index=stocks.indexOf(stock);
      stock['stock']=Provider.of<ProductsProvider>(context, listen: false).getCurrentStock(product['sku']);
      //stock['location_id']=initData['location_id'];
      Provider.of<ProductsStockProvider>(context, listen: false).updateData(stock, index+1);

    }
    return '';
  }
 Future<String> changeStocks(Map<String,dynamic> product,v) async {
    var stocks =
        Provider.of<ProductsStockProvider>(context, listen: false).mapData;

    final stock = stocks.firstWhere(
            (element) => element['product_id'].toString() == product['id'].toString()&&(element['location_id'].toString()==initData['location_id'].toString()),
        orElse: () => {});

    if (product.isNotEmpty) {
      int index=stocks.indexOf(stock);
      stock['stock']=(double.tryParse(stock['stock'].toString())??0.0)+v;
      //Provider.of<ProductsStockProvider>(context, listen: false).updateData(stock, index+1);

      Provider.of<ProductsProvider>(context, listen: false).setCurrentStock(product['sku'], stock['stock']);
    }
    return '';
  }

  init() async {

    final value = await getDefaults();
    initData.addAll(value);
    await Provider.of<ProductsStockProvider>(context, listen: false).getData();
    await Provider.of<ProductsProvider>(context, listen: false).getData();
    await Provider.of<HeadersFootersProvider>(context, listen: false).getData();
    await Provider.of<LocationProvider>(context, listen: false).getData();
    await Provider.of<CustomerProvider>(context, listen: false).getData();
    await getStocks();
    setState(() {
    });

  }

  String trim(name) {
    return name
        .toString()
        .substring(0, math.min(name.toString().length, 15));
  }
  String trim2(name) {
    return name
        .toString()
        .substring(0, math.min(name.toString().length, 22));
  }
}
