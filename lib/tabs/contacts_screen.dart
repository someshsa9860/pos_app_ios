import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screens/contacts/customers_screen.dart';
import '../screens/contacts/supplier_screen.dart';
import '../widgets/list_items.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  //static const routeName = '/contacts';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ContentListItem(
            icon: Icons.arrow_right_alt_rounded,
            title: "Suppliers",
            onClick: () {
                                    Navigator.pop(context);

              Navigator.of(context)
                  .pushNamed(ContactsSupplierScreen.routeName);
            }),
        ContentListItem(
            icon: Icons.arrow_right_alt_rounded,
            title: "Customers",
            onClick: () {
                                    Navigator.pop(context);

              Navigator.of(context)
                  .pushNamed(ContactsCustomersScreen.routeName);
            }),
        // ContentListItem(
        //     icon: Icons.arrow_right_alt_rounded,
        //     title: "Customer Groups",
        //     onClick: () {
        //                             Navigator.pop(context);

        //       Navigator.of(context).pushNamed(ContactsGroupScreen.routeName);
        //     }),
        // ContentListItem(
        //     icon: Icons.arrow_right_alt_rounded,
        //     title: "Import Contacts",
        //     onClick: () {
        //                             Navigator.pop(context);

        //       Navigator.of(context).pushNamed(ContactsImportScreen.routeName);
        //     }),
      ],
    );
  }
}
