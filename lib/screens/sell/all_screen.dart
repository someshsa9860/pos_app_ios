import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class SellAllScreen extends StatelessWidget {
  const SellAllScreen({Key? key}) : super(key: key);
  static const routeName = '/sell-all';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),

    );
  }
}
