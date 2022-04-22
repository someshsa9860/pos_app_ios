import 'package:flutter/material.dart';

import '../screens/sell/add_screen.dart';
import '../screens/sell/all_screen.dart';

import '../screens/sell/list_return_screen.dart';

import '../widgets/app_drawer.dart';
import '../widgets/list_items.dart';

class SellScreen extends StatelessWidget {

  const SellScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      mainAxisSize: MainAxisSize.min,
        children: [
          // ContentListItem(
          //     icon: Icons.arrow_right_alt_rounded,
          //     title: "Sells Order",
          //     onClick: () {
          //                             Navigator.pop(context);

          //       Navigator.of(context).pushNamed(SellOrderScreen.routeName);
          //     }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "All Sells",
              onClick: () {
                                      Navigator.pop(context);

                Navigator.of(context).pushNamed(SellAllScreen.routeName,arguments: [-1]);
              }),
          // ContentListItem(
          //     icon: Icons.arrow_right_alt_rounded,
          //     title: "Add Sell",
          //     onClick: () {
          //                             Navigator.pop(context);
          //
          //       Navigator.of(context).pushNamed(SellAddScreen.routeName,arguments: [-1]);
          //     }),
          // ContentListItem(
          //     icon: Icons.arrow_right_alt_rounded,
          //     title: "List POS",
          //     onClick: () {
          //                             Navigator.pop(context);

          //       Navigator.of(context).pushNamed(SellListPosScreen.routeName);
          //     }),
          // ContentListItem(
          //     icon: Icons.arrow_right_alt_rounded,
          //     title: "POS",
          //     onClick: () {
          //                             Navigator.pop(context);

          //       Navigator.of(context).pushNamed(SellPOSScreen.routeName);
          //     }),
          // ContentListItem(
          //     icon: Icons.arrow_right_alt_rounded,
          //     title: "Add Drafts",
          //     onClick: () {
          //                             Navigator.pop(context);

          //       Navigator.of(context).pushNamed(SellAddDraftScreen.routeName);
          //     }),
          // ContentListItem(
          //     icon: Icons.arrow_right_alt_rounded,
          //     title: "List Drafts",
          //     onClick: () {
          //                             Navigator.pop(context);

          //       Navigator.of(context).pushNamed(SellListDraftScreen.routeName);
          //     }),
          // ContentListItem(
          //     icon: Icons.arrow_right_alt_rounded,
          //     title: "Add Quotation",
          //     onClick: () {
          //       Navigator.of(context)
          //           .pushNamed(SellAddQuotationScreen.routeName);
          //     }),
          // ContentListItem(
          //     icon: Icons.arrow_right_alt_rounded,
          //     title: "List Quotations",
          //     onClick: () {
          //       Navigator.of(context)
          //           .pushNamed(SellListQuotationScreen.routeName);
          //     }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "List Sell Return",
              onClick: () {
                                      Navigator.pop(context);

                Navigator.of(context).pushNamed(SellListReturnScreen.routeName);
              }),
          // ContentListItem(
          //     icon: Icons.arrow_right_alt_rounded,
          //     title: "Shipment",
          //     onClick: () {
          //                             Navigator.pop(context);

          //       Navigator.of(context).pushNamed(SellShipmentScreen.routeName);
          //     }),
          // ContentListItem(
          //     icon: Icons.arrow_right_alt_rounded,
          //     title: "Discounts",
          //     onClick: () {
          //                             Navigator.pop(context);

          //       Navigator.of(context).pushNamed(SellDiscountScreen.routeName);
          //     }),
          // ContentListItem(
          //     icon: Icons.arrow_right_alt_rounded,
          //     title: "Import Sells",
          //     onClick: () {
          //                             Navigator.pop(context);

          //       Navigator.of(context).pushNamed(SellImportScreen.routeName);
          //     }),
        ],
    );
  }
}
