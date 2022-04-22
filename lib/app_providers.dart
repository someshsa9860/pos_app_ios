import 'package:pos_app/provider/customer_provider.dart';
import 'package:pos_app/provider/headers_footers_provider.dart';
import 'package:pos_app/provider/location_provider.dart';
import 'package:pos_app/provider/paccounts_provider.dart';
import 'package:pos_app/provider/pmethods_provider.dart';
import 'package:pos_app/provider/pos_provider.dart';
import 'package:pos_app/provider/products_category_provider.dart';
import 'package:pos_app/provider/supplier_provider.dart';
import 'package:pos_app/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../provider/auth_provider.dart';
import '../provider/expense_provider.dart';
import '../provider/products_brands_provider.dart';
import '../provider/products_provider.dart';
import '../provider/products_stock_provider.dart';
import '../provider/products_units_provider.dart';
import '../provider/products_var_provider.dart';
import '../provider/reports_provider.dart';
import '../provider/sell_provider.dart';
import '../provider/sell_return_provider.dart';
import '../provider/selling_group_provider.dart';
import '../provider/tax_provider.dart';

List<SingleChildWidget> getProviders() {
  return [
    ChangeNotifierProvider(
      create: (ctx) => AuthProvider(),
    ),
    ChangeNotifierProvider(
      create: (ctx) => PosProvider(),
    ),
    ChangeNotifierProvider(
      create: (ctx) => CustomerProvider(),
    ),
    ChangeNotifierProvider(
      create: (ctx) => SupplierProvider(),
    ),
    ChangeNotifierProvider(
      create: (ctx) => LocationProvider(),
    ),
    ChangeNotifierProvider(
      create: (ctx) => PaymentAccountProvider(),
    ),
    ChangeNotifierProvider(
      create: (ctx) => PaymentMethodsProvider(),
    ),
    ChangeNotifierProvider(
      create: (ctx) => UsersProvider(),
    ),
    ChangeNotifierProvider(
      create: (ctx) => ExpenseProvider(),
    ),
    ChangeNotifierProvider(
      create: (ctx) => ProductsProvider(),
    ),
    ChangeNotifierProvider(
      create: (ctx) => SellProvider(),
    ),
    ChangeNotifierProvider(
      create: (ctx) => SellingGroupProvider(),
    ),
    ChangeNotifierProvider(
      create: (ctx) => ReportsProvider(),
    ),
    ChangeNotifierProvider(
      create: (ctx) => HeadersFootersProvider(),
    ),
    ChangeNotifierProvider(
      create: (ctx) => ProductsBrandProvider(),
    ),
    ChangeNotifierProvider(
      create: (ctx) => ProductCategoryProvider(),
    ),
    ChangeNotifierProvider(
      create: (ctx) => ProductsUnitsProvider(),
    ),
    ChangeNotifierProvider(
      create: (ctx) => ProductsVarProvider(),
    ),
    ChangeNotifierProvider(
      create: (ctx) => SellReturnProvider(),
    ),
    ChangeNotifierProvider(
      create: (ctx) => ProductsStockProvider(),
    ),
    ChangeNotifierProvider(
      create: (ctx) => TaxProvider(),
    ),
  ];
}
