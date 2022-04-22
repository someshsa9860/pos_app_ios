import 'package:flutter/material.dart';

import '../screens/expenses/add_screen.dart';

import '../screens/expenses/list_screen.dart';
import '../widgets/list_items.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ContentListItem(
            icon: Icons.arrow_right_alt_rounded,
            title: "List Expenses",
            onClick: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed(ExpensesListScreen.routeName);
            }),

        ContentListItem(
            icon: Icons.arrow_right_alt_rounded,
            title: "Add Expenses",
            onClick: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed(ExpensesAddScreen.routeName,arguments: [-1]);
            }),
        // ContentListItem(
        //     icon: Icons.arrow_right_alt_rounded,
        //     title: "Expense Categories",
        //     onClick: () {
        //       Navigator.of(context)
        //           .pushNamed(ExpensesCategoriesScreen.routeName);
        //     }),
      ],
    );
  }
}
