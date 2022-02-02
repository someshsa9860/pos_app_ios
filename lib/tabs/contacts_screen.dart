import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';
import '../widgets/list_items.dart';

import '../screens/contacts/customers_screen.dart';
import '../screens/contacts/group_screen.dart';
import '../screens/contacts/import_screen.dart';
import '../screens/contacts/supplier_screen.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  static const routeName = '/contacts';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: ListView(
        children: [
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Suppliers",
              onClick: () {
                Navigator.of(context)
                    .pushNamed(ContactsSupplierScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Customers",
              onClick: () {
                Navigator.of(context)
                    .pushNamed(ContactsCustomersScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Customer Groups",
              onClick: () {
                Navigator.of(context).pushNamed(ContactsGroupScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Import Contacts",
              onClick: () {
                Navigator.of(context).pushNamed(ContactsImportScreen.routeName);
              }),
        ],
      ),
      drawer: const AppDrawer(),
    );
  }
}
