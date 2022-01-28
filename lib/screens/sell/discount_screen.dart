import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class SellDiscountScreen extends StatelessWidget {
  const SellDiscountScreen({Key? key}) : super(key: key);
  static const routeName = '/sell-discount';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),

    );
  }
}
