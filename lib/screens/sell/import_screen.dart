import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class SellImportScreen extends StatelessWidget {
  const SellImportScreen({Key? key}) : super(key: key);
  static const routeName = '/sell-import';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),

    );
  }
}
