import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class SellShipmentScreen extends StatelessWidget {
  const SellShipmentScreen({Key? key}) : super(key: key);
  static const routeName = '/sell-shipment';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),

    );
  }
}
