import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pos_app/data_management/pos_database.dart';
import 'package:pos_app/data_management/pos_web_links.dart';
import 'package:pos_app/provider/auth_provider.dart';
import 'package:pos_app/screens/webview.dart';
import 'package:pos_app/widgets/special_design.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);
  static const routeName = '/login-screen';

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  @override
  void initState() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.initAuthProvider();
    super.initState();
  }

  final _form = GlobalKey<FormState>();

  bool _visibility = false;

  bool _init = true;

  @override
  void didChangeDependencies() {
    if (_init) {
      _init = false;

      bool? delete = ModalRoute.of(context)!.settings.arguments as bool?;
      if (delete != null && delete) {
        deleteDB();
      }
    }
    super.didChangeDependencies();
  }

  String _username = "null";

  String _password = "null";

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final authProvider = Provider.of<AuthProvider>(context);
    //authProvider.initAuthProvider();
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/background.jpg',
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Form(
                key: _form,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/pospoa.png'),
                      Card(
                        elevation: 8.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)),
                        child: CustomRow(
                          icon: const Icon(
                            Icons.person,
                            color: Colors.grey,
                          ),
                          radius: 20.0,
                          child: TextFormField(
                            initialValue: '',
                            textInputAction: TextInputAction.next,

                            validator: (v) {
                              if (v!.isEmpty) {
                                return 'Please enter Username';
                              }
                              return null;
                            },
                            onSaved: (v) {
                              _username = v!;
                            },
                            decoration: const InputDecoration(
                                border: InputBorder.none, hintText: 'Username'),
                          ),
                        ),
                      ),
                      Card(
                        elevation: 16.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)),
                        child: CustomRow(
                          icon: const Icon(
                            Icons.lock,
                            color: Colors.grey,
                          ),
                          radius: 20.0,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: '',
                                  textInputAction: TextInputAction.done,
                                  keyboardType: TextInputType.text,
                                  obscureText: !_visibility,

                                  onSaved: (v) {
                                    _password = v!;
                                  },
                                  validator: (v) {
                                    if (v!.isEmpty) {
                                      return 'Please enter password';
                                    }

                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Password',
                                  ),
                                ),
                              ),
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _visibility = !_visibility;
                                    });
                                  },
                                  icon: Icon(_visibility
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined))
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (ctx) => const MyWebView(forgotPassword)));
                          },
                          child: const Text('Forgot your password',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16.0)),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Card(
                          color: Colors.blue,
                          elevation: 16.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.0)),
                          child: CustomButton(
                            color: Colors.blue,
                            child: TextButton(
                                onPressed: () {
                                  if (saveForm()) {
                                    authProvider.login(_username, _password);
                                  }
                                },
                                child: const Text('Login',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 20.0))),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      if (authProvider.status == AuthStatus.authenticating ||
                          authProvider.status == AuthStatus.unAuthenticating)
                        const CircularProgressIndicator(),
                      const SizedBox(height: 10.0),
                      if (authProvider.info.isNotEmpty)
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: Colors.redAccent),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                authProvider.info,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          const Text('Not yet registered?', style: TextStyle(
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                              fontSize: 16.0)),
                          TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (ctx) => const MyWebView(register)));

                              },
                              child: const Text('Register Now',

                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16.0)))
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool saveForm() {
    bool valid = _form.currentState!.validate();
    if (!valid) {
      return false;
    }
    _form.currentState!.save();
    return true;
  }

  void deleteDB() async {
    Fluttertoast.showToast(msg: 'Deleting all local databases');
    await UniqueDatabase(tableName: '').deleteDB();
    await UniqueDatabase(tableName: '').getInstance();
  }
}
