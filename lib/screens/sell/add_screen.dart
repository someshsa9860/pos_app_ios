import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart'
    as barcode;
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart' as basic;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:pos_app/data_management/print.dart';
import 'package:pos_app/data_management/sync.dart';
import 'package:pos_app/provider/customer_provider.dart';
import 'package:pos_app/provider/headers_footers_provider.dart';
import 'package:pos_app/provider/location_provider.dart';
import 'package:pos_app/provider/paccounts_provider.dart';
import 'package:pos_app/provider/pmethods_provider.dart';
import 'package:pos_app/provider/products_provider.dart';
import 'package:pos_app/provider/sell_provider.dart';
import 'package:pos_app/provider/selling_group_provider.dart';
import 'package:pos_app/provider/supplier_provider.dart';
import 'package:pos_app/provider/tax_provider.dart';
import 'package:pos_app/screens/products/list_screen.dart';
import 'package:pos_app/widgets/app_drawer.dart';
import 'package:pos_app/widgets/border_row.dart';
import 'package:pos_app/widgets/custom_card.dart';
import 'package:pos_app/widgets/pos_search.dart';
import 'package:printer_one/printer_one.dart';
import 'package:provider/provider.dart';
import 'package:search_page/search_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bluetooth_printer.dart';
import '../settings.dart';

class SellAddScreen extends StatefulWidget {
  const SellAddScreen({Key? key}) : super(key: key);
  static const routeName = '/sell-add';

  @override
  State<SellAddScreen> createState() => _Screen();
}

class _Screen extends State<SellAddScreen> {
  final FocusNode _focusSellNotes = FocusNode();
  final FocusNode _focusPayTerm = FocusNode();
  final FocusNode _focusOrderTax = FocusNode();
  final FocusNode _focusDiscountAmount = FocusNode();
  final FocusNode _focusShippingDetails = FocusNode();
  final FocusNode _focusShippingAddress = FocusNode();
  final FocusNode _focusShippingCharge = FocusNode();
  final FocusNode _focusDeliverTo = FocusNode();
  final FocusNode _focusAmount = FocusNode();
  final FocusNode _focusPaymentNote = FocusNode();

  final form = GlobalKey<FormState>();
  var id, amount, method, account, note;
  final FlutterBlue _flutterBlue = FlutterBlue.instance;

  List<Map<String, dynamic>> mapProductList = [];

  List<DropdownMenuItem<String>> categories = [
    const DropdownMenuItem(
      child: Text('LOGISTICS'),
      value: 'LOGISTICS',
    ),
  ];

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

  void cancel() {
    setState(() {
      initData.clear();
      mapProductList.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final appBar = AppBar(
      title: Text(id == null ? "Add new Sell" : "Edit Sell"),
      actions: [
        TextButton(
            onPressed: () {
              var ck = _check();
              if (ck) {
                upload();
              }
            },
            child:
                //Text(id != null ? "Update Expense" : "Add new Expense"))
                const Text('Save', style: TextStyle(color: Colors.white))),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.of(context).pushNamed(AppSettings.routeName);
          },
        )
      ],
    );

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
        appBar: appBar,
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          height:
              MediaQuery.of(context).size.height - appBar.preferredSize.height,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: Form(
                    key: form,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _topWidget(context),
                          const Divider(),
                          _searchWidget(context),
                          const SizedBox(
                            height: 10.0,
                          ),
                          SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: _showProductList()),
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
                                        Text('Total: ' +
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
                                          Text('Discount(-): ' +
                                              calDiscount.toStringAsFixed(2)),
                                          const SizedBox(
                                            width: 10.0,
                                          ),
                                          Text('Order Tax(+): ' +
                                              calTax.toStringAsFixed(2)),
                                          const SizedBox(
                                            width: 10.0,
                                          ),
                                          Text('Shipping(+): ' +
                                              (double.tryParse(initData[
                                                              'shipping_charges']
                                                          .toString()) ??
                                                      0.0)
                                                  .toStringAsFixed(2))
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 0.5,
                                          color: Colors.grey,
                                          style: BorderStyle.solid)),
                                  child: Row(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Icon(Icons.info),
                                      ),
                                      Expanded(
                                        child: Container(
                                          decoration: const BoxDecoration(
                                              border: Border.symmetric(
                                                  vertical: BorderSide(
                                                      width: 0.5,
                                                      color: Colors.grey,
                                                      style:
                                                          BorderStyle.solid))),
                                          child: Consumer<TaxProvider>(
                                            builder: (ctx, taxP, _) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                child: DropdownButton(
                                                    hint:
                                                        const Text('Order Tax'),
                                                    value:
                                                        initData['tax_rate_id'],
                                                    onChanged: (v) {
                                                      initData['tax_rate_id'] =
                                                          v;
                                                      final taxMap = taxP
                                                          .mapData
                                                          .firstWhere(
                                                              (element) =>
                                                                  element[
                                                                      'id'] ==
                                                                  v);
                                                      tax = double.tryParse(
                                                              taxMap['amount']
                                                                  .toString()) ??
                                                          0.0;
                                                      setState(() {});
                                                    },
                                                    items: taxP.mapData
                                                        .map((e) =>
                                                            DropdownMenuItem(
                                                                value: e['id'],
                                                                child: Text(
                                                                    e['name'])))
                                                        .toSet()
                                                        .toList()),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                Column(
                                  children: [
                                    const Align(
                                      alignment: Alignment.topLeft,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('Sale Notes:'),
                                      ),
                                    ),
                                    BorderRow(
                                        child: TextFormField(
                                      focusNode: _focusSellNotes,
                                      textInputAction: TextInputAction.done,
                                      initialValue: initData['sale_note'],
                                      keyboardType: TextInputType.multiline,
                                      onFieldSubmitted: (v) {
                                        //FocusScope.of(context)
                                        //  .requestFocus(_focusShippingDetails);
                                      },
                                      validator: (v) {
                                        return null;
                                      },
                                      onSaved: (v) {
                                        initData['sale_note'] = v;
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'Sale Notes',
                                        border: InputBorder.none,
                                      ),
                                    )),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                Column(
                                  children: [
                                    const Align(
                                      alignment: Alignment.topLeft,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('Shipping Detail'),
                                      ),
                                    ),
                                    BorderRow(
                                      child: TextFormField(
                                        focusNode: _focusShippingDetails,
                                        textInputAction: TextInputAction.done,
                                        initialValue:
                                            initData['shipping_details'],
                                        keyboardType: TextInputType.multiline,
                                        onFieldSubmitted: (v) {
                                          //FocusScope/.of(context).requestFocus(
                                          //_focusShippingAddress);
                                        },
                                        validator: (v) {
                                          return null;
                                        },
                                        onSaved: (v) {
                                          initData['shipping_details'] = v;
                                        },
                                        decoration: const InputDecoration(
                                          labelText: 'Shipping Detail',
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                Column(
                                  children: [
                                    const Align(
                                      alignment: Alignment.topLeft,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('Shipping Address'),
                                      ),
                                    ),
                                    BorderRow(
                                      child: TextFormField(
                                        focusNode: _focusShippingAddress,
                                        textInputAction: TextInputAction.done,
                                        initialValue:
                                            initData['shipping_address'],
                                        keyboardType: TextInputType.multiline,
                                        onFieldSubmitted: (v) {
                                          //FocusScope.of(context)
                                          //  .requestFocus(_focusShippingCharge);
                                        },
                                        validator: (v) {
                                          return null;
                                        },
                                        onSaved: (v) {
                                          initData['shipping_address'] = v;
                                        },
                                        decoration: const InputDecoration(
                                          labelText: 'Shipping Address',
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                Column(
                                  children: [
                                    const Align(
                                      alignment: Alignment.topLeft,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('Shipping Charge'),
                                      ),
                                    ),
                                    BorderRow(
                                      child: TextFormField(
                                        focusNode: _focusShippingCharge,
                                        textInputAction: TextInputAction.done,
                                        initialValue:
                                            initData['shipping_charges'],
                                        keyboardType: TextInputType.number,
                                        onFieldSubmitted: (v) {
                                          //FocusScope.of(context)
                                          //  .requestFocus(_focusDeliverTo);
                                        },
                                        validator: (v) {
                                          return null;
                                        },
                                        onSaved: (v) {
                                          initData['shipping_charges'] = v;
                                        },
                                        onChanged: (v) {
                                          initData['shipping_charges'] = v;
                                        },
                                        decoration: const InputDecoration(
                                          labelText: 'Shipping Charge',
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                Column(
                                  children: [
                                    const Align(
                                      alignment: Alignment.topLeft,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('Deliver To'),
                                      ),
                                    ),
                                    BorderRow(
                                      child: TextFormField(
                                        focusNode: _focusDeliverTo,
                                        textInputAction: TextInputAction.done,
                                        initialValue: initData['delivered_to'],
                                        keyboardType: TextInputType.number,
                                        onFieldSubmitted: (v) {
                                          //FocusScope.of(context)
                                          //  .requestFocus(_focusAmount);
                                        },
                                        validator: (v) {
                                          return null;
                                        },
                                        onSaved: (v) {
                                          initData['delivered_to'] = v;
                                        },
                                        decoration: const InputDecoration(
                                          labelText: 'Deliver To',
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                Column(
                                  children: [
                                    const Align(
                                      alignment: Alignment.topLeft,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('Shipping Status'),
                                      ),
                                    ),
                                    BorderRow(
                                        child: DropdownButton(
                                            value: initData['shipping_status'],
                                            onChanged: (v) {
                                              if (v != null) {
                                                setState(() {
                                                  initData['shipping_status'] =
                                                      v;
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
                                        ])),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          MyCustomCard([
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  children: [
                                    const Align(
                                      alignment: Alignment.topLeft,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('Payment'),
                                      ),
                                    ),
                                    BorderRow(
                                      child: Consumer<PaymentMethodsProvider>(
                                        builder: (ctx, provider, _) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: DropdownButton(
                                                hint: const Text(
                                                    'Payment Methods'),
                                                value: method,
                                                onChanged: (v) {
                                                  method = v;
                                                  setState(() {});
                                                },
                                                items: methodList(provider)),
                                          );
                                        },
                                      ),
                                      icon: const Icon(Icons.info),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                Column(
                                  children: [
                                    const Align(
                                      alignment: Alignment.topLeft,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('Enter amount'),
                                      ),
                                    ),
                                    BorderRow(
                                      child: TextFormField(
                                        focusNode: _focusAmount,
                                        textInputAction: TextInputAction.done,
                                        initialValue: amount,
                                        keyboardType: TextInputType.number,
                                        onFieldSubmitted: (v) {
                                          //FocusScope.of(context)
                                          //  .requestFocus(_focusPaymentNote);
                                        },
                                        validator: (v) {
                                          if (v == null || v.isEmpty) {
                                            return 'This is required field';
                                          }
                                        },
                                        onSaved: (v) {
                                          amount = v;
                                        },
                                        decoration: const InputDecoration(
                                          labelText: 'Enter amount',
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                Column(
                                  children: [
                                    const Align(
                                      alignment: Alignment.topLeft,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('Payment Account'),
                                      ),
                                    ),
                                    BorderRow(
                                      child: Consumer<PaymentAccountProvider>(
                                        builder: (ctx, contacts, _) {
                                          return DropdownButton(
                                              //icon: const Icon(Icons.contact_support),
                                              value: account,
                                              underline: null,
                                              hint: const Text(
                                                'Payment Accounts',
                                                textAlign: TextAlign.end,
                                              ),
                                              onChanged: (v) {
                                                account = v;
                                                setState(() {});
                                              },
                                              items: accountsList(contacts));
                                        },
                                      ),
                                      icon: const Icon(
                                        Icons.person_rounded,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                Column(
                                  children: [
                                    const Align(
                                      alignment: Alignment.topLeft,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('Enter Payment Notes'),
                                      ),
                                    ),
                                    BorderRow(
                                      child: TextFormField(
                                        focusNode: _focusPaymentNote,
                                        textInputAction:
                                            TextInputAction.newline,
                                        initialValue: note,
                                        maxLines: null,
                                        keyboardType: TextInputType.multiline,
                                        validator: (v) {
                                          return null;
                                        },
                                        onSaved: (v) {
                                          note = v;
                                        },
                                        decoration: const InputDecoration(
                                          labelText: 'Enter Payment Notes',
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                              ],
                            )
                          ]),
                          const SizedBox(
                            height: 10.0,
                          ),
                          const Divider(),
                          const SizedBox(
                            height: 10.0,
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Payable: ' +
                                  totalPayable.toStringAsFixed(2)),
                              _printing
                                  ? const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(),
                                    )
                                  : TextButton(
                                      onPressed: printReceipt,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(Icons.print),
                                          SizedBox(
                                            width: 5.0,
                                          ),
                                          Text('Print')
                                        ],
                                      ))
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  var ck = _check();
                                  if (!ck) {
                                    return;
                                  }
                                  save();
                                  Fluttertoast.showToast(msg: 'printing');
                                  var list = genInvoice();
                                  var pdf = await printPDF(list);
                                  pdfShare(pdf.path);
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
                              ElevatedButton(
                                onPressed: () async {},
                                child: const Text('Recent Transactions'),
                              )
                            ],
                          ),
                          const Divider(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        drawer: const AppDrawer(),
      ),
    );
  }

  DefaultPrinters defaultPrinter = DefaultPrinters.pdfSave;
  bool _printing = false;

  void printReceipt() async {
    var ck = _check();
    if (!ck) {
      return;
    }
    save();
    setState(() {
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
          var list = genInvoiceSDK();
          //var pdf = await printPDF(list);
          printSDKOne(list);
          break;
        case DefaultPrinters.cs10:
          var list = genInvoiceSDK();

          printSDKTwo(list);
          break;

        case DefaultPrinters.bluetooth:
          Fluttertoast.showToast(msg: 'printing');
          if (!mounted) {
            return;
          }

          var on = await _flutterBlue.isOn;
          if (!on) {
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
          var list = genInvoice();
          var pdf = await printPDF(list);
          pdfShare(pdf.path);
          break;
        case DefaultPrinters.pdfSave:
        default:
          Fluttertoast.showToast(msg: 'printing');
          var list = genInvoice();
          var pdf = await printPDF(list);
          Fluttertoast.showToast(msg: 'saved successfully');
        //     android_intent.Intent()
        //       ..setAction(android_action.Action.ACTION_CREATE_DOCUMENT)
        //         ..addCategory(android_catagory.Category.CATEGORY_OPENABLE)
        //         ..setType('application/pdf')
        //         //..putExtra(android_et.TypedExtra.extr, data)
        // ..startActivity().whenComplete(() => null)

      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
    upload();
    setState(() {
      _printing = false;
    });
  }

  _searchWidget(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
              width: 0.5, color: Colors.grey, style: BorderStyle.solid)),
      child: PosSearch(scan: _scan, search: _search),
    );
  }

  Padding _topWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
                border: Border.all(
                    width: 0.5, color: Colors.grey, style: BorderStyle.solid)),
            child: Row(children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Icon(
                  Icons.money_rounded,
                  color: Colors.grey,
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                      border: Border.symmetric(
                          vertical: BorderSide(
                              width: 0.5,
                              color: Colors.grey,
                              style: BorderStyle.solid))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Consumer<LocationProvider>(
                      builder: (ctx, provider, _) {
                        return DropdownButton(
                            //icon: const Icon(Icons.contact_support),
                            value: initData['location_id'],
                            underline: null,
                            hint: const Text(
                              'Business Location',
                              textAlign: TextAlign.end,
                            ),
                            onChanged: (v) {
                              initData['location_id'] = v!;
                              setState(() {});
                            },
                            items: getLocationsList(provider));
                      },
                    ),
                  ),
                ),
              ),
            ]),
          ),
          const Divider(),
          Container(
            decoration: BoxDecoration(
                border: Border.all(
                    width: 0.5, color: Colors.grey, style: BorderStyle.solid)),
            child: Row(children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Icon(
                  Icons.money_rounded,
                  color: Colors.grey,
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                      border: Border.symmetric(
                          vertical: BorderSide(
                              width: 0.5,
                              color: Colors.grey,
                              style: BorderStyle.solid))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: Consumer<SellingGroupProvider>(
                        builder: (ctx, provider, _) {
                          return DropdownButton(
                              //icon: const Icon(Icons.contact_support),
                              value: (initData['selling_price_group_id'] != null
                                  ? (initData['selling_price_group_id']
                                              .toString() ==
                                          ('0'))
                                      ? null
                                      : initData['selling_price_group_id']
                                  : null),
                              underline: null,
                              hint: const Text(
                                'Select',
                                textAlign: TextAlign.end,
                              ),
                              onChanged: (v) {
                                initData['selling_price_group_id'] = v!;
                                setState(() {});
                              },
                              items: getSellingGroupList(provider));
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
          const Divider(),
          BorderRow(
            child: Consumer<CustomerProvider>(
              builder: (ctx, customers, _) {
                return Consumer<SupplierProvider>(
                  builder: (ctx, supplier, _) {
                    return DropdownButton(
                        value: initData['contact_id'],
                        underline: null,
                        hint: const Text(
                          'Select',
                          textAlign: TextAlign.end,
                        ),
                        onChanged: (v) {
                          initData['contact_id'] = v! as int;
                          setState(() {});
                        },
                        items: contactsList(supplier, customers));
                  },
                );
              },
            ),
            icon: const Icon(
              Icons.person_rounded,
              color: Colors.grey,
            ),
          ),
          const Divider(),
          Container(
            decoration: BoxDecoration(
                border: Border.all(
                    width: 0.5, color: Colors.grey, style: BorderStyle.solid)),
            child: Row(children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.grey,
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                      border: Border.symmetric(
                          vertical: BorderSide(
                              width: 0.5,
                              color: Colors.grey,
                              style: BorderStyle.solid))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: TextButton(
                          onPressed: () {
                            _selectSellDate();
                          },
                          child: Text(initData['transaction_date'] ??
                              DateFormat("y-M-d HH:mm")
                                  .format(DateTime.now()))),
                    ),
                  ),
                ),
              ),
            ]),
          ),
          const Divider(),
          Container(
            decoration: BoxDecoration(
                border: Border.all(
                    width: 0.5, color: Colors.grey, style: BorderStyle.solid)),
            child: Row(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100.0,
                      child: TextFormField(
                        initialValue: initData['_focusPayTerm'],
                        textInputAction: TextInputAction.done,
                        focusNode: _focusPayTerm,
                        keyboardType: TextInputType.number,
                        onFieldSubmitted: (v) {
                          //FocusScope/.of(context).requestFocus(_focusSellNotes);
                        },
                        validator: (v) {
                          return null;
                        },
                        onSaved: (v) {
                          initData['pay_term_number'] = v;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Enter Pay term',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    DropdownButton(
                        value: initData['pay_term_type'],
                        onChanged: (v) {
                          if (v != null) {
                            setState(() {
                              initData['pay_term_type'] = v;
                            });
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            child: Text('Days'),
                            value: 'days',
                          ),
                          DropdownMenuItem(
                            child: Text('Months'),
                            value: 'months',
                          ),
                          DropdownMenuItem(
                            child: Text('Years'),
                            value: 'years',
                          )
                        ]),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                      border: Border.symmetric(
                          vertical: BorderSide(
                              width: 0.5,
                              color: Colors.grey,
                              style: BorderStyle.solid))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: DropdownButton(
                        hint: const Text('Status'),
                        value: initData['status'],
                        onChanged: (v) {
                          if (v != null) {
                            setState(() {
                              initData['status'] = v;
                            });
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            child: Text('Final'),
                            value: 'final',
                          ),
                          DropdownMenuItem(
                            child: Text('Draft'),
                            value: 'draft',
                          ),
                          DropdownMenuItem(
                            child: Text('Quotation'),
                            value: 'quotation',
                          ),
                          DropdownMenuItem(
                            child: Text('Proforma'),
                            value: 'proforma',
                          )
                        ]),
                  ),
                ),
              ),
            ]),
          ),
          const Divider(),
          const SizedBox(
            height: 10.0,
          ),
        ],
      ),
    );
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

  bool uploading = false;

  upload() async {
    save();
    Map<String, dynamic> initData = {};
    initData.addAll(this.initData);
    initData.removeWhere((key, value) => value == null);
    var provider = Provider.of<SellProvider>(context, listen: false);

    if (initData['invoice_no'] == null) {
      initData['invoice_no'] = getRandomId();
    }

    if (id != null && id >= 0) {
      await provider.update(initData);
    } else {
      await provider.addDataData(initData);
    }
    cancel();
    setState(() {
      _printing = false;
    });
    //Navigator.of(context).pop();
  }

  Map<String, dynamic> initData = {};
  var _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _isInit = false;
      getContacts();

      List<dynamic> list =
          ModalRoute.of(context)!.settings.arguments as List<dynamic>;
      id = null;
      if (list.first >= 0) {
        final provider = Provider.of<SellProvider>(context, listen: false);

        final sell = provider.mapData[list.first];
        id = sell['id'];

        amount = sell['payment_lines']?[0]?['amount'];
        account = sell['payment_lines']?[0]?['account_id'];
        method = sell['payment_lines']?[0]?['method'];
        id = sell['id'];
        initData.addAll(sell);

        print(sell['sell_lines'].toString());
        for (var map in sell['sell_lines']) {
          mapProductList.add(map as Map<String, dynamic>);
        }
      }
    }
    super.didChangeDependencies();
  }

  Future<void> getContacts() async {}

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

  double getTax(price, tax) {
    return price * tax * 0.01;
  }

  void _scan() async {
    String res = await FlutterBarcodeScanner.scanBarcode(
        '#ffffff', 'cancel', true, barcode.ScanMode.DEFAULT);
    if (res.isNotEmpty) {}
  }

  int maxChars = 60;
  int maxCharsCol1 = 3;
  int maxCharsCol2 = 15;
  int maxCharsCol3 = 5;
  int maxCharsCol4 = 15;
  int maxCharsCol5 = 15;

  var discount = 0.0;
  var tax = 0.0;
  var taxName = 'vat';

  List<pw.Widget> genInvoice() {
    if (initData['invoice_no'] == null) {
      initData['invoice_no'] = getRandomId();
    }

    final supplier = Provider.of<SupplierProvider>(context, listen: false);
    final customer = Provider.of<CustomerProvider>(context, listen: false);
    List<pw.Widget> posLines = [];
    posLines.addAll(sellInvoiceHead(
        Provider.of<HeadersFootersProvider>(context, listen: false).headers));

    //DATA START

    posLines.add(pw.Padding(
        padding: const pw.EdgeInsets.all(1.0),
        child: pw.Text('Receipt', textAlign: pw.TextAlign.left)));

    posLines.add(pw.Padding(
        padding: const pw.EdgeInsets.all(1.0),
        child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Receipt No.'),
              pw.Text(initData['invoice_no'].toString()),
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

    final contactsData = getMapContacts(supplier, customer);

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
    discount = 0.0;
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
                  pw.Text((map['sub_total']).toStringAsFixed(2),
                      textAlign: pw.TextAlign.center),
                ]),
            //           pw.Divider(),
          ])));

      var disc = getDiscount(
        map['quantity'] ?? 0,
        map['unit_price'] ?? 0,
        map['discount_amount'] ?? 0,
        map['discount_type'] ?? 0,
      );
      discount = discount + disc;
    }

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
                  pw.Text('Discount:  -Ksh ' + (discount).toStringAsFixed(2)),
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
                      (double.tryParse(
                                  initData['shipping_charges'].toString()) ??
                              0.0)
                          .toStringAsFixed(2)),
                ]))));
    posLines.add(pw.Padding(
        padding: const pw.EdgeInsets.all(1.0),
        child: pw.Align(
            alignment: pw.Alignment.bottomRight,
            child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text('Total:  Ksh ' + (totalPayable).toStringAsFixed(2),
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ]))));

    //DATA END

    posLines.addAll(sellInvoiceBottom(
        Provider.of<HeadersFootersProvider>(context, listen: false).footers));

    return posLines;
  }

  List<POSLine> genInvoiceSDK()
  // {
  //   if (initData['invoice_no'] == null) {
  //     initData['invoice_no'] = getRandomId();
  //   }
  //
  //   final supplier = Provider.of<SupplierProvider>(context, listen: false);
  //   final customer = Provider.of<CustomerProvider>(context, listen: false);
  //
  //   List<POSLine> posLines = [];
  //   posLines.addAll(sellInvoiceHeadSDK(
  //       Provider.of<HeadersFootersProvider>(context, listen: false).headers));
  //
  //   //DATA START
  //
  //   posLines.add(POSLine(
  //       left: 'Receipt',
  //       center: '',
  //       end: '',
  //       bold: false.toString(),
  //       font: 'small',
  //       bitmap: ''));
  //   posLines.add(POSLine(
  //       left: 'Receipt No.',
  //       center: '',
  //       end: initData['invoice_no'].toString(),
  //       bold: false.toString(),
  //       font: 'small',
  //       bitmap: ''));
  //   posLines.add(POSLine(
  //       left: 'Date',
  //       center: '',
  //       end: (initData['transaction_date'] ??
  //               DateFormat('MM/dd/yyyy HH:mm').format(DateTime.now()))
  //           .toString(),
  //       bold: false.toString(),
  //       font: 'small',
  //       bitmap: ''));
  //   final contactsData = getMapContacts(supplier, customer);
  //
  //   posLines.add(POSLine(
  //       left: 'Customer',
  //       center: '',
  //       end: initData['contact_id'] == null
  //           ? ''
  //           : contactsData.elementAt(contactsData.indexWhere((element) =>
  //                   element['id'].toString() ==
  //                   initData['contact_id'].toString()))['name'] ??
  //               '',
  //       bold: false.toString(),
  //       font: 'small',
  //       bitmap: ''));
  //   posLines.add(POSLine(
  //       left: '',
  //       center: '',
  //       end: '',
  //       bold: false.toString(),
  //       font: 'small',
  //       bitmap: ''));
  //   posLines.add(POSLine(
  //       left: '#  Product',
  //       center: 'Quantity   Unit price',
  //       end: 'sub-total',
  //       bold: false.toString(),
  //       font: 'small',
  //       bitmap: ''));
  //
  //   for (Map<String, dynamic> map in mapProductList) {
  //     posLines.add(POSLine(
  //         left: (mapProductList.indexOf(map) + 1).toString() +
  //             map['name'].toString().substring(
  //                 0, math.min(map['name'].toString().length - 1, 20)),
  //         center: map['quantity'].toString() +
  //             (double.tryParse(map['unit_price'].toString()) ?? 0.0)
  //                 .toStringAsFixed(2),
  //         end: (map['sub_total']).toStringAsFixed(2),
  //         bold: false.toString(),
  //         font: 'small',
  //         bitmap: ''));
  //   }
  //   posLines.add(POSLine(
  //       left: '',
  //       center: 'Subtotal:  Ksh ',
  //       end: (total).toStringAsFixed(2),
  //       bold: false.toString(),
  //       font: 'small',
  //       bitmap: ''));
  //   posLines.add(POSLine(
  //       left: '',
  //       center: '',
  //       end: (total).toStringAsFixed(2),
  //       bold: false.toString(),
  //       font: 'small',
  //       bitmap: ''));
  //   posLines.add(POSLine(
  //       left: '',
  //       center: 'Discount:  -Ksh ',
  //       end: (discount).toStringAsFixed(2),
  //       bold: false.toString(),
  //       font: 'small',
  //       bitmap: ''));
  //   posLines.add(POSLine(
  //       left: '',
  //       center: 'Tax($taxName):  +Ksh ',
  //       end: (calTax).toStringAsFixed(2),
  //       bold: false.toString(),
  //       font: 'small',
  //       bitmap: ''));
  //   posLines.add(POSLine(
  //       left: '',
  //       center: 'Shipping Charge:  +Ksh ',
  //       end: (initData['shipping_charges'] ?? 0.0).toStringAsFixed(2),
  //       bold: false.toString(),
  //       font: 'small',
  //       bitmap: ''));
  //   posLines.add(POSLine(
  //       left: '',
  //       center: 'Total:  Ksh ',
  //       end: '' + (totalPayable).toStringAsFixed(2),
  //       bold: true.toString(),
  //       font: 'small',
  //       bitmap: ''));
  //
  //   posLines.addAll(sellInvoiceBottomSDK(
  //       Provider.of<HeadersFootersProvider>(context, listen: false).footers));
  //
  //   return posLines;
  // }

  {
    return [];
  }
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

    discount = 0.0;

    for (Map<String, dynamic> map in mapProductList) {
      value = value +
          ((map['quantity'] ?? 1) *
              (double.tryParse(map['unit_price'].toString()) ?? 0));

      var disc = getDiscount(
        map['quantity'] ?? 0,
        map['unit_price'] ?? 0,
        map['discount_amount'] ?? 0,
        map['discount_type'] ?? 0,
      );
      discount = discount + disc;
    }

    return value -
        discount +
        calTax +
        (double.tryParse(initData['shipping_charges'].toString()) ?? 0.0);
  }

  double get calDiscount {
    var discount = 0.0;
    for (Map<String, dynamic> map in mapProductList) {
      var disc = getDiscount(
        map['quantity'] ?? 0,
        map['unit_price'] ?? 0,
        map['discount_amount'] ?? 0,
        map['discount_type'] ?? 0,
      );
      discount = discount + disc;
    }
    return discount;
  }

  double get calTax {
    return (total - calDiscount) * tax / 100;
  }

  //*new
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
              var index = mapProductList
                  .indexWhere((element) => element['product_id'] == m['id']);
              if (index < 0) {
                Map<String, dynamic> map = {};
                map['product_id'] = m['id'];
                map['name'] = m['name'];
                try {
                  map['variation_id'] = m['product_variations']?[0]
                      ?['variations']?[0]?['product_variation_id'];
                } catch (_) {}

                map['quantity'] = 1;
                try {
                  map['unit_price'] = m['product_variations']?[0]?['variations']
                      ?[0]?['default_sell_price'];
                } catch (_) {}
                map['sub_total'] = double.tryParse(map['unit_price']) ?? 0;

                // try {
                //   map['tax_rate_id'] = m['product_tax']?['id'];
                // } catch (_) {}
                map['discount_amount'] = 0;
                map['discount_type'] = 'percentage';
                map['sub_unit_id'] = null;
                map['note'] = null;
                try {
                  map['unit'] = m['unit']?['actual_name'];
                } catch (_) {}

                mapProductList.add(map);
              } else {
                mapProductList
                    .elementAt(index)
                    .update('quantity', (value) => value + 1);
              }

              setState(() {});
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
                            image: FileImage(File(m['image_url'])));
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
              width: size.width * (0.2),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Product',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(
              width: size.width * (0.4),
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
              width: size.width * (0.3),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Unit Price',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(
              width: size.width * (0.4),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Discount',
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: size.width * (0.05),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.clear_outlined),
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
              width: size.width * (0.2),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  mapProductList[index]['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(
              width: size.width * (0.4),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 0.5,
                            color: Colors.grey,
                            style: BorderStyle.solid)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                            onPressed: () {
                              if (mapProductList[index]['quantity'] == null) {
                                mapProductList[index]['quantity'] = 0;
                              }
                              mapProductList[index]['quantity'] = math.max(
                                  (mapProductList[index]['quantity'] as int) -
                                      1,
                                  0);
                              if (mapProductList[index]['quantity'] == 0) {
                                mapProductList.removeAt(index);
                              }
                              setState(() {});
                            },
                            icon: const Icon(
                              Icons.remove_sharp,
                              color: Colors.red,
                              size: 16.0,
                            )),
                        Container(
                            decoration: const BoxDecoration(
                                border: Border.symmetric(
                                    vertical: BorderSide(
                                        width: 0.5,
                                        color: Colors.grey,
                                        style: BorderStyle.solid))),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child:
                                  Text('${mapProductList[index]['quantity']}'),
                            )),
                        IconButton(
                            onPressed: () {
                              if (mapProductList[index]['quantity'] == null) {
                                mapProductList[index]['quantity'] = 1;
                              } else {
                                mapProductList[index]['quantity'] = math.max(
                                    (mapProductList[index]['quantity'] as int) +
                                        1,
                                    0);
                              }
                              setState(() {});
                            },
                            icon: const Icon(
                              Icons.add,
                              size: 16.0,
                              color: Colors.green,
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 0.5,
                            color: Colors.grey,
                            style: BorderStyle.solid)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        mapProductList[index]['unit'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              width: size.width * (0.3),
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    textInputAction: TextInputAction.done,
                    initialValue:
                        mapProductList[index]['unit_price'].toString(),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      return null;
                    },
                    textAlign: TextAlign.end,
                    onSaved: (v) {
                      mapProductList[index]['unit_price'] =
                          double.tryParse(v ?? '0');
                    },
                    onChanged: (v) {
                      mapProductList[index]['unit_price'] =
                          double.tryParse(v) ??
                              mapProductList[index]['unit_price'];
                    },
                    decoration: const InputDecoration(
                      hintText: 'unit price',
                      border: InputBorder.none,
                    ),
                  )),
            ),
            SizedBox(
              width: size.width * (0.4),
              child: Center(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          textAlign: TextAlign.center,
                          textInputAction: TextInputAction.done,
                          initialValue: mapProductList[index]['discount_amount']
                              .toString(),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            return null;
                          },
                          onChanged: (v) {
                            mapProductList[index]['discount_amount'] =
                                double.tryParse(v) ??
                                    mapProductList[index]['discount_amount'];
                          },
                          onSaved: (v) {
                            mapProductList[index]['discount_amount'] =
                                int.tryParse(v ?? '0');
                          },
                          decoration: const InputDecoration(
                            hintText: 'Discount amount',
                            border: InputBorder.none,
                          ),
                        ),
                        DropdownButton(
                            hint: const Text('Discount Type'),
                            value: mapProductList[index]['discount_type'],
                            onChanged: (v) {
                              if (v != null) {
                                setState(() {
                                  mapProductList[index]['discount_type'] = v;
                                });
                              }
                            },
                            items: const [
                              DropdownMenuItem(
                                child: Text('Fixed'),
                                value: 'fixed',
                              ),
                              DropdownMenuItem(
                                child: Text('Percentage'),
                                value: 'percentage',
                              ),
                            ]),
                      ],
                    )),
              ),
            ),
            SizedBox(
              width: size.width * (0.2),
              child: Padding(
                  padding: EdgeInsets.all(8.0),
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: size.width * (0.05),
                child: IconButton(
                    onPressed: () {
                      setState(() {
                        mapProductList.removeAt(index);
                      });
                    },
                    icon: const Icon(Icons.clear_outlined)),
              ),
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
    mapProductList[index]['sub_total'] = v;

    return v.toStringAsFixed(2);
  }

  var discountType = 'fixed';

  void save() {
    print('uploading');
    setState(() {
      uploading = true;
    });

    if (id != null) {
      initData['id'] = id;
    }

    initData['payments'] = [
      {
        'amount': amount,
        'method': method,
        'account_id': account,
      }
    ];

    initData['products'] = mapProductList;
    if (initData['invoice_no'] == null) {
      initData['invoice_no'] = getRandomId();
    }
    print(initData.toString());
  }

  Future<List<int>> printBluetooth() async {
    if (initData['invoice_no'] == null) {
      initData['invoice_no'] = getRandomId();
    }
    final paper = PaperSize.mm58;
    final cProfile = await CapabilityProfile.load();
    final Generator ticket = Generator(paper, cProfile);
    List<int> bytes = [];
    //ticket.text(text);

    final supplier = Provider.of<SupplierProvider>(context, listen: false);
    final customer = Provider.of<CustomerProvider>(context, listen: false);

    bytes.addAll(await sellInvoiceHeadBlue(paper, cProfile,
        Provider.of<HeadersFootersProvider>(context, listen: false).headers));

    //DATA START
    bytes += ticket.text('Receipt',
        styles: const PosStyles(bold: false, align: PosAlign.left));

    bytes += ticket.row([
      PosColumn(
          text: 'Receipt No.',
          width: 6,
          styles: const PosStyles(bold: false, align: PosAlign.left)),
      PosColumn(
          text: initData['invoice_no'].toString(),
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

    final contactsData = getMapContacts(supplier, customer);

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
            text: (mapProductList.indexOf(map) + 1).toString() + ' ',
            width: 3,
            styles: const PosStyles(bold: false, align: PosAlign.center)),
        PosColumn(
            text: map['name']
                .toString()
                .substring(0, math.min(map['name'].toString().length - 1, 20)),
            width: 9,
            styles: const PosStyles(bold: false, align: PosAlign.center)),
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
    bytes += ticket.hr(ch: ' ');

    bytes += ticket.text('Subtotal:  Ksh ' + (total).toStringAsFixed(2),
        styles: const PosStyles(bold: false, align: PosAlign.right));
    bytes += ticket.text('Discount:  -Ksh ' + (calDiscount).toStringAsFixed(2),
        styles: const PosStyles(bold: false, align: PosAlign.right));
    bytes += ticket.text('Tax($taxName):  +Ksh ' + (calTax).toStringAsFixed(2),
        styles: const PosStyles(bold: false, align: PosAlign.right));
    bytes += ticket.text(
        'Shipping Charge:  +Ksh ' +
            (double.tryParse(initData['shipping_charges'].toString()) ?? 0.0)
                .toStringAsFixed(2),
        styles: const PosStyles(bold: false, align: PosAlign.right));
    bytes += ticket.text(
        'Total:  Ksh ' + (total - calDiscount + calTax).toStringAsFixed(2),
        styles: const PosStyles(bold: false, align: PosAlign.right));

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

  bool _check() {
    if (form.currentState == null) {
      return false;
    }
    form.currentState!.save();
    save();
    if (form.currentState!.validate()) {
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
          if (_keyRequired('payments', ['amount'], ['Enter payment amount'])) {
            return true;
          }
        }
      }
    }
    return false;
  }

  List<DropdownMenuItem<int>> getSellingGroupList(
      SellingGroupProvider provider) {
    print(provider.mapData.length);
    final list = getmapDataingGroups(provider).map((v) {
      return DropdownMenuItem(
        child: Text(v['name']),
        value: (v['id']) as int,
      );
    });

    return list.toSet().toList();
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
      if (valu != null) {
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

    return [...mlist.toSet().toList()];
  }

  List<Map<String, dynamic>> getmapDataingGroups(
          SellingGroupProvider provider) =>
      [...provider.mapData];
}
