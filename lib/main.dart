import 'package:flutter/material.dart';

import '../screens/contacts/customers_screen.dart';
import '../screens/contacts/group_screen.dart';
import '../screens/contacts/import_screen.dart';
import '../screens/contacts/supplier_screen.dart';
import '../screens/products/add_screen.dart';
import '../screens/products/brands_screen.dart';
import '../screens/products/categories_screen.dart';
import '../screens/products/imports_screen.dart';
import '../screens/products/list_screen.dart';
import '../screens/products/print_label_screen.dart';
import '../screens/products/selling_pr_gr_screen.dart';
import '../screens/products/units_screen.dart';
import '../screens/products/variations_screen.dart';
import '../screens/products/warranties_screen.dart';
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
import '../screens/sell/add_draft_screen.dart';
import '../screens/sell/add_quotation_screen.dart';
import '../screens/sell/add_screen.dart';
import '../screens/sell/all_screen.dart';
import '../screens/sell/discount_screen.dart';
import '../screens/sell/import_screen.dart';
import '../screens/sell/list_drafts_screen.dart';
import '../screens/sell/list_pos_screen.dart';
import '../screens/sell/list_quotation_screen.dart';
import '../screens/sell/list_return_screen.dart';
import '../screens/sell/order_screen.dart';
import '../screens/sell/pos_screen.dart';
import '../screens/sell/shipment_screen.dart';
import '../tabs/contacts_screen.dart';
import '../tabs/expenses_screen.dart';
import '../tabs/products_screen.dart';
import '../tabs/purchases_screen.dart';
import '../tabs/reports_screen.dart';
import '../tabs/sell_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RENOTECH',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
      routes: {
        ContactsScreen.routeName: (ctx) => const ContactsScreen(),
        ExpensesScreen.routeName: (ctx) => const ExpensesScreen(),
        ProductsScreen.routeName: (ctx) => const ProductsScreen(),
        PurchasesScreen.routeName: (ctx) => const PurchasesScreen(),
        ReportsScreen.routeName: (ctx) => const ReportsScreen(),
        SellScreen.routeName: (ctx) => const SellScreen(),
        ContactsCustomersScreen.routeName: (ctx) =>
            const ContactsCustomersScreen(),
        ContactsGroupScreen.routeName: (ctx) => const ContactsGroupScreen(),
        ContactsImportScreen.routeName: (ctx) => const ContactsImportScreen(),
        ContactsSupplierScreen.routeName: (ctx) =>
            const ContactsCustomersScreen(),
        ProductsAddScreen.routeName: (ctx) => const ProductsAddScreen(),
        ProductsBrandsScreen.routeName: (ctx) => const ProductsBrandsScreen(),
        ProductsCategoriesScreen.routeName: (ctx) =>
            const ProductsCategoriesScreen(),
        ProductsImportScreen.routeName: (ctx) => const ProductsImportScreen(),
        ProductsListScreen.routeName: (ctx) => const ProductsListScreen(),
        ProductsPrintLabelScreen.routeName: (ctx) =>
            const ProductsPrintLabelScreen(),
        ProductsPriceGroupScreen.routeName: (ctx) =>
            const ProductsPriceGroupScreen(),
        ProductsUnitsScreen.routeName: (ctx) => const ProductsUnitsScreen(),
        ProductsVariationsScreen.routeName: (ctx) =>
            const ProductsVariationsScreen(),
        ProductsWarrantiesScreen.routeName: (ctx) =>
            const ProductsWarrantiesScreen(),
        ReportActivityLogScreen.routeName: (ctx) =>
            const ReportActivityLogScreen(),
        ReportCustrGroupScreen.routeName: (ctx) =>
            const ReportCustrGroupScreen(),
        ReportExpenseScreen.routeName: (ctx) => const ReportExpenseScreen(),
        ReportItemsScreen.routeName: (ctx) => const ReportItemsScreen(),
        ReportProductPurchaseScreen.routeName: (ctx) =>
            const ReportProductPurchaseScreen(),
        ReportProductSellScreen.routeName: (ctx) =>
            const ReportProductSellScreen(),
        ReportProfitLossScreen.routeName: (ctx) =>
            const ReportProfitLossScreen(),
        ReportPurchasePaymentScreen.routeName: (ctx) =>
            const ReportPurchasePaymentScreen(),
        ReportPurchaseSellScreen.routeName: (ctx) =>
            const ReportPurchaseSellScreen(),
        ReportRegisterScreen.routeName: (ctx) => const ReportRegisterScreen(),
        ReportSellPaymentScreen.routeName: (ctx) =>
            const ReportSellPaymentScreen(),
        ReportSellRepresentativeScreen.routeName: (ctx) =>
            const ReportSellRepresentativeScreen(),
        ReportStocksAdjScreen.routeName: (ctx) => const ReportStocksAdjScreen(),
        ReportStocksScreen.routeName: (ctx) => const ReportStocksScreen(),
        ReportSupplyCustScreen.routeName: (ctx) =>
            const ReportSupplyCustScreen(),
        ReportTaxScreen.routeName: (ctx) => const ReportTaxScreen(),
        ReportTrendingProductScreen.routeName: (ctx) =>
            const ReportTrendingProductScreen(),
        SellAddDraftScreen.routeName: (ctx) => const SellAddDraftScreen(),
        SellAddQuotationScreen.routeName: (ctx) =>
            const SellAddQuotationScreen(),
        SellAddScreen.routeName: (ctx) => const SellAddScreen(),
        SellAllScreen.routeName: (ctx) => const SellAllScreen(),
        SellDiscountScreen.routeName: (ctx) => const SellDiscountScreen(),
        SellImportScreen.routeName: (ctx) => const SellImportScreen(),
        SellListDraftScreen.routeName: (ctx) => const SellListDraftScreen(),
        SellListPosScreen.routeName: (ctx) => const SellListPosScreen(),
        SellListQuotationScreen.routeName: (ctx) =>
            const SellListQuotationScreen(),
        SellListReturnScreen.routeName: (ctx) => const SellListReturnScreen(),
        SellOrderScreen.routeName: (ctx) => const SellOrderScreen(),
        SellPOSScreen.routeName: (ctx) => const SellPOSScreen(),
        SellShipmentScreen.routeName: (ctx) => const SellShipmentScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _passwordFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();

  final bool _visibility = false;
  String _username = "null";
  String _password = "null";

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
      ),
      body: Form(
        key: _form,
        child: ListView(
          children: [
            TextFormField(
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_passwordFocusNode);
              },
              validator: (v) {
                if (v!.isEmpty) {
                  return 'Please enter title';
                }
                return null;
              },
              onSaved: (v) {
                _username = v!;
              },
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Title'),
            ),
            TextFormField(
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.text,
              obscureText: !_visibility,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_passwordFocusNode);
              },
              onSaved: (v) {
                _password = v!;
              },
              validator: (v) {
                if (v!.isEmpty) {
                  return 'Please enter price';
                }

                return null;
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Price',
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  if (saveForm()) {
                  } else {
                    //
                  }
                },
                child: const Text('Login'))
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    super.dispose();
  }

  bool saveForm() {
    bool valid = _form.currentState!.validate();
    if (!valid) {
      return false;
    }
    _form.currentState!.save();
    return true;
  }
}
