import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class SellListReturnScreen extends StatelessWidget {
  const SellListReturnScreen({Key? key}) : super(key: key);
  static const routeName = '/sell-list-return';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),

    );
  }
}
