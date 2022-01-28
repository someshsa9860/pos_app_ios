import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class ExpensesCategoriesScreen extends StatelessWidget {
  const ExpensesCategoriesScreen({Key? key}) : super(key: key);
  static const routeName = '/expenses-categories';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),

    );
  }
}
