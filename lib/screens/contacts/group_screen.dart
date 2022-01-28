import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class ContactsGroupScreen extends StatelessWidget{
  const ContactsGroupScreen({Key? key}) : super(key: key);
  static const routeName='/contacts-group';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),

    );
  }
}