import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class ContactsImportScreen extends StatelessWidget{
  const ContactsImportScreen({Key? key}) : super(key: key);
  static const routeName='/contacts-import';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),

    );
  }
}