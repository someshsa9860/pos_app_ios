import 'dart:convert';

import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart' as basic;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pos_app/widgets/app_drawer.dart';
import 'package:pos_app/widgets/custom_card.dart';

import 'package:shared_preferences/shared_preferences.dart';

class BluetoothScreen extends StatefulWidget {
  static const routeName = '/bluetooth-screen';

  BluetoothScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return BluetoothScreenState();
  }
}

class BluetoothScreenState extends State<BluetoothScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotate;

  final FlutterBlue _flutterBlue = FlutterBlue.instance;
  var _dev;

  var bluetoothManager = PrinterBluetoothManager();

  PrinterBluetooth? _bluetoothDevice;

  var _scanMode = ScanMode.lowPower;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Bluetooth Printer Setting')),
      body: SizedBox(
          width: size.width,
          height: size.height,
          child: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MyCustomCard(
                    [
                      const Text('Select scan options from below'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text('Low Power'),
                              Radio<ScanMode>(
                                  value: ScanMode.lowPower,
                                  groupValue: _scanMode,
                                  onChanged: (mode) {
                                    setState(() {
                                      _scanMode = mode ?? _scanMode;
                                     scan();
                                    });
                                  }),
                            ],
                          ),
                          Row(
                            children: [
                              const Text('Low Latency'),
                              Radio<ScanMode>(
                                  value: ScanMode.lowLatency,
                                  groupValue: _scanMode,
                                  onChanged: (mode) {
                                    setState(() {
                                      _scanMode = mode ?? _scanMode;
                                     scan();
                                    });
                                  }),
                            ],
                          ),
                          Row(
                            children: [
                              const Text('balanced'),
                              Radio<ScanMode>(
                                  value: ScanMode.balanced,
                                  groupValue: _scanMode,
                                  onChanged: (mode) {
                                    setState(() {
                                      _scanMode = mode ?? _scanMode;
                                     scan();
                                    });
                                  }),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text('opportunistic'),
                              Radio<ScanMode>(
                                  value: ScanMode.opportunistic,
                                  groupValue: _scanMode,
                                  onChanged: (mode) {
                                    setState(() {
                                      _scanMode = mode ?? _scanMode;
                                     scan();
                                    });
                                  }),
                            ],
                          ),
                          // Row(
                          //   children: [
                          //     ElevatedButton(
                          //         onPressed: () {
                          //           _devices = [];
                          //
                          //           getPairedDevices();
                          //         },
                          //         child: const Text('paired devices')),
                          //   ],
                          // ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Selected printer (address):',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(_bluetoothDevice == null ||
                                  _bluetoothDevice!.address == null
                              ? 'unavailable'
                              : _bluetoothDevice!.address ?? ''),
                          IconButton(
                              onPressed: () {
                                scan();
                              },
                              icon: RotationTransition(
                                  turns: _rotate,
                                  child: Icon(
                                    Icons.sync,
                                    color: Theme.of(context).primaryColor,
                                  ))),
                        ],
                      ),
                    ],
                    topLeft: 0.0,
                    topRight: 0.0,
                    bottomLeft: 16.0,
                    bottomRight: 16.0,
                  )),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MyCustomCard(
                    [
                      _devices.isEmpty
                          ? const Center(
                              child: Text('Bluetooth Device not found'),
                            )
                          : Column(
                              children: _devices
                                  .map((e) => ListTile(
                                        onTap: () {
                                          _bluetoothDevice = e;
                                          _dev =
                                              basic.BluetoothDevice.fromJson({
                                            'name': _bluetoothDevice == null
                                                ? null
                                                : _bluetoothDevice!.name,
                                            'address': _bluetoothDevice == null
                                                ? null
                                                : _bluetoothDevice!.address,
                                            'type': _bluetoothDevice == null
                                                ? null
                                                : _bluetoothDevice!.type,
                                            'connected': true,
                                          });
                                          setState(() {});
                                          save();
                                        },
                                        title: Text(e.name ?? 'Unnamed'),
                                        subtitle: Text(e.address ?? 'Unnamed'),
                                        trailing: _bluetoothDevice != null &&
                                                (_bluetoothDevice!.address ==
                                                    e.address)
                                            ? const Icon(Icons.check)
                                            : null,
                                      ))
                                  .toList(),
                            ),
                    ],
                    topLeft: 8.0,
                    topRight: 8.0,
                    bottomLeft: 0.0,
                    bottomRight: 0.0,
                  ),
                ),
              )
            ],
          )),
    );
  }

  List<PrinterBluetooth> _devices = [];

  scan() async {
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
    setState(() {
      _devices = [];
    });
    _controller.reset();
    _controller.forward();
    final scanning=_flutterBlue.isScanning;

    try {
      // bluetoothManager.s
      _flutterBlue
          .startScan(scanMode: _scanMode, timeout: const Duration(seconds: 4))
          .whenComplete(() => _controller.reset());
      _flutterBlue.scanResults.listen((event) {
        if (!mounted) {
          return;
        }

        if (event.isNotEmpty) {
          for (var result in event) {
            print(result.device.name);
            var item = PrinterBluetooth(basic.BluetoothDevice.fromJson({
              'name': result.device.name.isEmpty?'name not available':result.device.name.isEmpty,
              'address': result.device.id.id,
              'type': result.device.type.index,
              'connected': true,
            }));
            var index = _devices
                .indexWhere((element) => element.address == item.address);
            if (index == -1) {
              _devices.add(item);
              print(({
                'name': result.device.name,
                'address': result.device.id.id,
                'type': result.device.type.index,
                'connected': true,
              }).toString());
            }
          }
          setState(() {
            _devices = _devices.toSet().toList();
            //_devices = devices;
          });
        }
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'please turn on bluetooth');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 4000));

    _rotate = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _rotate.addListener(() {
      setState(() {});
    });
    init();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  init() async {
    final preferences = await SharedPreferences.getInstance();
    final _jd = preferences.getString('blue_device');
    if (_jd != null) {
      _dev = basic.BluetoothDevice.fromJson(jsonDecode(_jd));
      _bluetoothDevice = PrinterBluetooth(_dev!);
      setState(() {});
    }
    _devices = [];

    //getPairedDevices();
  }

  void save() async {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
    final preferences = await SharedPreferences.getInstance();
    preferences.setString('blue_device', jsonEncode(_dev!.toJson()));
  }

  // getPairedDevices() async {
  //   var on = await _flutterBlue.isOn;
  //   if (!on) {
  //     Fluttertoast.showToast(msg: 'please turn on bluetooth');
  //     return;
  //   }
  //
  //   _controller.reset();
  //   _controller.forward();
  //   try {
  //     List<Object?>? clist = await PrinterOne.bluetooth;
  //
  //     if (clist != null && clist.isNotEmpty) {
  //       for (var result in clist) {
  //         result as Map<Object?, Object?>;
  //         var item = PrinterBluetooth(basic.BluetoothDevice.fromJson({
  //           'name': result['name'],
  //           'address': result['address'],
  //           'type': result['type'],
  //           'connected': true,
  //         }));
  //
  //         var index =
  //             _devices.indexWhere((element) => element.address == item.address);
  //         if (index == -1) {
  //           _devices.add(item);
  //         }
  //       }
  //       setState(() {
  //         _devices = _devices.toSet().toList();
  //       });
  //     }
  //   } catch (e) {
  //     Fluttertoast.showToast(msg: e.toString());
  //   }
  // }
}
