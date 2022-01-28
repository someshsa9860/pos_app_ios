import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class SellPOSScreen extends StatelessWidget {
  const SellPOSScreen({Key? key}) : super(key: key);
  static const routeName = '/sell-pos';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),

    );
  }
}
