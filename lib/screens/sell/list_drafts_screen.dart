import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class SellListDraftScreen extends StatelessWidget {
  const SellListDraftScreen({Key? key}) : super(key: key);
  static const routeName = '/sell-list-draft';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),

    );
  }
}
