import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class SellAddDraftScreen extends StatelessWidget {
  const SellAddDraftScreen({Key? key}) : super(key: key);
  static const routeName = '/sell-add-draft';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),

    );
  }
}
