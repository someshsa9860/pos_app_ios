import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class SellAddScreen extends StatelessWidget {
  const SellAddScreen({Key? key}) : super(key: key);
  static const routeName = '/sell-';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),

    );
  }
}