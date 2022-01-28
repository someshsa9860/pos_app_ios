import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class SellOrderScreen extends StatelessWidget {
  const SellOrderScreen({Key? key}) : super(key: key);
  static const routeName = '/sell-order';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),

    );
  }
}
