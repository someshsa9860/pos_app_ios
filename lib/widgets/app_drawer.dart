import 'package:flutter/material.dart';
import 'package:pos_app/tabs/expenses_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../tabs/contacts_screen.dart';
import '../tabs/products_screen.dart';
import '../tabs/purchases_screen.dart';
import '../tabs/reports_screen.dart';
import '../tabs/sell_screen.dart';

class AppDrawer extends StatelessWidget {
  static const backOfficeUrl = '';

  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(

      child: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AppBar(
              title: const Text('Account Detail'),
              automaticallyImplyLeading: false,
            ),
            Expanded(
              child: ListView(
                children: [
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.contacts_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Contacts'),
                    onTap: () {
                      Navigator.pushNamed(context, ContactsScreen.routeName);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Image.asset(
                      'assets/products.png',
                      width: 32.0,
                      height: 32.0,
                    ),
                    title: const Text('Products'),
                    onTap: () {
                      Navigator.of(context)
                          .pushReplacementNamed(ProductsScreen.routeName);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.arrow_circle_down_sharp,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Purchases'),
                    onTap: () {
                      Navigator.of(context)
                          .pushReplacementNamed(PurchasesScreen.routeName);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.arrow_circle_up_sharp,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Sell'),
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed(SellScreen.routeName);
                    },
                  ),
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
                      Navigator.of(context)
                          .pushReplacementNamed(ExpensesScreen.routeName);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.auto_graph_sharp,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Reports'),
                    onTap: () {
                      Navigator.of(context)
                          .pushReplacementNamed(ReportsScreen.routeName);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.web,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Back Office Link'),
                    onTap: () async {
                      var result = await launch(backOfficeUrl);
                    },
                  ),
                  const Divider(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
