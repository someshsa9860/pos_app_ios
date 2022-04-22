import 'package:flutter/cupertino.dart';
import 'package:pos_app/screens/bluetooth_printer.dart';
import 'package:pos_app/screens/contacts/supplier_screen.dart';
import 'package:pos_app/screens/home.dart';
import 'package:pos_app/screens/login_screen.dart';
import 'package:pos_app/screens/products/category_screen.dart';
import 'package:pos_app/screens/products/list_screen.dart';
import 'package:pos_app/screens/sell/list_return_screen.dart';
import 'package:pos_app/screens/sell/pos_all_screen.dart';
import 'package:pos_app/screens/sell/pos_screen.dart';
import 'package:pos_app/screens/settings.dart';

import '../screens/contacts/add_contact_screen.dart';
import '../screens/contacts/customers_screen.dart';
import '../screens/expenses/add_screen.dart';
import '../screens/expenses/list_screen.dart';
import '../screens/products/brands_screen.dart';
import '../screens/products/selling_pr_gr_screen.dart';
import '../screens/products/units_screen.dart';
import '../screens/products/variations_screen.dart';
import '../screens/reports/profit_loss_screen.dart';
import '../screens/sell/add_screen.dart';
import '../screens/sell/all_screen.dart';

Map<String, WidgetBuilder> getRoutes() {
  return {
    AddContact.routeName: (ctx) => const AddContact(),
    PosAllScreen.routeName: (ctx) => const PosAllScreen(),
    MyHomePage.routeName: (ctx) => const MyHomePage(),
    ContactsSupplierScreen.routeName: (ctx) => const ContactsSupplierScreen(),
    ProductsListScreen.routeName: (ctx) => const ProductsListScreen(),
    SellListReturnScreen.routeName: (ctx) => const SellListReturnScreen(),
    ExpensesAddScreen.routeName: (ctx) => const ExpensesAddScreen(),
    ExpensesListScreen.routeName: (ctx) => const ExpensesListScreen(),
    BluetoothScreen.routeName: (ctx) => BluetoothScreen(),
    AppSettings.routeName: (ctx) => const AppSettings(),
    ContactsCustomersScreen.routeName: (ctx) => const ContactsCustomersScreen(),
    ProductsBrandsScreen.routeName: (ctx) => const ProductsBrandsScreen(),
    ProductsCategoryScreen.routeName: (ctx) => const ProductsCategoryScreen(),
    ProductsPriceGroupScreen.routeName: (ctx) =>
        const ProductsPriceGroupScreen(),
    ProductsUnitsScreen.routeName: (ctx) => const ProductsUnitsScreen(),
    ProductsVariationsScreen.routeName: (ctx) =>
        const ProductsVariationsScreen(),
    SellAddScreen.routeName: (ctx) => const SellAddScreen(),
    POSScreen.routeName: (ctx) => const POSScreen(),
    SellAllScreen.routeName: (ctx) => const SellAllScreen(),
    Login.routeName: (ctx) => const Login(),
    ReportProfitLossScreen.routeName: (ctx) => const ReportProfitLossScreen(),
  };
}
