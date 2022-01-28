import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../tabs/contacts_screen.dart';
import '../tabs/products_screen.dart';
import '../tabs/purchases_screen.dart';
import '../tabs/reports_screen.dart';
import '../tabs/sell_screen.dart';

class AppDrawer extends StatelessWidget {
  static const backOfficeUrl = '';

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: const Text('Account Detail'),
            automaticallyImplyLeading: false,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.contacts_outlined),
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
            leading: const Icon(Icons.arrow_circle_down_sharp),
            title: const Text('Purchases'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(PurchasesScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.arrow_circle_up_sharp),
            title: const Text('Sell'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(SellScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(2.0),
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(4.0)),
              child: Text(
                ' - ',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                    color: Theme.of(context).primaryTextTheme.subtitle1!.color),
              ),
            ),
            title: const Text('Expenses'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(SellScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.auto_graph_sharp),
            title: const Text('Reports'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(ReportsScreen.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.web),
            title: const Text('Back Office Link'),
            onTap: () async {
              var result = await launch(backOfficeUrl);
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
