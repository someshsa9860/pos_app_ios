import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class SellListPosScreen extends StatelessWidget {
  const SellListPosScreen({Key? key}) : super(key: key);
  static const routeName = '/sell-list-pos';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),

    );
  }
}
