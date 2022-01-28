import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class PurchaseOrdersScreen extends StatelessWidget {
  const PurchaseOrdersScreen({Key? key}) : super(key: key);
  static const routeName = '/purchase-order';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),
    );
  }
}
