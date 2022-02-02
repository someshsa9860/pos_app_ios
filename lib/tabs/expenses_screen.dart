import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

import '../screens/expenses/add_screen.dart';
import '../screens/expenses/categories_screen.dart';
import '../screens/expenses/list_screen.dart';
import '../widgets/list_items.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({Key? key}) : super(key: key);
  static const routeName = '/expenses';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
      ),
      body: ListView(
        children: [
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "List Expenses",
              onClick: () {
                Navigator.of(context).pushNamed(ExpensesListScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Add Expenses",
              onClick: () {
                Navigator.of(context).pushNamed(ExpensesAddScreen.routeName);
              }),
          ContentListItem(
              icon: Icons.arrow_right_alt_rounded,
              title: "Expense Categories",
              onClick: () {
                Navigator.of(context)
                    .pushNamed(ExpensesCategoriesScreen.routeName);
              }),
        ],
      ),
      drawer: AppDrawer(),
    );
  }
}
