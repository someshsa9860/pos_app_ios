import 'package:flutter/material.dart';
import 'package:pos_app/screens/sell/list_drafts_screen.dart';

import '../screens/sell/add_draft_screen.dart';
import '../screens/sell/add_quotation_screen.dart';
import '../screens/sell/add_screen.dart';
import '../screens/sell/all_screen.dart';
import '../screens/sell/discount_screen.dart';
import '../screens/sell/import_screen.dart';
import '../screens/sell/list_pos_screen.dart';
import '../screens/sell/list_quotation_screen.dart';
import '../screens/sell/list_return_screen.dart';
import '../screens/sell/order_screen.dart';
import '../screens/sell/pos_screen.dart';
import '../screens/sell/shipment_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/content_list_item.dart';

class SellScreen extends StatelessWidget {
  static const routeName = '/sell';

  const SellScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sell'),
      ),
      drawer: AppDrawer(),
      body: ListView(
        children: [
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Sells Order",
              onClick: () {
                Navigator.of(context).pushNamed(SellOrderScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "All Sells",
              onClick: () {
                Navigator.of(context).pushNamed(SellAllScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Add Sell",
              onClick: () {
                Navigator.of(context).pushNamed(SellAddScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "List POS",
              onClick: () {
                Navigator.of(context).pushNamed(SellListPosScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "POS",
              onClick: () {
                Navigator.of(context).pushNamed(SellPOSScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Add Drafts",
              onClick: () {
                Navigator.of(context).pushNamed(SellAddDraftScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "List Drafts",
              onClick: () {
                Navigator.of(context).pushNamed(SellListDraftScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Add Quotation",
              onClick: () {
                Navigator.of(context)
                    .pushNamed(SellAddQuotationScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "List Quotations",
              onClick: () {
                Navigator.of(context)
                    .pushNamed(SellListQuotationScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "List Sell Return",
              onClick: () {
                Navigator.of(context).pushNamed(SellListReturnScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Shipment",
              onClick: () {
                Navigator.of(context).pushNamed(SellShipmentScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Discounts",
              onClick: () {
                Navigator.of(context).pushNamed(SellDiscountScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Import Sells",
              onClick: () {
                Navigator.of(context).pushNamed(SellImportScreen.routeName);
              }),
        ],
      ),
    );
  }
}
