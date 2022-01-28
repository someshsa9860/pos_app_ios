import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

class ReportPurchasePaymentScreen extends StatelessWidget {
  const ReportPurchasePaymentScreen({Key? key}) : super(key: key);
  static const routeName = '/report-purchase-payment';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer: AppDrawer(),
    );
  }
}
