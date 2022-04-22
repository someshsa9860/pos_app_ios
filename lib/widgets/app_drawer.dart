import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pos_app/provider/auth_provider.dart';
import 'package:pos_app/screens/home.dart';
import 'package:pos_app/screens/sell/pos_screen.dart';
import 'package:pos_app/screens/settings.dart';
import 'package:pos_app/screens/webview.dart';
import 'package:pos_app/tabs/contacts_screen.dart';
import 'package:pos_app/tabs/expenses_screen.dart';
import 'package:pos_app/tabs/products_screen.dart';
import 'package:pos_app/tabs/reports_screen.dart';
import 'package:pos_app/tabs/sell_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/auth_provider.dart';
import '../provider/customer_provider.dart';
import '../provider/expense_provider.dart';
import '../provider/location_provider.dart';
import '../provider/paccounts_provider.dart';
import '../provider/pmethods_provider.dart';
import '../provider/pos_provider.dart';
import '../provider/products_brands_provider.dart';
import '../provider/products_category_provider.dart';
import '../provider/products_provider.dart';
import '../provider/products_stock_provider.dart';
import '../provider/products_units_provider.dart';
import '../provider/products_var_provider.dart';
import '../provider/reports_provider.dart';
import '../provider/sell_provider.dart';
import '../provider/sell_return_provider.dart';
import '../provider/selling_group_provider.dart';
import '../provider/supplier_provider.dart';
import '../provider/tax_provider.dart';
import '../provider/user_provider.dart';
import '../screens/sell/pos_screen.dart';

enum CurrentTab { none, contacts, purchases, sell, products, expenses, reports }

CurrentTab currentTab = CurrentTab.none;
const backOfficeUrl = 'https://pospoa.com/pos/home';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AppBar(
              title: const Text('Navigation'),
              automaticallyImplyLeading: false,
            ),
            Expanded(
              child: ListView(
                children: [
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.home,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('POS'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushNamed(POSScreen.routeName);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.contacts_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Contacts'),
                    onTap: () {
                      if (currentTab == CurrentTab.contacts) {
                        currentTab = CurrentTab.none;
                        setState(() {});
                        return;
                      }
                      currentTab = CurrentTab.contacts;
                      setState(() {});
                    },
                  ),
                  if (currentTab == CurrentTab.contacts) const ContactsScreen(),
                  const Divider(),
                  ListTile(
                    leading: Image.asset(
                      'assets/products.png',
                      width: 32.0,
                      height: 32.0,
                    ),
                    title: const Text('Products'),
                    onTap: () {
                      if (currentTab == CurrentTab.products) {
                        currentTab = CurrentTab.none;
                        setState(() {});
                        return;
                      }
                      currentTab = CurrentTab.products;
                      setState(() {});
                    },
                  ),
                  if (currentTab == CurrentTab.products) const ProductsScreen(),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.arrow_circle_up_sharp,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Sell'),
                    onTap: () {
                      if (currentTab == CurrentTab.sell) {
                        currentTab = CurrentTab.none;
                        setState(() {});
                        return;
                      }
                      currentTab = CurrentTab.sell;
                      setState(() {});
                    },
                  ),
                  if (currentTab == CurrentTab.sell) const SellScreen(),
                  const Divider(),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                          border: Border.all(
                            width: 1.0,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          borderRadius: BorderRadius.circular(16.0)),
                      child: Text(
                        ' - ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                    title: const Text('Expenses'),
                    onTap: () {
                      if (currentTab == CurrentTab.expenses) {
                        currentTab = CurrentTab.none;
                        setState(() {});
                        return;
                      }
                      currentTab = CurrentTab.expenses;
                      setState(() {});
                    },
                  ),
                  if (currentTab == CurrentTab.expenses) const ExpensesScreen(),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.auto_graph_sharp,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Reports'),
                    onTap: () {
                      if (currentTab == CurrentTab.reports) {
                        currentTab = CurrentTab.none;
                        setState(() {});
                        return;
                      }
                      currentTab = CurrentTab.reports;
                      setState(() {});
                    },
                  ),
                  if (currentTab == CurrentTab.reports) const ReportsScreen(),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.settings,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Settings'),
                    onTap: () {
                      Navigator.of(context).pushNamed(AppSettings.routeName);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.exit_to_app,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Close'),
                    onTap: () {
                      if (Platform.isAndroid) {
                        Navigator.pop(context);
                        SystemNavigator.pop();
                      } else {
                        Navigator.of(context).pushReplacementNamed('/');
                      }
                    },
                  ),
                  const Divider(),

                  ListTile(
                    leading: Icon(
                      Icons.power_settings_new_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Logout'),
                    onTap: ()=>logout(false),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.web,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Back Office Link'),
                    onTap: () async {
                      Navigator.pop(context);
                      // await launch(backOfficeUrl);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => const MyWebView(backOfficeUrl)));
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    _opacity = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    super.initState();
  }

  logout(bool delete) async {
    Navigator.pop(context);
    Provider.of<AuthProvider>(context, listen: false).logout();
    Provider.of<ProductsStockProvider>(context, listen: false).logout();
    Provider.of<ExpenseProvider>(context, listen: false).logout();
    Provider.of<CustomerProvider>(context, listen: false).logout();
    Provider.of<SupplierProvider>(context, listen: false).logout();
    Provider.of<LocationProvider>(context, listen: false).logout();
    Provider.of<PaymentAccountProvider>(context, listen: false).logout();
    Provider.of<PaymentMethodsProvider>(context, listen: false).logout();
    Provider.of<ProductsProvider>(context, listen: false).logout();
    Provider.of<PosProvider>(context, listen: false).logout();
    Provider.of<SellProvider>(context, listen: false).logout();
    Provider.of<SellingGroupProvider>(context, listen: false).logout();
    Provider.of<ProductsBrandProvider>(context, listen: false).logout();
    Provider.of<ProductCategoryProvider>(context, listen: false).logout();
    Provider.of<ProductsUnitsProvider>(context, listen: false).logout();
    Provider.of<ProductsVarProvider>(context, listen: false).logout();
    Provider.of<SellReturnProvider>(context, listen: false).logout();
    Provider.of<ReportsProvider>(context, listen: false).logout();
    Provider.of<TaxProvider>(context, listen: false).logout();
    Provider.of<UsersProvider>(context, listen: false).logout();
    Navigator.pushReplacementNamed(context, MyHomePage.routeName,
        arguments: delete);
    final preferences = await SharedPreferences.getInstance();

    preferences.setString('user', '');

  }
}
