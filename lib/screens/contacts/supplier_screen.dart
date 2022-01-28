import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class ContactsSupplierScreen extends StatelessWidget{
  const ContactsSupplierScreen({Key? key}) : super(key: key);
  static const routeName='/contacts-supplier';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),

    );
  }
}