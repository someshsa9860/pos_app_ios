import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pos_app/data_management/api.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/auth_provider.dart';
import '../provider/customer_provider.dart';
import '../provider/expense_provider.dart';
import '../provider/headers_footers_provider.dart';
import '../provider/location_provider.dart';
import '../provider/paccounts_provider.dart';
import '../provider/pmethods_provider.dart';
import '../provider/pos_provider.dart';
import '../provider/products_brands_provider.dart';
import '../provider/products_category_provider.dart';
import '../provider/products_provider.dart';
import '../provider/products_stock_provider.dart';
import '../provider/products_units_provider.dart';
import '../provider/products_var_provider.dart';
import '../provider/reports_provider.dart';
import '../provider/sell_provider.dart';
import '../provider/sell_return_provider.dart';
import '../provider/selling_group_provider.dart';
import '../provider/supplier_provider.dart';
import '../provider/tax_provider.dart';
import '../provider/user_provider.dart';
import '../screens/login_screen.dart';
import '../screens/sell/pos_screen.dart';
import '../widgets/refresh_widget.dart';

enum InternetStatus { online, offline }

class MyHomePage extends StatefulWidget {
  static const routeName = '/home-screen';

  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Center(
        child: _getScreen(provider),
      ),
    );
  }

  var init = true;

  @override
  void didChangeDependencies() {
    if (init) {
      init = false;
      final provider = Provider.of<AuthProvider>(context, listen: false);
      provider.initAuthProvider();
    }
    super.didChangeDependencies();
  }

  @override
  void initState() {
    initInternet();

    initData(context);
    sync();
    super.initState();
  }

  dynamic internetSubscription;

  void initInternet() async {
    internetSubscription =
        Connectivity().onConnectivityChanged.listen((event) async {
      if (event == ConnectivityResult.none) {
        var online = await InternetConnectionChecker().hasConnection;
        if (!online) {
          if (internetStatus == InternetStatus.online) {
            Fluttertoast.showToast(
                msg: 'You are offline', toastLength: Toast.LENGTH_LONG);
            internetStatus = InternetStatus.offline;
            try {
              setState(() {});
            } catch (e) {
              //print()
            }
          }
        }
      } else {
        var online = await InternetConnectionChecker().hasConnection;
        if (online) {
          if (internetStatus == InternetStatus.offline) {
            Fluttertoast.showToast(
                msg: 'back to online', toastLength: Toast.LENGTH_LONG);
            setState(() {
              internetStatus = InternetStatus.online;
            });
            sync();
          }
        }
      }
    });
  }

  initData(BuildContext context) async {
    await getUser();
    if (user.token == null) {
      return;
    }

    try {
      Provider.of<ProductsStockProvider>(context, listen: false).getData().catchError((e)=>print(''));
      Provider.of<ExpenseProvider>(context, listen: false).getData().catchError((e)=>print(''));
      Provider.of<CustomerProvider>(context, listen: false).getData().catchError((e)=>print(''));
      Provider.of<SupplierProvider>(context, listen: false).getData().catchError((e)=>print(''));
      Provider.of<LocationProvider>(context, listen: false).getData().catchError((e)=>print(''));
      Provider.of<PaymentAccountProvider>(context, listen: false).getData().catchError((e)=>print(''));
      Provider.of<PaymentMethodsProvider>(context, listen: false).getData().catchError((e)=>print(''));
      Provider.of<ProductsProvider>(context, listen: false).getData().catchError((e)=>print(''));
      Provider.of<PosProvider>(context, listen: false).getData().catchError((e)=>print(''));
      Provider.of<SellProvider>(context, listen: false).getData().catchError((e)=>print(''));
      Provider.of<SellingGroupProvider>(context, listen: false).getData().catchError((e)=>print(''));
      Provider.of<ProductsBrandProvider>(context, listen: false).getData().catchError((e)=>print(''));
      Provider.of<ProductCategoryProvider>(context, listen: false).getData().catchError((e)=>print(''));
      Provider.of<ProductsUnitsProvider>(context, listen: false).getData().catchError((e)=>print(''));
      Provider.of<ProductsVarProvider>(context, listen: false).getData().catchError((e)=>print(''));
      Provider.of<SellReturnProvider>(context, listen: false).getData().catchError((e)=>print(''));
      Provider.of<ReportsProvider>(context, listen: false).getData().catchError((e)=>print(''));
      Provider.of<TaxProvider>(context, listen: false).getData().catchError((e)=>print(''));
      Provider.of<UsersProvider>(context, listen: false).getData().catchError((e)=>print(''));
      final p = await Permission.storage.isDenied;
      if (p) {
        final res = await Permission.storage.request();
        if (res.isDenied) {
          return 'go';
        }
      }
    } catch (e) {
      //
    }
  }

  sync() async {
    await getUser();
    if (user.token == null) {
      return;
    }
    Provider.of<ProductsStockProvider>(context, listen: false).sync();

    Provider.of<ExpenseProvider>(context, listen: false).sync();
    Provider.of<CustomerProvider>(context, listen: false).sync();
    Provider.of<SupplierProvider>(context, listen: false).sync();
    Provider.of<LocationProvider>(context, listen: false).sync();
    Provider.of<PaymentAccountProvider>(context, listen: false).sync();
    Provider.of<ProductsProvider>(context, listen: false).sync();
    Provider.of<PosProvider>(context, listen: false).sync();
    Provider.of<SellProvider>(context, listen: false).sync();
    Provider.of<SellingGroupProvider>(context, listen: false).sync();
    Provider.of<ProductsBrandProvider>(context, listen: false).sync();
    Provider.of<ProductCategoryProvider>(context, listen: false).sync();
    Provider.of<ProductsUnitsProvider>(context, listen: false).sync();
    Provider.of<ProductsVarProvider>(context, listen: false).sync();
    Provider.of<SellReturnProvider>(context, listen: false).sync();
    Provider.of<ReportsProvider>(context, listen: false).sync();
    Provider.of<TaxProvider>(context, listen: false).sync();
    Provider.of<UsersProvider>(context, listen: false).sync();

    // for(var map in Provider.of<ProductsProvider>(context, listen: false).mapData){
    //   await CallApi().getImgFromUrl(map['image_url']);
    // }
  }

  Widget _getScreen(AuthProvider user) {
    switch (user.status) {
      case AuthStatus.unInitialized:
        return const CircularProgressIndicator();
      case AuthStatus.unAuthenticating:
        return const CircularProgressIndicator();
      case AuthStatus.authenticating:
        return const CircularProgressIndicator();

      case AuthStatus.unAuthenticated:
        return const Login();
      case AuthStatus.authenticated:
        return DashBoard();
    }
  }
}

InternetStatus internetStatus = InternetStatus.online;

class DashBoard extends StatelessWidget {
  const DashBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return FutureBuilder(
      future: getData(context),
      builder: (ctx, data) {
        if (data.hasData) {
          return const POSScreen();
        }
        return const MyCustomProgressBar(
          msg: 'Fetching all data weight',
          progressBar: true,
        );
      },
    );
  }

  Future<String> getData(BuildContext context) async {
    final pref = await SharedPreferences.getInstance();
    final initiated = pref.getBool('initiated');
    if (initiated != null) {
      if (initiated) {
        return 'go';
      }
    }
    await init(context);
    return 'go';
  }

  Future<String> init(BuildContext context) async {
    await getUser();
    if (user.token == null) {
      return '';
    }

    try {
      await Provider.of<ProductsStockProvider>(context, listen: false)
          .getData().catchError((e)=>print(''));
    } catch (e) {
      print(e);
    }
    try {
      Provider.of<ExpenseProvider>(context, listen: false).getData().catchError((e)=>print(''));
      await Provider.of<CustomerProvider>(context, listen: false).getData().catchError((e)=>print(''));
    } catch (e) {
      print(e);
    }
    try {
      Provider.of<SupplierProvider>(context, listen: false).getData().catchError((e)=>print(''));
      await Provider.of<LocationProvider>(context, listen: false).getData().catchError((e)=>print(''));
    } catch (e) {
      print(e);
    }
    try {
      await Provider.of<PaymentAccountProvider>(context, listen: false)
          .getData().catchError((e)=>print(''));
    } catch (e) {
      print(e);
    }
    try {
      await Provider.of<TaxProvider>(context, listen: false).getData().catchError((e)=>print(''));
    } catch (e) {
      print(e);
    }
    try {
      Provider.of<PaymentMethodsProvider>(context, listen: false).getData().catchError((e)=>print(''));
      Provider.of<ProductsProvider>(context, listen: false).getData().catchError((e)=>print(''));
      Provider.of<PosProvider>(context, listen: false).getData().catchError((e)=>print(''));
      Provider.of<SellProvider>(context, listen: false).getData().catchError((e)=>print(''));
      Provider.of<SellingGroupProvider>(context, listen: false).getData().catchError((e)=>print(''));
      Provider.of<ProductsBrandProvider>(context, listen: false).getData().catchError((e)=>print(''));
      Provider.of<ProductCategoryProvider>(context, listen: false).getData().catchError((e)=>print(''));
      Provider.of<ProductsUnitsProvider>(context, listen: false).getData().catchError((e)=>print(''));
      Provider.of<ProductsVarProvider>(context, listen: false).getData().catchError((e)=>print(''));
      Provider.of<SellReturnProvider>(context, listen: false).getData().catchError((e)=>print(''));
      Provider.of<ReportsProvider>(context, listen: false).getData().catchError((e)=>print(''));
      Provider.of<UsersProvider>(context, listen: false).getData().catchError((e)=>print(''));
      Provider.of<HeadersFootersProvider>(context, listen: false).getData().catchError((e)=>print(''));

      final pref = await SharedPreferences.getInstance();

      await pref.setBool('initiated', true);
    } catch (e) {
      print(e);
    }
    return '';
  }
}
