import 'package:flutter/material.dart';
import 'package:pos_app/data_management/pos_web_links.dart' as web;
import 'package:pos_app/screens/webview.dart';

import '../widgets/list_items.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ContentListItem(
            icon: Icons.arrow_right_alt_rounded,
            title: "Profit / Loss Report",
            onClick: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => const MyWebView(web.profitLossReport)));
            }),
        ContentListItem(
            icon: Icons.arrow_right_alt_rounded,
            title: "Product Purchase Report",
            onClick: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) =>
                      const MyWebView(web.productPurchaseReport)));
            }),
        ContentListItem(
            icon: Icons.arrow_right_alt_rounded,
            title: "Sales Representative Report",
            onClick: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) =>
                      const MyWebView(web.salesRepresentativeReport)));
            }),
        ContentListItem(
            icon: Icons.arrow_right_alt_rounded,
            title: "Register Report",
            onClick: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => const MyWebView(web.registerReport)));
            }),
        ContentListItem(
            icon: Icons.arrow_right_alt_rounded,
            title: "Expense Report",
            onClick: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => const MyWebView(web.expenseReport)));
            }),
        ContentListItem(
            icon: Icons.arrow_right_alt_rounded,
            title: "Sell Payment Report",
            onClick: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => const MyWebView(web.sellPaymentReport)));
            }),
        ContentListItem(
            icon: Icons.arrow_right_alt_rounded,
            title: "Purchase Payment Report",
            onClick: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) =>
                      const MyWebView(web.purchasePaymentReport)));
            }),
        ContentListItem(
            icon: Icons.arrow_right_alt_rounded,
            title: "Product Sell Report",
            onClick: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => const MyWebView(web.productSellReport)));
            }),
        ContentListItem(
            icon: Icons.arrow_right_alt_rounded,
            title: "Items Report",
            onClick: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => const MyWebView(web.itemsReport)));
            }),
        ContentListItem(
            icon: Icons.arrow_right_alt_rounded,
            title: "Purchase & Sell",
            onClick: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => const MyWebView(web.purchaseSell)));
            }),
        ContentListItem(
            icon: Icons.arrow_right_alt_rounded,
            title: "Trending Products",
            onClick: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => const MyWebView(web.trendingProducts)));
            }),
        ContentListItem(
            icon: Icons.arrow_right_alt_rounded,
            title: "Stock Adjustment Report",
            onClick: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) =>
                      const MyWebView(web.stockAdjustmentReport)));
            }),
        ContentListItem(
            icon: Icons.arrow_right_alt_rounded,
            title: "Stock Report",
            onClick: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => const MyWebView(web.stockReport)));
            }),
        ContentListItem(
            icon: Icons.arrow_right_alt_rounded,
            title: "Customers Group Report",
            onClick: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => const MyWebView(web.customerGroup)));
            }),
        ContentListItem(
            icon: Icons.arrow_right_alt_rounded,
            title: "Supplier & Customer Report",
            onClick: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => const MyWebView(web.customerSupplier)));
            }),
        ContentListItem(
            icon: Icons.arrow_right_alt_rounded,
            title: "Tax Report",
            onClick: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => const MyWebView(web.taxReport)));
            }),
        ContentListItem(
            icon: Icons.arrow_right_alt_rounded,
            title: "Activity Log",
            onClick: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => const MyWebView(web.activityLog)));
            }),
      ],
    );
  }
}
