import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class ReportSellPaymentScreen extends StatelessWidget {
  const ReportSellPaymentScreen({Key? key}) : super(key: key);
  static const routeName = '/report-sell-payment';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),
    );
  }
}
