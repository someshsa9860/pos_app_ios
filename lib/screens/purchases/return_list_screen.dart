import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class PurchaseReturnListScreen extends StatelessWidget {
  const PurchaseReturnListScreen({Key? key}) : super(key: key);
  static const routeName = '/purchase-return-list';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),
    );
  }
}
