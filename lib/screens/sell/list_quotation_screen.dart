import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class SellListQuotationScreen extends StatelessWidget {
  const SellListQuotationScreen({Key? key}) : super(key: key);
  static const routeName = '/sell-list-quotation';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),
    );
  }
}
