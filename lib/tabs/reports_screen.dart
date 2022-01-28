import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';
import 'package:pos_app/widgets/content_list_item.dart';

class ReportsScreen extends StatelessWidget {
  static const routeName = '/reports';

  const ReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      drawer: AppDrawer(),
      body: ListView(
        children: [
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Profit / Loss Report",
              onClick: () {
                Navigator.of(context).pushNamed(ReportsProfitLossScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Product Purchase Report",
              onClick: () {
                Navigator.of(context).pushNamed(ReportsProductPurchaseScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Sales Representative Report",
              onClick: () {
                Navigator.of(context)
                    .pushNamed(ReportsSalesRepreScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Register Report",
              onClick: () {
                Navigator.of(context)
                    .pushNamed(ReportsRegScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Expense Report",
              onClick: () {
                Navigator.of(context).pushNamed(ReportsExpenseScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Sell Payment Report",
              onClick: () {
                Navigator.of(context)
                    .pushNamed(ReportsSellPaymentScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Purchase Payment Report",
              onClick: () {
                Navigator.of(context).pushNamed(ReportsPurchasePaymentScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Product Sell Report",
              onClick: () {
                Navigator.of(context)
                    .pushNamed(ReportsProductSellScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Items Report",
              onClick: () {
                Navigator.of(context).pushNamed(ReportsItemsScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Purchase & Sell",
              onClick: () {
                Navigator.of(context)
                    .pushNamed(ReportsPurchaseSellScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Trending Products",
              onClick: () {
                Navigator.of(context)
                    .pushNamed(ReportsTrendingProductsScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Stock Adjustment Report",
              onClick: () {
                Navigator.of(context)
                    .pushNamed(ReportsStockAdjScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Stock Report",
              onClick: () {
                Navigator.of(context)
                    .pushNamed(ReportsStocksScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Customers Group Report",
              onClick: () {
                Navigator.of(context)
                    .pushNamed(ReportsCustGroupScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Supplier & Customer Report",
              onClick: () {
                Navigator.of(context)
                    .pushNamed(ReportsSuplyerCustScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Tax Report",
              onClick: () {
                Navigator.of(context)
                    .pushNamed(ReportsTaxScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Activity Log",
              onClick: () {
                Navigator.of(context)
                    .pushNamed(ReportsActivitityLogScreen.routeName);
              }),
        ],
      ),
    );
  }
}
