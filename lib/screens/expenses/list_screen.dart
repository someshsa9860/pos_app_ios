import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class ExpensesListScreen extends StatelessWidget {
  const ExpensesListScreen({Key? key}) : super(key: key);
  static const routeName = '/expenses-list';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),

    );
  }
}
