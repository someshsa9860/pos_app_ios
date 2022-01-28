import 'package:flutter/material.dart';
import 'package:pos_app/screens/purchases/add_screen.dart';
import 'package:pos_app/screens/purchases/list_screen.dart';
import 'package:pos_app/screens/purchases/orders_screen.dart';
import 'package:pos_app/screens/purchases/return_list_screen.dart';
import 'package:pos_app/widgets/app_drawer.dart';
import 'package:pos_app/widgets/content_list_item.dart';

class PurchasesScreen extends StatelessWidget {
  static const routeName = '/purchases';

  const PurchasesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchases'),
      ),
      drawer: AppDrawer(),
      body: ListView(
        children: [
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Purchase Order",
              onClick: () {
                Navigator.of(context).pushNamed(PurchaseOrdersScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Purchases",
              onClick: () {
                Navigator.of(context).pushNamed(PurchaseListScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Add Purchase",
              onClick: () {
                Navigator.of(context).pushNamed(PurchaseAddScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Purchase Return",
              onClick: () {
                Navigator.of(context)
                    .pushNamed(PurchaseReturnListScreen.routeName);
              }),
        ],
      ),
    );
  }
}
