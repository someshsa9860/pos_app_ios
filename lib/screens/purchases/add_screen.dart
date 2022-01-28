import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class PurchaseAddScreen extends StatelessWidget {
  const PurchaseAddScreen({Key? key}) : super(key: key);
  static const routeName = '/purchase-add';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),
    );
  }
}
