import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class ContactsCustomersScreen extends StatelessWidget {
  const ContactsCustomersScreen({Key? key}) : super(key: key);
  static const routeName = '/contacts-customers';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),
    );
  }
}
