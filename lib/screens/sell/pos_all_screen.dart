import 'dart:convert';
import 'dart:math';

import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
import 'package:pos_app/provider/pos_provider.dart';
import 'package:pos_app/provider/supplier_provider.dart';
import 'package:pos_app/screens/bluetooth_printer.dart';
import 'package:pos_app/screens/sell/pos_screen.dart';
import 'package:pos_app/screens/settings.dart';
import 'package:pos_app/widgets/app_drawer.dart';
import 'package:pos_app/widgets/refresh_widget.dart';
import 'package:printer_one/printer_one.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PosAllScreen extends StatefulWidget {
  const PosAllScreen({Key? key}) : super(key: key);
  static const routeName = '/pos-all';

  @override
  State<PosAllScreen> createState() => _Screen();
}

class _Screen extends State<PosAllScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarName),
      ),
      body: Consumer<PosProvider>(
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
                              'Invoice No. & Customer name ',
                              style: TextStyle(fontWeight: FontWeight.w300),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Print',
                                style: TextStyle(fontWeight: FontWeight.w300),
                              ),
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
      drawer: const AppDrawer(),
    );
  }

  var _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _isInit = false;
      final contacts = Provider.of<PosProvider>(context, listen: false);
      refresh(contacts);
    }
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  //screen-specific-changes

  final String appBarName = 'Pos';

  //swipe-refresh
  Future<void> refresh(PosProvider contacts) async {
    await contacts.getData();
    await contacts.sync();
    await Provider.of<HeadersFootersProvider>(context, listen: false).getData();
  }

  setListForMenu(PosProvider value) {
    return value.mapData;
  }

  getLength(PosProvider contacts) {
    return contacts.mapData.length;
  }

  Map<String, dynamic> getMapForFunction(PosProvider contacts, int index) {
    return contacts.mapData[index];
  }

  ListView buildListView(PosProvider contacts, BuildContext context) {
    return ListView.builder(
        itemCount: getLength(contacts),
        itemBuilder: (ctx, index) {
          return Column(
            children: [
              ListTile(
                leading: Text('${contacts.mapData[index]['invoice_no']}'),
                title: Text(
                    getContactName('${contacts.mapData[index]['contact_id']}')),
                subtitle: Text('${contacts.mapData[index]['final_total']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () {
                          printReceipt(contacts.mapData[index]);
                        },
                        icon: Icon(
                          Icons.print,
                          color: Theme.of(context).primaryColor,
                        )),
                    IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, POSScreen.routeName,
                              arguments: [contacts.mapData[index]]);
                        },
                        icon: Icon(
                          Icons.edit,
                          color: Theme.of(context).primaryColor,
                        )),
                  ],
                ),
              ),
            ],
          );
        });
  }

  String getContactName(String fieldPos) {
    final customer = Provider.of<CustomerProvider>(context, listen: false);
    final supplier = Provider.of<CustomerProvider>(context, listen: false);
    final contacts = [];
    contacts.addAll(customer.mapData);
    contacts.addAll(supplier.mapData);

    final name = contacts.firstWhere(
        (element) => element['id'].toString() == fieldPos,
        orElse: () => null);

    if (name == null) {
      return 'unknown';
    }
    contacts.clear();
    return name['name'];
  }

  List<Map<String, dynamic>> getMapContacts(
      SupplierProvider supplierProvider, CustomerProvider customerProvider) {
    var mlist = [];
    mlist.addAll(supplierProvider.mapData);

    mlist.addAll(customerProvider.mapData);

    return [...mlist.toSet().toList()];
  }

  var initData = {};

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

  List<Map<String, dynamic>> mapProductList = [];

  final FlutterBlue _flutterBlue = FlutterBlue.instance;

  printReceipt(map) async {
    initData = {};
    initData.addAll(map);
    final mapList = map['products'] as List<dynamic>;
    print('posAll');
    print(mapList);
    mapProductList.clear();
    for (var element in mapList) {
      element as Map<String, dynamic>;
      mapProductList.add(element);
    }
    final pref = await SharedPreferences.getInstance();
    if (pref.getString('settings_printer') != null) {
      defaultPrinter = DefaultPrinters
          .values[int.tryParse(pref.getString('settings_printer') ?? '0') ?? 0];
    }

    switch (defaultPrinter) {
      // case DefaultPrinters.cs30:
      //   var list = genInvoice();
      //   var pdf = await printPDF(list);
      //   Fluttertoast.showToast(msg: 'saved successfully');
      //   printSDKOne([
      //     POSLine(
      //         left: '',
      //         center: '',
      //         end: '',
      //         bold: true.toString(),
      //         font: 'small',
      //         bitmap: pdf.path)
      //   ]);
      //   break;
      // case DefaultPrinters.cs10:
      //   var list = genInvoice();
      //   var pdf = await printPDF(list);
      //   Fluttertoast.showToast(msg: 'saved successfully');
      //   printSDKTwo([
      //     POSLine(
      //         left: '',
      //         center: '',
      //         end: '',
      //         bold: true.toString(),
      //         font: 'small',
      //         bitmap: pdf.path)
      //   ]);
      //   break;

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
          Fluttertoast.showToast(msg: 'please turn on bluetooth and location');
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
        Fluttertoast.showToast(msg: pdf.path);
    }
  }

  DefaultPrinters defaultPrinter = DefaultPrinters.pdfSave;

  Future<List<int>> printBluetooth() async {
    if (initData['invoice_no'] == null) {
      initData['invoice_no'] = getRandomId();
    }
    final paper = PaperSize.mm58;
    final cProfile = await CapabilityProfile.load();
    final Generator ticket = Generator(paper, cProfile);
    List<int> bytes = [];
    //ticket.text(text);

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

    final supplier = Provider.of<SupplierProvider>(context, listen: false);
    final customer = Provider.of<CustomerProvider>(context, listen: false);
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
            text: '# ' + (mapProductList.indexOf(map) + 1).toString() + ' ',
            width: 2,
            styles: const PosStyles(bold: false, align: PosAlign.left)),
        PosColumn(
            text: map['name'].toString(),
            width: 10,
            styles: const PosStyles(bold: false, align: PosAlign.left)),
      ]);
      bytes += ticket.row([
        PosColumn(
            text: map['quantity'].toString(),
            width: 2,
            styles: const PosStyles(bold: false, align: PosAlign.center)),
        PosColumn(
            text: (double.tryParse(map['unit_price'].toString()) ?? 0.0)
                .toStringAsFixed(2),
            width: 3,
            styles: const PosStyles(bold: false, align: PosAlign.center)),
        PosColumn(
            text: (initData['total']).toStringAsFixed(2),
            width: 3,
            styles: const PosStyles(bold: false, align: PosAlign.center)),
      ]);
    }
    bytes += ticket.hr(ch: '_');
    bytes += ticket.text(
        'Subtotal:  Ksh ' + (initData['total']).toStringAsFixed(2),
        styles: const PosStyles(bold: false, align: PosAlign.right));
    bytes += ticket.text(
        'Discount:  -Ksh ' + (initData['calDiscount']).toStringAsFixed(2),
        styles: const PosStyles(bold: false, align: PosAlign.right));
    bytes += ticket.text(
        'Tax(${initData['taxName']}):  +Ksh ' +
            (initData['calTax']).toStringAsFixed(2),
        styles: const PosStyles(bold: false, align: PosAlign.right));
    bytes += ticket.text(
        'Shipping Charge:  +Ksh ' +
            (initData['shipping_charges'] ?? 0.0).toStringAsFixed(2),
        styles: const PosStyles(bold: false, align: PosAlign.right));
    bytes += ticket.text(
        'Total:  Ksh ' +
            (initData['total'] - initData['calDiscount'] + initData['calTax'])
                .toStringAsFixed(2),
        styles: const PosStyles(bold: false, align: PosAlign.right));
    bytes += ticket.text('Payment Method: ${initData['payments'][0]['method']}',
        styles: const PosStyles(bold: false, align: PosAlign.right));
    bytes += ticket.hr(ch: '_');

    bytes.addAll(await sellInvoiceBottomBlue(paper, cProfile,
        Provider.of<HeadersFootersProvider>(context, listen: false).footers));
    bytes += ticket.feed(2);
    bytes += ticket.cut();

    return bytes;
  }

  List<pw.Widget> genInvoice() {
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
                      width: 80.0, child: pw.Text(map['name'].toString())),
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
                        initData['discount'],
                        initData['discountType'],
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
                  pw.Text('Subtotal:  Ksh ' +
                      (initData['total']).toStringAsFixed(2)),
                ]))));

    posLines.add(pw.Padding(
        padding: const pw.EdgeInsets.all(1.0),
        child: pw.Align(
            alignment: pw.Alignment.bottomRight,
            child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text('Discount:  -Ksh ' +
                      (initData['calDiscount']).toStringAsFixed(2)),
                ]))));

    posLines.add(pw.Padding(
        padding: const pw.EdgeInsets.all(1.0),
        child: pw.Align(
            alignment: pw.Alignment.bottomRight,
            child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text('Tax(${initData['taxName']}):  +Ksh ' +
                      (initData['calTax']).toStringAsFixed(2)),
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
                          (initData['total'] -
                                  initData['calDiscount'] +
                                  initData['calTax'])
                              .toStringAsFixed(2),
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
                  pw.Text(
                      'Payment Method: ${initData['payments'][0]['method']}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ]))));

    //DATA END
    posLines.add(pw.Divider());

    posLines.addAll(sellInvoiceBottom(
        Provider.of<HeadersFootersProvider>(context, listen: false).footers));

    return posLines;
  }

  List<POSLine> genInvoiceSDK() {
    if (initData['invoice_no'] == null) {
      initData['invoice_no'] = getRandomId();
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
      format: '%${max(1,((26-('RECEIPT').length)/2).toInt())}s %1s %-${max(1, min(28,((26-('RECEIPT').length)).toInt()))}s %1s %${max(1,((26-('RECEIPT').length)/2).toInt())}s ',

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
          col5: (getSubTotal(
            0,
            map['quantity'] ?? 0,
            map['unit_price'] ?? 0,
            initData['discount'],
            initData['discountType'],
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
        col5: 'Ksh ${(initData['total'] ?? 0.0).toStringAsFixed(2)}',
        bold: false.toString(),
        font: 'small',
        bitmap: ''));
    posLines.add(POSLine(
        col1: ' ',
        col2: ' ',
        col3: ' ',
        col4: 'Discount:',
        format: '%-1s %1s %1s %-10s %15s',
        col5: '-Ksh ${(initData['calDiscount'] ?? 0.0).toStringAsFixed(2)}',
        bold: false.toString(),
        font: 'small',
        bitmap: ''));
    posLines.add(POSLine(
        col1: ' ',
        col2: ' ',
        col3: ' ',
        col4: 'Tax(${initData['taxName']}):',
        format: '%-1s %1s %1s %-10s %15s',
        col5: '+Ksh ${(initData['calTax'] ?? 0.0).toStringAsFixed(2)}',
        bold: false.toString(),
        font: 'small',
        bitmap: ''));
    // posLines.add(POSLine(
    //     col1: ' ',
    //     col2: ' ',
    //     col3: ' ',
    //     col4: 'Shipping Charge:',
    //     format: '%-3s %2s %1s %-24s %20s',
    //     col5:
    //         '+Ksh ${(initData['shipping_charges'] ?? 0.0).toStringAsFixed(2)}',
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
            '+Ksh ${(initData['total'] - initData['calDiscount'] + initData['calTax']).toStringAsFixed(2)}',
        bold: true.toString(),
        font: fontLarge,
        bitmap: ''));
    posLines.add(POSLine(
        col1: ' ',
        col2: ' ',
        col3: ' ',
        col4: 'Payment Method:',
        format: '%-1s %1s %1s %-15s %10s',
        col5: 'Ksh ${initData['payments'][0]['method']}',
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

  Future<PrinterBluetooth?>? getPrinterBlu() async {
    final preferences = await SharedPreferences.getInstance();
    final _jd = preferences.getString('blue_device');
    if (_jd != null) {
      final _dev = basic.BluetoothDevice.fromJson(jsonDecode(_jd));
      return PrinterBluetooth(_dev);
    }
    return null;
  }
  String trim2(name) {
    return name
        .toString()
        .substring(0, min(name.toString().length, 20));
  }String trim(name) {
    return name
        .toString()
        .substring(0, min(name.toString().length, 20));
  }
}
