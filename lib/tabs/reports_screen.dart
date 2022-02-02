import 'package:flutter/material.dart';

import '../screens/reports/activity_log_screen.dart';
import '../screens/reports/cust_group.dart';
import '../screens/reports/expense_screen.dart';
import '../screens/reports/items_screen.dart';
import '../screens/reports/product_purchase_screen.dart';
import '../screens/reports/product_sell_screen.dart';
import '../screens/reports/profit_loss_screen.dart';
import '../screens/reports/purchase_payment_screen.dart';
import '../screens/reports/purchase_sell_screen.dart';
import '../screens/reports/register_screen.dart';
import '../screens/reports/sell_payment_screen.dart';
import '../screens/reports/sells_representative_screen.dart';
import '../screens/reports/stocks_adj_screen.dart';
import '../screens/reports/stocks_screen.dart';
import '../screens/reports/supply_customer_screen.dart';
import '../screens/reports/tax_report_screen.dart';
import '../screens/reports/trending_products_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/list_items.dart';

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
                Navigator.of(context)
                    .pushNamed(ReportProfitLossScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Product Purchase Report",
              onClick: () {
                Navigator.of(context)
                    .pushNamed(ReportProductPurchaseScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Sales Representative Report",
              onClick: () {
                Navigator.of(context)
                    .pushNamed(ReportSellRepresentativeScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Register Report",
              onClick: () {
                Navigator.of(context).pushNamed(ReportRegisterScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Expense Report",
              onClick: () {
                Navigator.of(context).pushNamed(ReportExpenseScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Sell Payment Report",
              onClick: () {
                Navigator.of(context)
                    .pushNamed(ReportSellPaymentScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Purchase Payment Report",
              onClick: () {
                Navigator.of(context)
                    .pushNamed(ReportPurchasePaymentScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Product Sell Report",
              onClick: () {
                Navigator.of(context)
                    .pushNamed(ReportProductSellScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Items Report",
              onClick: () {
                Navigator.of(context).pushNamed(ReportItemsScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Purchase & Sell",
              onClick: () {
                Navigator.of(context)
                    .pushNamed(ReportPurchaseSellScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Trending Products",
              onClick: () {
                Navigator.of(context)
                    .pushNamed(ReportTrendingProductScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Stock Adjustment Report",
              onClick: () {
                Navigator.of(context)
                    .pushNamed(ReportStocksAdjScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Stock Report",
              onClick: () {
                Navigator.of(context).pushNamed(ReportStocksScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Customers Group Report",
              onClick: () {
                Navigator.of(context)
                    .pushNamed(ReportCustrGroupScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Supplier & Customer Report",
              onClick: () {
                Navigator.of(context)
                    .pushNamed(ReportSupplyCustScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Tax Report",
              onClick: () {
                Navigator.of(context).pushNamed(ReportTaxScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Activity Log",
              onClick: () {
                Navigator.of(context)
                    .pushNamed(ReportActivityLogScreen.routeName);
              }),
        ],
      ),
    );
  }
}
